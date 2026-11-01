import 'dart:math';

import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/games/game_catalog.dart';
import 'package:chess_for_kids/features/games/game_model.dart';
import 'package:chess_for_kids/features/games/game_play_screen.dart';
import 'package:chess_for_kids/features/games/game_progress.dart';
import 'package:chess_for_kids/features/games/game_result_view.dart';
import 'package:chess_for_kids/features/games/mini_game_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
      game.boards[board],
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
    ValueChanged<GameBoard>? onNext,
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
    final key = gameStarsKey(rook, rook.boards[0]);
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
    'next goes to the following board and is hidden on the last one',
    (tester) async {
      GameBoard? next;
      await pumpResult(
        tester,
        finished(rook, 0, tour),
        onNext: (b) => next = b,
      );
      await tester.tap(find.byKey(const Key('result-next')));
      expect(next, rook.boards[1]);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      final last = rook.boards.last;
      final session = MiniGameSession(rook, last, random: Random(1));
      final solution = <String>[];
      while (session.outcome == SessionOutcome.playing) {
        final m = session.hint()!;
        solution.add(m.uci);
        session.playChild(m);
      }
      await pumpResult(tester, session);
      expect(find.byKey(const Key('result-next')), findsNothing);
      expect(find.byKey(const Key('result-back')), findsOneWidget);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('next is hidden when the following board is still locked', (
    tester,
  ) async {
    final hunt = gameById(app.games, 'hunt');
    await app.state.updateProfile(
      app.state.currentProfile!.copyWith(
        unlockAllMiniGames: false,
        lessonsDone: {hunt.unlockedByLesson},
      ),
    );
    final session = MiniGameSession(hunt, hunt.boards[1], random: Random(1));
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

  testWidgets('again restarts the same board without a new record', (
    tester,
  ) async {
    final game = rook;
    await tester.pumpWidget(
      app.wrap(
        GamePlayScreen(game: game, board: game.boards[0], random: Random(1)),
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
    await tester.tap(find.byKey(const Key('result-again')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('game-hint')), findsOneWidget);
    expect(find.byKey(const Key('star-a8')), findsOneWidget);
    await move('a1', 'a2');
    await tester.pumpAndSettle();
    expect(app.state.currentProfile!.miniGameWins, 1);
    for (final u in ['a2a8', 'a8h8', 'h8h1', 'h1d1', 'd1d4']) {
      await move(u.substring(0, 2), u.substring(2));
    }
    await tester.pumpAndSettle();
    expect(app.state.currentProfile!.miniGameWins, 2);
    expect(
      app.state.currentProfile!.stars[gameStarsKey(game, game.boards[0])],
      3,
    );
  });

  testWidgets('on a narrow phone the next button spans the full width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpResult(tester, finished(rook, 0, tour));
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(const Key('result-next'))).width,
      greaterThan(300),
    );
    await tester.pumpAndSettle();
  });
}
