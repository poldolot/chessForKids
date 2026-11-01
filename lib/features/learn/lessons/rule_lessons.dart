import 'package:flutter/material.dart';

import '../../../engine/engine.dart';
import '../lesson_model.dart';

Move _m(String uci) => Move.parseUci(uci);
List<Move> _moves(String ucis) => ucis.split(' ').map(Move.parseUci).toList();
const Piece _wq = Piece(PieceColor.white, PieceType.queen);
const Piece _wr = Piece(PieceColor.white, PieceType.rook);
const Piece _wb = Piece(PieceColor.white, PieceType.bishop);
const Piece _wn = Piece(PieceColor.white, PieceType.knight);
const Piece _wk = Piece(PieceColor.white, PieceType.king);
const Piece _wp = Piece(PieceColor.white, PieceType.pawn);

Lesson _rule(String id, IconData icon, List<LessonStep> steps) => Lesson(
  id: id,
  kind: LessonKind.rule,
  titleKey: 'learn.$id.title',
  icon: icon,
  steps: [
    IntroStep(lineKey: 'learn.$id.intro', icon: icon),
    ...steps,
  ],
);

bool _isCastling(Position before, Move m) =>
    before.pieceAt(m.from)?.type == PieceType.king &&
    (m.to.file - m.from.file).abs() == 2;

bool _isCheckmate(Position after) =>
    evaluatePosition(after).outcome == GameOutcome.checkmate;

bool _isStalemate(Position after) =>
    evaluatePosition(after).outcome == GameOutcome.stalemate;

/// Good when the move is a checkmate, fail otherwise (the board resets).
MoveVerdict _mateOrFail(TaskState before, Move move, Position after) =>
    _isCheckmate(after) ? MoveVerdict.good : MoveVerdict.fail;

BoardTaskStep _mateInOne(String fen, String solution) => BoardTaskStep(
  lineKey: 'learn.mate.task',
  fen: fen,
  passive: false,
  goal: (s) => s.goodMoves >= 1,
  solution: _moves(solution),
  verdict: _mateOrFail,
  hintKey: 'learn.mate.hint',
);

/// A defence against check; [accept] says which kind of defence is taught.
BoardTaskStep _defence(
  String lineKey,
  String fen,
  String solution,
  bool Function(Position before, Move move) accept,
) => BoardTaskStep(
  lineKey: lineKey,
  fen: fen,
  passive: false,
  orientation: PieceColor.black,
  goal: (s) => s.goodMoves >= 1,
  solution: _moves(solution),
  verdict: (before, move, after) =>
      accept(before.position, move) ? MoveVerdict.good : MoveVerdict.wasted,
  hintKey: 'learn.check.hint',
);

final Lesson setupLesson = _rule('setup', Icons.grid_on_rounded, [
  const ArrangeStep(
    lineKey: 'learn.setup.task',
    targetFen: '8/8/8/8/8/8/8/RNBQKBNR w - - 0 1',
    tray: [_wk, _wr, _wb, _wq, _wn, _wr, _wn, _wb],
  ),
]);

final Lesson checkLesson = _rule('check', Icons.warning_amber_rounded, [
  DemoStep(
    lineKey: 'learn.check.intro',
    fen: '4k3/8/8/8/8/8/8/R3K3 w - - 0 1',
    moves: [(_m('a1a8'), 'learn.check.demo')],
  ),
  _defence(
    'learn.check.escape',
    'R3k3/8/8/8/8/8/8/4K3 b - - 0 1',
    'e8e7',
    (before, m) => before.pieceAt(m.from)?.type == PieceType.king,
  ),
  _defence(
    'learn.check.capture',
    '4k3/8/8/8/8/8/8/q3R1K1 b - - 0 1',
    'a1e1',
    (before, m) => m.to == Square.parse('e1'),
  ),
  _defence(
    'learn.check.block',
    'R3k3/3r4/8/8/8/8/8/4K3 b - - 0 1',
    'd7d8',
    (before, m) => const ['b8', 'c8', 'd8'].contains(m.to.name),
  ),
]);

