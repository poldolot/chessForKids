import 'piece.dart';

/// Which castlings are still available to each side.
final class CastlingRights {
  const CastlingRights({
    required this.whiteKingSide,
    required this.whiteQueenSide,
    required this.blackKingSide,
    required this.blackQueenSide,
  });

  /// Parses the FEN castling field, e.g. `KQkq` or `-`.
  factory CastlingRights.fromFen(String field) {
    if (field == '-') {
      return none;
    }
    if (field.isEmpty || field.split('').any((c) => !'KQkq'.contains(c))) {
      throw FormatException('Invalid castling field', field);
    }
    return CastlingRights(
      whiteKingSide: field.contains('K'),
      whiteQueenSide: field.contains('Q'),
      blackKingSide: field.contains('k'),
      blackQueenSide: field.contains('q'),
    );
  }

  static const CastlingRights all = CastlingRights(
    whiteKingSide: true,
    whiteQueenSide: true,
    blackKingSide: true,
    blackQueenSide: true,
  );

  static const CastlingRights none = CastlingRights(
    whiteKingSide: false,
    whiteQueenSide: false,
    blackKingSide: false,
    blackQueenSide: false,
  );

  final bool whiteKingSide;
  final bool whiteQueenSide;
  final bool blackKingSide;
  final bool blackQueenSide;

  /// Whether [color] may still castle king-side.
  bool kingSide(PieceColor color) =>
      color == PieceColor.white ? whiteKingSide : blackKingSide;

  /// Whether [color] may still castle queen-side.
  bool queenSide(PieceColor color) =>
      color == PieceColor.white ? whiteQueenSide : blackQueenSide;

  /// Returns a copy with the given rights removed.
  ///
  /// With `color == null` both sides are affected. `kingSide` and `queenSide`
  /// select which rights to drop; both default to true.
  CastlingRights without({
    PieceColor? color,
    bool kingSide = true,
    bool queenSide = true,
  }) {
    final white = color == null || color == PieceColor.white;
    final black = color == null || color == PieceColor.black;
    return CastlingRights(
      whiteKingSide: whiteKingSide && !(white && kingSide),
      whiteQueenSide: whiteQueenSide && !(white && queenSide),
      blackKingSide: blackKingSide && !(black && kingSide),
      blackQueenSide: blackQueenSide && !(black && queenSide),
    );
  }

  /// FEN castling field, `-` when no rights remain.
  String get fen {
    final buffer = StringBuffer();
    if (whiteKingSide) buffer.write('K');
    if (whiteQueenSide) buffer.write('Q');
    if (blackKingSide) buffer.write('k');
    if (blackQueenSide) buffer.write('q');
    return buffer.isEmpty ? '-' : buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is CastlingRights &&
      other.whiteKingSide == whiteKingSide &&
      other.whiteQueenSide == whiteQueenSide &&
      other.blackKingSide == blackKingSide &&
      other.blackQueenSide == blackQueenSide;

  @override
  int get hashCode =>
      Object.hash(whiteKingSide, whiteQueenSide, blackKingSide, blackQueenSide);

  @override
  String toString() => fen;
}
