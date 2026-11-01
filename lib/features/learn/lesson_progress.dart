import '../../data/models.dart';
import 'lesson_model.dart';
import 'lessons/catalog.dart';

/// The first lesson is always open; every other one opens when the
/// previous lesson is done.
bool isLessonUnlocked(Lesson lesson, Profile profile) {
  final index = lessons.indexOf(lesson);
  if (index <= 0) {
    return true;
  }
  return profile.lessonsDone.contains(lessons[index - 1].id);
}

/// 0 mistakes → 3 stars, 1–2 → 2, more → 1 (spec §5.3).
int starsForMistakes(int mistakes) {
  if (mistakes == 0) {
    return 3;
  }
  return mistakes <= 2 ? 2 : 1;
}

/// The badge a finished lesson earns, given the profile after it was marked
/// done: piece lessons give their own badge, the rule lessons together give
/// `chessPlayer`.
String? badgeForLesson(Lesson lesson, Profile profileAfterDone) {
  if (lesson.kind == LessonKind.piece) {
    return lesson.id;
  }
  final allRulesDone = kRuleLessonIds.every(
    profileAfterDone.lessonsDone.contains,
  );
  return allRulesDone ? 'chessPlayer' : null;
}

String starsKey(Lesson lesson) => 'lesson:${lesson.id}';

/// Stars earned across all lessons.
int learnEarnedStars(Profile profile) =>
    lessons.fold(0, (sum, l) => sum + (profile.stars[starsKey(l)] ?? 0));

/// Stars shown on the Learn tile: none until the first star, then 1–3 in
/// proportion to the stars earned.
int learnSectionStars(Profile profile) {
  final earned = learnEarnedStars(profile);
  if (earned == 0) {
    return 0;
  }
  return (1 + (2 * earned) ~/ kLearnMaxStars).clamp(1, 3);
}

/// The first lesson that is unlocked but not done, or `null` when all are.
Lesson? nextLesson(Profile profile) {
  for (final lesson in lessons) {
    if (!profile.lessonsDone.contains(lesson.id) &&
        isLessonUnlocked(lesson, profile)) {
      return lesson;
    }
  }
  return null;
}
