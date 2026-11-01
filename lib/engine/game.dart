import 'apply_move.dart';
import 'attacks.dart';
import 'move.dart';
import 'move_generator.dart' as generator;
import 'outcome.dart';
import 'piece.dart';
import 'position.dart';
import 'square.dart';

/// A game in progress: the current position plus the history needed for
/// undo, repetition detection and resignation.
final class Game {
  Game({Position? start, this.rules = generator.GameRules.standard})
    : _history = [start ?? Position.initial()];

  /// Optional rules in force for this game.
  final generator.GameRules rules;
  final List<Position> _history;
  final List<Move> _moves = [];
  PieceColor? _resigned;

  /// The current position.
  Position get position => _history.last;

  /// Every position from the start to the current one.
  List<Position> get history => List.unmodifiable(_history);

  /// The moves played so far.
  List<Move> get moves => List.unmodifiable(_moves);

  /// Legal moves in the current position under this game's [rules].
  List<Move> legalMoves({Square? from}) =>
      generator.legalMoves(position, from: from, rules: rules);

  /// Whether the side to move is in check.
  bool get isCheck => isInCheck(position);

  /// The current result: resignation, then position-based outcomes, then
  /// threefold repetition of the current position.
  GameResult get result {
    if (_resigned != null) {
      return GameResult(GameOutcome.resignation, winner: _resigned!.opposite);
    }
    final positional = evaluatePosition(position, rules: rules);
    if (positional.isOver) {
      return positional;
    }
    if (_repetitions(position.repetitionKey) >= 3) {
      return const GameResult(GameOutcome.threefoldRepetition);
    }
    return GameResult.ongoing;
  }

  /// Plays [move]. Throws [StateError] if the game is over and
  /// [ArgumentError] if the move is not legal.
  void play(Move move) {
    if (result.isOver) {
      throw StateError('The game is over');
    }
    if (!legalMoves(from: move.from).contains(move)) {
      throw ArgumentError.value(move, 'move', 'Illegal move');
    }
    _history.add(position.play(move));
    _moves.add(move);
  }

  /// Takes back the last move and clears any resignation. Returns the move
  /// taken back, or `null` when there is nothing to undo.
  Move? undo() {
    _resigned = null;
    if (_moves.isEmpty) {
      return null;
    }
    _history.removeLast();
    return _moves.removeLast();
  }

  /// Ends the game with [color] resigning. Throws [StateError] if the game
  /// is already over.
  void resign(PieceColor color) {
    if (result.isOver) {
      throw StateError('The game is over');
    }
    _resigned = color;
  }

  int _repetitions(String key) =>
      _history.where((p) => p.repetitionKey == key).length;
}
