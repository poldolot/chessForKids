import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a1 is index 0, dark, file 0 rank 0', () {
    final s = Square.parse('a1');
    expect(s.index, 0);
    expect(s.file, 0);
    expect(s.rank, 0);
    expect(s.isLight, isFalse);
  });

  test('h8 is index 63 and dark, e4 is light', () {
    expect(Square.parse('h8').index, 63);
    expect(Square.parse('h8').isLight, isFalse);
    expect(Square.parse('e4').isLight, isTrue);
  });

  test('name round-trips for all squares', () {
    for (final s in Square.all) {
      expect(Square.parse(s.name), s);
    }
  });

  test('fromFileRank matches parse', () {
    expect(Square.fromFileRank(4, 3), Square.parse('e4'));
  });

  test('offset returns null off the board', () {
    expect(Square.parse('a1').offset(-1, 0), isNull);
    expect(Square.parse('h8').offset(0, 1), isNull);
    expect(Square.parse('e4').offset(1, 2), Square.parse('f6'));
  });

  test('parse rejects garbage', () {
    expect(() => Square.parse('i9'), throwsFormatException);
    expect(() => Square.parse('e'), throwsFormatException);
  });
}
