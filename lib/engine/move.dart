import 'piece.dart';
import 'square.dart';

/// A move from one square to another, with an optional promotion piece.
///
/// Castling and en passant are not flagged here: they are derived from the
/// position when the move is applied.
final class Move {
  const Move(this.from, this.to, {this.promotion});

  /// Parses long algebraic (UCI) notation such as `e2e4` or `e7e8q`.
  factory Move.parseUci(String uci) {
    if (uci.length != 4 && uci.length != 5) {
      throw FormatException('Invalid UCI move', uci);
    }
    final from = Square.parse(uci.substring(0, 2));
    final to = Square.parse(uci.substring(2, 4));
    PieceType? promotion;
    if (uci.length == 5) {
      promotion = PieceType.fromLetter(uci[4]);
      if (promotion == null ||
          promotion == PieceType.king ||
          promotion == PieceType.pawn) {
        throw FormatException('Invalid promotion piece', uci);
      }
    }
    return Move(from, to, promotion: promotion);
  }

  final Square from;
  final Square to;

  /// The piece a pawn becomes when reaching the last rank; `null` otherwise.
  final PieceType? promotion;

  /// Long algebraic (UCI) notation.
  String get uci => '${from.name}${to.name}${promotion?.letter ?? ''}';

  @override
  bool operator ==(Object other) =>
      other is Move &&
      other.from == from &&
      other.to == to &&
      other.promotion == promotion;

  @override
  int get hashCode => Object.hash(from, to, promotion);

  @override
  String toString() => uci;
}
