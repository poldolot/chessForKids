import 'dart:math';

import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/games/game_catalog.dart';
import 'package:chess_for_kids/features/games/game_model.dart';
import 'package:chess_for_kids/features/games/policies.dart';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// BFS distance (in moves of [piece] standing on [from]) to each square of
/// [board], a position with the moving piece removed; every other piece is a
/// fixed obstacle and [avoid] squares may not be entered.
Map<Square, int> distances(
  Position board,
  Piece piece,
  Square from, {
  Set<Square> avoid = const {},
}) {
  final dist = <Square, int>{from: 0};
  final queue = [from];
  while (queue.isNotEmpty) {
    final s = queue.removeAt(0);
    final p = board.withPiece(s, piece).copyWith(sideToMove: piece.color);
    for (final m in pseudoLegalMoves(p, from: s)) {
      if (avoid.contains(m.to) || board.pieceAt(m.to) != null) {
        continue;
      }
      if (!dist.containsKey(m.to)) {
        dist[m.to] = dist[s]! + 1;
        queue.add(m.to);
      }
    }
  }
  return dist;
}

/// Fewest moves for the piece on [from] to visit every star (all orders).
int? optimalCollect(Position position, Square from, Set<Square> stars) {
  final piece = position.pieceAt(from)!;
  final board = position.withPiece(from, null);
  int? best;
  void visit(Square at, Set<Square> left, int moves) {
    if (best != null && moves >= best!) {
      return;
    }
    if (left.isEmpty) {
      best = moves;
      return;
    }
    final d = distances(board, piece, at);
    for (final star in left) {
      final steps = d[star];
      if (steps != null) {
        visit(star, {...left}..remove(star), moves + steps);
      }
    }
  }

  visit(from, stars, 0);
  return best;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MiniGame> games;
  setUpAll(() async => games = await loadMiniGames(rootBundle));

  group('collect games', () {
    for (final id in ['rookRoads', 'bishopTracks']) {
      test(
        '$id boards: par equals the optimal number of moves and every star is reachable',
        () {
          for (final b in gameById(games, id).boards) {
            final position = b.startPosition;
            final from = position
                .pieces(PieceColor.white)
                .firstWhere((e) => e.$2.type != PieceType.pawn)
                .$1;
            final d = distances(
              position.withPiece(from, null),
              position.pieceAt(from)!,
              from,
            );
            for (final s in b.stars) {
              expect(
                d.containsKey(s),
                isTrue,
                reason: '$id ${b.index}: star $s unreachable',
              );
            }
            final optimum = optimalCollect(position, from, b.stars);
            expect(
              optimum,
              b.par,
              reason:
                  '$id board ${b.index}: optimum is $optimum, par is ${b.par}',
            );
            expect(b.stars.length, 5, reason: '$id ${b.index}');
          }
        },
      );
    }
  });

  test(
    'king race boards: par equals the shortest safe path to the last rank',
    () {
      for (final b in gameById(games, 'kingRace').boards) {
        final position = b.startPosition;
        final king = position.kingSquare(PieceColor.white)!;
        final attacked = {
          for (final s in Square.all)
            if (isSquareAttacked(position, s, PieceColor.black)) s,
        };
        final d = distances(
          position.withPiece(king, null),
          const Piece(PieceColor.white, PieceType.king),
          king,
          avoid: attacked,
        );
        final toLastRank = [
          for (final e in d.entries)
            if (e.key.rank == 7) e.value,
        ];
        expect(
          toLastRank,
          isNotEmpty,
          reason: 'kingRace ${b.index}: no safe path',
        );
        final optimum = toLastRank.reduce((a, c) => a < c ? a : c);
        expect(
          optimum,
          b.par,
          reason:
              'kingRace board ${b.index}: optimum is $optimum, par is ${b.par}',
        );
        expect(
          attacked.contains(king),
          isFalse,
          reason: 'kingRace ${b.index}: king starts in check',
        );
      }
    },
  );

  test('pawn war board has eight pawns on each side and nothing else', () {
    final position = gameById(games, 'pawnWar').boards.single.startPosition;
    for (final color in PieceColor.values) {
      final pieces = position.pieces(color).map((e) => e.$2.type).toList();
      expect(pieces.length, 8);
      expect(pieces.every((t) => t == PieceType.pawn), isTrue);
    }
  });

  test('hunt boards have one white hunter and one black prey', () {
    for (final b in gameById(games, 'hunt').boards) {
      final position = b.startPosition;
      final white = position
          .pieces(PieceColor.white)
          .where((e) => e.$2.type != PieceType.pawn);
      expect(white.length, 1, reason: 'hunt ${b.index}');
      final black = position
          .pieces(PieceColor.black)
          .where(
            (e) => e.$2.type != PieceType.pawn || b.index < 2 || b.index == 4,
          );
      expect(black, isNotEmpty, reason: 'hunt ${b.index}');
      expect(b.moveLimit, isNotNull);
      expect(b.par, isNotNull);
    }
  });

  test('hunt boards: the hint policy catches the fleeing prey within par', () {
    for (final b in gameById(games, 'hunt').boards) {
      var p = b.startPosition;
      var hunter = p
          .pieces(PieceColor.white)
          .firstWhere((e) => e.$2.type != PieceType.pawn)
          .$1;
      var prey = p.pieces(PieceColor.black).first.$1;
      var moves = 0;
      final random = Random(1);
      while (moves < b.moveLimit!) {
        final step = huntStep(p, hunter, prey)!;
        moves++;
        p = p.play(step);
        hunter = step.to;
        if (hunter == prey) {
          break;
        }
        final flee = fleeMove(p, PieceColor.black, hunter, random, prey: prey);
        if (flee == null) {
          p = p.pass();
        } else {
          p = p.play(flee);
          prey = flee.to;
        }
      }
      expect(
        hunter,
        prey,
        reason: 'hunt ${b.index}: not caught within ${b.moveLimit}',
      );
      expect(
        moves,
        lessThanOrEqualTo(b.par!),
        reason: 'hunt board ${b.index}: caught in $moves, par is ${b.par}',
      );
    }
  });

  test('collect boards: following the hint collects every star within par', () {
    for (final id in ['rookRoads', 'bishopTracks']) {
      for (final b in gameById(games, id).boards) {
        var p = b.startPosition;
        var piece = p
            .pieces(PieceColor.white)
            .firstWhere((e) => e.$2.type != PieceType.pawn)
            .$1;
        final left = {...b.stars};
        var moves = 0;
        while (left.isNotEmpty && moves <= b.par!) {
          final step = nearestStarStep(p, piece, left)!;
          p = p.play(step).pass();
          piece = step.to;
          left.remove(step.to);
          moves++;
        }
        expect(
          left,
          isEmpty,
          reason: '$id ${b.index}: hint path did not finish within par',
        );
        expect(
          moves,
          b.par,
          reason: '$id ${b.index}: hint used $moves moves, par ${b.par}',
        );
      }
    }
  });

  test(
    'king race boards: following the hint reaches the last rank within par',
    () {
      for (final b in gameById(games, 'kingRace').boards) {
        var p = b.startPosition;
        var moves = 0;
        while (p.kingSquare(PieceColor.white)!.rank != 7 && moves <= b.par!) {
          final step = kingRaceStep(p, PieceColor.white)!;
          p = p.play(step).pass();
          moves++;
        }
        expect(
          p.kingSquare(PieceColor.white)!.rank,
          7,
          reason: 'kingRace ${b.index}',
        );
        expect(
          moves,
          b.par,
          reason: 'kingRace ${b.index}: hint used $moves moves, par ${b.par}',
        );
      }
    },
  );
}
