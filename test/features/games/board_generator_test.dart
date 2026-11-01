import 'dart:math';

import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/games/board_generator.dart';
import 'package:chess_for_kids/features/games/game_model.dart';
import 'package:chess_for_kids/features/games/policies.dart';
import 'package:flutter_test/flutter_test.dart';

/// The level table the assets will carry (task 3); kept here so the
/// generator is tested against the real difficulty curve.
const collectLevels = [
  GameLevel(index: 0, stars: 3, obstacles: 0, slack: 3),
  GameLevel(index: 1, stars: 4, obstacles: 0, slack: 3),
  GameLevel(index: 2, stars: 5, obstacles: 1, slack: 3),
  GameLevel(index: 3, stars: 5, obstacles: 2, slack: 2),
  GameLevel(index: 4, stars: 6, obstacles: 3, slack: 2),
];

const huntLevels = [
  GameLevel(index: 0, hunter: PieceType.knight, prey: PieceType.pawn, limit: 8),
  GameLevel(
    index: 1,
    hunter: PieceType.knight,
    prey: PieceType.bishop,
    trapped: true,
    limit: 10,
  ),
  GameLevel(
    index: 2,
    hunter: PieceType.rook,
    prey: PieceType.bishop,
    trapped: true,
    limit: 8,
    unlockedByLesson: 'queen',
  ),
  GameLevel(
    index: 3,
    hunter: PieceType.bishop,
    prey: PieceType.knight,
    trapped: true,
    limit: 8,
    unlockedByLesson: 'queen',
  ),
  GameLevel(
    index: 4,
    hunter: PieceType.queen,
    prey: PieceType.pawn,
    limit: 8,
    unlockedByLesson: 'queen',
  ),
];

const kingLevels = [
  GameLevel(index: 0, blockers: {PieceType.pawn: 3}, slack: 4),
  GameLevel(index: 1, blockers: {PieceType.pawn: 5}, slack: 4),
  GameLevel(
    index: 2,
    blockers: {PieceType.pawn: 6, PieceType.bishop: 1},
    slack: 4,
  ),
  GameLevel(
    index: 3,
    blockers: {PieceType.pawn: 6, PieceType.knight: 2},
    slack: 3,
  ),
  GameLevel(
    index: 4,
    blockers: {PieceType.pawn: 7, PieceType.bishop: 2},
    slack: 3,
  ),
];

