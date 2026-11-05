import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/features/learn/celebrate_view.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;
  late int next;
  setUp(() async {
    app = await TestApp.create();
    next = 0;
    await app.state.createProfile(
      name: 'Zosia',
      theme: TeacherTheme.ufo,
      avatarIndex: 1,
    );
  });

  Future<void> pumpCelebrate(
    WidgetTester tester,
    String lessonId, {
    required int mistakes,
  }) async {
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: CelebrateView(
            key: UniqueKey(),
            lesson: lessonById(lessonId),
            mistakes: mistakes,
            onNext: () => next++,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('celebrate records stars, lesson done and the piece badge', (
    tester,
  ) async {
    await pumpCelebrate(tester, 'rook', mistakes: 1);
    final p = app.state.currentProfile!;
    expect(p.stars['lesson:rook'], 2);
    expect(p.lessonsDone, contains('rook'));
    expect(p.badges, contains('rook'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byKey(const Key('celebrate-star-0')), findsOneWidget);
    expect(find.byKey(const Key('celebrate-star-1')), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(const Key('celebrate-star-1')), findsOneWidget);
    expect(find.byKey(const Key('celebrate-star-2')), findsNothing);
    expect(
      app.speaker.spoken.map((s) => s.$1),
      containsAllInOrder(['learn.common.wellDone', 'learn.common.badge']),
    );
    final badgeLine = app.speaker.spoken.lastWhere(
      (s) => s.$1 == 'learn.common.badge',
    );
    expect(badgeLine.$2, 'Masz nową odznakę: Wieża!');
    expect(find.text('Masz nową odznakę: Wieża!'), findsOneWidget);
    expect(find.byKey(const Key('celebrate-badge')), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('a worse repeat keeps the best stars and the badge', (
    tester,
  ) async {
    await pumpCelebrate(tester, 'rook', mistakes: 0);
    await tester.pumpAndSettle();
    expect(app.state.currentProfile!.stars['lesson:rook'], 3);
    await pumpCelebrate(tester, 'rook', mistakes: 5);
    await tester.pumpAndSettle();
    final p = app.state.currentProfile!;
    expect(p.stars['lesson:rook'], 3);
    expect(p.badges, contains('rook'));
    expect(p.badges.length, 1);
  });

  testWidgets('chessPlayer badge only after every rule lesson', (tester) async {
    final seven = kRuleLessonIds.take(7).toSet();
    await app.state.updateProfile(
      app.state.currentProfile!.copyWith(lessonsDone: seven),
    );
    await pumpCelebrate(tester, 'check', mistakes: 0);
    await tester.pumpAndSettle();
    expect(app.state.currentProfile!.badges, isNot(contains('chessPlayer')));
    expect(find.byKey(const Key('celebrate-badge')), findsNothing);
    await pumpCelebrate(tester, 'values', mistakes: 0);
    await tester.pumpAndSettle();
    expect(app.state.currentProfile!.badges, contains('chessPlayer'));
  });

  testWidgets('next calls onNext', (tester) async {
    await pumpCelebrate(tester, 'pawn', mistakes: 3);
    await tester.pumpAndSettle();
    expect(app.state.currentProfile!.stars['lesson:pawn'], 1);
    await tester.tap(find.byKey(const Key('celebrate-next')));
    expect(next, 1);
  });
}
