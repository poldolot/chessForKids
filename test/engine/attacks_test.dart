import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

Position fen(String f) => Position.fromFen(f);

void main() {
  test('pawn attacks diagonally only', () {
    final p = fen('8/8/8/8/8/8/4P3/8 w - - 0 1');
    expect(isSquareAttacked(p, Square.parse('d3'), PieceColor.white), isTrue);
    expect(isSquareAttacked(p, Square.parse('f3'), PieceColor.white), isTrue);
    expect(isSquareAttacked(p, Square.parse('e3'), PieceColor.white), isFalse);
  });

  test('black pawn attacks downwards', () {
    final p = fen('8/4p3/8/8/8/8/8/8 b - - 0 1');
    expect(isSquareAttacked(p, Square.parse('d6'), PieceColor.black), isTrue);
    expect(isSquareAttacked(p, Square.parse('d8'), PieceColor.black), isFalse);
  });

  test('sliders are blocked by any piece', () {
    final p = fen('8/8/8/8/8/8/8/R2p3k w - - 0 1');
    expect(isSquareAttacked(p, Square.parse('d1'), PieceColor.white), isTrue);
    expect(isSquareAttacked(p, Square.parse('e1'), PieceColor.white), isFalse);
  });

  test('bishop and queen attack along diagonals', () {
    final p = fen('8/8/8/8/3B4/8/8/8 w - - 0 1');
    expect(isSquareAttacked(p, Square.parse('h8'), PieceColor.white), isTrue);
    expect(isSquareAttacked(p, Square.parse('d8'), PieceColor.white), isFalse);
    final q = fen('8/8/8/8/3Q4/8/8/8 w - - 0 1');
    expect(isSquareAttacked(q, Square.parse('d8'), PieceColor.white), isTrue);
  });

  test('knight jumps over pieces', () {
    final p = fen('8/8/8/8/8/2PPP3/2PNP3/2PPP3 w - - 0 1');
    expect(isSquareAttacked(p, Square.parse('e4'), PieceColor.white), isTrue);
  });

  test('king attacks adjacent squares', () {
    final p = fen('8/8/8/8/3K4/8/8/8 w - - 0 1');
    expect(isSquareAttacked(p, Square.parse('e5'), PieceColor.white), isTrue);
    expect(isSquareAttacked(p, Square.parse('d6'), PieceColor.white), isFalse);
  });

  test(
    'isInCheck follows side to move and kingless sides are never in check',
    () {
      expect(isInCheck(fen('4k3/8/8/8/8/8/4R3/4K3 b - - 0 1')), isTrue);
      expect(isInCheck(fen('4k3/8/8/8/8/8/4R3/4K3 w - - 0 1')), isFalse);
      expect(
        isInCheck(fen('4k3/8/8/8/8/8/4R3/4K3 w - - 0 1'), PieceColor.black),
        isTrue,
      );
      expect(
        isInCheck(fen('8/pppppppp/8/8/8/8/PPPPPPPP/8 w - - 0 1')),
        isFalse,
      );
    },
  );
}
