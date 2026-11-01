import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uci round-trip with and without promotion', () {
    expect(Move.parseUci('e2e4').uci, 'e2e4');
    final m = Move.parseUci('e7e8q');
    expect(m.promotion, PieceType.queen);
    expect(m.uci, 'e7e8q');
    expect(Move.parseUci('e2e4'), const Move(Square(12), Square(28)));
    expect(Move.parseUci('e2e4'), isNot(Move.parseUci('e2e3')));
  });

  test('parseUci rejects malformed input', () {
    expect(() => Move.parseUci('e2'), throwsFormatException);
    expect(() => Move.parseUci('e2e4x'), throwsFormatException);
  });
}
