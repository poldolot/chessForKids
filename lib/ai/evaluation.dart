import '../engine/engine.dart';

/// Material value in centipawns (pawn 100 ... queen 900, king 0).
int pieceValue(PieceType type) => type.value * 100;

const int _centreBonus = 20;
const int _ringBonus = 10;
const int _sixthRankPawn = 20;
const int _seventhRankPawn = 40;

/// Static score of [position] in centipawns from [side]'s point of view:
/// material plus a small bonus for pieces in the centre and pawns close to
/// promotion. Deliberately simple: the "easy" computer should play like a
/// beginner, not a grandmaster.
int evaluate(Position position, PieceColor side) {
  var score = 0;
  for (final (square, piece) in position.pieces()) {
    final value = pieceValue(piece.type) + _placement(square, piece);
    score += piece.color == side ? value : -value;
  }
  return score;
}

int _placement(Square square, Piece piece) {
  var bonus = 0;
  final file = square.file;
  final rank = square.rank;
  if ((file == 3 || file == 4) && (rank == 3 || rank == 4)) {
    bonus += _centreBonus;
  } else if (file >= 2 && file <= 5 && rank >= 2 && rank <= 5) {
    bonus += _ringBonus;
  }
  if (piece.type == PieceType.pawn) {
    final advance = piece.color == PieceColor.white ? rank : 7 - rank;
    if (advance == 5) {
      bonus += _sixthRankPawn;
    } else if (advance == 6) {
      bonus += _seventhRankPawn;
    }
  }
  return bonus;
}
