import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('rook in the center of an empty board has 14 moves', () {
    expect(
      ucis(Position.fromFen('8/8/8/8/3R4/8/8/8 w - - 0 1'), 'd4').length,
      14,
    );
  });

  test('rook stops before own piece and captures enemy piece', () {
    final p = Position.fromFen('8/8/8/3p4/3R4/3P4/8/8 w - - 0 1');
    final m = ucis(p, 'd4');
    expect(m, contains('d4d5'));
    expect(m, isNot(contains('d4d6')));
    expect(m, isNot(contains('d4d3')));
    expect(m.length, 8);
  });

  test('bishop, queen, knight, king counts on empty board', () {
    expect(
      ucis(Position.fromFen('8/8/8/8/3B4/8/8/8 w - - 0 1'), 'd4').length,
      13,
    );
    expect(
      ucis(Position.fromFen('8/8/8/8/3Q4/8/8/8 w - - 0 1'), 'd4').length,
      27,
    );
    expect(
      ucis(Position.fromFen('8/8/8/8/3N4/8/8/8 w - - 0 1'), 'd4').length,
      8,
    );
    expect(ucis(Position.fromFen('N7/8/8/8/8/8/8/8 w - - 0 1'), 'a8'), [
      'a8b6',
      'a8c7',
    ]);
    expect(
      ucis(Position.fromFen('8/8/8/8/3K4/8/8/8 w - - 0 1'), 'd4').length,
      8,
    );
  });

  test('knight captures enemy pieces but not own', () {
    final p = Position.fromFen('8/8/2p1P3/8/3N4/8/8/8 w - - 0 1');
    final m = ucis(p, 'd4');
    expect(m, contains('d4c6'));
    expect(m, isNot(contains('d4e6')));
  });

  test('from on empty square or enemy piece yields nothing', () {
    final p = Position.fromFen('8/8/8/8/3r4/8/8/8 w - - 0 1');
    expect(ucis(p, 'd4'), isEmpty);
    expect(ucis(p, 'e4'), isEmpty);
  });

  test('without from, all pieces of the side to move are generated', () {
    expect(
      pseudoLegalMoves(Position.fromFen('8/8/8/8/3R4/8/8/N7 w - - 0 1')).length,
      14 + 2,
    );
    expect(
      pseudoLegalMoves(Position.fromFen('8/8/8/8/3R4/8/8/N7 b - - 0 1')),
      isEmpty,
    );
  });
}
