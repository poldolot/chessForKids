import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/board/interactive_board.dart';
import 'package:chess_for_kids/features/board/piece_image.dart';
import 'package:chess_for_kids/features/board/promotion_picker.dart';
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

  Future<void> pumpBoard(WidgetTester tester, Position position) async {
    await tester.pumpWidget(
      app.wrap(
        Scaffold(
          body: Center(
            child: InteractiveBoard(
              position: position,
              onMove: moves.add,
              size: 320,
              promotionChooser: showPromotionPicker,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'moving a pawn to the last rank asks for a piece and plays the chosen one',
    (tester) async {
      await pumpBoard(
        tester,
        Position.fromFen('8/4P3/8/8/8/8/8/K6k w - - 0 1'),
      );
      await tester.tap(sq('e7'));
      await tester.pump();
      await tester.tap(sq('e8'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('promote-q')), findsOneWidget);
      expect(moves, isEmpty);
      await tester.tap(find.byKey(const Key('promote-n')));
      await tester.pumpAndSettle();
      expect(moves, [Move.parseUci('e7e8n')]);
      expect(find.byKey(const Key('promote-q')), findsNothing);
    },
  );

  testWidgets('dismissing the picker cancels the move', (tester) async {
    await pumpBoard(tester, Position.fromFen('8/4P3/8/8/8/8/8/K6k w - - 0 1'));
    await tester.tap(sq('e7'));
    await tester.pump();
    await tester.tap(sq('e8'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(moves, isEmpty);
    expect(find.byKey(const Key('move-dot')), findsNothing);
    expect(find.byKey(const Key('promote-q')), findsNothing);
  });

  testWidgets(
    'picker shows the four pieces of the moving color, each large enough',
    (tester) async {
      await pumpBoard(
        tester,
        Position.fromFen('K6k/8/8/8/8/8/4p3/8 b - - 0 1'),
      );
      await tester.tap(sq('e2'));
      await tester.pump();
      await tester.tap(sq('e1'));
      await tester.pumpAndSettle();
      final sheetPieces = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(PieceImage),
      );
      expect(sheetPieces, findsNWidgets(4));
      for (final e in sheetPieces.evaluate()) {
        expect((e.widget as PieceImage).piece.color, PieceColor.black);
      }
      for (final k in ['promote-q', 'promote-r', 'promote-b', 'promote-n']) {
        expect(
          tester.getSize(find.byKey(Key(k))).shortestSide,
          greaterThanOrEqualTo(72),
          reason: k,
        );
      }
      await tester.tap(find.byKey(const Key('promote-r')));
      await tester.pumpAndSettle();
      expect(moves, [Move.parseUci('e2e1r')]);
    },
  );
}
