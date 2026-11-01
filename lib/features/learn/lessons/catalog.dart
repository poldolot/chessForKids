import '../lesson_model.dart';
import 'piece_lessons.dart';
import 'rule_lessons.dart';

/// Ids of the rule lessons, in order; they follow the six piece lessons.
const List<String> kRuleLessonIds = [
  'setup',
  'check',
  'mate',
  'stalemate',
  'castling',
  'enPassant',
  'promotion',
  'values',
];

/// Every lesson in the order the child meets them.
final List<Lesson> lessons = List.unmodifiable([
  ...pieceLessons,
  ...ruleLessons,
]);

/// The most stars a profile can earn in the learn section.
int get kLearnMaxStars => lessons.length * 3;

Lesson lessonById(String id) {
  for (final lesson in lessons) {
    if (lesson.id == id) {
      return lesson;
    }
  }
  throw ArgumentError.value(id, 'id', 'Unknown lesson');
}
