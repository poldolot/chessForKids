import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/features/games/game_levels_screen.dart';
import 'package:chess_for_kids/features/games/game_play_screen.dart';
import 'package:chess_for_kids/features/games/games_screen.dart';
import 'package:chess_for_kids/features/games/widgets/game_card.dart';
import 'package:chess_for_kids/features/learn/lesson_screen.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:chess_for_kids/features/menu/menu_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;
  setUp(() async {
    app = await TestApp.create();
    await app.state.createProfile(
      name: 'Zosia',
      theme: TeacherTheme.robots,
      avatarIndex: 1,
    );
  });

  Finder card(String id) => find.byKey(Key('game-$id'));

  Future<void> pumpGames(WidgetTester tester) async {
    await tester.pumpWidget(app.wrap(const GamesScreen()));
    await tester.pump();
  }

  testWidgets('five cards, all locked for a fresh profile, title spoken', (
    tester,
  ) async {
    await pumpGames(tester);
    expect(find.byType(GameCard), findsNWidgets(5));
    for (final id in [
      'pawnWar',
      'rookRoads',
      'bishopTracks',
      'kingRace',
      'hunt',
    ]) {
      expect(tester.widget<GameCard>(card(id)).unlocked, isFalse, reason: id);
    }
    expect(app.speaker.spoken.last.$1, 'games.title');
    await tester.pumpAndSettle();
  });

  testWidgets(
    'the pawn lesson unlocks pawn war; the parent switch unlocks everything',
    (tester) async {
      await app.state.markLessonDone('pawn');
      await pumpGames(tester);
      expect(tester.widget<GameCard>(card('pawnWar')).unlocked, isTrue);
      expect(tester.widget<GameCard>(card('rookRoads')).unlocked, isFalse);
      await app.state.updateProfile(
        app.state.currentProfile!.copyWith(unlockAllMiniGames: true),
      );
      await tester.pump();
      expect(tester.widget<GameCard>(card('hunt')).unlocked, isTrue);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'tapping a locked game speaks without interrupting and opens its lesson',
    (tester) async {
      await pumpGames(tester);
      await tester.tap(card('rookRoads'));
      await tester.pumpAndSettle();
      final locked = app.speaker.spoken.firstWhere(
        (s) => s.$1 == 'games.common.locked',
      );
      expect(locked.$2, contains('Wieża'));
      // The locked line interrupts; the lesson's first line queues behind it
      // so a real engine speaks both in order.
      final firstLine = lessonById('rook').steps.first.lineKey;
      final keys = app.speaker.spoken.map((s) => s.$1).toList();
      expect(
        keys.indexOf('games.common.locked'),
        lessThan(keys.indexOf(firstLine)),
      );
      expect(
        app.speaker.nonInterrupting,
        isNot(contains('games.common.locked')),
      );
      expect(app.speaker.nonInterrupting, contains(firstLine));
      expect(find.byType(LessonScreen), findsOneWidget);
      expect(
        tester.widget<LessonScreen>(find.byType(LessonScreen)).lesson.id,
        'rook',
      );
    },
  );

  testWidgets(
    'an unlocked game opens its level list; pawn war goes straight to play',
    (tester) async {
      await app.state.updateProfile(
        app.state.currentProfile!.copyWith(unlockAllMiniGames: true),
      );
      await pumpGames(tester);
      await tester.tap(card('rookRoads'));
      await tester.pumpAndSettle();
      expect(find.byType(GameLevelsScreen), findsOneWidget);
      expect(app.speaker.spoken.last.$1, 'games.common.boards');
      expect(find.byKey(const Key('level-0')), findsOneWidget);
      expect(find.byKey(const Key('level-4')), findsOneWidget);
      Navigator.of(tester.element(find.byType(GameLevelsScreen))).pop();
      await tester.pumpAndSettle();
      await tester.tap(card('pawnWar'));
      await tester.pumpAndSettle();
      expect(find.byType(GamePlayScreen), findsOneWidget);
    },
  );

  testWidgets('cards show stars earned out of the maximum', (tester) async {
    await app.state.updateProfile(
      app.state.currentProfile!.copyWith(
        unlockAllMiniGames: true,
        stars: {'game:rookRoads:0': 3, 'game:rookRoads:1': 2},
      ),
    );
    await pumpGames(tester);
    final rook = tester.widget<GameCard>(card('rookRoads'));
    expect(rook.earnedStars, 5);
    expect(rook.maxStars, 15);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'hunt levels with other pieces stay locked without the queen lesson',
    (tester) async {
      await app.state.markLessonDone('knight');
      await pumpGames(tester);
      await tester.tap(card('hunt'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('level-2-locked')), findsOneWidget);
      expect(find.byKey(const Key('level-0-locked')), findsNothing);
      await tester.tap(find.byKey(const Key('level-2')));
      await tester.pumpAndSettle();
      expect(find.byType(GamePlayScreen), findsNothing);
      expect(
        app.speaker.spoken.map((s) => s.$1),
        contains('games.common.locked'),
      );
      expect(find.byType(LessonScreen), findsOneWidget);
      Navigator.of(tester.element(find.byType(LessonScreen))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('level-0')));
      await tester.pumpAndSettle();
      expect(find.byType(GamePlayScreen), findsOneWidget);
    },
  );

  testWidgets('level list shows the best stars per level', (tester) async {
    await app.state.updateProfile(
      app.state.currentProfile!.copyWith(
        unlockAllMiniGames: true,
        stars: {'game:kingRace:1': 2},
      ),
    );
    await pumpGames(tester);
    await tester.tap(card('kingRace'));
    await tester.pumpAndSettle();
    final row = tester.widget<StarRow>(
      find.descendant(
        of: find.byKey(const Key('level-1')),
        matching: find.byType(StarRow),
      ),
    );
    expect(row.stars, 2);
  });

  testWidgets(
    'finishing the lesson behind a locked game unlocks it on return',
    (tester) async {
      await pumpGames(tester);
      await tester.tap(card('rookRoads'));
      await tester.pumpAndSettle();
      expect(find.byType(LessonScreen), findsOneWidget);
      await app.state.markLessonDone('rook');
      Navigator.of(tester.element(find.byType(LessonScreen))).pop();
      await tester.pumpAndSettle();
      expect(find.byType(GamesScreen), findsOneWidget);
      expect(tester.widget<GameCard>(card('rookRoads')).unlocked, isTrue);
      await tester.tap(card('rookRoads'));
      await tester.pumpAndSettle();
      expect(find.byType(GameLevelsScreen), findsOneWidget);
    },
  );
}
