import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../engine/engine.dart';
import 'game_model.dart';
import 'policies.dart';

enum SessionOutcome { playing, won, lost }

/// Why a pawn war board ended: a pawn reached the last rank, or the side
/// to move had no move left (and whoever cannot move has lost).
enum GameEnding { reachedEnd, noMoves }

/// What a child's move led to.
enum SessionEvent { moved, star, won, lost, limitReset }

/// Stars for a won board by move count: at par 3, up to two over 2, else 1.
int starsForMoves(int moves, int? par) {
  if (par == null || moves <= par) {
    return 3;
  }
  return moves <= par + 2 ? 2 : 1;
}

final class _Snapshot {
  const _Snapshot(
    this.position,
    this.starsLeft,
    this.movesMade,
    this.lostPawn,
    this.lastMove,
  );

  final Position position;
  final Set<Square> starsLeft;
  final int movesMade;
  final bool lostPawn;
  final Move? lastMove;
}

/// One play-through of a mini-game board: the child's moves, the opponent's
/// replies, stars, limit, undo, hints and the outcome. No widgets.
final class MiniGameSession extends ChangeNotifier {
  MiniGameSession(this.game, this.board, {Random? random})
    : _random = random ?? Random() {
    _start();
  }

  final MiniGame game;
  final GameBoard board;
  final Random _random;

  late Position _position;
  late Set<Square> _starsLeft;
  int _movesMade = 0;
  int _mistakes = 0;
  bool _lostPawn = false;
  Move? _lastMove;
  SessionOutcome _outcome = SessionOutcome.playing;
  GameEnding? _ending;
  bool _awaitingOpponent = false;
  final List<_Snapshot> _history = [];
  int _initialHuntDistance = 1;

  static const PieceColor childColor = PieceColor.white;

  void _start() {
    _position = board.startPosition;
    _starsLeft = {...board.stars};
    _movesMade = 0;
    _lostPawn = false;
    _lastMove = null;
    _outcome = SessionOutcome.playing;
    _ending = null;
    _awaitingOpponent = false;
    _history.clear();
    if (game.kind == MiniGameKind.hunt) {
      _initialHuntDistance = max(1, _huntDistance() ?? 1);
    }
    if (game.kind == MiniGameKind.pawnWar &&
        legalMoves(_position, rules: board.rules).isEmpty) {
      _outcome = SessionOutcome.lost;
      _ending = GameEnding.noMoves;
    }
  }

  Position get position => _position;
  int get movesMade => _movesMade;
  int get mistakes => _mistakes;
  Set<Square> get starsLeft => _starsLeft;
  Move? get lastMove => _lastMove;
  SessionOutcome get outcome => _outcome;

  /// How the board ended; `null` while playing and in games other than
  /// pawn war, whose only way to end is winning.
  GameEnding? get ending => _ending;
  bool get awaitingOpponent => _awaitingOpponent;
  bool get lostPawn => _lostPawn;
  bool get canUndo => _history.isNotEmpty && _outcome == SessionOutcome.playing;

  /// Squares the opponent attacks (king race only).
  Set<Square> get danger => game.kind == MiniGameKind.kingRace
      ? {
          for (final s in Square.all)
            if (isSquareAttacked(_position, s, childColor.opposite)) s,
        }
      : const {};

  /// 0..1, what the progress bar shows.
  double get progress {
    switch (game.kind) {
      case MiniGameKind.rookRoads:
      case MiniGameKind.bishopTracks:
        final total = board.stars.length;
        return total == 0 ? 0 : (total - _starsLeft.length) / total;
      case MiniGameKind.kingRace:
        return (_position.kingSquare(childColor)?.rank ?? 0) / 7;
      case MiniGameKind.pawnWar:
        var best = 0;
        for (final (s, p) in _position.pieces(childColor)) {
          if (p.type == PieceType.pawn && s.rank > best) {
            best = s.rank;
          }
        }
        return _outcome == SessionOutcome.won ? 1 : best / 7;
      case MiniGameKind.hunt:
        if (_outcome == SessionOutcome.won) {
          return 1;
        }
        final d = _huntDistance();
        return d == null
            ? 0
            : (1 - d / _initialHuntDistance).clamp(0, 1).toDouble();
    }
  }

  Square? get _hunter => board.hunterSquare(_position);
  Square? get _prey => board.preySquare(_position);

  int? _huntDistance() {
    final hunter = _hunter;
    final prey = _prey;
    if (hunter == null || prey == null) {
      return null;
    }
    return shortestPath(_position, hunter, {prey})?.length;
  }

  /// The child's single moving piece in collect games.
  Square? get _collector {
    for (final (s, p) in _position.pieces(childColor)) {
      if (p.type != PieceType.pawn) {
        return s;
      }
    }
    return null;
  }

  bool allows(Move move) {
    switch (game.kind) {
      case MiniGameKind.pawnWar:
        return move.promotion == null || move.promotion == PieceType.queen;
      case MiniGameKind.hunt:
        return move.from == _hunter;
      case MiniGameKind.rookRoads:
      case MiniGameKind.bishopTracks:
        // Obstacle pawns stay put; only the collecting piece moves.
        return move.from == _collector;
      case MiniGameKind.kingRace:
        return move.from == _position.kingSquare(childColor);
    }
  }

