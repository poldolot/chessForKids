import '../../../engine/engine.dart';
import '../lesson_model.dart';

Square _sq(String name) => Square.parse(name);
List<Move> _moves(String ucis) => ucis.split(' ').map(Move.parseUci).toList();

/// Good only when the move lands on a star still to be collected.
MoveVerdict starVerdict(TaskState before, Move move, Position after) =>
    before.starsLeft.contains(move.to) ? MoveVerdict.good : MoveVerdict.wasted;

/// True when some piece of the side to move can capture.
bool _captureAvailable(Position position) =>
    legalMoves(position).any((m) => isCaptureMove(position, m));

/// "How it moves": three moves of a lone piece.
BoardTaskStep _explore(String id, String fen, String solution) => BoardTaskStep(
  lineKey: 'learn.$id.move',
  fen: fen,
  goal: (s) => s.goodMoves >= 3,
  solution: _moves(solution),
  hintKey: 'learn.$id.hint',
);

/// "How it captures": only captures are offered; two of them finish the step.
BoardTaskStep _capture(String id, String fen, String solution) => BoardTaskStep(
  lineKey: 'learn.$id.capture',
  fen: fen,
  goal: (s) => s.captures >= 2,
  solution: _moves(solution),
  moveFilter: isCaptureMove,
  hintKey: 'learn.common.captureFrame',
);

/// "Try it": collect every star within five moves. The star layouts are
/// chosen so that every sequence of star-to-star moves can still finish
/// (checked by `lessons_solvable_test.dart`).
BoardTaskStep _collectStars(
  String id,
  String fen,
  List<String> stars,
  String solution,
) => BoardTaskStep(
  lineKey: 'learn.$id.practice',
  fen: fen,
  goal: (s) => s.starsLeft.isEmpty,
  solution: _moves(solution),
  verdict: starVerdict,
  stars: stars.map(_sq).toSet(),
  moveLimit: 5,
  hintKey: 'learn.common.limitHint',
);

Lesson _pieceLesson(String id, PieceType type, List<LessonStep> tasks) {
  final piece = Piece(PieceColor.white, type);
  return Lesson(
    id: id,
    kind: LessonKind.piece,
    titleKey: 'learn.$id.title',
    piece: piece,
    steps: [
      IntroStep(lineKey: 'learn.$id.intro', piece: piece),
      ...tasks,
    ],
  );
}

final Lesson pawnLesson = _pieceLesson('pawn', PieceType.pawn, [
  // Three moves, at least one of them the two-square start.
  BoardTaskStep(
    lineKey: 'learn.pawn.move',
    fen: '8/8/8/8/8/8/4P3/8 w - - 0 1',
    goal: (s) => s.goodMoves >= 3 && s.doubleSteps >= 1,
    solution: _moves('e2e4 e4e5 e5e6'),
    hintKey: 'learn.pawn.hint',
  ),
  _capture('pawn', '8/8/8/2p1p3/3p1p2/4P3/8/8 w - - 0 1', 'e3d4 d4c5'),
  // Five plain moves and three captures; walking past a capture is a
  // mistake, promotions are not offered, the limit keeps it solvable.
  BoardTaskStep(
    lineKey: 'learn.pawn.practice',
    fen: '8/8/8/1p1p1p1p/8/8/PPPPPPPP/8 w - - 0 1',
    goal: (s) => s.captures >= 3 && s.goodMoves - s.captures >= 5,
    solution: _moves('a2a4 a4b5 c2c4 c4d5 e2e4 e4f5 b2b3 g2g4'),
    moveLimit: 12,
    moveFilter: (p, m) => m.promotion == null,
    verdict: (before, move, after) =>
        _captureAvailable(before.position) &&
            !isCaptureMove(before.position, move)
        ? MoveVerdict.wasted
        : MoveVerdict.good,
    hintKey: 'learn.pawn.hint',
  ),
]);

final Lesson rookLesson = _pieceLesson('rook', PieceType.rook, [
  _explore('rook', '8/8/8/8/3R4/8/8/8 w - - 0 1', 'd4d8 d8h8 h8h1'),
  _capture('rook', '8/8/8/8/1p1R1p2/8/8/8 w - - 0 1', 'd4b4 b4f4'),
  _collectStars('rook', '8/8/8/8/3R4/8/8/8 w - - 0 1', [
    'd8',
    'h8',
    'h1',
    'a1',
    'a4',
  ], 'd4d8 d8h8 h8h1 h1a1 a1a4'),
]);

final Lesson bishopLesson = _pieceLesson('bishop', PieceType.bishop, [
  _explore('bishop', '8/8/8/8/8/8/8/2B5 w - - 0 1', 'c1a3 a3f8 f8h6'),
  _capture('bishop', '8/8/8/p7/8/2p5/8/4B3 w - - 0 1', 'e1c3 c3a5'),
  _collectStars('bishop', '8/8/8/8/8/8/1B6/8 w - - 0 1', [
    'a3',
    'f8',
    'h6',
    'e3',
    'a7',
  ], 'b2a3 a3f8 f8h6 h6e3 e3a7'),
]);

final Lesson queenLesson = _pieceLesson('queen', PieceType.queen, [
  _explore('queen', '8/8/8/8/8/8/8/3Q4 w - - 0 1', 'd1d8 d8h8 h8h1'),
  _capture('queen', '3p3p/8/8/8/8/8/8/3Q4 w - - 0 1', 'd1d8 d8h8'),
  _collectStars('queen', '8/8/8/8/8/8/8/3Q4 w - - 0 1', [
    'a1',
    'h1',
    'h8',
    'a8',
  ], 'd1a1 a1a8 a8h8 h8h1'),
]);

final Lesson kingLesson = _pieceLesson('king', PieceType.king, [
  _explore('king', '8/8/8/8/8/8/8/4K3 w - - 0 1', 'e1e2 e2e3 e3e4'),
  _capture('king', '8/8/8/8/4p3/4p3/4K3/8 w - - 0 1', 'e2e3 e3e4'),
  BoardTaskStep(
    lineKey: 'learn.king.practice',
    fen: '8/8/p1p1p1p1/8/1p1p1p1p/8/8/4K3 w - - 0 1',
    goal: (s) => s.position.kingSquare(PieceColor.white)?.rank == 7,
    solution: _moves('e1e2 e2d3 d3e4 e4e5 e5d6 d6d7 d7d8'),
    moveLimit: 12,
    showDanger: true,
    hintKey: 'learn.king.hint',
  ),
]);

final Lesson knightLesson = _pieceLesson('knight', PieceType.knight, [
  _explore('knight', '8/8/8/8/8/8/8/1N6 w - - 0 1', 'b1c3 c3e4 e4g5'),
  _capture('knight', '8/8/8/8/2p5/8/3p4/1N6 w - - 0 1', 'b1d2 d2c4'),
  _collectStars('knight', '8/8/8/8/8/8/8/1N6 w - - 0 1', [
    'c3',
    'e4',
    'g5',
    'f7',
    'h8',
  ], 'b1c3 c3e4 e4g5 g5f7 f7h8'),
]);

final List<Lesson> pieceLessons = [
  pawnLesson,
  rookLesson,
  bishopLesson,
  queenLesson,
  kingLesson,
  knightLesson,
];
