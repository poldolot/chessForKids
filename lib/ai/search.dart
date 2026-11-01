import 'dart:math';

import '../engine/engine.dart';
import 'evaluation.dart';
import 'level.dart';

const int _mateScore = 100000;

/// The computer's move for the side to move in [position], or `null` when
/// it has none.
///
/// A plain minimax with alpha-beta pruning to [level.depth] plies (or
/// [depth]) over [evaluate]. Checkmate counts ±[_mateScore] minus the
/// distance, so a quicker mate wins; stalemate and the other draws count 0.
/// Among the root moves scoring within [level.noise] of the best one is
/// drawn with [random]. A mate in one is always taken; with probability
/// [level.blunder] a random move that allows no mate in one is played
/// instead of searching (never when [careless] is false, e.g. for hints).
/// Pawns promote to queens only.
Move? chooseMove(
  Position position, {
  required MatchLevel level,
  required Random random,
  GameRules rules = GameRules.standard,
  int? depth,
  bool careless = true,
}) {
  final side = position.sideToMove;
  final moves = _candidates(position, rules);
  if (moves.isEmpty) {
    return null;
  }
  final mates = matingMoves(position, rules: rules);
  if (mates.isNotEmpty) {
    return mates[random.nextInt(mates.length)];
  }
  if (careless && level.blunder > 0 && random.nextDouble() < level.blunder) {
    final careless = [
      for (final move in moves)
        if (matingMoves(position.play(move), rules: rules).isEmpty) move,
    ];
    if (careless.isNotEmpty) {
      return careless[random.nextInt(careless.length)];
    }
  }
  final scored = <(Move, int)>[];
  var best = -_mateScore * 2;
  for (final move in moves) {
    final score = -_search(
      position.play(move),
      (depth ?? level.depth) - 1,
      -_mateScore * 2,
      -best + level.noise,
      side.opposite,
      rules,
      1,
    );
    scored.add((move, score));
    if (score > best) {
      best = score;
    }
  }
  final good = [
    for (final (move, score) in scored)
      if (score >= best - level.noise) move,
  ];
  return good[random.nextInt(good.length)];
}

/// Moves that checkmate at once.
List<Move> matingMoves(
  Position position, {
  GameRules rules = GameRules.standard,
}) => [
  for (final move in _candidates(position, rules))
    if (evaluatePosition(position.play(move), rules: rules).outcome ==
        GameOutcome.checkmate)
      move,
];

List<Move> _candidates(Position position, GameRules rules) => [
  for (final move in legalMoves(position, rules: rules))
    if (move.promotion == null || move.promotion == PieceType.queen) move,
];

/// Score of [position] for [side] (the side to move), searching [depth]
/// more plies. [ply] is the distance from the root, used to prefer the
/// shortest mate.
int _search(
  Position position,
  int depth,
  int alpha,
  int beta,
  PieceColor side,
  GameRules rules,
  int ply,
) {
  final result = evaluatePosition(position, rules: rules);
  if (result.isOver) {
    if (result.outcome == GameOutcome.checkmate) {
      return -(_mateScore - ply);
    }
    return 0;
  }
  if (depth <= 0) {
    return evaluate(position, side);
  }
  var best = -_mateScore * 2;
  for (final move in _candidates(position, rules)) {
    final score = -_search(
      position.play(move),
      depth - 1,
      -beta,
      -alpha,
      side.opposite,
      rules,
      ply + 1,
    );
    if (score > best) {
      best = score;
    }
    if (best > alpha) {
      alpha = best;
    }
    if (alpha >= beta) {
      break;
    }
  }
  return best;
}
