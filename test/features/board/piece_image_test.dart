import 'package:chess_for_kids/app/constants.dart';
import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/board/piece_image.dart';
import 'package:chess_for_kids/features/profiles/avatar_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final allPieces = [
    for (final color in PieceColor.values)
      for (final type in PieceType.values) Piece(color, type),
  ];

  test('all piece and avatar assets exist in the bundle', () async {
    for (final piece in allPieces) {
      await expectLater(
        rootBundle.load(pieceAsset(piece)),
        completes,
        reason: pieceAsset(piece),
      );
    }
    for (final theme in TeacherTheme.values) {
      for (var i = 1; i <= 4; i++) {
        await expectLater(
          rootBundle.load(avatarAsset(theme, i)),
          completes,
          reason: avatarAsset(theme, i),
        );
      }
    }
  });

  testWidgets('piece images render without errors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Wrap(
          children: [for (final p in allPieces) PieceImage(p, size: 48)],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PieceImage), findsNWidgets(12));
    expect(tester.takeException(), isNull);
  });

  testWidgets('avatar images render without errors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Wrap(
          children: [
            for (final t in TeacherTheme.values)
              for (var i = 1; i <= 4; i++) AvatarImage(t, i, size: 48),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AvatarImage), findsNWidgets(16));
    expect(tester.takeException(), isNull);
  });
}