final Lesson mateLesson = _rule('mate', Icons.emoji_events_rounded, [
  _mateInOne('k7/8/1K6/8/8/8/8/7R w - - 0 1', 'h1h8'),
  _mateInOne('6k1/5ppp/8/8/8/8/8/4R1K1 w - - 0 1', 'e1e8'),
  _mateInOne('7k/8/5K2/8/8/8/8/6Q1 w - - 0 1', 'g1g7'),
]);

final Lesson stalemateLesson = _rule('stalemate', Icons.handshake_rounded, [
  DemoStep(
    lineKey: 'learn.stalemate.intro',
    fen: '7k/8/5QK1/8/8/8/8/8 w - - 0 1',
    moves: [(_m('f6f7'), 'learn.stalemate.demo')],
  ),
  BoardTaskStep(
    lineKey: 'learn.stalemate.task',
    fen: '7k/8/5QK1/8/8/8/8/8 w - - 0 1',
    passive: false,
    goal: (s) => s.goodMoves >= 1,
    solution: _moves('f6g7'),
    verdict: (before, move, after) => _isCheckmate(after)
        ? MoveVerdict.good
        : _isStalemate(after)
        ? MoveVerdict.fail
        : MoveVerdict.wasted,
    hintKey: 'learn.stalemate.hint',
  ),
]);

final Lesson castlingLesson = _rule('castling', Icons.castle_rounded, [
  DemoStep(
    lineKey: 'learn.castling.intro',
    fen: '4k3/8/8/8/8/8/8/4K2R w K - 0 1',
    moves: [(_m('e1g1'), 'learn.castling.demo')],
  ),
  BoardTaskStep(
    lineKey: 'learn.castling.task',
    fen: 'r3k3/pppppppp/8/8/8/8/PPPPPPPP/4K2R w Kq - 0 1',
    passive: false,
    goal: (s) => s.goodMoves >= 1,
    solution: _moves('e1g1'),
    verdict: (before, move, after) => _isCastling(before.position, move)
        ? MoveVerdict.good
        : MoveVerdict.wasted,
    hintKey: 'learn.castling.hint',
  ),
]);

final Lesson enPassantLesson = _rule('enPassant', Icons.swap_horiz_rounded, [
  DemoStep(
    lineKey: 'learn.enPassant.intro',
    fen: '8/3p4/8/4P3/8/8/8/8 b - - 0 1',
    moves: [(_m('d7d5'), 'learn.enPassant.demo')],
  ),
  BoardTaskStep(
    lineKey: 'learn.enPassant.task',
    fen: '8/8/8/3pP3/8/8/8/8 w - d6 0 1',
    goal: (s) => s.captures >= 1,
    solution: _moves('e5d6'),
    moveFilter: (p, m) => m == _m('e5d6'),
    hintKey: 'learn.enPassant.hint',
  ),
]);

final Lesson promotionLesson = _rule('promotion', Icons.auto_awesome_rounded, [
  BoardTaskStep(
    lineKey: 'learn.promotion.task',
    fen: '8/4P3/8/8/8/8/8/k6K w - - 0 1',
    passive: false,
    goal: (s) => s.goodMoves >= 1,
    solution: _moves('e7e8q'),
    verdict: (before, move, after) =>
        move.promotion != null ? MoveVerdict.good : MoveVerdict.wasted,
  ),
  BoardTaskStep(
    lineKey: 'learn.promotion.knight',
    fen: '8/4P3/8/8/8/8/8/k6K w - - 0 1',
    passive: false,
    goal: (s) => s.goodMoves >= 1,
    solution: _moves('e7e8n'),
    verdict: (before, move, after) => move.promotion == PieceType.knight
        ? MoveVerdict.good
        : MoveVerdict.wasted,
    hintKey: 'learn.promotion.knight',
  ),
]);

final Lesson valuesLesson = _rule('values', Icons.balance_rounded, [
  const CompareStep(
    lineKey: 'learn.values.task',
    pairs: [(_wq, _wr), (_wp, _wn), (_wr, _wb), (_wn, _wq), (_wb, _wp)],
  ),
]);

final List<Lesson> ruleLessons = [
  setupLesson,
  checkLesson,
  mateLesson,
  stalemateLesson,
  castlingLesson,
  enPassantLesson,
  promotionLesson,
  valuesLesson,
];
