import 'package:flutter/foundation.dart';

import '../../engine/engine.dart';
import 'lesson_model.dart';

/// What happened after a move in a board task.
enum TaskEvent {
  /// Counted towards the goal.
  good,

  /// A mistake; play goes on from the new position.
  wasted,

  /// A mistake; the move is shown and the board must be [BoardTaskController.reset]
  /// by the caller once the child has seen it.
  fail,

  /// The move limit ran out; the board is already back at the start.
  reset,

  /// The goal is reached.
  complete,
}

/// Runs one [BoardTaskStep]: applies moves, judges them, collects stars,
/// enforces the move limit and reports completion. No widgets involved.
///
/// After the goal is reached the board stays playable: moves are still
/// applied but no longer judged, counted or rewarded.
final class BoardTaskController extends ChangeNotifier {
  BoardTaskController(this.step) : _state = _initial(step);

  final BoardTaskStep step;
  TaskState _state;
  int _mistakes = 0;
  bool _complete = false;
  bool _awaitingReset = false;

  static TaskState _initial(BoardTaskStep step) {
    final start = Position.fromFen(step.fen);
    return TaskState(
      position: start,
      start: start,
      rules: step.rules,
      starsLeft: step.stars,
    );
  }

  TaskState get state => _state;
  int get mistakes => _mistakes;
  bool get isComplete => _complete;

  /// True after a [TaskEvent.fail]: the wrong move is on the board and
  /// nothing else may be played until [reset].
  bool get isAwaitingReset => _awaitingReset;
  Set<Square> get starsLeft => _state.starsLeft;

  /// The side the child plays: whoever is to move at the start.
  PieceColor get childColor => _state.start.sideToMove;

  /// Squares attacked by the opponent, when the step asks to show them.
  Set<Square> get danger {
    if (!step.showDanger) {
      return const {};
    }
    final enemy = childColor.opposite;
    return {
      for (final s in Square.all)
        if (isSquareAttacked(_state.position, s, enemy)) s,
    };
  }

  bool allows(Move move) =>
      step.moveFilter?.call(_state.position, move) ?? true;

  /// Applies [move]. Throws [ArgumentError] for illegal or filtered moves
  /// and [StateError] while a failed move is waiting for [reset].
  TaskEvent onMove(Move move) {
    if (_awaitingReset) {
      throw StateError('Waiting for reset');
    }
    final before = _state;
    if (!allows(move) ||
        !legalMoves(
          before.position,
          from: move.from,
          rules: step.rules,
        ).contains(move)) {
      throw ArgumentError.value(move, 'move', 'Not an allowed move');
    }
    final after = before.position.play(move);
    if (_complete) {
      _state = before.copyWith(
        position: step.passive ? after.pass() : after,
        lastMove: move,
      );
      notifyListeners();
      return TaskEvent.good;
    }
    var verdict = step.verdict(before, move, after);
    // Without a passive opponent a wrong move would hand the turn to the
    // other side, so it is shown and taken back instead.
    if (!step.passive && verdict == MoveVerdict.wasted) {
      verdict = MoveVerdict.fail;
    }
    if (verdict == MoveVerdict.fail) {
      _mistakes++;
      _awaitingReset = true;
      _state = before.copyWith(position: after, lastMove: move);
      notifyListeners();
      return TaskEvent.fail;
    }
    if (verdict == MoveVerdict.wasted) {
      _mistakes++;
    }
    final mover = before.position.pieceAt(move.from);
    final captured = isCaptureMove(before.position, move);
    final doubleStep =
        mover?.type == PieceType.pawn &&
        (move.to.rank - move.from.rank).abs() == 2;
    var next = before.copyWith(
      position: after,
      movesMade: before.movesMade + 1,
      goodMoves: before.goodMoves + (verdict == MoveVerdict.good ? 1 : 0),
      captures: before.captures + (captured ? 1 : 0),
      doubleSteps: before.doubleSteps + (doubleStep ? 1 : 0),
      starsLeft: {...before.starsLeft}..remove(move.to),
      lastMove: move,
    );
    if (step.goal(next)) {
      if (step.passive) {
        next = next.copyWith(position: next.position.pass());
      }
      _state = next;
      _complete = true;
      notifyListeners();
      return TaskEvent.complete;
    }
    final limit = step.moveLimit;
    if (limit != null && next.movesMade >= limit) {
      // Running out of moves is one mistake; a wasted last move was already
      // counted, so it is not counted twice.
      if (verdict != MoveVerdict.wasted) {
        _mistakes++;
      }
      _resetState();
      return TaskEvent.reset;
    }
    if (step.passive) {
      next = next.copyWith(position: next.position.pass());
    }
    _state = next;
    notifyListeners();
    return verdict == MoveVerdict.good ? TaskEvent.good : TaskEvent.wasted;
  }

  /// A tap that was not a move: counts as a mistake (not after completion
  /// or while a failed move is shown).
  void onRejected() {
    if (_complete || _awaitingReset) {
      return;
    }
    _mistakes++;
    notifyListeners();
  }

  /// Back to the starting position; mistakes are kept.
  void reset() {
    _resetState();
  }

  void _resetState() {
    _state = _initial(step);
    _complete = false;
    _awaitingReset = false;
    notifyListeners();
  }
}
