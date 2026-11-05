import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../core/speaker.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/teacher_bubble.dart';
import 'celebrate_view.dart';
import 'lesson_model.dart';
import 'lesson_strings.dart';
import 'steps/arrange_step_view.dart';
import 'steps/board_task_view.dart';
import 'steps/compare_step_view.dart';
import 'steps/demo_step_view.dart';
import 'steps/intro_step_view.dart';
import 'widgets/step_dots.dart';

/// Plays a lesson step by step, counts mistakes and ends with a celebration.
class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.lesson,
    this.onFinished,
    this.queueFirstLine = false,
  });

  final Lesson lesson;

  /// When the lesson is opened right after another line was spoken (a
  /// locked mini-game), the first step's line waits for it instead of
  /// cutting it off.
  final bool queueFirstLine;

  /// Called when the child leaves the celebration; defaults to popping.
  final VoidCallback? onFinished;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  /// How long at most a first explanation holds the Next button, in case
  /// the speech engine never reports the end of the line.
  static const Duration _maxHold = Duration(seconds: 20);

  int _index = 0;
  int _mistakes = 0;
  bool _stepDone = false;
  bool _firstVisit = false;
  bool _holdExpired = false;
  Timer? _holdTimer;

  Lesson get lesson => widget.lesson;
  bool get _celebrating => _index >= lesson.steps.length;
  LessonStep? get _step => _celebrating ? null : lesson.steps[_index];

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppState>().currentProfile;
    _firstVisit = !(profile?.lessonsDone.contains(lesson.id) ?? false);
    _enterStep();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _enterStep() {
    _stepDone = _step is IntroStep;
    _holdTimer?.cancel();
    _holdExpired = false;
    if (_holdsForSpeech) {
      _holdTimer = Timer(_maxHold, () {
        if (mounted) {
          setState(() => _holdExpired = true);
        }
      });
    }
  }

  /// The first time a child meets a lesson, the explanation is heard to the
  /// end before Next works; later visits (and tasks) are never held.
  bool get _holdsForSpeech =>
      _firstVisit && _step is IntroStep && !_holdExpired;

  void _next() {
    if (_celebrating) {
      return;
    }
    setState(() {
      _index++;
      _enterStep();
    });
  }

  /// A task step is finished: only the Next button moves on, so the child
  /// can keep playing with the board for as long as they like.
  void _onTaskDone() {
    if (!_stepDone) {
      setState(() => _stepDone = true);
    }
  }

  void _onMistake() => setState(() => _mistakes++);

  void _finish() {
    final onFinished = widget.onFinished;
    if (onFinished != null) {
      onFinished();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Widget _stepView(LessonStep step) {
    return switch (step) {
      IntroStep() => IntroStepView(step: step),
      DemoStep() => DemoStepView(step: step, onDone: _onTaskDone),
      BoardTaskStep() => BoardTaskView(
        key: ValueKey('task-$_index'),
        step: step,
        onDone: _onTaskDone,
        onMistake: _onMistake,
      ),
      ArrangeStep() => ArrangeStepView(
        key: ValueKey('task-$_index'),
        step: step,
        onDone: _onTaskDone,
        onMistake: _onMistake,
      ),
      CompareStep() => CompareStepView(
        key: ValueKey('task-$_index'),
        step: step,
        onDone: _onTaskDone,
        onMistake: _onMistake,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppTheme.of(context).ui;
    final profile = context.watch<AppState>().currentProfile;
    final theme = profile?.theme ?? TeacherTheme.animals;
    final step = _step;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    key: const Key('lesson-back'),
                    iconSize: 32,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: StepDots(
                      count: lesson.steps.length + 1,
                      current: _index,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 8),
              if (step != null) ...[
                TeacherBubble(
                  theme: theme,
                  avatarIndex: 2,
                  text: learnLine(l10n, step.lineKey),
                  speechKey: step.lineKey,
                  interrupt: !(widget.queueFirstLine && _index == 0),
                ),
                const SizedBox(height: 12),
                Expanded(child: _stepView(step)),
                const SizedBox(height: 12),
                ValueListenableBuilder<bool>(
                  valueListenable: context.read<Speaker>().speaking,
                  builder: (context, speaking, _) => FilledButton.icon(
                    key: const Key('lesson-next'),
                    onPressed: _stepDone && !(_holdsForSpeech && speaking)
                        ? _next
                        : null,
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: Text(l10n.learnCommonNext),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.accent,
                      minimumSize: const Size.fromHeight(60),
                    ),
                  ),
                ),
              ] else
                Expanded(
                  child: CelebrateView(
                    lesson: lesson,
                    mistakes: _mistakes,
                    onNext: _finish,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
