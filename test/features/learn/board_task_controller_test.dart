import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/learn/board_task_controller.dart';
import 'package:chess_for_kids/features/learn/lesson_model.dart';
import 'package:chess_for_kids/features/learn/lessons/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

Square sq(String s) => Square.parse(s);
Move uci(String s) => Move.parseUci(s);

const rookFen = '8/8/8/8/3R4/8/8/8 w - - 0 1';

BoardTaskStep step({
  String fen = rookFen,
  Goal? goal,
  List<Move> solution = const [],
  Verdict? verdict,
  bool Function(Position, Move)? moveFilter,
  Set<Square> stars = const {},
  int? moveLimit,
  bool passive = true,
  bool showDanger = false,
}) {
  return BoardTaskStep(
    lineKey: 'k',
    fen: fen,
    goal: goal ?? (s) => s.starsLeft.isEmpty && s.goodMoves >= 1,
    solution: solution,
    verdict: verdict ?? anyMoveGood,
    moveFilter: moveFilter,
    stars: stars,
    moveLimit: moveLimit,
    passive: passive,
    showDanger: showDanger,
  );
}

void main() {
  test('collecting stars within the limit completes the task', () {
    final c = BoardTaskController(
      step(
        stars: {sq('d8'), sq('h8')},
        moveLimit: 2,
        solution: [uci('d4d8'), uci('d8h8')],
      ),
    );
    expect(c.onMove(uci('d4d8')), TaskEvent.good);
    expect(c.starsLeft, {sq('h8')});
    expect(c.state.position.sideToMove, PieceColor.white);
    expect(c.onMove(uci('d8h8')), TaskEvent.complete);
    expect(c.isComplete, isTrue);
    expect(c.mistakes, 0);
    expect(c.state.movesMade, 2);
  });

  test('a move off the stars is wasted and the limit resets the board', () {
    final c = BoardTaskController(
      step(
        stars: {sq('d8'), sq('h8')},
        moveLimit: 2,
        verdict: (before, move, after) => before.starsLeft.contains(move.to)
            ? MoveVerdict.good
            : MoveVerdict.wasted,
      ),
    );
    expect(c.onMove(uci('d4d5')), TaskEvent.wasted);
    expect(c.mistakes, 1);
    expect(c.onMove(uci('d5d6')), TaskEvent.reset);
    expect(c.mistakes, 2);
    expect(c.state.position.fen, rookFen);
    expect(c.state.movesMade, 0);
    expect(c.starsLeft.length, 2);
    expect(c.isComplete, isFalse);
  });

  test('fail verdict shows the move and waits for reset', () {
    final c = BoardTaskController(step(verdict: (b, m, a) => MoveVerdict.fail));
    expect(c.onMove(uci('d4d5')), TaskEvent.fail);
    expect(c.mistakes, 1);
    expect(c.isAwaitingReset, isTrue);
    expect(c.state.position.pieceAt(sq('d5')), isNotNull);
    expect(() => c.onMove(uci('d5d6')), throwsStateError);
    c.onRejected();
    expect(c.mistakes, 1);
    c.reset();
    expect(c.isAwaitingReset, isFalse);
    expect(c.state.position.fen, rookFen);
  });

  test('in a non-passive task a wasted move is shown and taken back, the child stays to move', () {
    final c = BoardTaskController(
      step(
        fen: '4k3/8/8/8/8/8/8/4K2R w K - 0 1',
        passive: false,
        goal: (s) => s.goodMoves >= 1,
        verdict: (b, m, a) =>
            m == uci('e1g1') ? MoveVerdict.good : MoveVerdict.wasted,
      ),
    );
    expect(c.onMove(uci('h1h2')), TaskEvent.fail);
    expect(c.state.position.sideToMove, PieceColor.black);
    c.reset();
    expect(c.state.position.sideToMove, PieceColor.white);
    expect(c.childColor, PieceColor.white);
    expect(c.onMove(uci('e1g1')), TaskEvent.complete);
  });

  test('double pawn steps are counted', () {
    final c = BoardTaskController(
      step(fen: '8/8/8/8/8/8/4P3/8 w - - 0 1', goal: (s) => s.doubleSteps >= 1),
    );
    expect(c.onMove(uci('e2e4')), TaskEvent.complete);
    expect(c.state.doubleSteps, 1);
  });

  test('illegal or filtered moves throw', () {
    final c = BoardTaskController(step());
    expect(() => c.onMove(uci('d4e5')), throwsArgumentError);
    final f = BoardTaskController(step(moveFilter: (p, m) => m.to == sq('d8')));
    expect(f.allows(uci('d4d5')), isFalse);
    expect(f.allows(uci('d4d8')), isTrue);
    expect(() => f.onMove(uci('d4d5')), throwsArgumentError);
  });

  test('captures and good moves are counted for pawn-style goals', () {
    final c = BoardTaskController(
      step(
        fen: '8/8/8/8/3p1p2/4P3/8/8 w - - 0 1',
        goal: (s) => s.captures >= 1 && s.goodMoves - s.captures >= 1,
      ),
    );
    expect(c.onMove(uci('e3d4')), TaskEvent.good);
    expect(c.state.captures, 1);
    expect(c.onMove(uci('d4d5')), TaskEvent.complete);
    expect(c.state.goodMoves, 2);
  });

  test(
    'danger squares are the enemy-attacked squares when showDanger is on',
    () {
      final c = BoardTaskController(
        step(fen: '8/8/8/8/8/8/3r4/4K3 w - - 0 1', showDanger: true),
      );
      expect(c.danger, contains(sq('e2')));
      expect(c.danger, contains(sq('d1')));
      expect(c.danger, isNot(contains(sq('f1'))));
      expect(BoardTaskController(step()).danger, isEmpty);
    },
  );

  test('non-passive task alternates sides', () {
    final c = BoardTaskController(
      step(fen: '4k3/8/8/8/8/8/8/4K2R w K - 0 1', passive: false),
    );
    c.onMove(uci('e1g1'));
    expect(c.state.position.sideToMove, PieceColor.black);
  });

  test('onRejected counts a mistake and notifies', () {
    final c = BoardTaskController(step());
    var n = 0;
    c.addListener(() => n++);
    c.onRejected();
    expect(c.mistakes, 1);
    expect(n, 1);
  });

  test(
    'goal reached on the last allowed move completes instead of resetting',
    () {
      final c = BoardTaskController(step(stars: {sq('d8')}, moveLimit: 1));
      expect(c.onMove(uci('d4d8')), TaskEvent.complete);
    },
  );

  test(
    'after completion moves are still applied but not judged or counted',
    () {
      final c = BoardTaskController(step(stars: {sq('d8')}, moveLimit: 1));
      expect(c.onMove(uci('d4d8')), TaskEvent.complete);
      expect(c.onMove(uci('d8h8')), TaskEvent.good);
      expect(c.state.position.pieceAt(sq('h8')), isNotNull);
      expect(c.isComplete, isTrue);
      expect(c.mistakes, 0);
      c.onRejected();
      expect(c.mistakes, 0);
    },
  );

  test('reset keeps the mistakes and restores the start', () {
    final c = BoardTaskController(step(stars: {sq('d8')}));
    c.onMove(uci('d4d5'));
    c.onRejected();
    c.reset();
    expect(c.state.position.fen, rookFen);
    expect(c.mistakes, 1);
    expect(c.starsLeft, {sq('d8')});
  });

  test('isCaptureMove recognises captures and en passant', () {
    final p = Position.fromFen('8/8/8/3pP3/8/8/8/8 w - d6 0 1');
    expect(isCaptureMove(p, uci('e5d6')), isTrue);
    expect(isCaptureMove(p, uci('e5e6')), isFalse);
    expect(isCaptureMove(Position.initial(), uci('e2e4')), isFalse);
  });

  test('Lesson.taskCount counts task steps only', () {
    final lesson = Lesson(
      id: 'x',
      kind: LessonKind.piece,
      titleKey: 'learn.x.title',
      steps: [
        const IntroStep(lineKey: 'a'),
        step(),
        const CompareStep(
          lineKey: 'c',
          pairs: [
            (
              Piece(PieceColor.white, PieceType.queen),
              Piece(PieceColor.white, PieceType.rook),
            ),
          ],
        ),
      ],
    );
    expect(lesson.taskCount, 2);
  });

  test(
    'pawn move task: four single steps reset the board instead of locking it',
    () {
      final task = lessonById('pawn').steps.whereType<BoardTaskStep>().first;
      final c = BoardTaskController(task);
      expect(c.onMove(uci('e2e3')), TaskEvent.good);
      expect(c.onMove(uci('e3e4')), TaskEvent.good);
      expect(c.onMove(uci('e4e5')), TaskEvent.good);
      expect(c.onMove(uci('a2a3')), TaskEvent.reset);
      expect(c.state.position.pieceAt(sq('e2')), isNotNull);
      expect(c.state.position.pieceAt(sq('a2')), isNotNull);
      expect(c.onMove(uci('e2e4')), TaskEvent.good);
      expect(c.onMove(uci('e4e5')), TaskEvent.good);
      expect(c.onMove(uci('e5e6')), TaskEvent.complete);
    },
  );
}
