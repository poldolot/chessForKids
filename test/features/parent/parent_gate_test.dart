import 'dart:math';

import 'package:chess_for_kids/features/parent/parent_gate_screen.dart';
import 'package:chess_for_kids/features/parent/parent_zone_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

/// Returns a fixed sequence of values for nextInt.
class _FixedRandom implements Random {
  _FixedRandom(this.values);
  final List<int> values;
  int _i = 0;
  @override
  int nextInt(int max) => values[_i++ % values.length];
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0;
}

void main() {
  late TestApp app;
  setUp(() async => app = await TestApp.create());

  Future<void> pumpGate(WidgetTester tester, Random random) async {
    await tester.pumpWidget(
      app.wrap(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                key: const Key('open-gate'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ParentGateScreen(random: random),
                  ),
                ),
                child: const Text('gate'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open-gate')));
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String digits) async {
    for (final d in digits.split('')) {
      await tester.tap(find.byKey(Key('key-$d')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('key-ok')));
    await tester.pumpAndSettle();
  }

  testWidgets('answer field shows a blinking cursor', (tester) async {
    await pumpGate(tester, _FixedRandom([1, 2]));
    final cursor = find.byKey(const Key('gate-cursor'));
    expect(cursor, findsOneWidget);
    double opacity() => tester.widget<AnimatedOpacity>(cursor).opacity;
    final first = opacity();
    await tester.pump(const Duration(milliseconds: 600));
    expect(opacity(), isNot(first));
    await tester.pump(const Duration(milliseconds: 600));
    expect(opacity(), first);
  });

  testWidgets('correct sum opens the parent zone', (tester) async {
    // nextInt(8) + 2 → 7 and 5
    await pumpGate(tester, _FixedRandom([5, 3]));
    expect(find.text('7 + 5 = ?'), findsOneWidget);
    await type(tester, '12');
    expect(find.byType(ParentZoneScreen), findsOneWidget);
    expect(find.byType(ParentGateScreen), findsNothing);
  });

  testWidgets('backspace removes the last digit', (tester) async {
    await pumpGate(tester, _FixedRandom([5, 3]));
    await tester.tap(find.byKey(const Key('key-1')));
    await tester.tap(find.byKey(const Key('key-3')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('key-back')));
    await tester.pump();
    await type(tester, '2');
    expect(find.byType(ParentZoneScreen), findsOneWidget);
  });

  testWidgets('wrong answer shows a new task, three wrong answers leave', (
    tester,
  ) async {
    await pumpGate(tester, _FixedRandom([5, 3, 0, 0, 1, 1, 2, 2]));
    await type(tester, '13');
    expect(find.text('2 + 2 = ?'), findsOneWidget);
    expect(find.byType(ParentGateScreen), findsOneWidget);
    await type(tester, '5');
    await type(tester, '5');
    expect(find.byType(ParentGateScreen), findsNothing);
    expect(find.byType(ParentZoneScreen), findsNothing);
  });
}
