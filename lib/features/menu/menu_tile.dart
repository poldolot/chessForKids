import 'package:flutter/material.dart';

import '../../app/constants.dart';
import '../../app/theme/app_theme.dart';

/// The three sections reachable from the main menu.
enum MenuSection { learn, miniGames, play }

/// A big colored tile with an icon, a title, a subtitle and 0–3 stars.
class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.section,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.stars,
    required this.onTap,
    this.progress,
    this.counter,
  });

  final MenuSection section;
  final String title;
  final String subtitle;

  /// 0..1, how far the section is towards its full stars; drawn as a thin
  /// bar under the subtitle when given.
  final double? progress;

  /// "25/30": stars earned out of the section's total, under the stars.
  final String? counter;
  final IconData icon;
  final Color color;
  final int stars;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(22),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kMinTouchTarget + 24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 44, color: palette.text),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: palette.text,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: palette.text.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                      ),
                      if (progress case final progress?) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: SizedBox(
                            height: 6,
                            child: LinearProgressIndicator(
                              key: const Key('tile-progress'),
                              value: progress.clamp(0, 1),
                              backgroundColor: palette.text.withValues(
                                alpha: 0.15,
                              ),
                              color: palette.text.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StarRow(stars: stars),
                    if (counter case final counter?) ...[
                      const SizedBox(height: 4),
                      Text(
                        counter,
                        key: const Key('tile-counter'),
                        style: TextStyle(
                          color: palette.text.withValues(alpha: 0.75),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Three star outlines, [stars] of them filled.
class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.stars, this.size = 22});

  final int stars;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Icon(
            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: i < stars
                ? palette.accentDeep
                : palette.text.withValues(alpha: 0.4),
          ),
      ],
    );
  }
}
