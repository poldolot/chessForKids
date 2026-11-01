/// The two sides of a chess game.
enum PieceColor {
  white,
  black;

  PieceColor get opposite => this == white ? black : white;
}

/// Piece kinds with their conventional material value and FEN letter.
enum PieceType {
  pawn(value: 1, letter: 'p'),
  knight(value: 3, letter: 'n'),
  bishop(value: 3, letter: 'b'),
  rook(value: 5, letter: 'r'),
  queen(value: 9, letter: 'q'),
  king(value: 0, letter: 'k');

  const PieceType({required this.value, required this.letter});

  /// Conventional material value (pawn 1 ... queen 9, king 0).
  final int value;

  /// Lowercase FEN letter.
  final String letter;

  /// The piece type for a lowercase FEN letter, or `null` if unknown.
  static PieceType? fromLetter(String letter) {
    for (final type in values) {
      if (type.letter == letter) {
        return type;
      }
    }
    return null;
  }
}

/// A colored piece.
final class Piece {
  const Piece(this.color, this.type);

  /// Parses a FEN letter: uppercase for white, lowercase for black.
  factory Piece.fromFenChar(String char) {
    if (char.length == 1) {
      final type = PieceType.fromLetter(char.toLowerCase());
      if (type != null) {
        final color = char == char.toUpperCase()
            ? PieceColor.white
            : PieceColor.black;
        return Piece(color, type);
      }
    }
    throw FormatException('Invalid piece character', char);
  }

  final PieceColor color;
  final PieceType type;

  /// FEN letter: uppercase for white, lowercase for black.
  String get fenChar =>
      color == PieceColor.white ? type.letter.toUpperCase() : type.letter;

  @override
  bool operator ==(Object other) =>
      other is Piece && other.color == color && other.type == type;

  @override
  int get hashCode => Object.hash(color, type);

  @override
  String toString() => fenChar;
}
