import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Position fen(String f) => Position.fromFen(f);

void main() {
  test('both castlings available on a clear back rank', () {
    final k = ucis(fen('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1'), 'e1');
    expect(k, containsAll(['e1g1', 'e1c1']));
    expect(k.length, 7);
  });

  test('castling blocked by pieces in between', () {
    final k = ucis(fen('r3k2r/8/8/8/8/8/8/RN2K1NR w KQkq - 0 1'), 'e1');
    expect(k, isNot(contains('e1g1')));
    expect(k, isNot(contains('e1c1')));
  });

  test('no castling while in check', () {
    final k = ucis(fen('r3k2r/8/8/8/8/8/4r3/R3K2R w KQkq - 0 1'), 'e1');
    expect(k, isNot(contains('e1g1')));
    expect(k, isNot(contains('e1c1')));
  });

  test('no castling through an attacked square', () {
    final k = ucis(fen('r3k2r/8/8/8/8/8/5r2/R3K2R w KQkq - 0 1'), 'e1');
    expect(k, isNot(contains('e1g1')));
    expect(k, contains('e1c1'));
  });

  test('no castling onto an attacked square', () {
    final k = ucis(fen('r3k2r/8/8/8/8/8/6r1/R3K2R w KQkq - 0 1'), 'e1');
    expect(k, isNot(contains('e1g1')));
  });

  test('attack on b1 does not prevent queen-side castling', () {
    expect(
      ucis(fen('r3k2r/8/8/8/8/8/1r6/R3K2R w KQkq - 0 1'), 'e1'),
      contains('e1c1'),
    );
  });

  test('castling needs the right', () {
    final k = ucis(fen('r3k2r/8/8/8/8/8/8/R3K2R w Qkq - 0 1'), 'e1');
    expect(k, isNot(contains('e1g1')));
    expect(k, contains('e1c1'));
  });

  test('castling can be disabled by rules', () {
    final k = ucis(
      fen('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1'),
      'e1',
      rules: const GameRules(castling: false),
    );
    expect(k, isNot(contains('e1g1')));
    expect(k, isNot(contains('e1c1')));
  });

  test('castling needs the rook on its square', () {
    final k = ucis(fen('r3k2r/8/8/8/8/8/8/R3K3 w KQkq - 0 1'), 'e1');
    expect(k, isNot(contains('e1g1')));
    expect(k, contains('e1c1'));
  });

  test('black castles on the eighth rank', () {
    expect(
      ucis(fen('r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 1'), 'e8'),
      containsAll(['e8g8', 'e8c8']),
    );
  });
}
