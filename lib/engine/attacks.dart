import 'directions.dart';
import 'piece.dart';
import 'position.dart';
import 'square.dart';

/// Whether any piece of color [by] attacks [square].
///
/// Pawns attack only diagonally forward; kings attack adjacent squares even
/// when they could not legally move there; sliders stop at the first piece.
bool isSquareAttacked(Position position, Square square, PieceColor by) {
  final pawnRankDelta = by == PieceColor.white ? -1 : 1;
  for (final fileDelta in const [-1, 1]) {
    if (position.pieceAtOffset(square, fileDelta, pawnRankDelta) ==
        Piece(by, PieceType.pawn)) {
      return true;
    }
  }
  for (final (df, dr) in knightJumps) {
    if (position.pieceAtOffset(square, df, dr) == Piece(by, PieceType.knight)) {
      return true;
    }
  }
  for (final (df, dr) in royalDirections) {
    if (position.pieceAtOffset(square, df, dr) == Piece(by, PieceType.king)) {
      return true;
    }
  }
  if (_slidingAttack(
    position,
    square,
    by,
    orthogonalDirections,
    PieceType.rook,
  )) {
    return true;
  }
  return _slidingAttack(
    position,
    square,
    by,
    diagonalDirections,
    PieceType.bishop,
  );
}

bool _slidingAttack(
  Position position,
  Square square,
  PieceColor by,
  List<(int, int)> directions,
  PieceType slider,
) {
  for (final (df, dr) in directions) {
    var current = square.offset(df, dr);
    while (current != null) {
      final piece = position.pieceAt(current);
      if (piece != null) {
        if (piece.color == by &&
            (piece.type == slider || piece.type == PieceType.queen)) {
          return true;
        }
        break;
      }
      current = current.offset(df, dr);
    }
  }
  return false;
}

/// Whether the king of [color] (default: the side to move) is attacked.
/// A side without a king is never in check.
bool isInCheck(Position position, [PieceColor? color]) {
  final side = color ?? position.sideToMove;
  final king = position.kingSquare(side);
  if (king == null) {
    return false;
  }
  return isSquareAttacked(position, king, side.opposite);
}

extension on Position {
  /// The piece on [square] shifted by the deltas, or `null` when off board or empty.
  Piece? pieceAtOffset(Square square, int fileDelta, int rankDelta) {
    final target = square.offset(fileDelta, rankDelta);
    return target == null ? null : pieceAt(target);
  }
}
