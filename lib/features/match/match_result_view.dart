import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../core/speaker.dart';
import '../../data/models.dart';
import '../../engine/engine.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/game_layout.dart';
import '../../widgets/teacher_bubble.dart';
import '../board/board_highlights.dart';
import '../board/board_view.dart';
import '../menu/main_menu_screen.dart' show badgeIcon;
import 'match_progress.dart';
import 'match_session.dart';
import 'match_strings.dart';

/// The end of a match: records the result once, clears the saved game,
/// keeps the final position where the board was, shows the stars, a trophy
/// (win), a handshake (draw) or a heart (loss) and any badge just earned.
class MatchResultView extends StatefulWidget {
  const MatchResultView({
    super.key,
    required this.session,
    required this.onAgain,
    required this.onBack,
  });

  final MatchSession session;
  final VoidCallback onAgain;
  final VoidCallback onBack;

  @override
  State<MatchResultView> createState() => _MatchResultViewState();
}

class _MatchResultViewState extends State<MatchResultView> {
  static const Duration _starDelay = Duration(milliseconds: 300);
  static const Duration _badgeDelay = Duration(milliseconds: 800);

  late final int _stars = widget.session.stars;
  int _shownStars = 0;
  String? _badge;
  bool _badgeShown = false;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    // Recording notifies AppState listeners, which must not happen while
    // the first frame is still being built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _record();
      }
    });
    for (var i = 1; i <= _stars; i++) {
      _timers.add(
        Timer(_starDelay * i, () {
          if (mounted) {
            setState(() => _shownStars = i);
          }
        }),
      );
    }
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  Future<void> _record() async {
    final state = context.read<AppState>();
    if (state.currentProfile == null) {
      return;
    }
    await state.recordMatch(stars: _stars, won: widget.session.childWon);
    await state.saveMatch(null);
    final profile = state.currentProfile;
    if (profile == null) {
      return;
    }
    final earned = matchBadges(profile);
    if (earned.isEmpty) {
      return;
    }
    for (final badge in earned) {
      await state.awardBadge(badge);
    }
    if (!mounted) {
      return;
    }
    setState(() => _badge = earned.first);
    _timers.add(
      Timer(_badgeDelay, () {
        if (mounted) {
          setState(() => _badgeShown = true);
          final l10n = AppLocalizations.of(context);
          final key = _badgeKey(earned.first);
          // Queued behind the result line rather than cutting it off.
          context.read<Speaker>().say(
            matchLine(l10n, key),
            key: key,
            interrupt: false,
          );
        }
      }),
    );
  }

  static String _badgeKey(String badge) => switch (badge) {
    'firstMatch' => 'match.badgeFirstMatch',
    'firstWin' => 'match.badgeFirstWin',
    'persistent' => 'match.badgePersistent',
    _ => 'match.badgeCollector',
  };

  String get _lineKey {
    final session = widget.session;
    return switch (session.result.outcome) {
      GameOutcome.checkmate => session.childWon ? 'match.won' : 'match.lost',
      GameOutcome.resignation => 'match.resigned',
      GameOutcome.stalemate => 'match.stalemate',
      _ => 'match.draw',
    };
  }

  (String key, IconData icon) get _picture {
    final session = widget.session;
    if (session.childWon) {
      return ('result-icon-trophy', Icons.emoji_events_rounded);
    }
    if (session.result.isDraw) {
      return ('result-icon-handshake', Icons.handshake_rounded);
    }
    return ('result-icon-consolation', Icons.favorite_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppTheme.of(context).ui;
    final profile = context.watch<AppState>().currentProfile;
    final theme = profile?.theme ?? TeacherTheme.animals;
    final session = widget.session;
    final lineKey = _lineKey;
    final (pictureKey, pictureIcon) = _picture;
    return GameLayout(
      key: const Key('match-result'),
      bubble: TeacherBubble(
        theme: theme,
        avatarIndex: 4,
        text: matchLine(l10n, lineKey),
        speechKey: lineKey,
      ),
      slot: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: i < _shownStars
                  ? TweenAnimationBuilder<double>(
                      key: Key('result-star-$i'),
                      tween: Tween(begin: 0.2, end: 1),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Icon(
                        Icons.star_rounded,
                        size: GameLayout.slotHeight,
                        color: palette.accentDeep,
                      ),
                    )
                  : Icon(
                      Icons.star_outline_rounded,
                      size: GameLayout.slotHeight,
                      color: palette.muted.withValues(alpha: 0.4),
                    ),
            ),
        ],
      ),
      board: BoardView(
        position: session.position,
        orientation: session.childColor,
        highlights: BoardHighlights(lastMove: session.lastMove),
      ),
      overlay: _badge != null && _badgeShown
          ? _OverlayCard(
              key: const Key('result-badge'),
              icon: badgeIcon(_badge!),
              text: matchLine(l10n, _badgeKey(_badge!)),
            )
          : _OverlayCard(key: Key(pictureKey), icon: pictureIcon),
      controls: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              key: const Key('result-back'),
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(matchLine(l10n, 'match.back')),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(GameLayout.controlsHeight),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              key: const Key('result-again'),
              onPressed: widget.onAgain,
              icon: const Icon(Icons.replay_rounded),
              label: Text(matchLine(l10n, 'match.again')),
              style: FilledButton.styleFrom(
                backgroundColor: palette.accent,
                minimumSize: const Size.fromHeight(GameLayout.controlsHeight),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A round card floating over the board: the result picture, or a badge
/// with its line.
class _OverlayCard extends StatelessWidget {
  const _OverlayCard({super.key, required this.icon, this.text});

  final IconData icon;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: palette.text.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: palette.accent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: palette.text),
          ),
          if (text case final text?) ...[
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
