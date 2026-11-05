import 'dart:math';

import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/games/policies.dart';
import 'package:flutter_test/flutter_test.dart';

Square sq(String s) => Square.parse(s);
Move uci(String s) => Move.parseUci(s);
Position fen(String f) => Position.fromFen(f);

void main() {
  test('shortestPath finds the rook detour around an own pawn', () {
    final p = fen('8/8/8/8/3P4/8/8/R7 w - - 0 1');
    final path = shortestPath(p, sq('a1'), {sq('d8')});
    expect(path, isNotNull);
    expect(path!.length, 2);
    expect(path.last, sq('d8'));
    expect(path.first, anyOf(sq('a8'), sq('d1')));
  });

  test('shortestPath returns null when unreachable and respects avoid', () {
    expect(
      shortestPath(fen('8/8/8/8/8/8/8/2B5 w - - 0 1'), sq('c1'), {sq('d7')}),
      isNull,
    );
    final p = fen('8/8/8/8/8/8/8/R7 w - - 0 1');
    expect(shortestPath(p, sq('a1'), {sq('a8')}, avoid: {sq('a8')}), isNull);
    expect(
      shortestPath(p, sq('a1'), {sq('h8')}, avoid: {sq('a8')})!.first,
      sq('h1'),
    );
  });

  test(
    'nearestStarStep prefers the closer star and steps along a shortest path',
    () {
      final p = fen('8/8/8/8/8/8/8/R7 w - - 0 1');
      final step = nearestStarStep(p, sq('a1'), {sq('h8'), sq('a5')});
      expect(step, uci('a1a5'));
      expect(nearestStarStep(p, sq('a1'), {}), isNull);
    },
  );

  test('nearestStarStep never wastes a move when a star is one move away', () {
    final p = fen('8/8/8/8/3R4/8/8/8 w - - 0 1');
    final step = nearestStarStep(p, sq('d4'), {sq('d8'), sq('h1')});
    expect(step!.to, sq('d8'));
  });

  test('kingRaceStep avoids attacked squares and reaches the last rank', () {
    var p = fen('8/8/p1p1p1p1/8/1p1p1p1p/8/8/4K3 w - - 0 1');
    for (var i = 0; i < 7; i++) {
      final step = kingRaceStep(p, PieceColor.white);
      expect(step, isNotNull, reason: 'stuck at ${p.fen}');
      expect(
        isSquareAttacked(p, step!.to, PieceColor.black),
        isFalse,
        reason: '$step into attack',
      );
      p = p.play(step).pass();
    }
    expect(p.kingSquare(PieceColor.white)!.rank, 7);
  });

  test(
    'pawnWarMove promotes when it can, else captures, else pushes safely',
    () {
      final r = Random(1);
      expect(
        pawnWarMove(
          fen('8/4P3/8/8/8/8/8/8 w - - 0 1'),
          PieceColor.white,
          r,
        )?.promotion,
        PieceType.queen,
      );
      expect(
        pawnWarMove(fen('8/8/8/3p4/4P3/8/8/7P w - - 0 1'), PieceColor.white, r),
        uci('e4d5'),
      );
      final safe = pawnWarMove(
        fen('8/8/8/2p5/8/8/1P2P3/8 w - - 0 1'),
        PieceColor.white,
        r,
      );
      // b2b4 would be captured by c5; e2e4 and e2e3 and b2b3 are safe
      expect(safe, isNot(uci('b2b4')));
      expect(
        pawnWarMove(fen('8/8/8/8/8/8/8/8 w - - 0 1'), PieceColor.white, r),
        isNull,
      );
    },
  );

  test(
    'pawnWarMove plays black downwards and prefers the most advanced pawn',
    () {
      final m = pawnWarMove(
        fen('8/p7/8/8/8/3p4/8/8 b - - 0 1'),
        PieceColor.black,
        Random(2),
      );
      expect(m!.from, sq('d3'));
      expect(m.to, sq('d2'));
    },
  );

  test(
    'fleeMove runs away from the hunter and never onto an attacked square',
    () {
      final p = fen('8/8/8/8/8/8/3p4/1N6 b - - 0 1');
      // the pawn can only go to d1 which is attacked? d1 is not attacked by Nb1 (b1 attacks a3,c3,d2); so d2d1 allowed
      final m = fleeMove(p, PieceColor.black, sq('b1'), Random(1));
      expect(m, isNotNull);
      final q = fen('8/8/8/8/8/8/8/1N1n4 b - - 0 1');
      final flee = fleeMove(q, PieceColor.black, sq('b1'), Random(1));
      expect(flee, isNotNull);
      expect(isSquareAttacked(q, flee!.to, PieceColor.white), isFalse);
      expect(
        fleeMove(
          fen('3b4/2p1p3/8/8/8/8/8/R7 b - - 0 1'),
          PieceColor.black,
          sq('a1'),
          Random(1),
          prey: sq('d8'),
        ),
        isNull,
      );
    },
  );

  test('huntStep captures when it can, otherwise closes in', () {
    expect(
      huntStep(fen('8/8/8/8/8/2p5/8/1N6 w - - 0 1'), sq('b1'), sq('c3')),
      uci('b1c3'),
    );
    final step = huntStep(
      fen('8/5p2/8/8/8/8/8/6N1 w - - 0 1'),
      sq('g1'),
      sq('f7'),
    );
    expect(step, isNotNull);
    expect(step!.from, sq('g1'));
  });

  test('pawnWarMove respects rules without en passant', () {
    final p = fen('8/8/8/3pP3/8/8/8/8 w - d6 0 1');
    final m = pawnWarMove(
      p,
      PieceColor.white,
      Random(1),
      rules: const GameRules(enPassant: false),
    );
    expect(m, uci('e5e6'));
  });

  test('a careless pawn war opponent sometimes ignores a capture', () {
    final p = Position.fromFen('8/8/8/8/3p4/4P3/8/8 b - - 0 1');
    var ignored = 0;
    for (var seed = 0; seed < 40; seed++) {
      final steady = pawnWarMove(p, PieceColor.black, Random(seed));
      expect(steady, Move.parseUci('d4e3'), reason: 'seed $seed');
      final careless = pawnWarMove(
        p,
        PieceColor.black,
        Random(seed),
        blunder: 0.6,
      );
      if (careless != Move.parseUci('d4e3')) {
        ignored++;
      }
    }
    expect(ignored, greaterThan(10));
  });
}
