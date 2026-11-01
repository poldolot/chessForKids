import 'package:chess_for_kids/app/constants.dart';
import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/features/menu/coming_soon_screen.dart';
import 'package:chess_for_kids/features/menu/main_menu_screen.dart';
import 'package:chess_for_kids/features/menu/menu_tile.dart';
import 'package:chess_for_kids/features/menu/parent_lock_button.dart';
import 'package:chess_for_kids/features/profiles/profile_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;

  setUp(() async {
    app = await TestApp.create();
    await app.state.createProfile(
      name: 'Zosia',
      theme: TeacherTheme.animals,
      avatarIndex: 2,
    );
  });

  Future<void> pumpMenu(
    WidgetTester tester, {
    ValueChanged<MenuSection>? onSection,
    VoidCallback? onParentZone,
  }) async {
    await tester.pumpWidget(
      app.wrap(
        MainMenuScreen(onSection: onSection, onParentZone: onParentZone),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'menu shows three tiles, avatar, star total and twelve badge slots',
    (tester) async {
      await app.state.addStars('lesson:pawn', 3);
      await pumpMenu(tester);
      expect(find.byType(MenuTile), findsNWidgets(3));
      expect(find.byKey(const Key('menu-avatar')), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.byKey(const Key('badge-pawn')), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('badge-'),
        ),
        findsNWidgets(12),
      );
    },
  );

  testWidgets('greeting uses the name when present', (tester) async {
    await pumpMenu(tester);
    expect(app.speaker.spoken.last.$2, 'Cześć, Zosia! W co dziś gramy?');
  });

  testWidgets('greeting without a name', (tester) async {
    await app.state.updateProfile(app.state.currentProfile!.copyWith(name: ''));
    await pumpMenu(tester);
    expect(app.speaker.spoken.last.$2, 'Cześć! W co dziś gramy?');
  });

  testWidgets('tiles call onSection', (tester) async {
    final opened = <MenuSection>[];
    await pumpMenu(tester, onSection: opened.add);
    await tester.tap(find.byKey(const Key('tile-learn')));
    await tester.tap(find.byKey(const Key('tile-miniGames')));
    await tester.tap(find.byKey(const Key('tile-play')));
    expect(opened, [
      MenuSection.learn,
      MenuSection.miniGames,
      MenuSection.play,
    ]);
  });

  testWidgets('without onSection a tile opens the coming soon screen', (
    tester,
  ) async {
    await pumpMenu(tester);
    await tester.tap(find.byKey(const Key('tile-learn')));
    await tester.pumpAndSettle();
    expect(find.byType(ComingSoonScreen), findsOneWidget);
    expect(app.speaker.spoken.last.$2, 'Już wkrótce!');
  });

  testWidgets('avatar opens the profile picker', (tester) async {
    await pumpMenu(tester);
    await tester.tap(find.byKey(const Key('menu-avatar')));
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePickerScreen), findsOneWidget);
  });

  testWidgets('parent lock needs a long hold', (tester) async {
    var unlocked = 0;
    await pumpMenu(tester, onParentZone: () => unlocked++);
    await tester.tap(find.byType(ParentLockButton));
    await tester.pump();
    expect(unlocked, 0);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ParentLockButton)),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(unlocked, 0);
    await tester.pump(const Duration(milliseconds: 1100));
    await gesture.up();
    await tester.pump();
    expect(unlocked, 1);
  });

  testWidgets('releasing early does not unlock', (tester) async {
    var unlocked = 0;
    await pumpMenu(tester, onParentZone: () => unlocked++);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ParentLockButton)),
    );
    await tester.pump(const Duration(seconds: 1));
    await gesture.up();
    await tester.pump(const Duration(seconds: 3));
    expect(unlocked, 0);
  });

  testWidgets('every tile and the lock meet the minimum touch target', (
    tester,
  ) async {
    await pumpMenu(tester);
    for (final tile in find.byType(MenuTile).evaluate()) {
      expect(
        tester.getSize(find.byWidget(tile.widget)).height,
        greaterThanOrEqualTo(kMinTouchTarget),
      );
    }
    expect(
      tester.getSize(find.byType(ParentLockButton)).shortestSide,
      greaterThanOrEqualTo(kMinTouchTarget),
    );
  });

  test('section stars for learn follow the lesson progress', () {
    const base = Profile(
      id: 'x',
      name: '',
      theme: TeacherTheme.ufo,
      avatarIndex: 1,
    );
    expect(sectionStars(base, MenuSection.learn), 0);
    expect(
      sectionStars(base.copyWith(stars: {'lesson:pawn': 2}), MenuSection.learn),
      1,
    );
  });

  test('section stars for mini-games use the game catalog', () {
    const base = Profile(
      id: 'x',
      name: '',
      theme: TeacherTheme.ufo,
      avatarIndex: 1,
    );
    expect(sectionStars(base, MenuSection.miniGames, games: app.games), 0);
    expect(
      sectionStars(
        base.copyWith(stars: {'game:rookRoads:0': 3}),
        MenuSection.miniGames,
        games: app.games,
      ),
      1,
    );
  });

  test('section stars for play grow with match stars', () {
    const base = Profile(
      id: 'x',
      name: '',
      theme: TeacherTheme.ufo,
      avatarIndex: 1,
    );
    expect(sectionStars(base, MenuSection.play), 0);
    expect(sectionStars(base.copyWith(matchStars: 10), MenuSection.play), 1);
    expect(sectionStars(base.copyWith(matchStars: 45), MenuSection.play), 3);
    expect(sectionStars(base, MenuSection.miniGames), 0);
  });
}
