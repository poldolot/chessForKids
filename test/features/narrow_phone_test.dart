import 'package:chess_for_kids/data/models.dart';
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
}
