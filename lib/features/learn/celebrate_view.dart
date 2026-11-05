import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../core/speaker.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/teacher_bubble.dart';
import '../menu/badge_strings.dart';
import '../menu/main_menu_screen.dart';
import 'lesson_model.dart';
import 'lesson_progress.dart';
import 'lesson_strings.dart';

/// "Well done": records the result, shows the stars one by one and the
/// badge when one was earned.
class CelebrateView extends StatefulWidget {
  const CelebrateView({
    super.key,
    required this.lesson,
    required this.mistakes,
    required this.onNext,
  });

  final Lesson lesson;
  final int mistakes;
  final VoidCallback onNext;

  @override
  State<CelebrateView> createState() => _CelebrateViewState();
}

class _CelebrateViewState extends State<CelebrateView> {
  static const Duration _starDelay = Duration(milliseconds: 300);
  static const Duration _badgeDelay = Duration(milliseconds: 800);

  late final int _stars = starsForMistakes(widget.mistakes);
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
    final lesson = widget.lesson;
    await state.addStars(starsKey(lesson), _stars);
    await state.markLessonDone(lesson.id);
    final profile = state.currentProfile;
    if (profile == null) {
      return;
    }
    final badge = badgeForLesson(lesson, profile);
    if (badge == null || profile.badges.contains(badge)) {
      return;
    }
    // Award even if the child already tapped Next; only the UI is gated.
    await state.awardBadge(badge);
    if (!mounted) {
      return;
    }
    setState(() => _badge = badge);
    _timers.add(
      Timer(_badgeDelay, () {
        if (mounted) {
          setState(() => _badgeShown = true);
          _say('learn.common.badge');
        }
      }),
    );
  }

  void _say(String key) {
    final l10n = AppLocalizations.of(context);
    context.read<Speaker>().say(_badgeText(l10n), key: key);
  }

  /// "You earned a new badge: Rook!" — the generic line plus the name.
  String _badgeText(AppLocalizations l10n) {
    final line = learnLine(l10n, 'learn.common.badge');
    final badge = _badge;
    if (badge == null) {
      return line;
    }
    final base = line.endsWith('!') ? line.substring(0, line.length - 1) : line;
    return '$base: ${badgeName(l10n, badge)}!';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppTheme.of(context).ui;
    final profile = context.watch<AppState>().currentProfile;
    final theme = profile?.theme ?? TeacherTheme.animals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TeacherBubble(
          theme: theme,
          avatarIndex: 2,
          text: learnLine(l10n, 'learn.common.wellDone'),
          speechKey: 'learn.common.wellDone',
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: i < _shownStars
                    ? TweenAnimationBuilder<double>(
                        key: Key('celebrate-star-$i'),
                        tween: Tween(begin: 0.2, end: 1),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: Icon(
                          Icons.star_rounded,
                          size: 72,
                          color: palette.accentDeep,
                        ),
                      )
                    : Icon(
                        Icons.star_outline_rounded,
                        size: 72,
                        color: palette.muted.withValues(alpha: 0.4),
                      ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        if (_badge != null && _badgeShown)
          Container(
            key: const Key('celebrate-badge'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: palette.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badgeIcon(_badge!),
                    size: 36,
                    color: palette.text,
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    _badgeText(l10n),
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
        const Spacer(),
        FilledButton.icon(
          key: const Key('celebrate-next'),
          onPressed: widget.onNext,
          icon: const Icon(Icons.play_arrow_rounded, size: 28),
          label: Text(learnLine(l10n, 'learn.common.next')),
          style: FilledButton.styleFrom(
            backgroundColor: palette.accent,
            minimumSize: const Size.fromHeight(60),
          ),
        ),
      ],
    );
  }
}
