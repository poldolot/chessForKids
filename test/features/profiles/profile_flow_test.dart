import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/features/profiles/profile_picker_screen.dart';
import 'package:chess_for_kids/features/profiles/profile_wizard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;

  setUp(() async => app = await TestApp.create());

  Future<void> pumpWizard(WidgetTester tester) async {
    await tester.pumpWidget(app.wrap(const ProfileWizardScreen()));
    await tester.pumpAndSettle();
  }

  testWidgets('wizard creates a profile with theme, avatar and name', (
    tester,
  ) async {
    await pumpWizard(tester);
    expect(app.speaker.spoken.last.$2, 'Wybierz swoich nauczycieli');
    await tester.tap(find.byKey(const Key('theme-robots')));
    await tester.pumpAndSettle();
    expect(app.speaker.spoken.last.$2, 'Wybierz swój obrazek');
    await tester.tap(find.byKey(const Key('avatar-3')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('name-field')), 'Zosia');
    await tester.tap(find.byKey(const Key('wizard-done')));
    await tester.pumpAndSettle();
    final p = app.state.currentProfile!;
    expect((p.theme, p.avatarIndex, p.name), (TeacherTheme.robots, 3, 'Zosia'));
  });

  testWidgets('name is optional and whitespace is trimmed', (tester) async {
    await pumpWizard(tester);
    await tester.tap(find.byKey(const Key('theme-ufo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('avatar-1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('name-field')), '  ');
    await tester.tap(find.byKey(const Key('wizard-done')));
    await tester.pumpAndSettle();
    expect(app.state.currentProfile!.name, '');
  });

  testWidgets('wizard in edit mode updates the existing profile', (
    tester,
  ) async {
    final existing = await app.state.createProfile(
      name: 'A',
      theme: TeacherTheme.animals,
      avatarIndex: 1,
    );
    await tester.pumpWidget(app.wrap(ProfileWizardScreen(existing: existing)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theme-vehicles')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('avatar-2')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('name-field')), 'B');
    await tester.tap(find.byKey(const Key('wizard-done')));
    await tester.pumpAndSettle();
    expect(app.state.profiles.length, 1);
    final p = app.state.profiles.single;
    expect(
      (p.id, p.theme, p.avatarIndex, p.name),
      (existing.id, TeacherTheme.vehicles, 2, 'B'),
    );
  });

  testWidgets('picker lists profiles, speaks the prompt and selects on tap', (
    tester,
  ) async {
    final a = await app.state.createProfile(
      name: 'Ala',
      theme: TeacherTheme.animals,
      avatarIndex: 1,
    );
    await app.state.createProfile(
      name: 'Bartek',
      theme: TeacherTheme.robots,
      avatarIndex: 2,
    );
    await tester.pumpWidget(app.wrap(const ProfilePickerScreen()));
    await tester.pumpAndSettle();
    expect(app.speaker.spoken.last.$2, 'Wybierz profil lub dodaj nowy.');
    expect(find.byKey(const Key('picker-queen')), findsOneWidget);
    expect(find.text('Ala'), findsOneWidget);
    expect(find.text('Bartek'), findsOneWidget);
    await tester.tap(find.byKey(Key('profile-${a.id}')));
    await tester.pumpAndSettle();
    expect(app.state.currentProfile?.id, a.id);
  });

  testWidgets('picker avatars are large and the add button opens the wizard', (
    tester,
  ) async {
    final a = await app.state.createProfile(
      name: 'Ala',
      theme: TeacherTheme.animals,
      avatarIndex: 1,
    );
    await tester.pumpWidget(app.wrap(const ProfilePickerScreen()));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(Key('profile-${a.id}'))).shortestSide,
      greaterThanOrEqualTo(96),
    );
    await tester.tap(find.byKey(const Key('add-profile')));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileWizardScreen), findsOneWidget);
  });
}
