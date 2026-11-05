import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/learn/learn_screen.dart';
import 'package:chess_for_kids/features/learn/lesson_model.dart';
import 'package:chess_for_kids/features/learn/lesson_screen.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:chess_for_kids/features/learn/widgets/lesson_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;
  setUp(() async {
    app = await TestApp.create();
    await app.state.createProfile(
      name: 'Zosia',
      theme: TeacherTheme.vehicles,
      avatarIndex: 1,
    );
  });

  Finder node(String id) => find.byKey(Key('lesson-$id'));
  Finder sq(String name) => find.byKey(Key('sq-$name'));

  Future<void> pumpLearn(WidgetTester tester) async {
    await tester.pumpWidget(app.wrap(const LearnScreen()));
    await tester.pump();
  }

  Future<void> tapMove(WidgetTester tester, Move move) async {
    await tester.tap(sq(move.from.name));
    await tester.pump();
    await tester.tap(sq(move.to.name));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
  }

  testWidgets(
    'path lists 14 lessons, only the first unlocked for a fresh profile',
    (tester) async {
      await pumpLearn(tester);
      expect(find.byType(LessonNode), findsWidgets);
      await tester.scrollUntilVisible(
        node('values'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(node('values'), findsOneWidget);
      expect(tester.widget<LessonNode>(node('values')).unlocked, isFalse);
      await tester.scrollUntilVisible(
        node('pawn'),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.widget<LessonNode>(node('pawn')).unlocked, isTrue);
      expect(tester.widget<LessonNode>(node('pawn')).isNext, isTrue);
      expect(tester.widget<LessonNode>(node('rook')).unlocked, isFalse);
      expect(app.speaker.spoken.last.$1, 'learn.pawn.title');
      await tester.pumpAndSettle();
    },
  );

  testWidgets('tapping a locked lesson speaks and does not navigate', (
    tester,
  ) async {
    await pumpLearn(tester);
    await tester.tap(node('rook'));
    await tester.pump();
    expect(app.speaker.spoken.last.$1, 'learn.common.locked');
    expect(find.byType(LessonScreen), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'finishing a lesson returns to the path with stars and unlocks the next',
    (tester) async {
      await pumpLearn(tester);
      await tester.tap(node('pawn'));
      await tester.pumpAndSettle();
      expect(find.byType(LessonScreen), findsOneWidget);
      await tester.tap(find.byKey(const Key('lesson-next')));
      await tester.pump();
      for (final step in lessonById('pawn').steps.whereType<BoardTaskStep>()) {
        for (final move in step.solution) {
          await tapMove(tester, move);
        }
        await tester.tap(find.byKey(const Key('lesson-next')));
        await tester.pump();
      }
      expect(find.byKey(const Key('celebrate-next')), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byKey(const Key('celebrate-next')));
      await tester.pumpAndSettle();
      expect(find.byType(LearnScreen), findsOneWidget);
      expect(find.byType(LessonScreen), findsNothing);
      expect(app.state.currentProfile!.stars['lesson:pawn'], 3);
      expect(tester.widget<LessonNode>(node('pawn')).stars, 3);
      expect(tester.widget<LessonNode>(node('rook')).unlocked, isTrue);
      expect(tester.widget<LessonNode>(node('rook')).isNext, isTrue);
    },
  );

  testWidgets('leaving a lesson midway saves nothing', (tester) async {
    await pumpLearn(tester);
    await tester.tap(node('pawn'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-next')));
    await tester.pump();
    await tapMove(tester, Move.parseUci('e2e4'));
    await tester.tap(find.byKey(const Key('lesson-back')));
    await tester.pumpAndSettle();
    expect(find.byType(LearnScreen), findsOneWidget);
    expect(app.state.currentProfile!.lessonsDone, isEmpty);
    expect(app.state.currentProfile!.stars, isEmpty);
  });

  testWidgets('all lessons done: the teacher congratulates', (tester) async {
    await app.state.updateProfile(
      app.state.currentProfile!.copyWith(
        lessonsDone: lessons.map((l) => l.id).toSet(),
      ),
    );
    await pumpLearn(tester);
    expect(app.speaker.spoken.last.$1, 'learn.common.allDone');
    await tester.pumpAndSettle();
  });

  testWidgets('a short screen shows an arrow while lessons hide below', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpLearn(tester);
    await tester.pump();
    expect(find.byKey(const Key('learn-more')), findsOneWidget);
    await tester.tap(find.byKey(const Key('learn-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('learn-more')), findsOneWidget);
    final list = find.byType(Scrollable).first;
    await tester.fling(list, const Offset(0, -4000), 3000);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('learn-more')), findsNothing);
  });

  testWidgets(
    'each lesson icon starts a fifth of the way up the previous one',
    (tester) async {
      await pumpLearn(tester);
      final pawn = tester.getTopLeft(node('pawn')).dy;
      final rook = tester.getTopLeft(node('rook')).dy;
      expect(rook - pawn, closeTo(LessonNode.circleSize * 4 / 5, 0.5));
      expect(
        tester.getTopLeft(node('bishop')).dy - rook,
        closeTo(LessonNode.circleSize * 4 / 5, 0.5),
      );
      await tester.pumpAndSettle();
    },
  );
}
