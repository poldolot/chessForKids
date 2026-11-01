import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/features/games/game_boards_screen.dart';
import 'package:chess_for_kids/features/games/game_catalog.dart';
import 'package:chess_for_kids/features/games/game_play_screen.dart';
import 'package:chess_for_kids/features/games/games_screen.dart';
import 'package:chess_for_kids/features/learn/learn_screen.dart';
import 'package:chess_for_kids/features/learn/lesson_screen.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:chess_for_kids/features/menu/main_menu_screen.dart';
import 'package:chess_for_kids/features/parent/parent_gate_screen.dart';
import 'package:chess_for_kids/features/profiles/profile_wizard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

void main() {
  late TestApp app;

  setUp(() async {
    app = await TestApp.create();
  });

  Future<void> pumpNarrow(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app.wrap(screen));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('wizard steps fit a 360x640 phone', (tester) async {
    await pumpNarrow(tester, const ProfileWizardScreen());
    await tester.tap(find.byKey(const Key('theme-vehicles')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('main menu fits a 360x640 phone', (tester) async {
    await app.state.createProfile(
      name: 'Zosia',
      theme: TeacherTheme.animals,
      avatarIndex: 1,
    );
    await pumpNarrow(tester, const MainMenuScreen());
  });

  testWidgets('parent gate fits a 360x640 phone', (tester) async {
    await pumpNarrow(tester, const ParentGateScreen());
  });

  testWidgets('learn path and a lesson fit a 360x640 phone', (tester) async {
    await app.state.createProfile(
      name: 'Zosia',
      theme: TeacherTheme.animals,
      avatarIndex: 1,
    );
    await pumpNarrow(tester, const LearnScreen());
    await tester.pumpWidget(app.wrap(LessonScreen(lesson: lessonById('pawn'))));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('lesson-next')));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
  });

  testWidgets('games list, boards and play fit a 360x640 phone', (
    tester,
  ) async {
    await app.state.createProfile(
      name: 'Zosia',
      theme: TeacherTheme.animals,
      avatarIndex: 1,
    );
    await app.state.updateProfile(
      app.state.currentProfile!.copyWith(unlockAllMiniGames: true),
    );
    await pumpNarrow(tester, const GamesScreen());
    final rook = gameById(app.games, 'rookRoads');
    await tester.pumpWidget(app.wrap(GameBoardsScreen(game: rook)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      app.wrap(GamePlayScreen(game: rook, board: rook.boards[0])),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('game-hint')));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
  });
}
