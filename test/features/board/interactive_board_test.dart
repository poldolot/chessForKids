import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/board/interactive_board.dart';
import 'package:chess_for_kids/features/board/piece_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;
  late List<Move> moves;
  setUp(() async {
    app = await TestApp.create();
    moves = [];
  });

  Finder sq(String name) => find.byKey(Key('sq-$name'));
  Finder dots() => find.byKey(const Key('move-dot'));

  Future<void> pumpBoard(
    WidgetTester tester,
    Position position, {
    bool enabled = true,
    PieceColor? movableColor,
    GameRules rules = GameRules.standard,
  }) async {
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: Center(
            child: InteractiveBoard(
              position: position,
              onMove: moves.add,
              enabled: enabled,
              movableColor: movableColor,
              rules: rules,
              size: 320,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tapping own piece shows its legal targets', (tester) async {
    await pumpBoard(tester, Position.initial());
    await tester.tap(sq('e2'));
    await tester.pump();
    expect(dots(), findsNWidgets(2));
    expect(
      find.descendant(
        of: sq('e2'),
        matching: find.byKey(const Key('selected-frame')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tap target plays the move and clears selection', (tester) async {
    await pumpBoard(tester, Position.initial());
    await tester.tap(sq('e2'));
    await tester.pump();
    await tester.tap(sq('e4'));
    await tester.pump();
    expect(moves, [Move.parseUci('e2e4')]);
    expect(dots(), findsNothing);
  });

  testWidgets(
    'tapping an enemy piece, an empty square or an illegal target clears the selection without a move',
    (tester) async {
      await pumpBoard(tester, Position.initial());
      for (final target in ['e7', 'e5', 'h8']) {
        await tester.tap(sq('e2'));
        await tester.pump();
        expect(dots(), findsNWidgets(2));
        await tester.tap(sq(target));
        await tester.pump();
        expect(dots(), findsNothing, reason: target);
      }
      expect(moves, isEmpty);
    },
  );

  testWidgets('tapping another own piece moves the selection', (tester) async {
    await pumpBoard(tester, Position.initial());
    await tester.tap(sq('e2'));
    await tester.pump();
    await tester.tap(sq('g1'));
    await tester.pump();
    expect(
      find.descendant(
        of: sq('g1'),
        matching: find.byKey(const Key('selected-frame')),
      ),
      findsOneWidget,
    );
    expect(find.descendant(of: sq('f3'), matching: dots()), findsOneWidget);
    expect(find.descendant(of: sq('h3'), matching: dots()), findsOneWidget);
    expect(moves, isEmpty);
  });

  testWidgets('captures are marked with a frame, including en passant', (
    tester,
  ) async {
    await pumpBoard(tester, Position.fromFen('8/8/8/3pP3/8/8/8/8 w - d6 0 1'));
    await tester.tap(sq('e5'));
    await tester.pump();
    expect(
      find.descendant(
        of: sq('d6'),
        matching: find.byKey(const Key('capture-frame')),
      ),
      findsOneWidget,
    );
    expect(find.descendant(of: sq('e6'), matching: dots()), findsOneWidget);
    // A capture square shows the dot too, so every move looks the same.
    expect(find.descendant(of: sq('d6'), matching: dots()), findsOneWidget);
    await tester.tap(sq('d6'));
    await tester.pump();
    expect(moves, [Move.parseUci('e5d6')]);
  });

  testWidgets('rules are respected', (tester) async {
    await pumpBoard(
      tester,
      Position.fromFen('8/8/8/3pP3/8/8/8/8 w - d6 0 1'),
      rules: const GameRules(enPassant: false),
    );
    await tester.tap(sq('e5'));
    await tester.pump();
    expect(find.byKey(const Key('capture-frame')), findsNothing);
  });

  testWidgets(
    'board is inert when disabled or when it is not the movable color',
    (tester) async {
      await pumpBoard(tester, Position.initial(), enabled: false);
      await tester.tap(sq('e2'));
      await tester.pump();
      expect(dots(), findsNothing);
      await pumpBoard(
        tester,
        Position.initial(),
        movableColor: PieceColor.black,
      );
      await tester.tap(sq('e2'));
      await tester.pump();
      expect(dots(), findsNothing);
    },
  );

  testWidgets('check highlights the king square', (tester) async {
    await pumpBoard(
      tester,
      Position.fromFen('4k3/8/8/8/8/8/4r3/4K3 w - - 0 1'),
    );
    expect(find.byKey(const Key('check-e1')), findsOneWidget);
  });

  testWidgets('drag and drop plays a legal move and ignores an illegal drop', (
    tester,
  ) async {
    await pumpBoard(tester, Position.initial());
    await tester.timedDrag(
      sq('e2'),
      tester.getCenter(sq('e4')) - tester.getCenter(sq('e2')),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();
    expect(moves, [Move.parseUci('e2e4')]);
    await tester.timedDrag(
      sq('d2'),
      tester.getCenter(sq('d5')) - tester.getCenter(sq('d2')),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();
    expect(moves.length, 1);
    expect(dots(), findsNothing);
  });

  testWidgets('pieces of the start position are drawn', (tester) async {
    await pumpBoard(tester, Position.initial());
    expect(find.byType(PieceImage), findsNWidgets(32));
  });

  testWidgets('a dragged move is not animated again, a tapped move is', (
    tester,
  ) async {
    Position position = Position.initial();
    Move? last;
    late StateSetter rebuild;
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                return InteractiveBoard(
                  position: position,
                  lastMove: last,
                  size: 320,
                  onMove: (m) => setState(() {
                    position = position.play(m);
                    last = m;
                  }),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.timedDrag(
      sq('e2'),
      tester.getCenter(sq('e4')) - tester.getCenter(sq('e2')),
      const Duration(milliseconds: 300),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.byKey(const Key('sliding-piece')), findsNothing);
    await tester.pumpAndSettle();
    await tester.tap(sq('e7'));
    await tester.pump();
    await tester.tap(sq('e5'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.byKey(const Key('sliding-piece')), findsOneWidget);
    await tester.pumpAndSettle();
    rebuild(() {});
  });

  testWidgets(
    'selection survives a rebuild with an equal but new position instance',
    (tester) async {
      late StateSetter rebuild;
      await tester.pumpWidget(
        app.wrap(
          Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  rebuild = setState;
                  return InteractiveBoard(
                    position: Position.fromFen(kInitialFen),
                    onMove: moves.add,
                    size: 320,
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(sq('e2'));
      await tester.pump();
      expect(dots(), findsNWidgets(2));
      rebuild(() {});
      await tester.pump();
      expect(dots(), findsNWidgets(2));
    },
  );
}
