import 'apply_move.dart';
import 'attacks.dart';
import 'directions.dart';
import 'move.dart';
import 'piece.dart';
import 'position.dart';
import 'square.dart';

/// Optional rules that lessons may switch off before they are taught.
final class GameRules {
  const GameRules({this.enPassant = true, this.castling = true});

  /// Whether en passant captures are generated.
  final bool enPassant;

  /// Whether castling moves are generated.
  final bool castling;

  static const GameRules standard = GameRules();
}

/// Moves that follow the piece movement rules, without checking whether the
/// mover's king is left in check. Use `legalMoves` for the legal subset.
///
/// With [from], only moves of the piece on that square are returned; an empty
/// square or an opponent's piece yields no moves.
List<Move> pseudoLegalMoves(
  Position position, {
  Square? from,
  GameRules rules = GameRules.standard,
}) {
  final moves = <Move>[];
  if (from != null) {
    final piece = position.pieceAt(from);
    if (piece != null && piece.color == position.sideToMove) {
      _pieceMoves(position, from, piece, rules, moves);
    }
    return moves;
  }
  for (final (square, piece) in position.pieces(position.sideToMove)) {
    _pieceMoves(position, square, piece, rules, moves);
  }
  return moves;
}

/// Legal moves: pseudo-legal moves after which the mover's king is not
/// attacked. A side without a king has no such restriction.
List<Move> legalMoves(
  Position position, {
  Square? from,
  GameRules rules = GameRules.standard,
}) {
  final candidates = pseudoLegalMoves(position, from: from, rules: rules);
  final mover = position.sideToMove;
  if (position.kingSquare(mover) == null) {
    return candidates;
  }
  return [
    for (final move in candidates)
      if (!isInCheck(position.play(move), mover)) move,
  ];
}

void _pieceMoves(
  Position position,
  Square from,
  Piece piece,
  GameRules rules,
  List<Move> out,
) {
  switch (piece.type) {
    case PieceType.rook:
      _slidingMoves(position, from, piece.color, orthogonalDirections, out);
    case PieceType.bishop:
      _slidingMoves(position, from, piece.color, diagonalDirections, out);
    case PieceType.queen:
      _slidingMoves(position, from, piece.color, royalDirections, out);
    case PieceType.king:
      _steppingMoves(position, from, piece.color, royalDirections, out);
      if (rules.castling) {
        _castlingMoves(position, from, piece.color, out);
      }
    case PieceType.knight:
      _steppingMoves(position, from, piece.color, knightJumps, out);
    case PieceType.pawn:
      _pawnMoves(position, from, piece.color, rules, out);
  }
}

const List<PieceType> _promotionPieces = [
  PieceType.queen,
  PieceType.rook,
  PieceType.bishop,
  PieceType.knight,
];

void _pawnMoves(
  Position position,
  Square from,
  PieceColor color,
  GameRules rules,
  List<Move> out,
) {
  final forward = color == PieceColor.white ? 1 : -1;
  final startRank = color == PieceColor.white ? 1 : 6;
  final lastRank = color == PieceColor.white ? 7 : 0;

  void add(Square to) {
    if (to.rank == lastRank) {
      for (final promotion in _promotionPieces) {
        out.add(Move(from, to, promotion: promotion));
      }
    } else {
      out.add(Move(from, to));
    }
  }

  final oneAhead = from.offset(0, forward);
  if (oneAhead != null && position.pieceAt(oneAhead) == null) {
    add(oneAhead);
    final twoAhead = from.offset(0, 2 * forward);
    if (from.rank == startRank &&
        twoAhead != null &&
        position.pieceAt(twoAhead) == null) {
      out.add(Move(from, twoAhead));
    }
  }
  for (final fileDelta in const [-1, 1]) {
    final to = from.offset(fileDelta, forward);
    if (to == null) {
      continue;
    }
    final target = position.pieceAt(to);
    if (target != null && target.color != color) {
      add(to);
    } else if (target == null && rules.enPassant && to == position.enPassant) {
      out.add(Move(from, to));
    }
  }
}

void _slidingMoves(
  Position position,
  Square from,
  PieceColor color,
  List<(int, int)> directions,
  List<Move> out,
) {
  for (final (df, dr) in directions) {
    var to = from.offset(df, dr);
    while (to != null) {
      final target = position.pieceAt(to);
      if (target == null) {
        out.add(Move(from, to));
      } else {
        if (target.color != color) {
          out.add(Move(from, to));
        }
        break;
      }
      to = to.offset(df, dr);
    }
  }
}

void _steppingMoves(
  Position position,
  Square from,
  PieceColor color,
  List<(int, int)> steps,
  List<Move> out,
) {
  for (final (df, dr) in steps) {
    final to = from.offset(df, dr);
    if (to == null) {
      continue;
    }
    final target = position.pieceAt(to);
    if (target == null || target.color != color) {
      out.add(Move(from, to));
    }
  }
}

/// Castling: the king moves two files towards a rook that has not moved.
/// All squares between them are empty, the king is not in check and does not
/// pass through or land on an attacked square (the rook's path may be attacked).
void _castlingMoves(
  Position position,
  Square from,
  PieceColor color,
  List<Move> out,
) {
  final homeRank = color == PieceColor.white ? 0 : 7;
  if (from != Square.fromFileRank(4, homeRank)) {
    return;
  }
  final rights = position.castling;
  final enemy = color.opposite;
  if (isSquareAttacked(position, from, enemy)) {
    return;
  }
  // (hasRight, rookFile, emptyFiles, kingPathFiles, kingTargetFile)
  final sides = [
    (rights.kingSide(color), 7, const [5, 6], const [5, 6], 6),
    (rights.queenSide(color), 0, const [1, 2, 3], const [2, 3], 2),
  ];
  for (final (hasRight, rookFile, emptyFiles, kingPath, targetFile) in sides) {
    if (!hasRight) {
      continue;
    }
    if (position.pieceAt(Square.fromFileRank(rookFile, homeRank)) !=
        Piece(color, PieceType.rook)) {
      continue;
    }
    if (emptyFiles.any(
      (f) => position.pieceAt(Square.fromFileRank(f, homeRank)) != null,
    )) {
      continue;
    }
    if (kingPath.any(
      (f) =>
          isSquareAttacked(position, Square.fromFileRank(f, homeRank), enemy),
    )) {
      continue;
    }
    out.add(Move(from, Square.fromFileRank(targetFile, homeRank)));
  }
}
