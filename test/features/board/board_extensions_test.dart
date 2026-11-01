import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/board/board_highlights.dart';
import 'package:chess_for_kids/features/board/board_view.dart';
import 'package:chess_for_kids/features/board/interactive_board.dart';
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

  Future<void> pumpBoard(WidgetTester tester, Widget board) async {
    await tester.pumpWidget(app.wrap(Scaffold(body: Center(child: board))));
    await tester.pumpAndSettle();
  }

  Future<void> pumpInteractive(
    WidgetTester tester,
    Position position, {
    ValueChanged<Square>? onRejected,
    bool Function(Move)? moveFilter,
    Square? shakeSquare,
    BoardHighlights extra = const BoardHighlights(),
  }) {
    return pumpBoard(
      tester,
      InteractiveBoard(
        position: position,
        onMove: moves.add,
        onRejected: onRejected,
        moveFilter: moveFilter,
        shakeSquare: shakeSquare,
        extraHighlights: extra,
        size: 320,
      ),
    );
  }

  testWidgets('danger, stars and ghosts are painted with their keys', (
    tester,
  ) async {
    await pumpBoard(
      tester,
      BoardView(
        position: Position.fromFen('8/8/8/8/8/8/8/4K3 w - - 0 1'),
        size: 320,
        highlights: BoardHighlights(
          danger: {Square.parse('e2')},
          stars: {Square.parse('e8')},
          ghosts: {
            Square.parse('a1'): const Piece(PieceColor.white, PieceType.rook),
          },
        ),
      ),
    );
    expect(
      find.descendant(
        of: sq('e2'),
        matching: find.byKey(const Key('danger-dot')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sq('e8'), matching: find.byKey(const Key('star-e8'))),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: sq('a1'),
        matching: find.byKey(const Key('ghost-a1')),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'onRejected fires for enemy piece, empty square and filtered-out target',
    (tester) async {
      final rejected = <Square>[];
      await pumpInteractive(
        tester,
        Position.initial(),
        onRejected: rejected.add,
        moveFilter: (m) => m.to.rank == 3,
      );
      await tester.tap(sq('e7'));
      await tester.pump();
      await tester.tap(sq('e4'));
      await tester.pump();
      await tester.tap(sq('e2'));
      await tester.pump();
      expect(find.byKey(const Key('move-dot')), findsOneWidget);
      await tester.tap(sq('e3'));
      await tester.pump();
      expect(rejected.map((s) => s.name), ['e7', 'e4', 'e3']);
      expect(moves, isEmpty);
      await tester.tap(sq('e2'));
      await tester.pump();
      await tester.tap(sq('e4'));
      await tester.pump();
      expect(moves, [Move.parseUci('e2e4')]);
    },
  );

  testWidgets('onRejected is not called for own pieces or legal targets', (
    tester,
  ) async {
    final rejected = <Square>[];
    await pumpInteractive(tester, Position.initial(), onRejected: rejected.add);
    await tester.tap(sq('e2'));
    await tester.pump();
    await tester.tap(sq('d2'));
    await tester.pump();
    await tester.tap(sq('d4'));
    await tester.pump();
    expect(rejected, isEmpty);
    expect(moves, [Move.parseUci('d2d4')]);
  });

  testWidgets('shakeSquare rotates the piece and settles back', (tester) async {
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: Center(
            child: InteractiveBoard(
              position: Position.initial(),
              onMove: moves.add,
              shakeSquare: Square.parse('e2'),
              size: 320,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    Transform shake() => tester.widget<Transform>(
      find.descendant(of: sq('e2'), matching: find.byKey(const Key('shake'))),
    );
    expect(shake().transform.getRotation().right.y.abs(), greaterThan(0.01));
    await tester.pumpAndSettle();
    expect(shake().transform.getRotation().right.y, closeTo(0, 1e-6));
  });

  testWidgets('extraHighlights are merged with the selection highlights', (
    tester,
  ) async {
    await pumpInteractive(
      tester,
      Position.initial(),
      extra: BoardHighlights(stars: {Square.parse('e4')}),
    );
    await tester.tap(sq('e2'));
    await tester.pump();
    expect(
      find.descendant(of: sq('e4'), matching: find.byKey(const Key('star-e4'))),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: sq('e4'),
        matching: find.byKey(const Key('move-dot')),
      ),
      findsOneWidget,
    );
  });
}
