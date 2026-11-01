import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/teacher_bubble.dart';
import '../learn/lesson_progress.dart';
import '../profiles/avatar_image.dart';
import '../profiles/profile_picker_screen.dart';
import 'coming_soon_screen.dart';
import 'menu_tile.dart';
import 'parent_lock_button.dart';

/// Badge identifiers in display order (spec §5.6).
const List<String> kBadgeIds = [
  'pawn',
  'rook',
  'bishop',
  'queen',
  'king',
  'knight',
  'chessPlayer',
  'firstMatch',
  'firstWin',
  'persistent',
  'hunter',
  'collector',
];

/// Icon shown for each badge id, in the menu and on the celebration screen.
IconData badgeIcon(String id) => _badgeIcons[id] ?? Icons.emoji_events_rounded;

const Map<String, IconData> _badgeIcons = {
  'pawn': Icons.looks_one_rounded,
  'rook': Icons.castle_rounded,
  'bishop': Icons.change_history_rounded,
  'queen': Icons.diamond_rounded,
  'king': Icons.workspace_premium_rounded,
  'knight': Icons.pets_rounded,
  'chessPlayer': Icons.school_rounded,
  'firstMatch': Icons.flag_rounded,
  'firstWin': Icons.emoji_events_rounded,
  'persistent': Icons.loop_rounded,
  'hunter': Icons.track_changes_rounded,
  'collector': Icons.auto_awesome_rounded,
};

/// Stars shown on a section tile (0–3). Mini-games fill in their own rule in
/// plan 4; matches earn one tile star per ten match stars.
int sectionStars(Profile profile, MenuSection section) {
  return switch (section) {
    MenuSection.play => (profile.matchStars ~/ 10).clamp(0, 3),
    MenuSection.learn => learnSectionStars(profile),
    MenuSection.miniGames => 0,
  };
}

/// The child's home screen: greeting, three section tiles, badges, parent lock.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key, this.onSection, this.onParentZone});

  final ValueChanged<MenuSection>? onSection;
  final VoidCallback? onParentZone;

  void _openSection(BuildContext context, MenuSection section) {
    if (onSection != null) {
      onSection!(section);
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const ComingSoonScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppTheme.of(context).ui;
    final profile = context.watch<AppState>().currentProfile;
    if (profile == null) {
      return const ProfilePickerScreen();
    }
    final greeting = profile.name.isEmpty
        ? l10n.greeting
        : l10n.greetingNamed(profile.name);
    final header = Row(
      children: [
        InkWell(
          key: const Key('menu-avatar'),
          borderRadius: BorderRadius.circular(32),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ProfilePickerScreen(),
            ),
          ),
          child: AvatarImage(profile.theme, profile.avatarIndex, size: 56),
        ),
        const SizedBox(width: 12),
        Icon(Icons.star_rounded, color: palette.accentDeep, size: 28),
        const SizedBox(width: 4),
        Text(
          '${profile.totalStars}',
          style: TextStyle(
            color: palette.text,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        ParentLockButton(
          key: const Key('parent-lock'),
          onUnlocked: () => onParentZone?.call(),
        ),
      ],
    );
    final bubble = TeacherBubble(
      theme: profile.theme,
      avatarIndex: 1,
      text: greeting,
      speechKey: 'menu.greeting',
    );
    final tiles = [
      MenuTile(
        key: const Key('tile-learn'),
        section: MenuSection.learn,
        title: l10n.learn,
        subtitle: l10n.learnSubtitle,
        icon: Icons.menu_book_rounded,
        color: palette.learn,
        stars: sectionStars(profile, MenuSection.learn),
        onTap: () => _openSection(context, MenuSection.learn),
      ),
      const SizedBox(height: 14),
      MenuTile(
        key: const Key('tile-miniGames'),
        section: MenuSection.miniGames,
        title: l10n.miniGames,
        subtitle: l10n.miniGamesSubtitle,
        icon: Icons.sports_esports_rounded,
        color: palette.games,
        stars: sectionStars(profile, MenuSection.miniGames),
        onTap: () => _openSection(context, MenuSection.miniGames),
      ),
      const SizedBox(height: 14),
      MenuTile(
        key: const Key('tile-play'),
        section: MenuSection.play,
        title: l10n.play,
        subtitle: l10n.playSubtitle,
        icon: Icons.emoji_events_rounded,
        color: palette.play,
        stars: sectionStars(profile, MenuSection.play),
        onTap: () => _openSection(context, MenuSection.play),
      ),
    ];
    final badges = _BadgeRow(earned: profile.badges);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Tall screens spread the content out; short ones scroll.
              if (constraints.maxHeight >= _comfortableHeight) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: 12),
                    bubble,
                    const Spacer(),
                    ...tiles,
                    const Spacer(),
                    badges,
                  ],
                );
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: 12),
                    bubble,
                    const SizedBox(height: 20),
                    ...tiles,
                    const SizedBox(height: 20),
                    badges,
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Below this height the menu scrolls instead of spreading out.
  static const double _comfortableHeight = 620;
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.earned});

  final Set<String> earned;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final id in kBadgeIds)
          Container(
            key: ValueKey('badge-$id'),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: earned.contains(id) ? palette.accent : palette.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _badgeIcons[id],
              size: 22,
              color: earned.contains(id)
                  ? palette.text
                  : palette.muted.withValues(alpha: 0.35),
            ),
          ),
      ],
    );
  }
}
