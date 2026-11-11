import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/learn/lesson_model.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lessons are ordered as the spec says and have unique ids', () {
    final ids = lessons.map((l) => l.id).toList();
    expect(ids.first, 'chess');
    expect(ids.skip(1).take(6), [
      'pawn',
      'rook',
      'bishop',
      'queen',
      'king',
      'knight',
    ]);
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
    expect(ids.length, 15);
    expect(ids.skip(7).toList(), kRuleLessonIds);
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
    for (final lesson in lessons.skip(7)) {
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

  test('the opening lesson tells the story with two tasks', () {
    final chess = lessonById('chess');
    expect(chess.kind, LessonKind.story);
    expect(chess.steps.first, isA<IntroStep>());
    expect(chess.steps.last, isA<IntroStep>());
    expect(chess.taskCount, 2);
    expect(chess.steps.whereType<FindStep>().single.targets.length, 2);
    final spotlights = chess.steps.whereType<SpotlightStep>().toList();
    expect(spotlights.length, 2);
    final all = spotlights[0].parts.expand((p) => p.$1).toSet();
    expect(all.length, 32, reason: 'every piece of the start position');
    // The second spotlight explains the mate: the guarded queen first.
    final why = spotlights[1];
    expect(
      evaluatePosition(Position.fromFen(why.fen)).outcome,
      GameOutcome.checkmate,
    );
    expect(why.parts.first.$1, {Square.parse('c4'), Square.parse('f7')});
    expect(why.parts.last.$1, {Square.parse('e8')});
    final demos = chess.steps.whereType<DemoStep>().toList();
    expect(chess.steps.indexOf(why), chess.steps.indexOf(demos.last) + 1);
    final mate = chess.steps.whereType<BoardTaskStep>().single;
    final after = Position.fromFen(mate.fen).play(mate.solution.single);
    expect(evaluatePosition(after).outcome, GameOutcome.checkmate);
    for (final demo in chess.steps.whereType<DemoStep>()) {
      var position = Position.fromFen(demo.fen);
      for (final (move, _) in demo.moves) {
        expect(legalMoves(position), contains(move), reason: demo.lineKey);
        position = position.play(move);
      }
    }
  });

  test('lessonById finds lessons and rejects unknown ids', () {
    expect(lessonById('rook').titleKey, 'learn.rook.title');
    expect(() => lessonById('nope'), throwsArgumentError);
  });

  test('max stars is three per lesson', () {
    expect(kLearnMaxStars, lessons.length * 3);
  });
}
