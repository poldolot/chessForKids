import 'dart:math';

import '../../engine/engine.dart';
import 'game_model.dart';
import 'policies.dart';

const int _collectParMargin = 3;
const int _kingParMin = 7;
const int _kingParMax = 10;
const int _huntParMin = 2;
const int _huntSimulations = 3;

/// A fresh board for [level] of a [kind] game, drawn with [random] and
/// checked: every star reachable, par equal to the optimum, obstacles that
/// matter, a safe road for the king, a prey the hunter can reach. Never the
/// same board as [avoid]. Throws [StateError] when [attempts] draws produce
/// nothing acceptable, which the tests rule out for every shipped level.
GameBoard generateBoard(
  MiniGameKind kind,
  GameLevel level,
  Random random, {
  GameRules rules = GameRules.standard,
  int attempts = 400,
  GameBoard? avoid,
}) {
  if (level.fen case final fen?) {
    return GameBoard(
      index: level.index,
      fen: fen,
      moveLimit: level.limit,
      unlockedByLesson: level.unlockedByLesson,
      rules: rules,
    );
  }
  for (var i = 0; i < attempts; i++) {
    final board = switch (kind) {
      MiniGameKind.rookRoads => _collect(PieceType.rook, level, random, rules),
      MiniGameKind.bishopTracks => _collect(
        PieceType.bishop,
        level,
        random,
        rules,
      ),
      MiniGameKind.kingRace => _kingRace(level, random, rules),
      MiniGameKind.hunt => _hunt(level, random, rules),
      MiniGameKind.pawnWar => null,
    };
    if (board != null && !_sameBoard(board, avoid)) {
      return board;
    }
  }
  throw StateError('No acceptable $kind board for level ${level.index}');
}

/// "Again" must not hand back the board just played.
bool _sameBoard(GameBoard a, GameBoard? b) =>
    b != null &&
    a.fen == b.fen &&
    a.stars.length == b.stars.length &&
    a.stars.containsAll(b.stars);

Square _randomSquare(Random random, Iterable<Square> from) {
  final list = from.toList();
  return list[random.nextInt(list.length)];
}

GameBoard? _collect(
  PieceType type,
  GameLevel level,
  Random random,
  GameRules rules,
) {
  final piece = Piece(PieceColor.white, type);
  final start = _randomSquare(random, Square.all);
  var position = Position.empty().withPiece(start, piece);
  final free = Square.all.where((s) => s != start).toList()..shuffle(random);
  final sameColour = type == PieceType.bishop
      ? free.where((s) => s.isLight == start.isLight).toList()
      : free;
  if (sameColour.length < level.stars) {
    return null;
  }
  final stars = sameColour.take(level.stars).toSet();
  final open = position;
  final obstacleSquares = sameColour
      .where((s) => !stars.contains(s) && s.rank >= 1 && s.rank <= 6)
      .take(level.obstacles)
      .toList();
  if (obstacleSquares.length < level.obstacles) {
    return null;
  }
  for (final s in obstacleSquares) {
    position = position.withPiece(
      s,
      const Piece(PieceColor.white, PieceType.pawn),
    );
  }
  final par = optimalTour(position, start, stars);
  if (par == null ||
      par < level.stars ||
      par > level.stars + _collectParMargin) {
    return null;
  }
  if (level.obstacles > 0 && optimalTour(open, start, stars)! >= par) {
    // Obstacles that change nothing are decoration, not difficulty.
    return null;
  }
  return GameBoard(
    index: level.index,
    fen: position.fen,
    stars: stars,
    par: par,
    moveLimit: par + level.slack,
    unlockedByLesson: level.unlockedByLesson,
    rules: rules,
  );
}

GameBoard? _kingRace(GameLevel level, Random random, GameRules rules) {
  const king = Piece(PieceColor.white, PieceType.king);
  final start = Square.fromFileRank(random.nextInt(8), 0);
  var position = Position.empty().withPiece(start, king);
  final pawnSquares = [
    for (final s in Square.all)
      if (s.rank >= 2 && s.rank <= 5) s,
  ]..shuffle(random);
  final pieceSquares = [
    for (final s in Square.all)
      if (s.rank >= 4) s,
  ]..shuffle(random);
  final used = <Square>{start};
  for (final e in level.blockers.entries) {
    final pool = e.key == PieceType.pawn ? pawnSquares : pieceSquares;
    var placed = 0;
    for (final s in pool) {
      if (placed == e.value) {
        break;
      }
      if (used.add(s)) {
        position = position.withPiece(s, Piece(PieceColor.black, e.key));
        placed++;
      }
    }
    if (placed < e.value) {
      return null;
    }
  }
  if (isSquareAttacked(position, start, PieceColor.black)) {
    return null;
  }
  final attacked = {
    for (final s in Square.all)
      if (isSquareAttacked(position, s, PieceColor.black)) s,
  };
  final d = reachDistances(
    position.withPiece(start, null),
    king,
    start,
    avoid: attacked,
  );
  int? par;
  for (final e in d.entries) {
    if (e.key.rank == 7 && (par == null || e.value < par)) {
      par = e.value;
    }
  }
  if (par == null || par < _kingParMin || par > _kingParMax) {
    return null;
  }
  return GameBoard(
    index: level.index,
    fen: position.fen,
    par: par,
    moveLimit: par + level.slack,
    unlockedByLesson: level.unlockedByLesson,
    rules: rules,
  );
}

