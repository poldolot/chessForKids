import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/board/piece_image.dart';
import 'package:chess_for_kids/features/learn/board_task_controller.dart';
import 'package:chess_for_kids/features/learn/lesson_model.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:chess_for_kids/features/learn/steps/board_task_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;
  late int done;
  late int mistakes;
  late List<TaskEvent> events;

  setUp(() async {
    app = await TestApp.create();
    done = 0;
    mistakes = 0;
    events = [];
  });

  Finder sq(String name) => find.byKey(Key('sq-$name'));
  BoardTaskStep taskOf(String lesson, int index) =>
      lessonById(lesson).steps[index] as BoardTaskStep;
  final rookPractice = taskOf('rook', 3);

  Future<void> pumpTask(WidgetTester tester, BoardTaskStep step) async {
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: BoardTaskView(
            step: step,
            onDone: () => done++,
            onMistake: () => mistakes++,
            onEvent: events.add,
          ),
        ),
      ),
    );
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
    'collecting all stars completes the step and leaves the board playable',
    (tester) async {
      await pumpTask(tester, rookPractice);
      expect(find.byKey(const Key('star-d8')), findsOneWidget);
      for (final m in rookPractice.solution) {
        await tapMove(tester, m);
      }
      expect(done, 1);
      expect(mistakes, 0);
      expect(find.byKey(const Key('star-d8')), findsNothing);
      await tester.tap(sq('a4'));
      await tester.pump();
      expect(find.byKey(const Key('move-dot')), findsWidgets);
      await tapMove(tester, Move.parseUci('a4a8'));
      expect(mistakes, 0);
      expect(done, 1);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('a wasted move shakes, speaks the hint and counts a mistake', (
    tester,
  ) async {
    await pumpTask(tester, rookPractice);
    await tapMove(tester, Move.parseUci('d4d5'));
    expect(mistakes, 1);
    expect(app.speaker.spoken.last.$1, 'learn.common.limitHint');
    expect(find.byKey(const Key('shake')), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('running out of moves resets the board and says try again', (
    tester,
  ) async {
    await pumpTask(tester, rookPractice);
    for (final m in ['d4d5', 'd5d6', 'd6d7', 'd7e7', 'e7e6']) {
      await tapMove(tester, Move.parseUci(m));
    }
    expect(events.last, TaskEvent.reset);
    expect(mistakes, 5);
    expect(app.speaker.spoken.last.$1, 'learn.common.tryAgain');
    expect(
      find.descendant(of: sq('d4'), matching: find.byKey(const Key('shake'))),
      findsNothing,
    );
    await tester.tap(sq('d4'));
    await tester.pump();
    expect(find.byKey(const Key('move-dot')), findsWidgets);
    expect(find.byKey(const Key('star-d8')), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('a rejected tap counts a mistake and speaks the hint', (
    tester,
  ) async {
    await pumpTask(tester, taskOf('pawn', 2));
    await tester.tap(sq('e3'));
    await tester.pump();
    // Every legal move is shown, even the plain step the task does not
    // accept: the child sees how the piece moves at every stage.
    expect(
      find.descendant(
        of: sq('e4'),
        matching: find.byKey(const Key('move-dot')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: sq('d4'),
        matching: find.byKey(const Key('capture-frame')),
      ),
      findsOneWidget,
    );
    await tester.tap(sq('e4'));
    await tester.pump();
    expect(mistakes, 1);
    expect(app.speaker.spoken.last.$1, 'learn.common.captureFrame');
    expect(find.byKey(const Key('move-dot')), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('double tapping a target plays one move', (tester) async {
    await pumpTask(tester, rookPractice);
    await tester.tap(sq('d4'));
    await tester.pump();
    await tester.tap(sq('d8'));
    await tester.tap(sq('d8'));
    await tester.pump();
    expect(events.where((e) => e == TaskEvent.good).length, 1);
    expect(mistakes, 0);
    await tester.pumpAndSettle();
  });

  testWidgets('danger squares are shown for the king race', (tester) async {
    await pumpTask(tester, taskOf('king', 3));
    expect(find.byKey(const Key('danger-dot')), findsWidgets);
    expect(
      find.descendant(
        of: sq('e3'),
        matching: find.byKey(const Key('danger-dot')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: sq('d3'),
        matching: find.byKey(const Key('danger-dot')),
      ),
      findsNothing,
    );
  });

  testWidgets('moves-left indicator counts down', (tester) async {
    await pumpTask(tester, rookPractice);
    expect(find.byKey(const Key('moves-left')), findsOneWidget);
    expect(find.byKey(const Key('move-left-dot-4')), findsOneWidget);
    await tapMove(tester, Move.parseUci('d4d8'));
    expect(find.byKey(const Key('move-left-dot-4')), findsNothing);
    expect(find.byKey(const Key('move-left-dot-3')), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('tasks without a limit show the stars left instead', (
    tester,
  ) async {
    await pumpTask(tester, taskOf('rook', 1));
    expect(find.byKey(const Key('moves-left')), findsNothing);
  });

  testWidgets(
    'a wrong one-move answer is shown, the hint waits for the teacher, then the board returns',
    (tester) async {
      await pumpTask(tester, taskOf('mate', 1));
      await tapMove(tester, Move.parseUci('h1h2'));
      expect(mistakes, 1);
      expect(
        find.descendant(of: sq('h2'), matching: find.byType(PieceImage)),
        findsOneWidget,
      );
      expect(app.speaker.spoken.last.$1, 'learn.mate.hint');
      expect(app.speaker.nonInterrupting, contains('learn.mate.hint'));
      await tester.tap(sq('h2'));
      await tester.pump();
      expect(find.byKey(const Key('move-dot')), findsNothing);
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pump();
      expect(
        find.descendant(of: sq('h1'), matching: find.byType(PieceImage)),
        findsOneWidget,
      );
      await tapMove(tester, Move.parseUci('h1h8'));
      expect(done, 1);
      expect(mistakes, 1);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('only the child colour can be moved', (tester) async {
    await pumpTask(tester, taskOf('check', 2));
    // The black king on e8 is not the child's; the white king on e1 is.
    await tester.tap(sq('e8'));
    await tester.pump();
    expect(find.byKey(const Key('move-dot')), findsNothing);
    await tester.tap(sq('e1'));
    await tester.pump();
    expect(find.byKey(const Key('move-dot')), findsWidgets);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'a pawn reaching the end becomes a queen and the teacher explains',
    (tester) async {
      final step = BoardTaskStep(
        lineKey: 'learn.pawn.move',
        fen: '8/4P3/8/8/8/8/8/8 w - - 0 1',
        goal: (s) => s.goodMoves >= 2,
        solution: const [],
        moveFilter: (p, m) =>
            m.promotion == null || m.promotion == PieceType.queen,
        promotionNoteKey: 'learn.pawn.promotionNote',
      );
      await pumpTask(tester, step);
      await tester.tap(sq('e7'));
      await tester.pump();
      await tester.tap(sq('e8'));
      await tester.pump();
      expect(find.byKey(const Key('promote-q')), findsNothing);
      expect(app.speaker.spoken.last.$1, 'learn.pawn.promotionNote');
      expect(app.speaker.spoken.last.$2, contains('hetmana'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: sq('e8'), matching: find.byType(PieceImage)),
        findsOneWidget,
      );
    },
  );
}
