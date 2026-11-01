import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
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
  int _index = 0;
  int _mistakes = 0;
  bool _stepDone = false;

  Lesson get lesson => widget.lesson;
  bool get _celebrating => _index >= lesson.steps.length;
  LessonStep? get _step => _celebrating ? null : lesson.steps[_index];

  @override
  void initState() {
    super.initState();
    _enterStep();
  }

  void _enterStep() {
    _stepDone = _step is IntroStep;
  }

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
                FilledButton.icon(
                  key: const Key('lesson-next'),
                  onPressed: _stepDone ? _next : null,
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: Text(l10n.learnCommonNext),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.accent,
                    minimumSize: const Size.fromHeight(60),
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
