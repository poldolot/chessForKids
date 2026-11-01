import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../core/speaker.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/teacher_bubble.dart';
import 'badge_strings.dart';
import 'main_menu_screen.dart' show badgeIcon, kBadgeIds;

/// Every badge with its name and meaning; earned ones in colour. Tapping a
/// badge speaks its line, so a child who cannot read can browse the list.
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = context.watch<AppState>().currentProfile;
    final earned = profile?.badges ?? const <String>{};
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.badgesAll),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: TeacherBubble(
                theme: profile?.theme ?? TeacherTheme.animals,
                avatarIndex: 1,
                text: l10n.badgesYours,
                speechKey: 'menu.badges',
              ),
            ),
            Expanded(
              // All twelve rows are built at once, so each can be found and
              // spoken; the list is short.
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (final id in kBadgeIds)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: BadgeTile(
                          key: Key('badge-tile-$id'),
                          id: id,
                          earned: earned.contains(id),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One row of the badge list.
class BadgeTile extends StatelessWidget {
  const BadgeTile({super.key, required this.id, required this.earned});

  final String id;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppTheme.of(context).ui;
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () =>
            context.read<Speaker>().say(badgeLine(l10n, id), key: 'menu.badge'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: earned ? palette.accent : palette.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  badgeIcon(id),
                  size: 30,
                  color: earned
                      ? palette.text
                      : palette.muted.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badgeName(l10n, id),
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      badgeDescription(l10n, id),
                      style: TextStyle(color: palette.muted, fontSize: 15),
                    ),
                  ],
                ),
              ),
              if (earned)
                Icon(Icons.check_circle_rounded, color: palette.accentDeep),
            ],
          ),
        ),
      ),
    );
  }
}