void main() {
  Square mover(Position p) => p
      .pieces(PieceColor.white)
      .firstWhere((e) => e.$2.type != PieceType.pawn)
      .$1;

  group('collect boards', () {
    for (final kind in [MiniGameKind.rookRoads, MiniGameKind.bishopTracks]) {
      for (final level in collectLevels) {
        test('$kind level ${level.index}: valid for thirty seeds', () {
          for (var seed = 0; seed < 30; seed++) {
            final b = generateBoard(kind, level, Random(seed));
            final p = b.startPosition;
            final from = mover(p);
            final piece = p.pieceAt(from)!;
            expect(
              piece.type,
              kind == MiniGameKind.rookRoads
                  ? PieceType.rook
                  : PieceType.bishop,
            );
            expect(b.index, level.index);
            expect(b.stars.length, level.stars, reason: 'seed $seed');
            for (final s in b.stars) {
              expect(
                p.pieceAt(s),
                isNull,
                reason: 'seed $seed: star $s on a piece',
              );
              if (kind == MiniGameKind.bishopTracks) {
                expect(
                  s.isLight,
                  from.isLight,
                  reason: 'seed $seed: star $s off colour',
                );
              }
            }
            final pawns = p
                .pieces(PieceColor.white)
                .where((e) => e.$2.type == PieceType.pawn)
                .toList();
            expect(pawns.length, level.obstacles, reason: 'seed $seed');
            for (final (s, _) in pawns) {
              expect(
                s.rank,
                inInclusiveRange(1, 6),
                reason: 'seed $seed pawn on $s',
              );
            }
            if (level.obstacles > 0) {
              // The obstacles must actually lengthen the route.
              var open = p;
              for (final (s, _) in pawns) {
                open = open.withPiece(s, null);
              }
              expect(
                optimalTour(open, from, b.stars)!,
                lessThan(b.par!),
                reason: 'seed $seed ${b.fen}: obstacles change nothing',
              );
            }
            expect(p.pieces(PieceColor.black), isEmpty);
            final optimum = optimalTour(p, from, b.stars);
            expect(optimum, b.par, reason: 'seed $seed ${b.fen}');
            expect(b.par, inInclusiveRange(level.stars, level.stars + 3));
            expect(b.moveLimit, b.par! + level.slack);
            // Following the hint finishes in exactly par moves.
            var pos = p;
            var at = from;
            final left = {...b.stars};
            var moves = 0;
            while (left.isNotEmpty && moves <= b.par!) {
              final step = nearestStarStep(pos, at, left)!;
              pos = pos.play(step).pass();
              at = step.to;
              left.remove(at);
              moves++;
            }
            expect(left, isEmpty, reason: 'seed $seed ${b.fen}');
            expect(moves, b.par);
          }
        });
      }
    }
  });

  group('king race boards', () {
    for (final level in kingLevels) {
      test('level ${level.index}: valid for thirty seeds', () {
        for (var seed = 0; seed < 30; seed++) {
          final b = generateBoard(MiniGameKind.kingRace, level, Random(seed));
          final p = b.startPosition;
          final king = p.kingSquare(PieceColor.white)!;
          expect(king.rank, 0, reason: 'seed $seed');
          expect(
            isSquareAttacked(p, king, PieceColor.black),
            isFalse,
            reason: 'seed $seed ${b.fen}',
          );
          expect(p.pieces(PieceColor.white).length, 1);
          final black = p
              .pieces(PieceColor.black)
              .map((e) => e.$2.type)
              .toList();
          for (final e in level.blockers.entries) {
            expect(
              black.where((t) => t == e.key).length,
              e.value,
              reason: 'seed $seed',
            );
          }
          expect(b.par, inInclusiveRange(7, 10), reason: 'seed $seed ${b.fen}');
          expect(b.moveLimit, b.par! + level.slack);
          var pos = p;
          var moves = 0;
          while (pos.kingSquare(PieceColor.white)!.rank != 7 &&
              moves <= b.par!) {
            final step = kingRaceStep(pos, PieceColor.white)!;
            pos = pos.play(step).pass();
            moves++;
          }
          expect(
            pos.kingSquare(PieceColor.white)!.rank,
            7,
            reason: 'seed $seed ${b.fen}',
          );
          expect(moves, b.par, reason: 'seed $seed ${b.fen}');
        }
      });
    }
  });

  test('the same seed gives the same board, different seeds vary', () {
    final a = generateBoard(
      MiniGameKind.rookRoads,
      collectLevels[2],
      Random(5),
    );
    final b = generateBoard(
      MiniGameKind.rookRoads,
      collectLevels[2],
      Random(5),
    );
    expect(a.fen, b.fen);
    expect(a.stars, b.stars);
    final fens = {
      for (var s = 0; s < 30; s++)
        generateBoard(MiniGameKind.rookRoads, collectLevels[2], Random(s)).fen,
    };
    expect(fens.length, greaterThanOrEqualTo(25));
  });

  test('a fixed level returns its board untouched', () {
    const level = GameLevel(
      index: 0,
      fen: '8/pppppppp/8/8/8/8/PPPPPPPP/8 w - - 0 1',
    );
    final b = generateBoard(
      MiniGameKind.pawnWar,
      level,
      Random(1),
      rules: const GameRules(enPassant: false, castling: false),
    );
    expect(b.fen, level.fen);
    expect(b.rules.enPassant, isFalse);
    expect(b.par, isNull);
  });

  test('hardest levels generate quickly', () {
    final watch = Stopwatch()..start();
    for (var s = 0; s < 30; s++) {
      generateBoard(MiniGameKind.bishopTracks, collectLevels[4], Random(s));
      generateBoard(MiniGameKind.kingRace, kingLevels[4], Random(s));
    }
    expect(watch.elapsedMilliseconds, lessThan(4000));
  });

  test('level json parses blockers, hunter and prey letters', () {
    final level = GameLevel.fromJson(2, {
      'stars': 5,
      'obstacles': 1,
      'slack': 2,
      'blockers': {'p': 6, 'b': 1},
      'hunter': 'n',
      'prey': 'b',
      'trapped': true,
      'limit': 10,
      'unlock': 'queen',
    });
    expect(level.index, 2);
    expect(level.stars, 5);
    expect(level.blockers, {PieceType.pawn: 6, PieceType.bishop: 1});
    expect(level.hunter, PieceType.knight);
    expect(level.prey, PieceType.bishop);
    expect(level.trapped, isTrue);
    expect(level.limit, 10);
    expect(level.unlockedByLesson, 'queen');
  });

  group('hunt boards', () {
    for (final level in huntLevels) {
      test('level ${level.index}: valid for thirty seeds', () {
        for (var seed = 0; seed < 30; seed++) {
          final b = generateBoard(MiniGameKind.hunt, level, Random(seed));
          final p = b.startPosition;
          final whites = p.pieces(PieceColor.white).toList();
          expect(whites.length, 1, reason: 'seed $seed ${b.fen}');
          expect(whites.single.$2.type, level.hunter);
          final hunter = b.hunterSquare(p)!;
          final prey = b.preySquare(p)!;
          expect(
            p.pieceAt(prey)!.type,
            level.prey,
            reason: 'seed $seed ${b.fen}',
          );
          expect(p.pieceAt(prey)!.color, PieceColor.black);
          final blackPawns = p
              .pieces(PieceColor.black)
              .where((e) => e.$2.type == PieceType.pawn && e.$1 != prey);
          expect(
            blackPawns.isNotEmpty,
            level.trapped,
            reason: 'seed $seed ${b.fen}',
          );
          expect(
            shortestPath(p, hunter, {prey}),
            isNotNull,
            reason: 'seed $seed ${b.fen}: prey unreachable',
          );
          for (final (s, _) in blackPawns) {
            expect(s.rank, lessThan(7), reason: 'seed $seed pawn on $s');
          }
          // Nobody can take anybody at once.
          expect(
            isSquareAttacked(p, prey, PieceColor.white),
            isFalse,
            reason: 'seed $seed ${b.fen}',
          );
          expect(
            isSquareAttacked(p, hunter, PieceColor.black),
            isFalse,
            reason: 'seed $seed ${b.fen}',
          );
          expect(b.moveLimit, level.limit);
          expect(
            b.par,
            inInclusiveRange(2, level.limit! - 2),
            reason: 'seed $seed ${b.fen}',
          );
          expect(b.unlockedByLesson, level.unlockedByLesson);
          // The hint policy catches the prey within par.
          var pos = p;
          var at = hunter;
          var target = prey;
          var moves = 0;
          final random = Random(1);
          while (moves < b.moveLimit!) {
            final step = huntStep(pos, at, target)!;
            moves++;
            pos = pos.play(step);
            at = step.to;
            if (at == target) {
              break;
            }
            final flee = fleeMove(
              pos,
              PieceColor.black,
              at,
              random,
              prey: target,
            );
            if (flee == null) {
              pos = pos.pass();
            } else {
              pos = pos.play(flee);
              target = flee.to;
            }
          }
          expect(at, target, reason: 'seed $seed ${b.fen}: not caught');
          expect(
            moves,
            lessThanOrEqualTo(b.par!),
            reason: 'seed $seed ${b.fen}',
          );
        }
      });
    }
  });

  test('a board unlike the previous one is drawn even from the same seed', () {
    final level = huntLevels[4];
    final a = generateBoard(MiniGameKind.hunt, level, Random(1));
    final b = generateBoard(MiniGameKind.hunt, level, Random(1), avoid: a);
    expect(a.fen, isNot(b.fen));
    final c = generateBoard(
      MiniGameKind.rookRoads,
      collectLevels[0],
      Random(2),
    );
    final d = generateBoard(
      MiniGameKind.rookRoads,
      collectLevels[0],
      Random(2),
      avoid: c,
    );
    expect(
      d.fen == c.fen &&
          d.stars.containsAll(c.stars) &&
          c.stars.containsAll(d.stars),
      isFalse,
    );
  });

  test('every hunt level generates quickly', () {
    final watch = Stopwatch()..start();
    for (final level in huntLevels) {
      for (var s = 0; s < 20; s++) {
        generateBoard(MiniGameKind.hunt, level, Random(s));
      }
    }
    expect(watch.elapsedMilliseconds, lessThan(8000));
  });

  test('trapped hunt levels generate quickly', () {
    final watch = Stopwatch()..start();
    for (var s = 0; s < 30; s++) {
      generateBoard(MiniGameKind.hunt, huntLevels[1], Random(s));
    }
    expect(watch.elapsedMilliseconds, lessThan(3000));
  });
}
