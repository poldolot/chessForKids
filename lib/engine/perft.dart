import 'apply_move.dart';
import 'move_generator.dart';
import 'position.dart';

/// Counts the leaf nodes of the legal move tree to [depth].
///
/// Used to verify the move generator against published reference values.
int perft(Position position, int depth) {
  if (depth == 0) {
    return 1;
  }
  final moves = legalMoves(position);
  if (depth == 1) {
    return moves.length;
  }
  var nodes = 0;
  for (final move in moves) {
    nodes += perft(position.play(move), depth - 1);
  }
  return nodes;
}
