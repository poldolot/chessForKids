import 'dart:math';

import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/games/board_generator.dart';
import 'package:chess_for_kids/features/games/game_catalog.dart';
import 'package:chess_for_kids/features/games/game_model.dart';
import 'package:chess_for_kids/features/games/game_play_screen.dart';
import 'package:chess_for_kids/features/games/game_progress.dart';
import 'package:chess_for_kids/features/games/game_result_view.dart';
import 'package:chess_for_kids/features/games/mini_game_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixed_boards.dart';
import '../../support/test_app.dart';

void main() {
  late TestApp app;
  late MiniGame rook;

  setUp(() async {
    app = await TestApp.create();
    rook = gameById(app.games, 'rookRoads');
    await app.state.createProfile(
      name: 'Zosia',
      theme: TeacherTheme.ufo,
      avatarIndex: 1,
    );
    await app.state.updateProfile(
      app.state.currentProfile!.copyWith(unlockAllMiniGames: true),
    );
  });

  MiniGameSession finished(MiniGame game, int board, List<String> ucis) {
    final session = MiniGameSession(
      game,
      fixedBoard(game.id, board),
      random: Random(1),
    );
    for (final u in ucis) {
      session.playChild(Move.parseUci(u));
    }
    expect(session.outcome, isNot(SessionOutcome.playing));
    return session;
  }

  const tour = ['a1a8', 'a8h8', 'h8h1', 'h1d1', 'd1d4'];
  const slowTour = ['a1a2', 'a2a1', 'a1a8', 'a8h8', 'h8h1', 'h1d1', 'd1d4'];

  Future<void> pumpResult(
    WidgetTester tester,
    MiniGameSession session, {
    VoidCallback? onAgain,
    ValueChanged<GameLevel>? onNext,
  }) async {
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: GameResultView(
            game: session.game,
            board: session.board,
            session: session,
            onAgain: onAgain ?? () {},
            onNext: onNext ?? (_) {},
            onBack: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('records stars and the win once; a worse replay keeps the best', (
    tester,
  ) async {
    final key = gameStarsKey(rook, 0);
    await pumpResult(tester, finished(rook, 0, tour));
    expect(app.state.currentProfile!.stars[key], 3);
    expect(app.state.currentProfile!.miniGameWins, 1);
    expect(app.speaker.spoken.last.$1, 'games.common.won');
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await pumpResult(tester, finished(rook, 0, slowTour));
    expect(app.state.currentProfile!.stars[key], 3);
    expect(app.state.currentProfile!.miniGameWins, 2);
    await tester.pumpAndSettle();
  });

  testWidgets('stars appear one by one', (tester) async {
    await pumpResult(tester, finished(rook, 0, slowTour));
    expect(find.byKey(const Key('result-star-0')), findsNothing);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byKey(const Key('result-star-0')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('result-star-1')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('result-star-2')), findsNothing);
  });

  testWidgets('the tenth win awards the hunter badge after a moment', (
    tester,
  ) async {
    await app.state.updateProfile(
      app.state.currentProfile!.copyWith(miniGameWins: 9),
    );
    await pumpResult(tester, finished(rook, 0, tour));
    expect(app.state.currentProfile!.badges, contains('hunter'));
    expect(find.byKey(const Key('result-badge')), findsNothing);
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byKey(const Key('result-badge')), findsOneWidget);
    expect(app.speaker.spoken.last.$1, 'games.common.badgeHunter');
    expect(app.speaker.nonInterrupting, contains('games.common.badgeHunter'));
    await tester.pumpAndSettle();
  });

  testWidgets('fifty stars award the collector badge', (tester) async {
    await app.state.updateProfile(
      app.state.currentProfile!.copyWith(stars: {'lesson:pawn': 48}),
    );
    await pumpResult(tester, finished(rook, 0, tour));
    expect(app.state.currentProfile!.badges, contains('collector'));
    await tester.pump(const Duration(milliseconds: 900));
    expect(app.speaker.spoken.last.$1, 'games.common.badgeCollector');
    await tester.pumpAndSettle();
  });

  testWidgets(
    'next goes to the following level and is hidden on the last one',
    (tester) async {
      GameLevel? next;
      await pumpResult(
        tester,
        finished(rook, 0, tour),
        onNext: (l) => next = l,
      );
      await tester.tap(find.byKey(const Key('result-next')));
      expect(next, rook.levels[1]);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      final last = fixedBoard('rookRoads', 4);
      final session = MiniGameSession(rook, last, random: Random(1));
      while (session.outcome == SessionOutcome.playing) {
        session.playChild(session.hint()!);
      }
      await pumpResult(tester, session);
      expect(find.byKey(const Key('result-next')), findsNothing);
      expect(find.byKey(const Key('result-back')), findsOneWidget);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('next is hidden when the following level is still locked', (
    tester,
  ) async {
    final hunt = gameById(app.games, 'hunt');
    await app.state.updateProfile(
      app.state.currentProfile!.copyWith(
        unlockAllMiniGames: false,
        lessonsDone: {hunt.unlockedByLesson},
      ),
    );
    final session = MiniGameSession(
      hunt,
      fixedBoard('hunt', 1),
      random: Random(1),
    );
    while (session.outcome == SessionOutcome.playing) {
      session.playChild(session.hint()!);
      if (session.awaitingOpponent) {
        session.playOpponent();
      }
    }
    await pumpResult(tester, session);
    expect(find.byKey(const Key('result-next')), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'again starts a fresh board of the same level; each finish records',
    (tester) async {
      final game = rook;
      await tester.pumpWidget(
        app.wrap(
          GamePlayScreen(
            game: game,
            level: game.levels[0],
            board: fixedBoard('rookRoads', 0),
            random: Random(1),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      Future<void> move(String from, String to) async {
        await tester.tap(find.byKey(Key('sq-$from')));
        await tester.pump();
        await tester.tap(find.byKey(Key('sq-$to')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
      }

      for (final u in tour) {
        await move(u.substring(0, 2), u.substring(2));
      }
      await tester.pumpAndSettle();
      expect(app.state.currentProfile!.miniGameWins, 1);
      expect(app.state.currentProfile!.stars[gameStarsKey(game, 0)], 3);
      await tester.tap(find.byKey(const Key('result-again')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('game-hint')), findsOneWidget);
      // A different, generated board of level 0: three stars, not the old five.
      final fresh = generateBoard(game.kind, game.levels[0], Random(1));
      expect(fresh.stars.length, 3);
      final starKeys = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('star-'),
      );
      expect(starKeys, findsNWidgets(3));
      expect(app.state.currentProfile!.miniGameWins, 1);
      // Finish it with the hints: the second finish is recorded too.
      final session = MiniGameSession(game, fresh, random: Random(1));
      while (session.outcome == SessionOutcome.playing) {
        final m = session.hint()!;
        session.playChild(m);
        await move(m.from.name, m.to.name);
      }
      await tester.pumpAndSettle();
      expect(app.state.currentProfile!.miniGameWins, 2);
    },
  );

  testWidgets('on a narrow phone the next button spans the full width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpResult(tester, finished(rook, 0, tour));
    expect(tester.takeException(), isNull);
    // Back and again shrink to icons so the main button keeps its label.
    final next = tester.getSize(find.byKey(const Key('result-next')));
    final back = tester.getSize(find.byKey(const Key('result-back')));
    expect(next.width, greaterThan(150));
    expect(back.width, 60);
    await tester.pumpAndSettle();
  });
}
