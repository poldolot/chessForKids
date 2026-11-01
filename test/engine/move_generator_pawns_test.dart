import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test(
    'pawn single and double push from start rank, blocked when occupied',
    () {
      expect(ucis(Position.initial(), 'e2'), ['e2e3', 'e2e4']);
      expect(ucis(Position.fromFen('8/8/8/8/4p3/8/4P3/8 w - - 0 1'), 'e2'), [
        'e2e3',
      ]);
      expect(
        ucis(Position.fromFen('8/8/8/8/8/4p3/4P3/8 w - - 0 1'), 'e2'),
        isEmpty,
      );
    },
  );

  test('pawn off its start rank moves one square only', () {
    expect(ucis(Position.fromFen('8/8/8/8/8/4P3/8/8 w - - 0 1'), 'e3'), [
      'e3e4',
    ]);
  });

  test('pawn captures diagonally, never forward', () {
    final p = Position.fromFen('8/8/8/8/8/3ppp2/4P3/8 w - - 0 1');
    expect(ucis(p, 'e2'), ['e2d3', 'e2f3']);
  });

  test('pawn does not capture own pieces', () {
    expect(ucis(Position.fromFen('8/8/8/8/8/3P4/4P3/8 w - - 0 1'), 'e2'), [
      'e2e3',
      'e2e4',
    ]);
  });

  test('black pawns move down the board', () {
    expect(ucis(Position.fromFen('8/4p3/8/8/8/8/8/8 b - - 0 1'), 'e7'), [
      'e7e5',
      'e7e6',
    ]);
    expect(ucis(Position.fromFen('8/8/8/8/8/8/4p3/3P1P2 b - - 0 1'), 'e2'), [
      'e2d1b',
      'e2d1n',
      'e2d1q',
      'e2d1r',
      'e2e1b',
      'e2e1n',
      'e2e1q',
      'e2e1r',
      'e2f1b',
      'e2f1n',
      'e2f1q',
      'e2f1r',
    ]);
  });

  test('promotion yields four moves, also on capture', () {
    expect(ucis(Position.fromFen('8/4P3/8/8/8/8/8/8 w - - 0 1'), 'e7'), [
      'e7e8b',
      'e7e8n',
      'e7e8q',
      'e7e8r',
    ]);
    expect(
      ucis(Position.fromFen('3r4/4P3/8/8/8/8/8/8 w - - 0 1'), 'e7').length,
      8,
    );
  });

  test('en passant is generated only when allowed by the rules', () {
    final p = Position.fromFen('8/8/8/3pP3/8/8/8/8 w - d6 0 1');
    expect(ucis(p, 'e5'), ['e5d6', 'e5e6']);
    expect(ucis(p, 'e5', rules: const GameRules(enPassant: false)), ['e5e6']);
  });

  test('en passant only for a pawn adjacent to the target square', () {
    final p = Position.fromFen('8/8/8/3p3P/8/8/8/8 w - d6 0 1');
    expect(ucis(p, 'h5'), ['h5h6']);
  });

  test('initial position has 20 pseudo-legal moves', () {
    expect(pseudoLegalMoves(Position.initial()).length, 20);
  });
}
