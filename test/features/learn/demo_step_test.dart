import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/board/piece_image.dart';
import 'package:chess_for_kids/features/learn/lesson_model.dart';
import 'package:chess_for_kids/features/learn/steps/demo_step_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;
  setUp(() async => app = await TestApp.create());

  Finder pieceOn(String name) => find.descendant(
    of: find.byKey(Key('sq-$name')),
    matching: find.byType(PieceImage),
  );

  final demo = DemoStep(
    lineKey: 'learn.check.intro',
    fen: '4k3/8/8/8/8/8/8/R3K3 w - - 0 1',
    moves: [(Move.parseUci('a1a8'), 'learn.check.demo')],
  );

  /// Lets the 220 ms slide finish and the board rebuild afterwards.
  Future<void> settleSlide(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
  }

  testWidgets(
    'demo plays its moves on a timer, speaks per move and reports done',
    (tester) async {
      var done = 0;
      await tester.pumpWidget(
        app.wrap(
          Scaffold(
            body: DemoStepView(step: demo, onDone: () => done++),
          ),
        ),
      );
      await tester.pump();
      expect(pieceOn('a1'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 700));
      expect(app.speaker.spoken.last.$1, 'learn.check.demo');
      await settleSlide(tester);
      expect(pieceOn('a8'), findsOneWidget);
      expect(pieceOn('a1'), findsNothing);
      expect(done, 0);
      await tester.pump(const Duration(milliseconds: 1000));
      expect(done, 1);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('demo replay restarts from the first position', (tester) async {
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: DemoStepView(step: demo, onDone: () {}),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();
    expect(pieceOn('a8'), findsOneWidget);
    await tester.tap(find.byKey(const Key('demo-replay')));
    await tester.pump();
    expect(pieceOn('a1'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    await settleSlide(tester);
    expect(pieceOn('a8'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('a narrated demo waits for the line before the next move', (
    tester,
  ) async {
    final narrated = DemoStep(
      lineKey: 'learn.chess.turns',
      fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      pace: const Duration(milliseconds: 1000),
      moves: [
        (Move.parseUci('e2e4'), 'learn.chess.turnWhite'),
        (Move.parseUci('e7e5'), 'learn.chess.turnBlack'),
      ],
    );
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: DemoStepView(step: narrated, onDone: () {}),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    // The teacher starts explaining the first move.
    app.speaker.speaking.value = true;
    await settleSlide(tester);
    expect(pieceOn('e4'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await settleSlide(tester);
    expect(pieceOn('e7'), findsOneWidget);
    app.speaker.speaking.value = false;
    await tester.pump(const Duration(milliseconds: 1000));
    await settleSlide(tester);
    expect(pieceOn('e5'), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
