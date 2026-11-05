import 'package:chess_for_kids/features/board/piece_image.dart';
import 'package:chess_for_kids/features/learn/lesson_model.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:chess_for_kids/features/learn/steps/arrange_step_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;
  late int done;
  late int mistakes;
  setUp(() async {
    app = await TestApp.create();
    done = 0;
    mistakes = 0;
  });

  final step = lessonById('setup').steps.whereType<ArrangeStep>().single;
  Finder sq(String name) => find.byKey(Key('sq-$name'));
  Finder ghostOn(String name) => find.byKey(Key('ghost-$name'));
  Finder trayItem(String key) => find.byKey(Key('tray-$key'));

  /// A real piece on the square: a piece image without the square's ghost.
  void expectPlaced(String name) {
    expect(ghostOn(name), findsNothing, reason: 'ghost still on $name');
    expect(
      find.descendant(of: sq(name), matching: find.byType(PieceImage)),
      findsOneWidget,
      reason: name,
    );
  }

  Future<void> pumpArrange(WidgetTester tester) async {
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: ArrangeStepView(
            step: step,
            onDone: () => done++,
            onMistake: () => mistakes++,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> dragTo(
    WidgetTester tester,
    String trayKey,
    Offset target,
  ) async {
    final gesture = await tester.startGesture(
      tester.getCenter(trayItem(trayKey)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(0, -20));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(target);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets(
    'shadows mark the target squares and the tray holds eight pieces',
    (tester) async {
      await pumpArrange(tester);
      expect(ghostOn('a1'), findsOneWidget);
      expect(ghostOn('e1'), findsOneWidget);
      final trayFinder = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('tray-'),
      );
      expect(trayFinder, findsNWidgets(8));
    },
  );

  testWidgets(
    'dropping a piece on its shadow places it and removes it from the tray',
    (tester) async {
      await pumpArrange(tester);
      await dragTo(tester, 'R0', tester.getCenter(sq('a1')));
      expectPlaced('a1');
      expect(trayItem('R0'), findsNothing);
      expect(mistakes, 0);
    },
  );

  testWidgets('the two rooks may go to either rook square', (tester) async {
    await pumpArrange(tester);
    await dragTo(tester, 'R0', tester.getCenter(sq('h1')));
    expectPlaced('h1');
    await dragTo(tester, 'R1', tester.getCenter(sq('a1')));
    expectPlaced('a1');
    expect(mistakes, 0);
  });

  testWidgets(
    'a wrong square counts a mistake and keeps the piece; off-board does not',
    (tester) async {
      await pumpArrange(tester);
      await dragTo(tester, 'Q0', tester.getCenter(sq('e1')));
      expect(mistakes, 1);
      expect(trayItem('Q0'), findsOneWidget);
      expect(ghostOn('e1'), findsOneWidget);
      expect(app.speaker.spoken.last.$1, 'learn.setup.task');
      await dragTo(tester, 'Q0', const Offset(5, 5));
      expect(mistakes, 1);
      expect(trayItem('Q0'), findsOneWidget);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'placing every piece makes the pawns appear and completes the step',
    (tester) async {
      await pumpArrange(tester);
      const targets = {
        'R0': 'a1',
        'N0': 'b1',
        'B0': 'c1',
        'Q0': 'd1',
        'K0': 'e1',
        'B1': 'f1',
        'N1': 'g1',
        'R1': 'h1',
      };
      for (final entry in targets.entries) {
        await dragTo(tester, entry.key, tester.getCenter(sq(entry.value)));
      }
      expect(done, 0);
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();
      expect(done, 1);
      for (final file in 'abcdefgh'.split('')) {
        expectPlaced('${file}2');
      }
      expect(app.speaker.spoken.last.$1, 'learn.setup.pawns');
      expect(mistakes, 0);
    },
  );

  testWidgets('the board stays put while the tray empties', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpArrange(tester);
    final before = tester.getRect(sq('a1'));
    await dragTo(tester, 'R0', tester.getCenter(sq('a1')));
    await dragTo(tester, 'R1', tester.getCenter(sq('h1')));
    await dragTo(tester, 'Q0', tester.getCenter(sq('d1')));
    await dragTo(tester, 'K0', tester.getCenter(sq('e1')));
    expect(tester.getRect(sq('a1')), before);
    await tester.pumpAndSettle();
  });
}
