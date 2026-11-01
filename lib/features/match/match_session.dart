import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../ai/ai.dart';
import '../../data/models.dart';
import '../../engine/engine.dart';

/// One match between the child and the computer: whose turn it is, the
/// moves, undo by pairs, hints, resignation, the result and the stars.
/// No widgets; the screen runs the computer's thinking delay.
final class MatchSession extends ChangeNotifier {
  MatchSession({
    required this.childColor,
    this.level = MatchLevel.easy,
    Position? start,
    Random? random,
  }) : _start = start,
       _random = random ?? Random(),
       _game = Game(start: start);

  /// Restores a match saved with [toJson]. Unknown moves throw
  /// [FormatException]; the caller decides what to do with a broken save.
  factory MatchSession.fromJson(Map<String, dynamic> json, {Random? random}) {
    final child = json['child'] == 'black'
        ? PieceColor.black
        : PieceColor.white;
    final levelName = json['level'];
    final level = MatchLevel.values.firstWhere(
      (l) => l.name == levelName,
      orElse: () => MatchLevel.easy,
    );
    final fen = json['fen'];
    final session = MatchSession(
      childColor: child,
      level: level,
      start: fen is String ? Position.fromFen(fen) : null,
      random: random,
    );
    final moves = json['moves'];
    if (moves is! List) {
      throw FormatException('Saved match has no moves', json);
    }
    for (final raw in moves) {
      if (raw is! String) {
        throw FormatException('Bad move in saved match', raw);
      }
      final move = Move.parseUci(raw);
      if (!session._game.legalMoves(from: move.from).contains(move)) {
        throw FormatException('Illegal move in saved match', raw);
      }
      session._game.play(move);
    }
    return session;
  }

  /// The child's colour for a new match under [setting].
  static PieceColor pickChildColor(ChildColor setting, Random random) =>
      switch (setting) {
        ChildColor.white => PieceColor.white,
        ChildColor.random =>
          random.nextBool() ? PieceColor.white : PieceColor.black,
      };

  final PieceColor childColor;
  final MatchLevel level;
  final Position? _start;
  final Random _random;
  final Game _game;

  PieceColor get computerColor => childColor.opposite;
  Position get position => _game.position;
  Move? get lastMove => _game.moves.isEmpty ? null : _game.moves.last;
  GameResult get result => _game.result;
  bool get isCheck => _game.isCheck;

  bool get childToMove => !result.isOver && position.sideToMove == childColor;
  bool get computerToMove =>
      !result.isOver && position.sideToMove == computerColor;

  /// At least one child move is on the board and the game goes on.
  bool get canUndo => !result.isOver && _game.moves.length > _computerLead;

  /// Moves the computer made before the child's first (one when the
  /// computer is white, else none).
  int get _computerLead => _startSide == computerColor ? 1 : 0;

  PieceColor get _startSide => (_start ?? Position.initial()).sideToMove;

  List<Move> legalMoves({Square? from}) => _game.legalMoves(from: from);

  /// Only the child's own pieces move; every promotion is allowed because
  /// the picker chooses the piece.
  bool allows(Move move) => position.pieceAt(move.from)?.color == childColor;

  /// Plays the child's move. Throws [StateError] when it is not the child's
  /// turn and [ArgumentError] for an illegal move.
  void playChild(Move move) {
    if (!childToMove) {
      throw StateError('Not the child\'s turn');
    }
    _game.play(move);
    notifyListeners();
  }

  /// Plays the computer's move and returns it, or `null` when it is not
  /// the computer's turn.
  Move? playComputer() {
    if (!computerToMove) {
      return null;
    }
    final move = chooseMove(
      position,
      level: level,
      random: _random,
      rules: _game.rules,
    );
    if (move == null) {
      return null;
    }
    _game.play(move);
    notifyListeners();
    return move;
  }

  /// Takes back the computer's reply, if it came, and the child's last
  /// move. Does nothing at the start or after the game ended.
  void undo() {
    if (!canUndo) {
      return;
    }
    if (position.sideToMove == childColor) {
      _game.undo();
    }
    _game.undo();
    notifyListeners();
  }

  /// A sound move for the child, without playing it. Hints always come
  /// from the normal level, however sloppy the computer itself plays, so
  /// the child never gets a careless suggestion.
  Move? hint() {
    if (!childToMove) {
      return null;
    }
    return chooseMove(
      position,
      level: MatchLevel.normal,
      random: _random,
      rules: _game.rules,
      careless: false,
    );
  }

  /// The child gives up; the computer wins.
  void resign() {
    if (result.isOver) {
      return;
    }
    _game.resign(childColor);
    notifyListeners();
  }

  bool get childWon => result.winner == childColor;

  /// Stars for the finished match: a win 3, a draw 2, a loss 1 for
  /// finishing; 0 while the game goes on.
  int get stars {
    if (!result.isOver) {
      return 0;
    }
    if (childWon) {
      return 3;
    }
    return result.isDraw ? 2 : 1;
  }

  Map<String, dynamic> toJson() => {
    'version': 1,
    'child': childColor.name,
    'level': level.name,
    if (_start case final start?) 'fen': start.fen,
    'moves': [for (final m in _game.moves) m.uci],
  };
}
