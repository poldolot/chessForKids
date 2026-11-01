import 'package:chess_for_kids/ai/ai.dart';
import 'package:chess_for_kids/core/speaker.dart';
import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/features/parent/parent_zone_screen.dart';
import 'package:chess_for_kids/features/profiles/profile_wizard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;
  late Profile zosia;
  setUp(() async {
    app = await TestApp.create();
    zosia = await app.state.createProfile(
      name: 'Zosia',
      theme: TeacherTheme.animals,
      avatarIndex: 1,
    );
  });

  Future<void> pumpZone(WidgetTester tester) async {
    await tester.pumpWidget(
      app.wrap(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                key: const Key('open-zone'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ParentZoneScreen(),
                  ),
                ),
                child: const Text('zone'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open-zone')));
    await tester.pumpAndSettle();
  }

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isEmpty ||
        !const Rect.fromLTWH(
          0,
          0,
          800,
          600,
        ).contains(tester.getCenter(finder))) {
      await tester.scrollUntilVisible(
        finder,
        120,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));
    if (find.byType(ListView).evaluate().isNotEmpty) {
      await reveal(tester, finder);
    }
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('changing language updates settings', (tester) async {
    await pumpZone(tester);
    await tapKey(tester, 'lang-en');
    expect(app.state.settings.languageCode, 'en');
    await tapKey(tester, 'lang-system');
    expect(app.state.settings.languageCode, isNull);
  });

  testWidgets(
    'voice toggle and rate are persisted and applied to the speaker',
    (tester) async {
      await pumpZone(tester);
      await tapKey(tester, 'voice-switch');
      expect(app.state.settings.voiceEnabled, isFalse);
      expect(app.speaker.enabled, isFalse);
      await tapKey(tester, 'voice-switch');
      await tapKey(tester, 'rate-slow');
      expect(app.state.settings.speechRate, SpeechRate.slow);
      expect(app.speaker.rate, SpeechRate.slow);
      await tapKey(tester, 'test-voice');
      expect(app.speaker.spoken.last.$1, 'parent.testVoice');
    },
  );

  testWidgets('choosing palettes persists their ids', (tester) async {
    await pumpZone(tester);
    await tapKey(tester, 'board-palette-wood');
    expect(app.state.settings.boardPaletteId, 'wood');
    await tapKey(tester, 'ui-palette-meadow');
    expect(app.state.settings.uiPaletteId, 'meadow');
  });

  testWidgets('child color and unlock all mini-games toggles', (tester) async {
    await pumpZone(tester);
    await tapKey(tester, 'child-random');
    expect(app.state.settings.childColor, ChildColor.random);
    await tapKey(tester, 'level-veryEasy');
    expect(app.state.currentProfile!.matchLevel, MatchLevel.veryEasy);
    await tapKey(tester, 'level-normal');
    expect(app.state.currentProfile!.matchLevel, MatchLevel.normal);
    await tapKey(tester, 'unlock-minigames');
    expect(app.state.currentProfile!.unlockAllMiniGames, isTrue);
  });

  testWidgets('reset progress clears stars after confirmation', (tester) async {
    await app.state.addStars('lesson:pawn', 3);
    await pumpZone(tester);
    await tapKey(tester, 'profile-reset-${zosia.id}');
    await tapKey(tester, 'cancel');
    expect(app.state.currentProfile!.stars, isNotEmpty);
    await tapKey(tester, 'profile-reset-${zosia.id}');
    await tapKey(tester, 'confirm');
    expect(app.state.currentProfile!.stars, isEmpty);
  });

  testWidgets('edit opens the wizard for that profile', (tester) async {
    await pumpZone(tester);
    await tapKey(tester, 'profile-edit-${zosia.id}');
    expect(find.byType(ProfileWizardScreen), findsOneWidget);
  });

  testWidgets('deleting the current profile leaves the zone', (tester) async {
    await pumpZone(tester);
    await tapKey(tester, 'profile-delete-${zosia.id}');
    await tapKey(tester, 'confirm');
    expect(app.state.currentProfile, isNull);
    expect(app.state.profiles, isEmpty);
    expect(find.byType(ParentZoneScreen), findsNothing);
  });

  testWidgets('deleting another profile keeps the zone open', (tester) async {
    final other = await app.state.createProfile(
      name: 'B',
      theme: TeacherTheme.ufo,
      avatarIndex: 2,
    );
    await app.state.selectProfile(zosia.id);
    await pumpZone(tester);
    await tapKey(tester, 'profile-delete-${other.id}');
    await tapKey(tester, 'confirm');
    expect(app.state.profiles.map((p) => p.id), [zosia.id]);
    expect(find.byType(ParentZoneScreen), findsOneWidget);
  });

  testWidgets('palette swatches paint their colors at full height', (
    tester,
  ) async {
    await pumpZone(tester);
    final swatch = find.byKey(const Key('board-palette-classic'));
    await reveal(tester, swatch);
    final boxes = find.descendant(
      of: swatch,
      matching: find.byType(ColoredBox),
    );
    expect(boxes, findsNWidgets(2));
    for (final box in boxes.evaluate()) {
      expect(tester.getSize(find.byWidget(box.widget)).height, greaterThan(40));
    }
  });

  testWidgets('about section shows the offline notice', (tester) async {
    await pumpZone(tester);
    await reveal(tester, find.byKey(const Key('offline-notice')));
    expect(find.byKey(const Key('offline-notice')), findsOneWidget);
  });
}
