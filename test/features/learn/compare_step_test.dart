import 'package:chess_for_kids/app/constants.dart';
import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/learn/lesson_model.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:chess_for_kids/features/learn/steps/compare_step_view.dart';
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

  final step = lessonById('values').steps.whereType<CompareStep>().single;

  Future<void> pumpCompare(WidgetTester tester) async {
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: CompareStepView(
            step: step,
            onDone: () => done++,
            onMistake: () => mistakes++,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  String better((Piece, Piece) pair) =>
      pair.$1.type.value > pair.$2.type.value ? 'compare-a' : 'compare-b';
  String worse((Piece, Piece) pair) =>
      better(pair) == 'compare-a' ? 'compare-b' : 'compare-a';

  Future<void> choose(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
  }

  testWidgets('five correct picks complete the step without mistakes', (
    tester,
  ) async {
    await pumpCompare(tester);
    for (final pair in step.pairs) {
      await choose(tester, better(pair));
    }
    expect(done, 1);
    expect(mistakes, 0);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'a wrong pick counts a mistake, speaks the hint and keeps the pair',
    (tester) async {
      await pumpCompare(tester);
      final first = step.pairs.first;
      await choose(tester, worse(first));
      expect(mistakes, 1);
      expect(app.speaker.spoken.last.$1, 'learn.values.hint');
      expect(find.byKey(const Key('compare-progress-0')), findsNothing);
      await choose(tester, better(first));
      expect(find.byKey(const Key('compare-progress-0')), findsOneWidget);
      expect(done, 0);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('cards are large and show as many stars as the piece is worth', (
    tester,
  ) async {
    await pumpCompare(tester);
    expect(
      tester.getSize(find.byKey(const Key('compare-a'))).shortestSide,
      greaterThanOrEqualTo(kMinTouchTarget),
    );
    final first = step.pairs.first;
    expect(
      find.descendant(
        of: find.byKey(const Key('compare-a')),
        matching: find.byIcon(Icons.star_rounded),
      ),
      findsNWidgets(first.$1.type.value),
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('compare-b')),
        matching: find.byIcon(Icons.star_rounded),
      ),
      findsNWidgets(first.$2.type.value),
    );
  });
}
