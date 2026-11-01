import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/games/game_model.dart';

/// The boards the mini-games shipped with before boards were generated;
/// tests of the session and the screens use them for known positions.
const GameRules _pawnWarRules = GameRules(enPassant: false, castling: false);

Set<Square> _squares(String names) => {
  for (final s in names.split(' ')) Square.parse(s),
};

GameBoard _collect(int index, String fen, String stars, int par, int limit) =>
    GameBoard(
      index: index,
      fen: fen,
      stars: _squares(stars),
      par: par,
      moveLimit: limit,
    );

final Map<String, List<GameBoard>> fixedBoards = {
  'pawnWar': const [
    GameBoard(
      index: 0,
      fen: '8/pppppppp/8/8/8/8/PPPPPPPP/8 w - - 0 1',
      rules: _pawnWarRules,
    ),
  ],
  'rookRoads': [
    _collect(0, '8/8/8/8/8/8/8/R7 w - - 0 1', 'a8 h8 h1 d1 d4', 5, 8),
    _collect(1, '8/8/8/8/3P4/8/8/R7 w - - 0 1', 'd8 h8 h1 b1 b5', 6, 9),
    _collect(2, '8/8/8/8/8/2P1P3/8/3R4 w - - 0 1', 'd8 a8 a1 h1 h8', 5, 8),
    _collect(3, '8/8/8/3P4/8/8/8/R7 w - - 0 1', 'a8 d8 h8 h1 d1', 5, 8),
    _collect(4, '8/8/8/8/2P2P2/8/8/R7 w - - 0 1', 'a8 h8 h1 c1 c3', 5, 8),
  ],
  'bishopTracks': [
    _collect(0, '8/8/8/8/8/8/8/2B5 w - - 0 1', 'a3 f8 h6 e3 a7', 5, 8),
    _collect(1, '8/8/8/8/8/8/8/5B2 w - - 0 1', 'a6 h7 e8 b5 g2', 7, 10),
    _collect(2, '8/8/8/8/8/2P5/8/4B3 w - - 0 1', 'h4 b8 g7 d8 a5', 7, 10),
    _collect(3, '8/8/8/8/8/8/3P4/2B5 w - - 0 1', 'a3 f8 h6 e3 a7', 5, 8),
    _collect(4, '8/8/8/8/4p3/8/8/2B5 w - - 0 1', 'a3 c5 f8 h2 d4', 6, 9),
  ],
  'kingRace': const [
    GameBoard(
      index: 0,
      fen: '8/8/p1p1p1p1/8/1p1p1p1p/8/8/4K3 w - - 0 1',
      par: 7,
      moveLimit: 11,
    ),
    GameBoard(
      index: 1,
      fen: '8/8/8/2p1p1p1/8/1p1p1p2/8/4K3 w - - 0 1',
      par: 7,
      moveLimit: 11,
    ),
    GameBoard(
      index: 2,
      fen: '8/b7/2p1p1p1/8/8/8/8/4K3 w - - 0 1',
      par: 7,
      moveLimit: 11,
    ),
    GameBoard(
      index: 3,
      fen: '8/8/2n2n2/8/1p1p1p1p/8/8/4K3 w - - 0 1',
      par: 7,
      moveLimit: 11,
    ),
    GameBoard(
      index: 4,
      fen: '8/b6b/8/2p1p1p1/8/1p1p1p1p/8/4K3 w - - 0 1',
      par: 7,
      moveLimit: 11,
    ),
  ],
  'hunt': const [
    GameBoard(
      index: 0,
      fen: '8/8/3p4/8/8/8/8/1N6 w - - 0 1',
      par: 2,
      moveLimit: 8,
    ),
    GameBoard(
      index: 1,
      fen: '7b/6p1/8/8/8/8/8/1N6 w - - 0 1',
      par: 5,
      moveLimit: 10,
    ),
    GameBoard(
      index: 2,
      fen: '3b4/2p1p3/8/8/3P4/8/8/R7 w - - 0 1',
      par: 2,
      moveLimit: 6,
      unlockedByLesson: 'queen',
    ),
    GameBoard(
      index: 3,
      fen: 'n7/2p5/1p6/8/8/8/8/5B2 w - - 0 1',
      par: 2,
      moveLimit: 6,
      unlockedByLesson: 'queen',
    ),
    GameBoard(
      index: 4,
      fen: '8/p7/8/8/8/8/8/3Q4 w - - 0 1',
      par: 2,
      moveLimit: 8,
      unlockedByLesson: 'queen',
    ),
  ],
};

GameBoard fixedBoard(String gameId, int index) => fixedBoards[gameId]![index];
