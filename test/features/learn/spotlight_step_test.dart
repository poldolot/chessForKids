import 'package:chess_for_kids/features/learn/lesson_model.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:chess_for_kids/features/learn/steps/spotlight_step_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;
  setUp(() async => app = await TestApp.create());

  final step = lessonById('chess').steps.whereType<SpotlightStep>().first;
  Finder spot(String name) => find.byKey(Key('spotlight-$name'));

  Future<int> pumpStep(WidgetTester tester, void Function() onDone) async {
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: SpotlightStepView(step: step, onDone: onDone),
        ),
      ),
    );
    await tester.pump();
    return 0;
  }

  testWidgets('parts light up one after another, each with its line', (
    tester,
  ) async {
    var done = 0;
    await pumpStep(tester, () => done++);
    expect(spot('a2'), findsNothing);
    await tester.pump(SpotlightStepView.firstDelay);
    await tester.pump();
    expect(spot('a2'), findsOneWidget);
    expect(spot('h7'), findsOneWidget);
    expect(spot('a1'), findsNothing);
    expect(app.speaker.spoken.last.$1, 'learn.chess.pawns');
    await tester.pump(SpotlightStepView.partDelay);
    await tester.pump();
    expect(spot('a2'), findsNothing);
    expect(spot('a1'), findsOneWidget);
    expect(app.speaker.spoken.last.$1, 'learn.chess.rooks');
    for (var i = 2; i < step.parts.length; i++) {
      await tester.pump(SpotlightStepView.partDelay);
      await tester.pump();
    }
    expect(spot('e1'), findsOneWidget);
    expect(app.speaker.spoken.last.$1, 'learn.chess.kings');
    expect(done, 0);
    await tester.pump(SpotlightStepView.partDelay);
    expect(done, 1);
    expect(spot('e1'), findsOneWidget, reason: 'the last part stays lit');
    await tester.pumpAndSettle();
  });

  testWidgets('the next part waits until the teacher stops talking', (
    tester,
  ) async {
    await pumpStep(tester, () {});
    await tester.pump(SpotlightStepView.firstDelay);
    await tester.pump();
    expect(spot('a2'), findsOneWidget);
    app.speaker.speaking.value = true;
    await tester.pump(SpotlightStepView.partDelay * 3);
    await tester.pump();
    expect(spot('a1'), findsNothing);
    app.speaker.speaking.value = false;
    await tester.pump(SpotlightStepView.partDelay);
    await tester.pump();
    expect(spot('a1'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('replay starts the parts over', (tester) async {
    await pumpStep(tester, () {});
    await tester.pump(SpotlightStepView.firstDelay);
    await tester.pump(SpotlightStepView.partDelay);
    await tester.pump();
    expect(spot('a1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('demo-replay')));
    await tester.pump();
    expect(spot('a1'), findsNothing);
    await tester.pump(SpotlightStepView.firstDelay);
    await tester.pump();
    expect(spot('a2'), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
