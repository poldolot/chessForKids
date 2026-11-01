import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fen chars round-trip', () {
    expect(
      Piece.fromFenChar('K'),
      const Piece(PieceColor.white, PieceType.king),
    );
    expect(Piece.fromFenChar('n').fenChar, 'n');
    expect(const Piece(PieceColor.white, PieceType.queen).fenChar, 'Q');
    expect(() => Piece.fromFenChar('x'), throwsFormatException);
  });

  test('piece values match the spec', () {
    expect(PieceType.pawn.value, 1);
    expect(PieceType.knight.value, 3);
    expect(PieceType.bishop.value, 3);
    expect(PieceType.rook.value, 5);
    expect(PieceType.queen.value, 9);
    expect(PieceType.king.value, 0);
  });

  test('opposite color', () {
    expect(PieceColor.white.opposite, PieceColor.black);
    expect(PieceColor.black.opposite, PieceColor.white);
  });
}
