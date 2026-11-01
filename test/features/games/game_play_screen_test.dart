import 'dart:math';

import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/features/board/piece_image.dart';
import 'package:chess_for_kids/features/games/game_catalog.dart';
import 'package:chess_for_kids/features/games/game_play_screen.dart';
import 'package:chess_for_kids/features/games/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;
  setUp(() async {
    app = await TestApp.create();
    await app.state.createProfile(
      name: 'Zosia',
      theme: TeacherTheme.ufo,
      avatarIndex: 1,
    );
    await app.state.updateProfile(
      app.state.currentProfile!.copyWith(unlockAllMiniGames: true),
    );
  });

  Finder sq(String name) => find.byKey(Key('sq-$name'));
  Finder pieceOn(String name) =>
      find.descendant(of: sq(name), matching: find.byType(PieceImage));

  Future<void> pumpPlay(WidgetTester tester, String gameId, int board) async {
    final game = gameById(app.games, gameId);
    await tester.pumpWidget(
      app.wrap(
        GamePlayScreen(
          game: game,
          board: game.boards[board],
          opponentDelay: const Duration(milliseconds: 300),
          random: Random(1),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> tapMove(WidgetTester tester, String from, String to) async {
    await tester.tap(sq(from));
    await tester.pump();
    await tester.tap(sq(to));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
  }

  testWidgets(
    'first launch speaks the intro once, later launches say your move',
    (tester) async {
      await pumpPlay(tester, 'rookRoads', 0);
      expect(app.speaker.spoken.last.$1, 'games.rookRoads.intro');
      expect(app.state.currentProfile!.introducedGames, contains('rookRoads'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await pumpPlay(tester, 'rookRoads', 0);
      expect(app.speaker.spoken.last.$1, 'games.common.yourMove');
      expect(
        app.speaker.spoken.where((s) => s.$1 == 'games.rookRoads.intro').length,
        1,
      );
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'collect game: progress bar grows with stars and the result appears when done',
    (tester) async {
      await pumpPlay(tester, 'rookRoads', 0);
      expect(
        tester
            .widget<ProgressBar>(find.byKey(const Key('game-progress')))
            .value,
        0,
      );
      await tapMove(tester, 'a1', 'a8');
      expect(
        tester
            .widget<ProgressBar>(find.byKey(const Key('game-progress')))
            .value,
        closeTo(0.2, 1e-9),
      );
      for (final m in [
        ('a8', 'h8'),
        ('h8', 'h1'),
        ('h1', 'd1'),
        ('d1', 'd4'),
      ]) {
        await tapMove(tester, m.$1, m.$2);
      }
      expect(find.byKey(const Key('game-result')), findsOneWidget);
      await tester.tap(sq('d4'));
      await tester.pump();
      expect(find.byKey(const Key('move-dot')), findsNothing);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'hint highlights a legal move for two seconds without interrupting',
    (tester) async {
      await pumpPlay(tester, 'rookRoads', 0);
      await tester.tap(find.byKey(const Key('game-hint')));
      await tester.pump();
      expect(find.byKey(const Key('selected-frame')), findsOneWidget);
      expect(find.byKey(const Key('move-dot')), findsOneWidget);
      expect(app.speaker.spoken.last.$1, 'games.common.hint');
      expect(app.speaker.nonInterrupting, contains('games.common.hint'));
      await tester.pump(const Duration(milliseconds: 2100));
      expect(find.byKey(const Key('selected-frame')), findsNothing);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'pawn war: the board waits for the opponent, then the reply is on the board',
    (tester) async {
      await pumpPlay(tester, 'pawnWar', 0);
      await tester.tap(sq('e2'));
      await tester.pump();
      await tester.tap(sq('e4'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(pieceOn('e4'), findsOneWidget);
      await tester.tap(sq('d2'));
      await tester.pump();
      expect(find.byKey(const Key('move-dot')), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      final blackOnSeventh = [
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'g',
        'h',
      ].where((f) => pieceOn('${f}7').evaluate().isNotEmpty).length;
      expect(blackOnSeventh, 7);
      await tester.tap(sq('d2'));
      await tester.pump();
      expect(find.byKey(const Key('move-dot')), findsWidgets);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('undo takes back the child move and the reply', (tester) async {
    await pumpPlay(tester, 'pawnWar', 0);
    await tapMove(tester, 'e2', 'e4');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.tap(find.byKey(const Key('game-undo')));
    await tester.pump();
    expect(pieceOn('e2'), findsOneWidget);
    expect(pieceOn('e4'), findsNothing);
    final blackOnSeventh = [
      'a',
      'b',
      'c',
      'd',
      'e',
      'f',
      'g',
      'h',
    ].where((f) => pieceOn('${f}7').evaluate().isNotEmpty).length;
    expect(blackOnSeventh, 8);
    await tester.pumpAndSettle();
  });

  testWidgets('limit reset speaks without interrupting and the board returns', (
    tester,
  ) async {
    await pumpPlay(tester, 'rookRoads', 0);
    for (var i = 0; i < 8; i++) {
      await tapMove(tester, i.isEven ? 'a1' : 'a2', i.isEven ? 'a2' : 'a1');
    }
    expect(app.speaker.spoken.last.$1, 'games.common.limit');
    expect(app.speaker.nonInterrupting, contains('games.common.limit'));
    expect(pieceOn('a1'), findsOneWidget);
    expect(find.byKey(const Key('star-a8')), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('leaving midway records nothing', (tester) async {
    final game = gameById(app.games, 'rookRoads');
    await tester.pumpWidget(
      app.wrap(
        Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              key: const Key('open'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => GamePlayScreen(
                    game: game,
                    board: game.boards[0],
                    random: Random(1),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
    await tapMove(tester, 'a1', 'a8');
    Navigator.of(tester.element(find.byType(GamePlayScreen))).pop();
    await tester.pumpAndSettle();
    expect(app.state.currentProfile!.stars, isEmpty);
    expect(app.state.currentProfile!.miniGameWins, 0);
  });

  testWidgets('tapping an obstacle pawn shows no targets', (tester) async {
    await pumpPlay(tester, 'rookRoads', 3);
    await tester.tap(sq('d5'));
    await tester.pump();
    expect(find.byKey(const Key('move-dot')), findsNothing);
    await tester.tap(sq('a1'));
    await tester.pump();
    expect(find.byKey(const Key('move-dot')), findsWidgets);
    await tester.pumpAndSettle();
  });
}
