/// A square on the board, identified by its index 0..63.
///
/// `index = rank * 8 + file`, with file 0 = a .. 7 = h and rank 0 = 1 .. 7 = 8,
/// so a1 = 0, h1 = 7, a8 = 56 and h8 = 63. White pawns move towards higher ranks.
final class Square {
  const Square(this.index) : assert(index >= 0 && index < 64);

  factory Square.fromFileRank(int file, int rank) {
    assert(file >= 0 && file < 8 && rank >= 0 && rank < 8);
    return Square(rank * 8 + file);
  }

  /// Parses algebraic notation such as `e4`.
  factory Square.parse(String name) {
    if (name.length != 2) {
      throw FormatException('Invalid square name', name);
    }
    final file = name.codeUnitAt(0) - _aCode;
    final rank = name.codeUnitAt(1) - _oneCode;
    if (file < 0 || file > 7 || rank < 0 || rank > 7) {
      throw FormatException('Invalid square name', name);
    }
    return Square.fromFileRank(file, rank);
  }

  static const int _aCode = 0x61; // 'a'
  static const int _oneCode = 0x31; // '1'

  /// All 64 squares in index order (a1, b1, ..., h8).
  static final List<Square> all = List.unmodifiable(
    List.generate(64, Square.new),
  );

  /// 0..63, see the class documentation for the layout.
  final int index;

  /// 0 = a .. 7 = h.
  int get file => index & 7;

  /// 0 = first rank .. 7 = eighth rank.
  int get rank => index >> 3;

  /// Algebraic name, e.g. `e4`.
  String get name => String.fromCharCodes([_aCode + file, _oneCode + rank]);

  /// Whether the square is light. a1 is dark.
  bool get isLight => (file + rank).isOdd;

  /// The square shifted by the given deltas, or `null` when off the board.
  Square? offset(int fileDelta, int rankDelta) {
    final f = file + fileDelta;
    final r = rank + rankDelta;
    if (f < 0 || f > 7 || r < 0 || r > 7) {
      return null;
    }
    return Square.fromFileRank(f, r);
  }

  @override
  bool operator ==(Object other) => other is Square && other.index == index;

  @override
  int get hashCode => index;

  @override
  String toString() => name;
}
