import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/features/board/board_view.dart';
import 'package:chess_for_kids/features/board/piece_image.dart';
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
    expect(app.speaker.spoken.last.$2, startsWith('Wieża. '));
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

  FilledButton nextButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byKey(const Key('lesson-next')));

  testWidgets('a first explanation holds Next until it has been spoken', (
    tester,
  ) async {
    app.speaker.speaking.value = true;
    await pumpLesson(tester, 'rook');
    expect(nextButton(tester).onPressed, isNull);
    app.speaker.speaking.value = false;
    await tester.pump();
    expect(nextButton(tester).onPressed, isNotNull);
    await tester.tap(find.byKey(const Key('lesson-next')));
    await tester.pump();
    // Task steps are never held, whatever the speaker does.
    app.speaker.speaking.value = true;
    await tester.pump();
    expect(find.byType(BoardTaskView), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('a lesson done before is never held', (tester) async {
    await app.state.markLessonDone('rook');
    app.speaker.speaking.value = true;
    await pumpLesson(tester, 'rook');
    expect(nextButton(tester).onPressed, isNotNull);
    await tester.pumpAndSettle();
  });

  testWidgets('the hold gives up after twenty seconds without an end', (
    tester,
  ) async {
    app.speaker.speaking.value = true;
    await pumpLesson(tester, 'rook');
    expect(nextButton(tester).onPressed, isNull);
    await tester.pump(const Duration(seconds: 21));
    expect(nextButton(tester).onPressed, isNotNull);
    await tester.pumpAndSettle();
  });

  testWidgets('only the first step carries the title; both intros hold Next', (
    tester,
  ) async {
    final lesson = Lesson(
      id: 'chess',
      kind: LessonKind.story,
      titleKey: 'learn.chess.title',
      steps: const [
        IntroStep(lineKey: 'learn.chess.intro'),
        IntroStep(lineKey: 'learn.chess.outro'),
      ],
    );
    app.speaker.speaking.value = true;
    await tester.pumpWidget(app.wrap(LessonScreen(lesson: lesson)));
    await tester.pump();
    expect(app.speaker.spoken.last.$2, startsWith('Co to są szachy. '));
    expect(nextButton(tester).onPressed, isNull);
    app.speaker.speaking.value = false;
    await tester.pump();
    await tester.tap(find.byKey(const Key('lesson-next')));
    await tester.pump();
    expect(app.speaker.spoken.last.$1, 'learn.chess.outro');
    expect(app.speaker.spoken.last.$2, startsWith('Czasem'));
    app.speaker.speaking.value = true;
    await tester.pump();
    expect(
      nextButton(tester).onPressed,
      isNull,
      reason: 'the closing words are heard to the end as well',
    );
    app.speaker.speaking.value = false;
    await tester.pump();
    expect(nextButton(tester).onPressed, isNotNull);
    await tester.pumpAndSettle();
  });

  testWidgets('two demos in a row each start from their own position', (
    tester,
  ) async {
    await app.state.markLessonDone('chess');
    final chess = lessonById('chess');
    final demos = chess.steps.whereType<DemoStep>().toList();
    final lesson = Lesson(
      id: 'chess',
      kind: LessonKind.story,
      titleKey: 'learn.chess.title',
      steps: [demos[0], demos[1]],
    );
    await tester.pumpWidget(app.wrap(LessonScreen(lesson: lesson)));
    await tester.pump();
    Finder pieceOn(String name) => find.descendant(
      of: find.byKey(Key('sq-$name')),
      matching: find.byType(PieceImage),
    );
    expect(pieceOn('e2'), findsOneWidget);
    // Let the first demo play out.
    await tester.pump(const Duration(seconds: 12));
    await tester.pump(const Duration(milliseconds: 300));
    expect(pieceOn('e4'), findsOneWidget);
    await tester.tap(find.byKey(const Key('lesson-next')));
    await tester.pump();
    // The capture demo starts after 1.e4 d5: a black pawn on d5, e7 home.
    expect(pieceOn('d5'), findsOneWidget);
    expect(pieceOn('e7'), findsOneWidget);
    expect(pieceOn('c6'), findsNothing);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 300));
    expect(pieceOn('e4'), findsNothing, reason: 'exd5 was played');
    await tester.pumpAndSettle();
  });

  testWidgets('the board stays put across demo, find and task steps', (
    tester,
  ) async {
    await app.state.markLessonDone('chess');
    final chess = lessonById('chess');
    final lesson = Lesson(
      id: 'chess',
      kind: LessonKind.story,
      titleKey: 'learn.chess.title',
      steps: [
        chess.steps.whereType<SpotlightStep>().first,
        chess.steps.whereType<FindStep>().single,
        chess.steps.whereType<DemoStep>().first,
        chess.steps.whereType<BoardTaskStep>().single,
      ],
    );
    await tester.pumpWidget(app.wrap(LessonScreen(lesson: lesson)));
    await tester.pump();
    Offset boardAt() => tester.getTopLeft(find.byType(BoardView));
    Future<void> next() async {
      await tester.tap(find.byKey(const Key('lesson-next')));
      await tester.pump();
    }

    Future<void> tapSquare(String name) async {
      await tester.tap(find.byKey(Key('sq-$name')));
      await tester.pump();
    }

    final first = boardAt();
    // Spotlight plays out by itself.
    await tester.pump(const Duration(seconds: 10));
    await next();
    expect(boardAt(), first, reason: 'find step');
    await tapSquare('e1');
    await tapSquare('e8');
    await tester.pump(const Duration(seconds: 1));
    await next();
    expect(boardAt(), first, reason: 'demo step');
    await tester.pump(const Duration(seconds: 12));
    await tester.pump(const Duration(milliseconds: 300));
    await next();
    expect(boardAt(), first, reason: 'task step');
    await tapSquare('h5');
    await tapSquare('f7');
    await tester.pump(const Duration(milliseconds: 300));
    expect(boardAt(), first, reason: 'task step after the move');
    await tester.pumpAndSettle();
  });
}
