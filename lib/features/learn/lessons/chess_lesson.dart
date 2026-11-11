import '../../../engine/engine.dart';
import '../lesson_model.dart';

Move _m(String uci) => Move.parseUci(uci);
Set<Square> _squares(String names) =>
    names.split(' ').map(Square.parse).toSet();

const Piece _wk = Piece(PieceColor.white, PieceType.king);
const Piece _bk = Piece(PieceColor.black, PieceType.king);
const Piece _wp = Piece(PieceColor.white, PieceType.pawn);

const String _start =
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

/// A slow pace for demos narrated move by move.
const Duration _narrated = Duration(milliseconds: 1800);

bool _isCheckmate(Position after) =>
    evaluatePosition(after).outcome == GameOutcome.checkmate;

/// "What is chess": two armies, the king, taking turns, capturing, and a
/// whole short game to checkmate. The child watches, finds the kings and
/// plays the final move of the game.
final Lesson chessLesson = Lesson(
  id: 'chess',
  kind: LessonKind.story,
  titleKey: 'learn.chess.title',
  pieces: const [_wk, _bk],
  steps: [
    const IntroStep(lineKey: 'learn.chess.intro', pieces: [_wk, _bk]),
    SpotlightStep(
      lineKey: 'learn.chess.army',
      fen: _start,
      parts: [
        (
          _squares('a2 b2 c2 d2 e2 f2 g2 h2 a7 b7 c7 d7 e7 f7 g7 h7'),
          'learn.chess.pawns',
        ),
        (_squares('a1 h1 a8 h8'), 'learn.chess.rooks'),
        (_squares('b1 g1 b8 g8'), 'learn.chess.knights'),
        (_squares('c1 f1 c8 f8'), 'learn.chess.bishops'),
        (_squares('d1 d8'), 'learn.chess.queens'),
        (_squares('e1 e8'), 'learn.chess.kings'),
      ],
    ),
    FindStep(
      lineKey: 'learn.chess.findKing',
      fen: _start,
      targets: [
        (Square.parse('e1'), 'learn.chess.findBlackKing'),
        (Square.parse('e8'), 'learn.chess.kingsFound'),
      ],
      hintKey: 'learn.chess.findHint',
    ),
    DemoStep(
      lineKey: 'learn.chess.turns',
      fen: _start,
      pace: _narrated,
      moves: [
        (_m('e2e4'), 'learn.chess.turnWhite'),
        (_m('e7e5'), 'learn.chess.turnBlack'),
        (_m('g1f3'), 'learn.chess.turnWhiteAgain'),
        (_m('b8c6'), 'learn.chess.turnRule'),
      ],
    ),
    DemoStep(
      lineKey: 'learn.chess.capture',
      fen: 'rnbqkbnr/ppp1pppp/8/3p4/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2',
      pace: _narrated,
      moves: [
        (_m('e4d5'), 'learn.chess.captureWhite'),
        (_m('d8d5'), 'learn.chess.captureBlack'),
      ],
    ),
    DemoStep(
      lineKey: 'learn.chess.goal',
      fen: _start,
      pace: _narrated,
      moves: [
        (_m('e2e4'), null),
        (_m('e7e5'), null),
        (_m('f1c4'), null),
        (_m('b8c6'), null),
        (_m('d1h5'), 'learn.chess.queenAims'),
        (_m('g8f6'), null),
        (_m('h5f7'), 'learn.chess.mate'),
      ],
    ),
    SpotlightStep(
      lineKey: 'learn.chess.whyMate',
      fen: 'r1bqkb1r/pppp1Qpp/2n2n2/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4',
      parts: [
        (_squares('c4 f7'), 'learn.chess.whyGuard'),
        (_squares('d8 f8 d7 e7'), 'learn.chess.whyNoEscape'),
        (_squares('e8'), 'learn.chess.whyMateEnd'),
      ],
    ),
    BoardTaskStep(
      lineKey: 'learn.chess.task',
      fen:
          'r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4',
      passive: false,
      goal: (s) => s.goodMoves >= 1,
      solution: [_m('h5f7')],
      verdict: (before, move, after) =>
          _isCheckmate(after) ? MoveVerdict.good : MoveVerdict.fail,
      // Only the mating capture is offered, so the queen shows a single
      // red frame; any other tap just repeats the hint.
      moveFilter: (position, move) => move == _m('h5f7'),
      hintKey: 'learn.chess.taskHint',
    ),
    const IntroStep(lineKey: 'learn.chess.outro', piece: _wp),
  ],
);
