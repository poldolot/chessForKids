import 'package:chess_for_kids/app/app.dart';
import 'package:chess_for_kids/core/speaker.dart';
import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/features/board/piece_image.dart';
import 'package:chess_for_kids/features/learn/learn_screen.dart';
import 'package:chess_for_kids/features/menu/main_menu_screen.dart';
import 'package:chess_for_kids/features/parent/parent_gate_screen.dart';
import 'package:chess_for_kids/features/profiles/profile_picker_screen.dart';
import 'package:chess_for_kids/features/profiles/profile_wizard_screen.dart';
import 'package:chess_for_kids/features/sandbox/sandbox_screen.dart';
import 'package:chess_for_kids/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_store.dart';

void main() {
  late MemoryStore store;
  late FakeSpeaker speaker;

  setUp(() {
    EditableText.debugDeterministicCursor = true;
    store = MemoryStore();
    speaker = FakeSpeaker();
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearLocalesTestValue();
  });

  void devicePolish(WidgetTester tester) {
    tester.binding.platformDispatcher.localesTestValue = const [
      Locale('pl', 'PL'),
    ];
  }

  Future<AppState> pumpApp(WidgetTester tester) async {
    final state = await AppState.load(store);
    await tester.pumpWidget(ChessForKidsApp(state: state, speaker: speaker));
    await tester.pumpAndSettle();
    return state;
  }

  Future<Profile> seedProfile({String? lastId}) async {
    final state = await AppState.load(store);
    final p = await state.createProfile(
      name: 'Zosia',
      theme: TeacherTheme.animals,
      avatarIndex: 1,
    );
    if (lastId == null) {
      await state.deselectProfile();
    }
    return p;
  }

  testWidgets(
    'first launch opens the wizard, creating a profile leads to the menu',
    (tester) async {
      final state = await pumpApp(tester);
      expect(find.byType(ProfileWizardScreen), findsOneWidget);
      expect(find.byKey(const Key('wizard-back')), findsNothing);
      await tester.tap(find.byKey(const Key('theme-robots')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('avatar-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('wizard-done')));
      await tester.pumpAndSettle();
      expect(state.currentProfile, isNotNull);
      expect(find.byType(MainMenuScreen), findsOneWidget);
    },
  );

  testWidgets(
    'launch with a selected profile opens the menu with its greeting in Polish by default',
    (tester) async {
      devicePolish(tester);
      await seedProfile(lastId: 'keep');
      await pumpApp(tester);
      expect(find.byType(MainMenuScreen), findsOneWidget);
      expect(speaker.spoken.last.$2, 'Cześć, Zosia! W co dziś gramy?');
      expect(speaker.language, 'pl');
    },
  );

  testWidgets('launch with profiles but none selected opens the picker', (
    tester,
  ) async {
    await seedProfile();
    final state = await pumpApp(tester);
    expect(find.byType(ProfilePickerScreen), findsOneWidget);
    expect(speaker.spoken.last.$2, 'Who is playing?');
    expect(speaker.language, 'en');
    await tester.tap(find.byKey(Key('profile-${state.profiles.single.id}')));
    await tester.pumpAndSettle();
    expect(find.byType(MainMenuScreen), findsOneWidget);
  });

  testWidgets('language setting switches the locale and the speaker language', (
    tester,
  ) async {
    devicePolish(tester);
    await seedProfile(lastId: 'keep');
    final state = await pumpApp(tester);
    await state.updateSettings(state.settings.copyWith(languageCode: 'en'));
    await tester.pumpAndSettle();
    expect(find.text('Learn'), findsOneWidget);
    expect(speaker.language, 'en');
  });

  testWidgets('play tile opens the sandbox and a move can be made', (
    tester,
  ) async {
    await seedProfile(lastId: 'keep');
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('tile-play')));
    await tester.pumpAndSettle();
    expect(find.byType(SandboxScreen), findsOneWidget);
    await tester.tap(find.byKey(const Key('sq-e2')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('sq-e4')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('sq-e4')),
        matching: find.byType(PieceImage),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('sq-e2')),
        matching: find.byType(PieceImage),
      ),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('sandbox-undo')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('sq-e2')),
        matching: find.byType(PieceImage),
      ),
      findsOneWidget,
    );
  });

  testWidgets('sandbox announces check and checkmate', (tester) async {
    devicePolish(tester);
    await seedProfile(lastId: 'keep');
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('tile-play')));
    await tester.pumpAndSettle();
    Future<void> move(String from, String to) async {
      await tester.tap(find.byKey(Key('sq-$from')));
      await tester.pump();
      await tester.tap(find.byKey(Key('sq-$to')));
      await tester.pumpAndSettle();
    }

    await move('f2', 'f3');
    await move('e7', 'e5');
    await move('g2', 'g4');
    await move('d8', 'h4');
    expect(speaker.spoken.last.$2, 'Mat! Wygrały czarne!');
    await tester.tap(find.byKey(const Key('sandbox-new')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('sq-f2')),
        matching: find.byType(PieceImage),
      ),
      findsOneWidget,
    );
  });

  testWidgets('parent lock opens the gate', (tester) async {
    await seedProfile(lastId: 'keep');
    await pumpApp(tester);
    final lock = find.byKey(const Key('parent-lock'));
    final gesture = await tester.startGesture(tester.getCenter(lock));
    await tester.pump(const Duration(milliseconds: 3200));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byType(ParentGateScreen), findsOneWidget);
  });

  testWidgets(
    'adding a profile from the picker lands in the new profile menu',
    (tester) async {
      devicePolish(tester);
      await seedProfile();
      final state = await pumpApp(tester);
      expect(find.byType(ProfilePickerScreen), findsOneWidget);
      await tester.tap(find.byKey(const Key('add-profile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('theme-ufo')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('avatar-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('wizard-done')));
      await tester.pumpAndSettle();
      expect(state.profiles.length, 2);
      expect(state.currentProfile?.theme, TeacherTheme.ufo);
      expect(find.byType(MainMenuScreen), findsOneWidget);
      expect(find.byType(ProfilePickerScreen), findsNothing);
      expect(find.byType(ProfileWizardScreen), findsNothing);
    },
  );

  testWidgets('learn tile opens the lesson path', (tester) async {
    devicePolish(tester);
    await seedProfile(lastId: 'keep');
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('tile-learn')));
    await tester.pumpAndSettle();
    expect(find.byType(LearnScreen), findsOneWidget);
    expect(find.byKey(const Key('lesson-pawn')), findsOneWidget);
  });
}
