import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

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
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  final unlocked = isLessonUnlocked(lesson, profile);
                  final node = LessonNode(
                    key: Key('lesson-${lesson.id}'),
                    lesson: lesson,
                    unlocked: unlocked,
                    stars: profile.stars[starsKey(lesson)] ?? 0,
                    isNext: next?.id == lesson.id,
                    onTap: () => _open(context, lesson, unlocked),
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Align(
                      alignment: index.isEven
                          ? const Alignment(-0.5, 0)
                          : const Alignment(0.5, 0),
                      child: node,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