GameBoard? _hunt(GameLevel level, Random random, GameRules rules) {
  final hunterType = level.hunter;
  final preyType = level.prey;
  final limit = level.limit;
  if (hunterType == null || preyType == null || limit == null) {
    throw ArgumentError('Hunt level ${level.index} needs hunter, prey, limit');
  }
  final hunter = Square.fromFileRank(random.nextInt(8), random.nextInt(2));
  final Square prey;
  var position = Position.empty().withPiece(
    hunter,
    Piece(PieceColor.white, hunterType),
  );
  if (level.trapped) {
    // A prey near the edge with few first steps, all of them blocked by its
    // own pawns: it cannot move, so the hunt is a route to find.
    final candidates = [
      for (final s in Square.all)
        if (s.rank >= 4 && s != hunter && _firstSteps(preyType, s).length <= 3)
          s,
    ];
    if (candidates.isEmpty) {
      return null;
    }
    prey = candidates[random.nextInt(candidates.length)];
    position = position.withPiece(prey, Piece(PieceColor.black, preyType));
    for (final s in _firstSteps(preyType, prey)) {
      if (s == hunter || s.rank == 0 || s.rank == 7) {
        return null;
      }
      position = position.withPiece(
        s,
        const Piece(PieceColor.black, PieceType.pawn),
      );
    }
  } else {
    final preyRanks = preyType == PieceType.pawn ? [5, 6] : [4, 5, 6, 7];
    prey = Square.fromFileRank(
      random.nextInt(8),
      preyRanks[random.nextInt(preyRanks.length)],
    );
    if (prey == hunter) {
      return null;
    }
    position = position.withPiece(prey, Piece(PieceColor.black, preyType));
  }
  if (isSquareAttacked(position, prey, PieceColor.white) ||
      isSquareAttacked(position, hunter, PieceColor.black) ||
      shortestPath(position, hunter, {prey}) == null) {
    return null;
  }
  var par = 0;
  for (var seed = 1; seed <= _huntSimulations; seed++) {
    final moves = _huntLength(position, hunter, prey, limit, Random(seed));
    if (moves == null) {
      return null;
    }
    par = max(par, moves);
  }
  if (par < _huntParMin || par > limit - 2) {
    return null;
  }
  return GameBoard(
    index: level.index,
    fen: position.fen,
    par: par,
    moveLimit: limit,
    unlockedByLesson: level.unlockedByLesson,
    rules: rules,
  );
}

/// Moves the hint policy needs to catch the fleeing prey, or `null` when it
/// does not manage within [limit].
int? _huntLength(
  Position start,
  Square hunter,
  Square prey,
  int limit,
  Random random,
) {
  var position = start;
  var at = hunter;
  var target = prey;
  for (var moves = 1; moves <= limit; moves++) {
    final step = huntStep(position, at, target);
    if (step == null) {
      return null;
    }
    position = position.play(step);
    at = step.to;
    if (at == target) {
      return moves;
    }
    final flee = fleeMove(position, PieceColor.black, at, random, prey: target);
    if (flee == null) {
      position = position.pass();
    } else {
      position = position.play(flee);
      target = flee.to;
    }
  }
  return null;
}

/// The squares a [type] on [at] could step to first (one square along each
/// of its lines, or the knight's targets), on the board only.
List<Square> _firstSteps(PieceType type, Square at) {
  final deltas = switch (type) {
    PieceType.knight => const [
      (1, 2),
      (2, 1),
      (2, -1),
      (1, -2),
      (-1, -2),
      (-2, -1),
      (-2, 1),
      (-1, 2),
    ],
    PieceType.bishop => const [(1, 1), (1, -1), (-1, -1), (-1, 1)],
    PieceType.rook => const [(1, 0), (0, 1), (-1, 0), (0, -1)],
    PieceType.queen || PieceType.king => const [
      (1, 1),
      (1, -1),
      (-1, -1),
      (-1, 1),
      (1, 0),
      (0, 1),
      (-1, 0),
      (0, -1),
    ],
    PieceType.pawn => const [(0, -1)],
  };
  return [for (final (df, dr) in deltas) ?at.offset(df, dr)];
}
