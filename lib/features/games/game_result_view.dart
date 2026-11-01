import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants.dart';
import '../../app/theme/app_theme.dart';
import '../../core/speaker.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/teacher_bubble.dart';
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

/// The end of a mini-game board: records the result once, shows the final
/// position, the stars one by one and a badge when one was just earned.
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

  /// Called with the next unlocked board; the button is hidden when none.
  final ValueChanged<GameBoard> onNext;
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
      key: gameStarsKey(widget.game, widget.board),
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

  void _say(String key) {
    final l10n = AppLocalizations.of(context);
    context.read<Speaker>().say(gameLine(l10n, key), key: key);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppTheme.of(context).ui;
    final profile = context.watch<AppState>().currentProfile;
    final theme = profile?.theme ?? TeacherTheme.animals;
    final next = profile == null
        ? null
        : nextBoard(widget.game, widget.board, profile);
    final lineKey = _won ? 'games.common.won' : 'games.common.lost';
    return Column(
      key: const Key('game-result'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TeacherBubble(
          theme: theme,
          avatarIndex: 2,
          text: gameLine(l10n, lineKey),
          speechKey: lineKey,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Center(
            child: BoardView(
              position: widget.session.position,
              animateMove: widget.session.lastMove,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
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
                          size: 56,
                          color: palette.accentDeep,
                        ),
                      )
                    : Icon(
                        Icons.star_outline_rounded,
                        size: 56,
                        color: palette.muted.withValues(alpha: 0.4),
                      ),
              ),
          ],
        ),
        if (_badge != null && _badgeShown) ...[
          const SizedBox(height: 12),
          Container(
            key: const Key('result-badge'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: palette.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badgeIcon(_badge!),
                    size: 32,
                    color: palette.text,
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    gameLine(l10n, _badgeKey(_badge!)),
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (next != null) ...[
          FilledButton.icon(
            key: const Key('result-next'),
            onPressed: () => widget.onNext(next),
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: Text(gameLine(l10n, 'games.common.next')),
            style: FilledButton.styleFrom(
              backgroundColor: palette.accent,
              minimumSize: const Size.fromHeight(60),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('result-back'),
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(gameLine(l10n, 'games.common.back')),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(kMinTouchTarget),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('result-again'),
                onPressed: widget.onAgain,
                icon: const Icon(Icons.replay_rounded),
                label: Text(gameLine(l10n, 'games.common.again')),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(kMinTouchTarget),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
