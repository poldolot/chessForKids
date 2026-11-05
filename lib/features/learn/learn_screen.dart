import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../core/speaker.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/teacher_bubble.dart';
import '../profiles/profile_picker_screen.dart';
import 'lesson_model.dart';
import 'lesson_progress.dart';
import 'lesson_screen.dart';
import 'lesson_strings.dart';
import 'lessons/catalog.dart';
import 'widgets/lesson_node.dart';

/// The lesson path: one node per lesson, winding left and right.
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  /// The nodes zigzag left and right, so each one may start a fifth of the
  /// way up the previous icon (stars not counted): a tight, winding path.
  static const double _stride = LessonNode.circleSize * 4 / 5;
  static const double _nodeHeight = LessonNode.circleSize + 30;

  final ScrollController _scroll = ScrollController();
  bool _moreBelow = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_updateMore);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateMore());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _updateMore() {
    if (!_scroll.hasClients) {
      return;
    }
    final position = _scroll.position;
    final more = position.maxScrollExtent - position.pixels > 8;
    if (more != _moreBelow && mounted) {
      setState(() => _moreBelow = more);
    }
  }

  void _scrollDown() {
    if (!_scroll.hasClients) {
      return;
    }
    _scroll.animateTo(
      (_scroll.position.pixels + 320).clamp(
        0,
        _scroll.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _open(BuildContext context, Lesson lesson, bool unlocked) {
    if (!unlocked) {
      final l10n = AppLocalizations.of(context);
      context.read<Speaker>().say(
        learnLine(l10n, 'learn.common.locked'),
        key: 'learn.common.locked',
        interrupt: false,
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LessonScreen(lesson: lesson)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = context.watch<AppState>().currentProfile;
    if (profile == null) {
      return const ProfilePickerScreen();
    }
    final next = nextLesson(profile);
    final lineKey = next?.titleKey ?? 'learn.common.allDone';
    return Scaffold(
      appBar: AppBar(
        title: Text(learnLine(l10n, 'learn.title')),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TeacherBubble(
                theme: profile.theme,
                avatarIndex: 2,
                text: learnLine(l10n, lineKey),
                speechKey: lineKey,
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  NotificationListener<ScrollMetricsNotification>(
                    onNotification: (_) {
                      _updateMore();
                      return false;
                    },
                    child: SingleChildScrollView(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: SizedBox(
                        height: (lessons.length - 1) * _stride + _nodeHeight,
                        child: Stack(
                          children: [
                            for (final (index, lesson) in lessons.indexed)
                              Positioned(
                                top: index * _stride,
                                left: 0,
                                right: 0,
                                child: Align(
                                  alignment: index.isEven
                                      ? const Alignment(-0.5, 0)
                                      : const Alignment(0.5, 0),
                                  child: LessonNode(
                                    key: Key('lesson-${lesson.id}'),
                                    lesson: lesson,
                                    unlocked: isLessonUnlocked(lesson, profile),
                                    stars: profile.stars[starsKey(lesson)] ?? 0,
                                    isNext: next?.id == lesson.id,
                                    onTap: () => _open(
                                      context,
                                      lesson,
                                      isLessonUnlocked(lesson, profile),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_moreBelow)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 4,
                      child: Center(
                        child: _MoreBelowArrow(
                          key: const Key('learn-more'),
                          onTap: _scrollDown,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A bouncing chevron telling a child the path goes on below the screen.
class _MoreBelowArrow extends StatefulWidget {
  const _MoreBelowArrow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<_MoreBelowArrow> createState() => _MoreBelowArrowState();
}

class _MoreBelowArrowState extends State<_MoreBelowArrow>
    with SingleTickerProviderStateMixin {
  /// Bounces a few times, then rests: a loop would never let the screen
  /// settle (and keeps drawing for nothing).
  static const int _bounces = 6;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  int _done = 0;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed && ++_done < _bounces) {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, reduceMotion ? 0 : 6 * _controller.value),
        child: child,
      ),
      child: Material(
        color: palette.accent,
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 34,
              color: palette.text,
            ),
          ),
        ),
      ),
    );
  }
}
