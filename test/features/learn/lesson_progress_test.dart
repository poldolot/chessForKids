import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/features/learn/lesson_progress.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

const fresh = Profile(
  id: 'p',
  name: '',
  theme: TeacherTheme.animals,
  avatarIndex: 1,
);

void main() {
  test('only the first lesson is unlocked for a fresh profile', () {
    expect(isLessonUnlocked(lessons[0], fresh), isTrue);
    for (final lesson in lessons.skip(1)) {
      expect(isLessonUnlocked(lesson, fresh), isFalse, reason: lesson.id);
    }
  });

  test('finishing a lesson unlocks the next one only', () {
    final p = fresh.copyWith(lessonsDone: {'pawn'});
    expect(isLessonUnlocked(lessonById('rook'), p), isTrue);
    expect(isLessonUnlocked(lessonById('bishop'), p), isFalse);
  });

  test('stars from mistakes follow the spec', () {
    expect(starsForMistakes(0), 3);
    expect(starsForMistakes(1), 2);
    expect(starsForMistakes(2), 2);
    expect(starsForMistakes(3), 1);
    expect(starsForMistakes(40), 1);
  });

  test('piece lessons award their badge, rules award chessPlayer once all are done', () {
    expect(
      badgeForLesson(lessonById('rook'), fresh.copyWith(lessonsDone: {'rook'})),
      'rook',
    );
    final sevenRules = fresh.copyWith(
      lessonsDone: kRuleLessonIds.take(7).toSet(),
    );
    expect(badgeForLesson(lessonById('check'), sevenRules), isNull);
    final allRules = fresh.copyWith(lessonsDone: kRuleLessonIds.toSet());
    expect(badgeForLesson(lessonById('values'), allRules), 'chessPlayer');
  });

  test('learn section stars grow with earned stars', () {
    expect(learnEarnedStars(fresh), 0);
    expect(learnSectionStars(fresh), 0);
    expect(learnSectionStars(fresh.copyWith(stars: {'lesson:pawn': 1})), 1);
    final half = {for (final l in lessons.take(7)) 'lesson:${l.id}': 3};
    expect(learnSectionStars(fresh.copyWith(stars: half)), 2);
    final all = {for (final l in lessons) 'lesson:${l.id}': 3};
    expect(learnEarnedStars(fresh.copyWith(stars: all)), kLearnMaxStars);
    expect(learnSectionStars(fresh.copyWith(stars: all)), 3);
    expect(learnSectionStars(fresh.copyWith(stars: {'game:pawnwar:1': 3})), 0);
  });

  test('nextLesson skips done lessons and is null at the end', () {
    expect(nextLesson(fresh)?.id, 'pawn');
    expect(
      nextLesson(fresh.copyWith(lessonsDone: {'pawn', 'rook'}))?.id,
      'bishop',
    );
    expect(
      nextLesson(fresh.copyWith(lessonsDone: lessons.map((l) => l.id).toSet())),
      isNull,
    );
  });
}
