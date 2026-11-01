import 'castling_rights.dart';
import 'move.dart';
import 'piece.dart';
import 'position.dart';
import 'square.dart';

/// Applies moves to a [Position], producing a new position.
extension ApplyMove on Position {
  /// Returns the position after [move].
  ///
  /// Legality is not verified (the move generator does that), but the move
  /// must be well formed: a piece of the side to move on `from`, a promotion
  /// piece exactly when a pawn reaches the last rank. Castling, en passant,
  /// castling rights, the en passant square and both clocks are handled here.
  Position play(Move move) {
    final piece = pieceAt(move.from);
    if (piece == null || piece.color != sideToMove) {
      throw ArgumentError.value(move, 'move', 'No piece of the side to move');
    }
    final color = piece.color;
    final lastRank = color == PieceColor.white ? 7 : 0;
    final isPawn = piece.type == PieceType.pawn;
    final isPromotion = isPawn && move.to.rank == lastRank;
    if (isPromotion && move.promotion == null) {
      throw ArgumentError.value(move, 'move', 'Promotion piece required');
    }
    if (!isPromotion && move.promotion != null) {
      throw ArgumentError.value(move, 'move', 'Unexpected promotion piece');
    }

    final board = List<Piece?>.of(squares);
    var captured = board[move.to.index];

    final isEnPassant =
        isPawn &&
        captured == null &&
        move.to == enPassant &&
        move.from.file != move.to.file;
    if (isEnPassant) {
      final capturedSquare = Square.fromFileRank(move.to.file, move.from.rank);
      captured = board[capturedSquare.index];
      board[capturedSquare.index] = null;
    }

    board[move.from.index] = null;
    board[move.to.index] = isPromotion ? Piece(color, move.promotion!) : piece;

    final isCastling =
        piece.type == PieceType.king &&
        (move.to.file - move.from.file).abs() == 2;
    if (isCastling) {
      final rank = move.from.rank;
      final kingSide = move.to.file == 6;
      final rookFrom = Square.fromFileRank(kingSide ? 7 : 0, rank);
      final rookTo = Square.fromFileRank(kingSide ? 5 : 3, rank);
      board[rookTo.index] = board[rookFrom.index];
      board[rookFrom.index] = null;
    }

    var rights = castling;
    if (piece.type == PieceType.king) {
      rights = rights.without(color: color);
    }
    rights = _dropRookRight(rights, move.from);
    rights = _dropRookRight(rights, move.to);

    final isDoublePush = isPawn && (move.to.rank - move.from.rank).abs() == 2;
    final newEnPassant = isDoublePush
        ? Square.fromFileRank(
            move.from.file,
            (move.from.rank + move.to.rank) ~/ 2,
          )
        : null;

    return Position(
      squares: board,
      sideToMove: color.opposite,
      castling: rights,
      enPassant: newEnPassant,
      halfmoveClock: isPawn || captured != null ? 0 : halfmoveClock + 1,
      fullmoveNumber: color == PieceColor.black
          ? fullmoveNumber + 1
          : fullmoveNumber,
    );
  }
}

/// Removes the castling right tied to a rook's home square once anything
/// moves from or onto it (a rook leaving, or a rook being captured).
CastlingRights _dropRookRight(CastlingRights rights, Square square) {
  return switch (square.name) {
    'a1' => rights.without(color: PieceColor.white, kingSide: false),
    'h1' => rights.without(color: PieceColor.white, queenSide: false),
    'a8' => rights.without(color: PieceColor.black, kingSide: false),
    'h8' => rights.without(color: PieceColor.black, queenSide: false),
    _ => rights,
  };
}
