import 'package:chess_for_kids/features/learn/lesson_model.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:chess_for_kids/features/learn/steps/find_step_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;
  setUp(() async => app = await TestApp.create());

  final step = lessonById('chess').steps.whereType<FindStep>().single;
  Finder sq(String name) => find.byKey(Key('sq-$name'));
  Finder spot(String name) => find.byKey(Key('spotlight-$name'));

  late int done;
  late int mistakes;

  Future<void> pumpStep(WidgetTester tester) async {
    done = 0;
    mistakes = 0;
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: FindStepView(
            step: step,
            onDone: () => done++,
            onMistake: () => mistakes++,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('tapping the asked squares in order finishes the step', (
    tester,
  ) async {
    await pumpStep(tester);
    await tester.tap(sq('e1'));
    await tester.pump();
    expect(spot('e1'), findsOneWidget);
    expect(app.speaker.spoken.last.$1, 'learn.chess.findBlackKing');
    expect(done, 0);
    await tester.tap(sq('e8'));
    await tester.pump();
    expect(spot('e8'), findsOneWidget);
    expect(app.speaker.spoken.last.$1, 'learn.chess.kingsFound');
    expect(done, 0, reason: 'the closing line is still being said');
    await tester.pump(FindStepView.doneDelay);
    expect(done, 1);
    expect(mistakes, 0);
    await tester.pumpAndSettle();
  });

  testWidgets('the step is done only after the closing line is spoken', (
    tester,
  ) async {
    await pumpStep(tester);
    await tester.tap(sq('e1'));
    await tester.pump();
    await tester.tap(sq('e8'));
    await tester.pump(const Duration(milliseconds: 100));
    app.speaker.speaking.value = true;
    await tester.pump(const Duration(seconds: 5));
    expect(done, 0);
    app.speaker.speaking.value = false;
    await tester.pump(FindStepView.doneDelay);
    expect(done, 1);
    await tester.pumpAndSettle();
  });

  testWidgets('a wrong tap is a mistake with a quiet hint', (tester) async {
    await pumpStep(tester);
    await tester.tap(sq('d1'));
    await tester.pump();
    expect(mistakes, 1);
    expect(app.speaker.spoken.last.$1, 'learn.chess.findHint');
    expect(app.speaker.nonInterrupting, contains('learn.chess.findHint'));
    expect(spot('d1'), findsNothing);
    // The black king before the white one is also wrong: order matters.
    await tester.tap(sq('e8'));
    await tester.pump();
    expect(mistakes, 2);
    expect(done, 0);
    await tester.pumpAndSettle();
  });

  testWidgets('taps after the step is done change nothing', (tester) async {
    await pumpStep(tester);
    await tester.tap(sq('e1'));
    await tester.pump();
    await tester.tap(sq('e8'));
    await tester.pump(FindStepView.doneDelay);
    await tester.tap(sq('a1'));
    await tester.pump();
    expect(done, 1);
    expect(mistakes, 0);
    await tester.pumpAndSettle();
  });
}
