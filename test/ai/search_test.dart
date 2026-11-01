import 'dart:math';

import 'package:chess_for_kids/ai/ai.dart';
import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Position fen(String f) => Position.fromFen(f);
  Move uci(String u) => Move.parseUci(u);

  Move? pick(Position p, {int seed = 1}) =>
      chooseMove(p, level: MatchLevel.easy, random: Random(seed));

  test('mate in one is always played, whatever the seed', () {
    final p = fen('6k1/5ppp/8/8/8/8/8/R3K3 w - - 0 1');
    for (var seed = 0; seed < 20; seed++) {
      expect(pick(p, seed: seed), uci('a1a8'), reason: 'seed $seed');
    }
    expect(matingMoves(p), [uci('a1a8')]);
  });

  test('a free queen is taken', () {
    final p = fen('4k3/8/8/3q4/8/8/8/3RK3 w - - 0 1');
    for (var seed = 0; seed < 10; seed++) {
      expect(pick(p, seed: seed), uci('d1d5'), reason: 'seed $seed');
    }
  });

  test('a defended piece is not captured by the queen', () {
    // The rook on d8 is defended by the king: Qxd8 loses the queen.
    final p = fen('3rk3/8/8/8/8/8/8/Q3K3 w - - 0 1');
    for (var seed = 0; seed < 10; seed++) {
      expect(pick(p, seed: seed), isNot(uci('a1d8')), reason: 'seed $seed');
    }
  });

  test('the computer promotes to a queen only', () {
    final p = fen('8/P7/8/8/8/8/k7/4K3 w - - 0 1');
    expect(pick(p), uci('a7a8q'));
  });

  test('no move when the side to move has none', () {
    expect(pick(fen('7k/5Q2/6K1/8/8/8/8/8 b - - 0 1')), isNull);
  });

  test('every move in fifty random games is legal', () {
    for (var seed = 0; seed < 50; seed++) {
      final random = Random(seed);
      final game = Game();
      for (var ply = 0; ply < 40 && !game.result.isOver; ply++) {
        final move = chooseMove(
          game.position,
          level: MatchLevel.easy,
          random: random,
        );
        expect(move, isNotNull);
        expect(game.legalMoves(), contains(move));
        game.play(move!);
      }
    }
  });

  test('the same seed gives the same move', () {
    final p = Position.initial();
    expect(pick(p, seed: 7), pick(p, seed: 7));
  });

  test('the start position is searched quickly', () {
    final watch = Stopwatch()..start();
    pick(Position.initial());
    expect(watch.elapsedMilliseconds, lessThan(2000));
  });
}
