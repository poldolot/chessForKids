import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/features/learn/lesson_model.dart';
import 'package:chess_for_kids/features/learn/lesson_screen.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:chess_for_kids/features/learn/steps/board_task_view.dart';
import 'package:chess_for_kids/features/learn/steps/intro_step_view.dart';
import 'package:chess_for_kids/features/learn/widgets/step_dots.dart';
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

  Future<void> pumpLesson(WidgetTester tester, String id) async {
    await tester.pumpWidget(app.wrap(LessonScreen(lesson: lessonById(id))));
    await tester.pump();
  }

  testWidgets('lesson screen speaks the step line and advances with Next', (
    tester,
  ) async {
    await pumpLesson(tester, 'rook');
    expect(app.speaker.spoken.last.$1, 'learn.rook.intro');
    expect(find.byType(IntroStepView), findsOneWidget);
    await tester.tap(find.byKey(const Key('lesson-next')));
    await tester.pump();
    expect(find.byType(BoardTaskView), findsOneWidget);
    expect(app.speaker.spoken.last.$1, 'learn.rook.move');
  });

  testWidgets('step dots mark done, current and upcoming', (tester) async {
    await pumpLesson(tester, 'rook');
    final dots = tester.widget<StepDots>(find.byType(StepDots));
    expect(dots.count, lessonById('rook').steps.length + 1);
    expect(dots.current, 0);
    await tester.tap(find.byKey(const Key('lesson-next')));
    await tester.pump();
    expect(tester.widget<StepDots>(find.byType(StepDots)).current, 1);
    expect(find.byKey(const Key('dot-0')), findsOneWidget);
  });

  testWidgets('next is disabled until a task step reports done', (
    tester,
  ) async {
    await pumpLesson(tester, 'rook');
    await tester.tap(find.byKey(const Key('lesson-next')));
    await tester.pump();
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('lesson-next')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('intro breathes a few times unless animations are disabled', (
    tester,
  ) async {
    await pumpLesson(tester, 'rook');
    expect(find.byKey(const Key('breathe')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    final mid = tester
        .widget<ScaleTransition>(find.byKey(const Key('breathe')))
        .scale
        .value;
    expect(mid, greaterThan(1.0));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      app.wrap(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: LessonScreen(lesson: lessonById('rook')),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('breathe')), findsNothing);
  });

  testWidgets('back leaves the lesson', (tester) async {
    await tester.pumpWidget(
      app.wrap(
        Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              key: const Key('open'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LessonScreen(lesson: lessonById('rook')),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byKey(const Key('lesson-back')));
    await tester.pumpAndSettle();
    expect(find.byType(LessonScreen), findsNothing);
  });

  testWidgets('a finished task waits for Next instead of advancing by itself', (
    tester,
  ) async {
    await pumpLesson(tester, 'rook');
    await tester.tap(find.byKey(const Key('lesson-next')));
    await tester.pump();
    final explore = lessonById('rook').steps[1] as BoardTaskStep;
    for (final move in explore.solution) {
      await tester.tap(find.byKey(Key('sq-${move.from.name}')));
      await tester.pump();
      await tester.tap(find.byKey(Key('sq-${move.to.name}')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
    }
    await tester.pump(const Duration(seconds: 3));
    expect(tester.widget<StepDots>(find.byType(StepDots)).current, 1);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('lesson-next')))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.byKey(const Key('lesson-next')));
    await tester.pump();
    expect(tester.widget<StepDots>(find.byType(StepDots)).current, 2);
    await tester.pumpAndSettle();
  });
}
