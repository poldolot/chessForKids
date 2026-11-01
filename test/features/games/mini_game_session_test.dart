import 'dart:math';

import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/games/board_generator.dart';
import 'package:chess_for_kids/features/games/game_catalog.dart';
import 'package:chess_for_kids/features/games/game_model.dart';
import 'package:chess_for_kids/features/games/mini_game_session.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixed_boards.dart';

Square sq(String s) => Square.parse(s);
Move uci(String s) => Move.parseUci(s);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<MiniGame> games;
  setUpAll(() async => games = await loadMiniGames(rootBundle));

  MiniGameSession session(String id, int board, {GameBoard? custom}) {
    final game = gameById(games, id);
    return MiniGameSession(
      game,
      custom ?? fixedBoard(id, board),
      random: Random(1),
    );
  }

  test('collect game: stars, progress, par-based stars and limit reset', () {
    final s = session(
      'rookRoads',
      0,
    ); // a1; stars a8 h8 h1 d1 d4, par 5, limit 8
    expect(s.progress, 0);
    expect(s.playChild(uci('a1a8')), SessionEvent.star);
    expect(s.starsLeft.length, 4);
    expect(s.progress, closeTo(0.2, 1e-9));
    expect(s.position.sideToMove, PieceColor.white);
    expect(s.playChild(uci('a8h8')), SessionEvent.star);
    expect(s.playChild(uci('h8h1')), SessionEvent.star);
    expect(s.playChild(uci('h1d1')), SessionEvent.star);
    expect(s.playChild(uci('d1d4')), SessionEvent.won);
    expect(s.outcome, SessionOutcome.won);
    expect(s.movesMade, 5);
    expect(s.stars, 3);
    expect(() => s.playChild(uci('d4d5')), throwsArgumentError);
  });

  test('collect game: two extra moves give two stars, more give one', () {
    final s = session('rookRoads', 0);
    for (final m in ['a1a2', 'a2a1', 'a1a8', 'a8h8', 'h8h1', 'h1d1', 'd1d4']) {
      s.playChild(uci(m));
    }
    expect(s.outcome, SessionOutcome.won);
    expect(s.stars, 2);
  });

  test(
    'collect game: running out of moves resets the board and counts a mistake',
    () {
      final s = session('rookRoads', 0);
      SessionEvent? last;
      for (var i = 0; i < 8; i++) {
        last = s.playChild(uci(i.isEven ? 'a1a2' : 'a2a1'));
      }
      expect(last, SessionEvent.limitReset);
      expect(s.movesMade, 0);
      expect(s.starsLeft.length, 5);
      expect(s.mistakes, 1);
      expect(s.outcome, SessionOutcome.playing);
    },
  );

  test('king race: danger squares, won on the last rank, stars by par', () {
    final s = session('kingRace', 0);
    expect(s.danger, contains(sq('e3')));
    expect(s.danger, isNot(contains(sq('d3'))));
    expect(s.allows(uci('e1e2')), isTrue);
    for (final m in ['e1e2', 'e2d3', 'd3e4', 'e4e5', 'e5d6', 'd6d7']) {
      expect(s.playChild(uci(m)), SessionEvent.moved);
    }
    expect(s.progress, closeTo(6 / 7, 1e-9));
    expect(s.playChild(uci('d7d8')), SessionEvent.won);
    expect(s.stars, 3);
  });

  test(
    'pawn war: child promotion wins at once and only the queen is offered',
    () {
      final board = GameBoard(
        index: 0,
        fen: '8/4P3/8/8/8/8/8/8 w - - 0 1',
        rules: const GameRules(enPassant: false, castling: false),
      );
      final s = session('pawnWar', 0, custom: board);
      expect(s.allows(uci('e7e8n')), isFalse);
      expect(s.allows(uci('e7e8q')), isTrue);
      expect(s.playChild(uci('e7e8q')), SessionEvent.won);
      expect(s.awaitingOpponent, isFalse);
      expect(s.stars, 3);
    },
  );

  test('pawn war: opponent replies, lost pawns cost a star, a black pawn on rank 1 loses', () {
    final s = session('pawnWar', 0);
    expect(s.playChild(uci('e2e4')), SessionEvent.moved);
    expect(s.awaitingOpponent, isTrue);
    expect(() => s.playChild(uci('d2d4')), throwsArgumentError);
    final reply = s.playOpponent();
    expect(reply, isNotNull);
    expect(s.awaitingOpponent, isFalse);
    expect(s.position.sideToMove, PieceColor.white);
    expect(s.progress, closeTo(3 / 7, 1e-9));
    final lossBoard = GameBoard(
      index: 0,
      fen: '8/8/8/8/8/8/p6P/8 w - - 0 1',
      rules: const GameRules(enPassant: false, castling: false),
    );
    final t = session('pawnWar', 0, custom: lossBoard);
    t.playChild(uci('h2h3'));
    t.playOpponent();
    expect(t.outcome, SessionOutcome.lost);
    expect(t.stars, 1);
  });

  test('pawn war: a capture by the opponent marks lostPawn and a win then gives two stars', () {
    final board = GameBoard(
      index: 0,
      fen: '8/8/8/8/3p4/8/2P1P3/8 w - - 0 1',
      rules: const GameRules(enPassant: false, castling: false),
    );
    final s = session('pawnWar', 0, custom: board);
    s.playChild(uci('c2c3'));
    s.playOpponent(); // d4xc3 is the only capture and the policy prefers captures
    expect(s.lostPawn, isTrue);
    s.playChild(uci('e2e4'));
    s.playOpponent();
    while (s.outcome == SessionOutcome.playing) {
      final h = s.hint()!;
      s.playChild(h);
      if (s.awaitingOpponent) {
        s.playOpponent();
      }
    }
    if (s.outcome == SessionOutcome.won) {
      expect(s.stars, 2);
    }
  });

  test('collect games move only the collector, never an obstacle pawn', () {
    final rook = session('rookRoads', 3); // Ra1, pawn d5, star d8
    expect(rook.allows(uci('d5d6')), isFalse);
    expect(rook.allows(uci('a1a8')), isTrue);
    expect(rook.hint(), isNotNull);
    final bishop = session('bishopTracks', 2);
    final pawn = bishop.position
        .pieces(PieceColor.white)
        .firstWhere((e) => e.$2.type == PieceType.pawn)
        .$1;
    expect(bishop.allows(Move(pawn, pawn.offset(0, 1)!)), isFalse);
  });

  test('pawn war: when black has no move after the child moves, the child wins immediately', () {
    final board = GameBoard(
      index: 0,
      fen: '8/8/8/8/8/p7/P7/8 w - - 0 1',
      rules: const GameRules(enPassant: false, castling: false),
    );
    // white a2 blocked by black a3; black a3 blocked by white a2: nobody can move → the child has no move either
    final s = session('pawnWar', 0, custom: board);
    expect(legalMoves(s.position), isEmpty);
    expect(s.outcome, SessionOutcome.lost);
    final board2 = GameBoard(
      index: 0,
      fen: '8/8/8/8/8/8/p7/1P6 w - - 0 1',
      rules: const GameRules(enPassant: false, castling: false),
    );
    final t = session('pawnWar', 0, custom: board2);
    expect(
      t.playChild(uci('b1a2')),
      SessionEvent.won,
    ); // captures the last black pawn: black has no move
    expect(t.awaitingOpponent, isFalse);
  });

  test(
    'hunt: only the hunter moves, prey flees, capture wins, limit resets',
    () {
      final s = session('hunt', 0); // Nb1 vs pawn d6, limit 8
      expect(s.allows(uci('b1c3')), isTrue);
      expect(s.playChild(uci('b1c3')), SessionEvent.moved);
      expect(s.awaitingOpponent, isTrue);
      final flee = s.playOpponent();
      expect(flee, isNotNull);
      expect(s.progress, greaterThan(0));
      expect(s.playChild(uci('c3${flee!.to.name}')), SessionEvent.won);
      expect(s.stars, 3);
      final t = session('hunt', 2); // trapped bishop, limit 6
      SessionEvent? last;
      for (var i = 0; i < 6; i++) {
        last = t.playChild(uci(i.isEven ? 'a1a2' : 'a2a1'));
        if (t.awaitingOpponent) {
          t.playOpponent();
        }
      }
      expect(last, SessionEvent.limitReset);
      expect(t.movesMade, 0);
      expect(t.position.fen, t.board.fen);
    },
  );

  test('undo restores a child move and the opponent reply, stars and counters; undo at start is a no-op', () {
    final s = session('rookRoads', 0);
    expect(s.undo(), isFalse);
    s.playChild(uci('a1a8'));
    expect(s.undo(), isTrue);
    expect(s.position.fen, s.board.fen);
    expect(s.starsLeft.length, 5);
    expect(s.movesMade, 0);
    final p = session('pawnWar', 0);
    p.playChild(uci('e2e4'));
    p.playOpponent();
    expect(p.undo(), isTrue);
    expect(p.position.fen, p.board.fen);
    expect(p.awaitingOpponent, isFalse);
    expect(p.movesMade, 0);
  });

  test('hint is always a legal allowed move and for collect games finishes within par', () {
    for (final id in ['rookRoads', 'bishopTracks', 'kingRace', 'hunt']) {
      final game = gameById(games, id);
      for (final level in game.levels) {
        final b = generateBoard(game.kind, level, Random(level.index + 1));
        final s = MiniGameSession(game, b, random: Random(1));
        var guard = 0;
        while (s.outcome == SessionOutcome.playing && guard++ < 40) {
          final h = s.hint();
          expect(h, isNotNull, reason: '$id ${b.index}');
          expect(s.allows(h!), isTrue);
          expect(
            legalMoves(s.position, from: h.from, rules: b.rules),
            contains(h),
          );
          s.playChild(h);
          if (s.awaitingOpponent) {
            s.playOpponent();
          }
        }
        expect(s.outcome, SessionOutcome.won, reason: '$id ${b.index}');
        if (id != 'hunt') {
          expect(s.movesMade, b.par, reason: '$id ${b.index}');
        } else {
          expect(
            s.movesMade,
            lessThanOrEqualTo(b.par!),
            reason: '$id ${b.index}',
          );
        }
        expect(s.stars, 3, reason: '$id ${b.index}');
      }
    }
  });

  test('restart clears everything and onRejected counts a mistake', () {
    final s = session('rookRoads', 0);
    s.playChild(uci('a1a8'));
    s.onRejected();
    expect(s.mistakes, 1);
    s.restart();
    expect(s.position.fen, s.board.fen);
    expect(s.movesMade, 0);
    expect(s.mistakes, 0);
    expect(s.starsLeft.length, 5);
    expect(s.outcome, SessionOutcome.playing);
  });
}
