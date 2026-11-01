import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/learn/lesson_model.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lessons are ordered as the spec says and have unique ids', () {
    final ids = lessons.map((l) => l.id).toList();
    expect(ids.take(6), ['pawn', 'rook', 'bishop', 'queen', 'king', 'knight']);
    expect(ids.toSet().length, ids.length);
  });

  test('piece lessons have a piece, three task steps and an intro first', () {
    for (final lesson in lessons.where((l) => l.kind == LessonKind.piece)) {
      expect(lesson.piece, isNotNull, reason: lesson.id);
      expect(lesson.taskCount, 3, reason: lesson.id);
      expect(lesson.steps.first, isA<IntroStep>(), reason: lesson.id);
      expect(lesson.titleKey, 'learn.${lesson.id}.title');
    }
  });

  test('rule lessons follow the piece lessons in spec order', () {
    final ids = lessons.map((l) => l.id).toList();
    expect(ids.length, 14);
    expect(ids.skip(6).toList(), kRuleLessonIds);
    expect(kRuleLessonIds, [
      'setup',
      'check',
      'mate',
      'stalemate',
      'castling',
      'enPassant',
      'promotion',
      'values',
    ]);
    for (final lesson in lessons.skip(6)) {
      expect(lesson.kind, LessonKind.rule, reason: lesson.id);
      expect(lesson.icon, isNotNull, reason: lesson.id);
      expect(lesson.steps.first, isA<IntroStep>(), reason: lesson.id);
      expect(lesson.taskCount, greaterThanOrEqualTo(1), reason: lesson.id);
    }
  });

  test(
    'compare pairs have different values and the setup tray matches its target',
    () {
      final values = lessonById('values');
      final compare = values.steps.whereType<CompareStep>().single;
      expect(compare.pairs.length, 5);
      var leftWins = 0;
      for (final (a, b) in compare.pairs) {
        expect(a.type.value, isNot(b.type.value));
        if (a.type.value > b.type.value) {
          leftWins++;
        }
      }
      expect(
        leftWins,
        inInclusiveRange(2, 3),
        reason: 'the correct card must appear on both sides',
      );
      final setup = lessonById('setup');
      final arrange = setup.steps.whereType<ArrangeStep>().single;
      final target = Position.fromFen(arrange.targetFen);
      final targetPieces = target.pieces().map((e) => e.$2).toList()
        ..sort((x, y) => x.fenChar.compareTo(y.fenChar));
      final tray = [...arrange.tray]
        ..sort((x, y) => x.fenChar.compareTo(y.fenChar));
      expect(tray, targetPieces);
      expect(tray.length, 8);
    },
  );

  test('lessonById finds lessons and rejects unknown ids', () {
    expect(lessonById('rook').titleKey, 'learn.rook.title');
    expect(() => lessonById('nope'), throwsArgumentError);
  });

  test('max stars is three per lesson', () {
    expect(kLearnMaxStars, lessons.length * 3);
  });
}
