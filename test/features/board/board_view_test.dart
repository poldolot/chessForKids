import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/board/board_highlights.dart';
import 'package:chess_for_kids/features/board/board_view.dart';
import 'package:chess_for_kids/features/board/piece_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp app;
  setUp(() async => app = await TestApp.create());

  Finder sq(String name) => find.byKey(Key('sq-$name'));

  Future<void> pumpBoard(WidgetTester tester, BoardView board) async {
    await tester.pumpWidget(app.wrap(Scaffold(body: Center(child: board))));
    await tester.pumpAndSettle();
  }

  testWidgets('renders 64 squares and 32 pieces for the start position', (
    tester,
  ) async {
    await pumpBoard(tester, BoardView(position: Position.initial(), size: 320));
    expect(
      find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('sq-'),
      ),
      findsNWidgets(64),
    );
    expect(find.byType(PieceImage), findsNWidgets(32));
    expect(tester.getSize(find.byType(BoardView)), const Size(320, 320));
  });

  testWidgets(
    'white orientation puts a1 bottom-left, black puts h1 top-right',
    (tester) async {
      await pumpBoard(
        tester,
        BoardView(position: Position.initial(), size: 320),
      );
      final a1 = tester.getCenter(sq('a1'));
      final h8 = tester.getCenter(sq('h8'));
      expect(a1.dx, lessThan(h8.dx));
      expect(a1.dy, greaterThan(h8.dy));
      await pumpBoard(
        tester,
        BoardView(
          position: Position.initial(),
          orientation: PieceColor.black,
          size: 320,
        ),
      );
      final a1b = tester.getCenter(sq('a1'));
      final h8b = tester.getCenter(sq('h8'));
      expect(a1b.dx, greaterThan(h8b.dx));
      expect(a1b.dy, lessThan(h8b.dy));
    },
  );

  testWidgets(
    'highlights paint dots, capture frames, selection, last move and check',
    (tester) async {
      final highlights = BoardHighlights(
        selected: Square.parse('e2'),
        moveTargets: {Square.parse('e3'), Square.parse('e4')},
        captureTargets: {Square.parse('d3')},
        lastMove: Move.parseUci('g1f3'),
        checkedKing: Square.parse('e1'),
      );
      await pumpBoard(
        tester,
        BoardView(
          position: Position.initial(),
          highlights: highlights,
          size: 320,
        ),
      );
      // Plain targets and capture targets both get a dot.
      expect(find.byKey(const Key('move-dot')), findsNWidgets(3));
      expect(
        find.descendant(
          of: sq('e4'),
          matching: find.byKey(const Key('move-dot')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sq('d3'),
          matching: find.byKey(const Key('capture-frame')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sq('e2'),
          matching: find.byKey(const Key('selected-frame')),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('check-e1')), findsOneWidget);
      expect(
        find.descendant(
          of: sq('g1'),
          matching: find.byKey(const Key('last-move')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sq('f3'),
          matching: find.byKey(const Key('last-move')),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('square tap reports the square', (tester) async {
    final taps = <Square>[];
    await pumpBoard(
      tester,
      BoardView(position: Position.initial(), size: 320, onSquareTap: taps.add),
    );
    await tester.tap(sq('e2'));
    await tester.tap(sq('h8'));
    expect(taps, [Square.parse('e2'), Square.parse('h8')]);
  });

  testWidgets('board fills the shorter side when no size is given', (
    tester,
  ) async {
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: SizedBox(
            width: 300,
            height: 500,
            child: BoardView(position: Position.initial()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(BoardView)).width, 300);
    expect(
      tester.getSize(find.byKey(const Key('sq-a1'))).width,
      closeTo(37.5, 0.01),
    );
  });

  testWidgets('without drag callbacks a drag does not lift the piece', (
    tester,
  ) async {
    await pumpBoard(tester, BoardView(position: Position.initial(), size: 320));
    final gesture = await tester.startGesture(tester.getCenter(sq('e2')));
    await gesture.moveBy(const Offset(0, -60));
    await tester.pump();
    expect(
      find.descendant(of: sq('e2'), matching: find.byType(PieceImage)),
      findsOneWidget,
    );
    expect(find.byKey(const Key('drag-ghost')), findsNothing);
    await gesture.up();
  });

  testWidgets(
    'a move slides in the overlay, above the squares, then lands in its square',
    (tester) async {
      final after = Position.initial().play(Move.parseUci('e2e4'));
      await tester.pumpWidget(
        app.wrap(
          Scaffold(
            body: Center(
              child: BoardView(
                position: after,
                size: 320,
                animateMove: Move.parseUci('e2e4'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.byKey(const Key('sliding-piece')), findsOneWidget);
      expect(
        find.descendant(of: sq('e4'), matching: find.byType(PieceImage)),
        findsNothing,
      );
      final slidingY = tester
          .getCenter(find.byKey(const Key('sliding-piece')))
          .dy;
      expect(slidingY, greaterThan(tester.getCenter(sq('e4')).dy));
      expect(slidingY, lessThan(tester.getCenter(sq('e2')).dy));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sliding-piece')), findsNothing);
      expect(
        find.descendant(of: sq('e4'), matching: find.byType(PieceImage)),
        findsOneWidget,
      );
    },
  );

  testWidgets('a move target on a star square is drawn as a frame, not a dot', (
    tester,
  ) async {
    final a8 = Square.parse('a8');
    final b8 = Square.parse('b8');
    await pumpBoard(
      tester,
      BoardView(
        position: Position.fromFen('8/8/8/8/8/8/8/R7 w - - 0 1'),
        size: 320,
        highlights: BoardHighlights(stars: {a8}, moveTargets: {a8, b8}),
      ),
    );
    BoxDecoration decorationIn(Finder square) =>
        tester
                .widget<Container>(
                  find.descendant(
                    of: square,
                    matching: find.byKey(const Key('move-dot')),
                  ),
                )
                .decoration!
            as BoxDecoration;
    expect(decorationIn(sq('a8')).border, isNotNull);
    expect(decorationIn(sq('a8')).color, isNull);
    expect(decorationIn(sq('b8')).border, isNull);
    expect(decorationIn(sq('b8')).shape, BoxShape.circle);
  });

  testWidgets('castling slides the king first and the rook after it', (
    tester,
  ) async {
    final after = Position.fromFen('4k3/8/8/8/8/8/8/5RK1 b - - 1 1');
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: Center(
            child: BoardView(
              position: after,
              size: 320,
              animateMove: Move.parseUci('e1g1'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    // The king is on its way; the rook still rests on h1 and f1 is empty.
    expect(find.byKey(const Key('sliding-piece')), findsOneWidget);
    expect(find.byKey(const Key('castle-rook')), findsOneWidget);
    expect(
      find.descendant(of: sq('f1'), matching: find.byType(PieceImage)),
      findsNothing,
    );
    final rookAt = tester.getTopLeft(find.byKey(const Key('castle-rook')));
    expect(rookAt.dx, greaterThan(tester.getTopLeft(sq('g1')).dx));
    await tester.pump(const Duration(milliseconds: 500));
    // Now the rook slides and the king has arrived.
    expect(find.byKey(const Key('sliding-piece')), findsNothing);
    expect(find.byKey(const Key('castle-rook')), findsOneWidget);
    expect(
      find.descendant(of: sq('g1'), matching: find.byType(PieceImage)),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('castle-rook')), findsNothing);
    expect(
      find.descendant(of: sq('f1'), matching: find.byType(PieceImage)),
      findsOneWidget,
    );
  });
}
