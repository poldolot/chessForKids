import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants.dart';
import '../../app/theme/app_theme.dart';
import '../../core/speaker.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/game_layout.dart';
import '../../widgets/teacher_bubble.dart';
import '../board/board_highlights.dart';
import '../board/board_view.dart';
import '../menu/main_menu_screen.dart' show badgeIcon;
import 'game_model.dart';
import 'game_progress.dart';
import 'game_strings.dart';
import 'mini_game_session.dart';

/// Wins needed for the hunter badge.
const int kHunterWins = 10;

/// Total stars needed for the collector badge.
const int kCollectorStars = 50;

/// The end of a mini-game board: records the result once, keeps the final
/// position where the board was, shows the stars one by one and a badge
/// when one was just earned.
class GameResultView extends StatefulWidget {
  const GameResultView({
    super.key,
    required this.game,
    required this.board,
    required this.session,
    required this.onAgain,
    required this.onNext,
    required this.onBack,
  });

  final MiniGame game;
  final GameBoard board;
  final MiniGameSession session;
  final VoidCallback onAgain;

  /// Called with the next unlocked level; the button is hidden when none.
  final ValueChanged<GameLevel> onNext;
  final VoidCallback onBack;

  @override
  State<GameResultView> createState() => _GameResultViewState();
}

class _GameResultViewState extends State<GameResultView> {
  static const Duration _starDelay = Duration(milliseconds: 300);
  static const Duration _badgeDelay = Duration(milliseconds: 800);

  late final int _stars = widget.session.stars;
  late final bool _won = widget.session.outcome == SessionOutcome.won;
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
    await state.recordMiniGame(
      key: gameStarsKey(widget.game, widget.board.index),
      stars: _stars,
      won: _won,
    );
    final profile = state.currentProfile;
    if (profile == null) {
      return;
    }
    final earned = <String>[
      if (profile.miniGameWins >= kHunterWins) 'hunter',
      if (profile.totalStars >= kCollectorStars) 'collector',
    ].where((b) => !profile.badges.contains(b)).toList();
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
          _say(_badgeKey(earned.first));
        }
      }),
    );
  }

  static String _badgeKey(String badge) => badge == 'hunter'
      ? 'games.common.badgeHunter'
      : 'games.common.badgeCollector';

  /// Queued behind the result line rather than cutting it off.
  void _say(String key) {
    final l10n = AppLocalizations.of(context);
    context.read<Speaker>().say(
      gameLine(l10n, key),
      key: key,
      interrupt: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppTheme.of(context).ui;
    final profile = context.watch<AppState>().currentProfile;
    final theme = profile?.theme ?? TeacherTheme.animals;
    final next = profile == null
        ? null
        : nextLevel(
            widget.game,
            widget.game.levels[widget.board.index],
            profile,
          );
    final lineKey = _won ? 'games.common.won' : 'games.common.lost';
    return GameLayout(
      key: const Key('game-result'),
      bubble: TeacherBubble(
        theme: theme,
        avatarIndex: 2,
        text: gameLine(l10n, lineKey),
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
        position: widget.session.position,
        highlights: BoardHighlights(lastMove: widget.session.lastMove),
      ),
      overlay: _badge != null && _badgeShown
          ? _BadgeCard(badge: _badge!, text: gameLine(l10n, _badgeKey(_badge!)))
          : null,
      controls: Row(
        children: [
          if (next != null) ...[
            _RoundButton(
              key: const Key('result-back'),
              icon: Icons.arrow_back_rounded,
              tooltip: gameLine(l10n, 'games.common.back'),
              onPressed: widget.onBack,
            ),
            const SizedBox(width: 12),
            _RoundButton(
              key: const Key('result-again'),
              icon: Icons.replay_rounded,
              tooltip: gameLine(l10n, 'games.common.again'),
              onPressed: widget.onAgain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                key: const Key('result-next'),
                onPressed: () => widget.onNext(next),
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: Text(gameLine(l10n, 'games.common.next')),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.accent,
                  minimumSize: const Size.fromHeight(GameLayout.controlsHeight),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('result-back'),
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(gameLine(l10n, 'games.common.back')),
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
                label: Text(gameLine(l10n, 'games.common.again')),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.accent,
                  minimumSize: const Size.fromHeight(GameLayout.controlsHeight),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A square outlined icon button the size of the controls strip.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: GameLayout.controlsHeight,
      height: GameLayout.controlsHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size.square(kMinTouchTarget),
        ),
        child: Tooltip(message: tooltip, child: Icon(icon, size: 30)),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge, required this.text});

  final String badge;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Container(
      key: const Key('result-badge'),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(22),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: palette.accent,
              shape: BoxShape.circle,
            ),
            child: Icon(badgeIcon(badge), size: 32, color: palette.text),
          ),
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
      ),
    );
  }
}
