import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/learn/board_task_controller.dart';
import 'package:chess_for_kids/features/learn/lesson_model.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final lesson in lessons) {
    for (final (i, step) in lesson.steps.indexed) {
      if (step is! BoardTaskStep) {
        continue;
      }
      group('${lesson.id} step $i', () {
        test('is solvable by its own solution without mistakes', () {
          final c = BoardTaskController(step);
          expect(step.solution, isNotEmpty);
          for (final move in step.solution) {
            expect(c.isComplete, isFalse, reason: 'completed before $move');
            expect(c.allows(move), isTrue, reason: '$move is filtered out');
            expect(
              legalMoves(c.state.position, from: move.from, rules: step.rules),
              contains(move),
              reason: '$move is illegal in ${c.state.position.fen}',
            );
            c.onMove(move);
          }
          expect(c.isComplete, isTrue);
          expect(c.mistakes, 0);
        });

        test('starts with at least one allowed move', () {
          final c = BoardTaskController(step);
          expect(
            legalMoves(c.state.position, rules: step.rules).where(c.allows),
            isNotEmpty,
          );
        });

        test(
          'every sequence of good moves can still finish within the limit',
          () {
            if (step.stars.isEmpty) {
              return;
            }
            var explored = 0;
            void explore(TaskState state) {
              if (state.starsLeft.isEmpty) {
                return;
              }
              expect(
                state.movesMade,
                lessThan(step.moveLimit ?? 99),
                reason: 'limit hit at ${state.position.fen}',
              );
              final good = <(Move, Position)>[];
              for (final move in legalMoves(
                state.position,
                rules: step.rules,
              )) {
                if (!(step.moveFilter?.call(state.position, move) ?? true)) {
                  continue;
                }
                final after = state.position.play(move);
                if (step.verdict(state, move, after) == MoveVerdict.good) {
                  good.add((move, after));
                }
              }
              expect(
                good,
                isNotEmpty,
                reason:
                    'dead end at ${state.position.fen} with ${state.starsLeft}',
              );
              for (final (move, after) in good) {
                explored++;
                explore(
                  state.copyWith(
                    position: step.passive ? after.pass() : after,
                    movesMade: state.movesMade + 1,
                    goodMoves: state.goodMoves + 1,
                    starsLeft: {...state.starsLeft}..remove(move.to),
                    lastMove: move,
                  ),
                );
              }
            }

            final start = Position.fromFen(step.fen);
            explore(
              TaskState(
                position: start,
                start: start,
                rules: step.rules,
                starsLeft: step.stars,
              ),
            );
            expect(explored, greaterThan(0));
          },
        );

        test(
          'star squares are empty at start and the limit covers the solution',
          () {
            final position = Position.fromFen(step.fen);
            for (final s in step.stars) {
              expect(
                position.pieceAt(s),
                isNull,
                reason: 'star on occupied $s',
              );
            }
            expect(
              step.moveLimit == null || step.moveLimit! >= step.solution.length,
              isTrue,
            );
          },
        );
      });
    }
  }
}
