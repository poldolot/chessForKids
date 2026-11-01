import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('pinned piece cannot leave the line', () {
    expect(legal('4k3/4r3/8/8/8/8/4B3/4K3 w - - 0 1', 'e2'), isEmpty);
  });

  test('pinned rook may still move along the pin line', () {
    expect(legal('4k3/4r3/8/8/8/8/4R3/4K3 w - - 0 1', 'e2'), [
      'e2e3',
      'e2e4',
      'e2e5',
      'e2e6',
      'e2e7',
    ]);
  });

  test('in check only evading moves are legal', () {
    expect(legal('4k3/8/8/8/8/8/4r3/4K3 w - - 0 1'), ['e1d1', 'e1e2', 'e1f1']);
  });

  test('en passant that exposes the king along the rank is illegal', () {
    expect(
      legal('8/8/8/KPp4r/8/8/8/4k3 w - c6 0 1', 'b5'),
      isNot(contains('b5c6')),
    );
    expect(legal('8/8/8/KPp4r/8/8/8/4k3 w - c6 0 1', 'b5'), contains('b5b6'));
  });

  test(
    'king cannot step onto an attacked square or next to the other king',
    () {
      expect(legal('8/8/8/8/8/8/8/K1k5 w - - 0 1', 'a1'), ['a1a2']);
    },
  );

  test('kingless side has no check restrictions', () {
    expect(legal('8/pppppppp/8/8/8/8/PPPPPPPP/8 w - - 0 1').length, 16);
  });

  test('initial position has 20 legal moves', () {
    expect(legal(kInitialFen).length, 20);
  });

  test('rules are forwarded to pseudo-legal generation', () {
    final p = Position.fromFen('8/8/8/3pP3/8/8/8/8 w - d6 0 1');
    expect(
      legalMoves(
        p,
        from: Square.parse('e5'),
        rules: const GameRules(enPassant: false),
      ).map((m) => m.uci),
      ['e5e6'],
    );
  });
}