  /// Plays the child's move. Throws [ArgumentError] when the game is over,
  /// the opponent has not replied yet, or the move is illegal or filtered.
  SessionEvent playChild(Move move) {
    if (_outcome != SessionOutcome.playing || _awaitingOpponent) {
      throw ArgumentError('Not the child\'s turn');
    }
    if (!allows(move) ||
        !legalMoves(
          _position,
          from: move.from,
          rules: board.rules,
        ).contains(move)) {
      throw ArgumentError.value(move, 'move', 'Not an allowed move');
    }
    _history.add(
      _Snapshot(_position, {..._starsLeft}, _movesMade, _lostPawn, _lastMove),
    );
    final preyBefore = _prey;
    final after = _position.play(move);
    _position = after;
    _lastMove = move;
    _movesMade++;
    var event = SessionEvent.moved;
    if (_starsLeft.remove(move.to)) {
      event = SessionEvent.star;
    }
    if (_childHasWon(move, preyBefore)) {
      _outcome = SessionOutcome.won;
      notifyListeners();
      return SessionEvent.won;
    }
    final limit = board.moveLimit;
    if (limit != null && _movesMade >= limit) {
      _mistakes++;
      _start();
      notifyListeners();
      return SessionEvent.limitReset;
    }
    if (game.alternating) {
      _awaitingOpponent = true;
    } else {
      _position = _position.pass();
    }
    notifyListeners();
    return event;
  }

  bool _childHasWon(Move move, Square? preyBefore) {
    switch (game.kind) {
      case MiniGameKind.rookRoads:
      case MiniGameKind.bishopTracks:
        return _starsLeft.isEmpty;
      case MiniGameKind.kingRace:
        return _position.kingSquare(childColor)?.rank == 7;
      case MiniGameKind.hunt:
        return preyBefore != null && move.to == preyBefore;
      case MiniGameKind.pawnWar:
        if (move.promotion != null) {
          _ending = GameEnding.reachedEnd;
          return true;
        }
        if (legalMoves(_position, rules: board.rules).isEmpty) {
          _ending = GameEnding.noMoves;
          return true;
        }
        return false;
    }
  }

  /// Plays the opponent's reply (pawn war, hunt). Returns the move, or
  /// `null` when the opponent stays put.
  Move? playOpponent() {
    if (!_awaitingOpponent) {
      return null;
    }
    _awaitingOpponent = false;
    Move? reply;
    switch (game.kind) {
      case MiniGameKind.pawnWar:
        reply = pawnWarMove(
          _position,
          childColor.opposite,
          _random,
          rules: board.rules,
          blunder: board.blunder,
        );
        if (reply == null) {
          _outcome = SessionOutcome.won;
          _ending = GameEnding.noMoves;
          break;
        }
        if (isCapture(_position, reply)) {
          _lostPawn = true;
        }
        _position = _position.play(reply);
        _lastMove = reply;
        if (reply.promotion != null) {
          _outcome = SessionOutcome.lost;
          _ending = GameEnding.reachedEnd;
        } else if (legalMoves(_position, rules: board.rules).isEmpty) {
          _outcome = SessionOutcome.lost;
          _ending = GameEnding.noMoves;
        }
      case MiniGameKind.hunt:
        final hunter = _hunter;
        final prey = _prey;
        if (hunter != null && prey != null) {
          reply = fleeMove(
            _position,
            childColor.opposite,
            hunter,
            _random,
            prey: prey,
          );
        }
        _position = reply == null ? _position.pass() : _position.play(reply);
        if (reply != null) {
          _lastMove = reply;
        }
      case MiniGameKind.rookRoads:
      case MiniGameKind.bishopTracks:
      case MiniGameKind.kingRace:
        break;
    }
    notifyListeners();
    return reply;
  }

  /// A good move for the child, never counted against them.
  Move? hint() {
    if (_outcome != SessionOutcome.playing || _awaitingOpponent) {
      return null;
    }
    switch (game.kind) {
      case MiniGameKind.rookRoads:
      case MiniGameKind.bishopTracks:
        final piece = _collector;
        return piece == null
            ? null
            : nearestStarStep(_position, piece, _starsLeft);
      case MiniGameKind.kingRace:
        return kingRaceStep(_position, childColor);
      case MiniGameKind.pawnWar:
        return pawnWarMove(_position, childColor, _random, rules: board.rules);
      case MiniGameKind.hunt:
        final hunter = _hunter;
        final prey = _prey;
        return hunter == null || prey == null
            ? null
            : huntStep(_position, hunter, prey);
    }
  }

  /// Takes back the child's last move together with the opponent's reply.
  bool undo() {
    if (!canUndo) {
      return false;
    }
    final snap = _history.removeLast();
    _position = snap.position;
    _starsLeft = snap.starsLeft;
    _movesMade = snap.movesMade;
    _lostPawn = snap.lostPawn;
    _lastMove = snap.lastMove;
    _awaitingOpponent = false;
    notifyListeners();
    return true;
  }

  void onRejected() {
    _mistakes++;
    notifyListeners();
  }

  /// Stars for the finished board (0 while playing).
  int get stars {
    switch (_outcome) {
      case SessionOutcome.playing:
        return 0;
      case SessionOutcome.lost:
        return 1;
      case SessionOutcome.won:
        if (game.kind == MiniGameKind.pawnWar) {
          return _lostPawn ? 2 : 3;
        }
        return starsForMoves(_movesMade, board.par);
    }
  }

  void restart() {
    _mistakes = 0;
    _start();
    notifyListeners();
  }
}
