import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void check(String fen, Map<int, int> expected) {
  final p = Position.fromFen(fen);
  expected.forEach((depth, nodes) {
    expect(perft(p, depth), nodes, reason: 'depth $depth');
  });
}

void main() {
  test('initial position', () {
    check(kInitialFen, {1: 20, 2: 400, 3: 8902, 4: 197281});
  });

  test('kiwipete', () {
    check(
      'r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1',
      {1: 48, 2: 2039, 3: 97862},
    );
  });

  test('position 3 (en passant and pins)', () {
    check('8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1', {
      1: 14,
      2: 191,
      3: 2812,
      4: 43238,
    });
  });

  test('position 4 (promotions and castling)', () {
    check('r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1', {
      1: 6,
      2: 264,
      3: 9467,
    });
  });

  test('position 5', () {
    check('rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8', {
      1: 44,
      2: 1486,
      3: 62379,
    });
  });
}
