import 'package:flutter/material.dart';

import '../../../app/constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../board/piece_image.dart';
import '../game_model.dart';

/// One game on the Mini-games screen: picture, title, stars, lock.
class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.game,
    required this.title,
    required this.unlocked,
    required this.earnedStars,
    required this.maxStars,
    required this.onTap,
  });

  final MiniGame game;
  final String title;
  final bool unlocked;
  final int earnedStars;
  final int maxStars;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Material(
      color: unlocked ? palette.surface : palette.muted.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kMinTouchTarget + 24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Opacity(
                  opacity: unlocked ? 1 : 0.4,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: game.piece != null
                        ? PieceImage(game.piece!)
                        : Icon(game.icon, size: 44, color: palette.text),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: unlocked ? palette.text : palette.muted,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: palette.accentDeep,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$earnedStars / $maxStars',
                            style: TextStyle(
                              color: palette.muted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!unlocked)
                  Icon(Icons.lock_rounded, color: palette.muted, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
