import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../engine/engine.dart';
import '../../l10n/app_localizations.dart';
import 'piece_image.dart';

const List<PieceType> _choices = [
  PieceType.queen,
  PieceType.rook,
  PieceType.bishop,
  PieceType.knight,
];

/// Bottom sheet with the four promotion pieces of [color]. The queen comes
/// first and larger as the usual choice. Dismissing the sheet returns `null`.
Future<PieceType?> showPromotionPicker(BuildContext context, PieceColor color) {
  final palette = AppTheme.of(context).ui;
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<PieceType>(
    context: context,
    backgroundColor: palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.choosePromotion,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final type in _choices)
                  _PromotionChoice(
                    key: Key('promote-${type.letter}'),
                    piece: Piece(color, type),
                    highlighted: type == PieceType.queen,
                    onTap: () => Navigator.of(context).pop(type),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _PromotionChoice extends StatelessWidget {
  const _PromotionChoice({
    super.key,
    required this.piece,
    required this.highlighted,
    required this.onTap,
  });

  final Piece piece;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    final size = highlighted ? 84.0 : 72.0;
    return Material(
      color: highlighted ? palette.accent : palette.background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: PieceImage(piece),
          ),
        ),
      ),
    );
  }
}
