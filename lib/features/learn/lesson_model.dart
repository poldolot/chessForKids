import 'package:flutter/widgets.dart';

import '../../engine/engine.dart';

/// Piece lessons teach one piece; rule lessons teach a rule of the game.
enum LessonKind { piece, rule }

/// How a move counts in a board task.
enum MoveVerdict {
  /// Counts towards the goal.
  good,

  /// A mistake, but play continues from the new position.
  wasted,

  /// A mistake that puts the board back to the start.
  fail,
}

/// What a board task knows about its progress.
final class TaskState {
  const TaskState({
    required this.position,
    required this.start,
    required this.rules,
    this.movesMade = 0,
    this.goodMoves = 0,
    this.captures = 0,
    this.doubleSteps = 0,
    this.starsLeft = const {},
    this.lastMove,
  });

  final Position position;
  final Position start;
  final GameRules rules;
  final int movesMade;
  final int goodMoves;
  final int captures;

  /// Pawn moves of two squares (taught in the pawn lesson).
  final int doubleSteps;
  final Set<Square> starsLeft;
  final Move? lastMove;

  GameResult get result => evaluatePosition(position, rules: rules);

  TaskState copyWith({
    Position? position,
    int? movesMade,
    int? goodMoves,
    int? captures,
    int? doubleSteps,
    Set<Square>? starsLeft,
    Move? lastMove,
  }) {
    return TaskState(
      position: position ?? this.position,
      start: start,
      rules: rules,
      movesMade: movesMade ?? this.movesMade,
      goodMoves: goodMoves ?? this.goodMoves,
      captures: captures ?? this.captures,
      doubleSteps: doubleSteps ?? this.doubleSteps,
      starsLeft: starsLeft ?? this.starsLeft,
      lastMove: lastMove ?? this.lastMove,
    );
  }
}

typedef Verdict = MoveVerdict Function(
  TaskState before,
  Move move,
  Position after,
);
typedef Goal = bool Function(TaskState state);

/// Every move counts as good.
MoveVerdict anyMoveGood(TaskState before, Move move, Position after) =>
    MoveVerdict.good;

/// Whether [move] captures something in [position] (including en passant).
bool isCaptureMove(Position position, Move move) {
  if (position.pieceAt(move.to) != null) {
    return true;
  }
  final mover = position.pieceAt(move.from);
  return mover?.type == PieceType.pawn && move.from.file != move.to.file;
}

/// One screen of a lesson. [lineKey] is the line the teacher says first.
sealed class LessonStep {
  const LessonStep({required this.lineKey});

  final String lineKey;
}

/// "Meet the piece": a big picture and one sentence.
final class IntroStep extends LessonStep {
  const IntroStep({required super.lineKey, this.piece, this.icon});

  final Piece? piece;
  final IconData? icon;
}

/// "Watch": moves played automatically, each with an optional line.
final class DemoStep extends LessonStep {
  const DemoStep({
    required super.lineKey,
    required this.fen,
    required this.moves,
    this.rules = GameRules.standard,
    this.orientation = PieceColor.white,
  });

  final String fen;
  final List<(Move move, String? lineKey)> moves;
  final GameRules rules;
  final PieceColor orientation;
}

/// "Try": the child moves pieces on a board until [goal] holds.
final class BoardTaskStep extends LessonStep {
  const BoardTaskStep({
    required super.lineKey,
    required this.fen,
    required this.goal,
    required this.solution,
    this.rules = GameRules.standard,
    this.passive = true,
    this.verdict = anyMoveGood,
    this.moveFilter,
    this.stars = const {},
    this.moveLimit,
    this.hintKey,
    this.showDanger = false,
    this.orientation = PieceColor.white,
  });

  final String fen;
  final Goal goal;

  /// Moves that finish the task without a mistake; checked by tests.
  final List<Move> solution;
  final GameRules rules;

  /// The opponent never moves: after each move the turn comes back.
  final bool passive;
  final Verdict verdict;

  /// Only moves passing this filter are offered; others count as rejected.
  final bool Function(Position position, Move move)? moveFilter;

  /// Squares with stars to collect.
  final Set<Square> stars;

  /// Moves allowed before the board resets; `null` means unlimited.
  final int? moveLimit;

  /// Line after a rejected tap or a wasted move; `null` → the common one.
  final String? hintKey;

  /// Show the squares the opponent attacks.
  final bool showDanger;
  final PieceColor orientation;
}

/// "Set up the pieces": drag pieces from a tray onto their shadows.
final class ArrangeStep extends LessonStep {
  const ArrangeStep({
    required super.lineKey,
    required this.targetFen,
    required this.tray,
  });

  final String targetFen;
  final List<Piece> tray;
}

/// "Which is worth more?": pairs of pieces to compare.
final class CompareStep extends LessonStep {
  const CompareStep({required super.lineKey, required this.pairs});

  final List<(Piece a, Piece b)> pairs;
}

/// A lesson: an ordered list of steps plus what it teaches.
final class Lesson {
  const Lesson({
    required this.id,
    required this.kind,
    required this.titleKey,
    required this.steps,
    this.piece,
    this.icon,
  });

  final String id;
  final LessonKind kind;
  final String titleKey;
  final List<LessonStep> steps;
  final Piece? piece;
  final IconData? icon;

  /// Steps in which mistakes are counted.
  int get taskCount => steps
      .where((s) => s is BoardTaskStep || s is ArrangeStep || s is CompareStep)
      .length;
}
