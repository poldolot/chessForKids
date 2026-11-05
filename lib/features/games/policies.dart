import 'dart:math';

import '../../engine/engine.dart';

/// Pure move policies used for hints and for the computer side of the
/// mini-games. None of them look further ahead than a breadth-first search
/// over one piece's moves; that is all a five-year-old's opponent needs.

int _progress(Square s, PieceColor side) =>
    side == PieceColor.white ? s.rank : 7 - s.rank;

/// Shortest route for the piece on [from] to any of [targets], moving over
/// empty squares (other pieces are obstacles; a target may hold a piece,
/// which the last step captures). Squares in [avoid] are never entered.
/// Returns the squares after [from], ending on the target, or `null`.
List<Square>? shortestPath(
  Position position,
  Square from,
  Set<Square> targets, {
  Set<Square> avoid = const {},
  GameRules rules = GameRules.standard,
}) {
  final piece = position.pieceAt(from);
  if (piece == null || targets.isEmpty) {
    return null;
  }
  final board = position.withPiece(from, null);
  final parent = <Square, Square?>{from: null};
  final queue = [from];
  while (queue.isNotEmpty) {
    final s = queue.removeAt(0);
    if (targets.contains(s) && s != from) {
      final path = <Square>[];
      for (Square? at = s; at != null && at != from; at = parent[at]) {
        path.insert(0, at);
      }
      return path;
    }
    final p = board
        .withPiece(s, piece)
        .copyWith(sideToMove: piece.color, clearEnPassant: true);
    for (final m in legalMoves(p, from: s, rules: rules)) {
      if (parent.containsKey(m.to) || avoid.contains(m.to)) {
        continue;
      }
      final occupant = board.pieceAt(m.to);
      if (occupant != null && !targets.contains(m.to)) {
        continue;
      }
      parent[m.to] = s;
      queue.add(m.to);
    }
  }
  return null;
}

/// First step of the shortest tour that collects every star (all orders of
/// up to a handful of stars are tried, with breadth-first distances between
/// them), so following the hint always finishes in the fewest moves.
Move? nearestStarStep(Position position, Square piece, Set<Square> stars) {
  final mover = position.pieceAt(piece);
  if (mover == null || stars.isEmpty) {
    return null;
  }
  final board = position.withPiece(piece, null);
  final cache = <(Square, Square), int?>{};
  int? distance(Square from, Square to) => cache.putIfAbsent((
    from,
    to,
  ), () => shortestPath(board.withPiece(from, mover), from, {to})?.length);
  List<Square>? bestOrder;
  var bestLength = 1 << 30;
  void visit(Square at, List<Square> order, Set<Square> left, int length) {
    if (length >= bestLength) {
      return;
    }
    if (left.isEmpty) {
      bestLength = length;
      bestOrder = order;
      return;
    }
    for (final star in left) {
      final d = distance(at, star);
      if (d != null) {
        visit(star, [...order, star], {...left}..remove(star), length + d);
      }
    }
  }

  visit(piece, const [], stars, 0);
  final order = bestOrder;
  if (order == null) {
    return null;
  }
  final first = shortestPath(position, piece, {order.first})!.first;
  return Move(piece, first);
}

/// First step of the shortest safe route of the king of [color] to the last
/// rank: squares the opponent attacks are never entered.
Move? kingRaceStep(Position position, PieceColor color) {
  final king = position.kingSquare(color);
  if (king == null) {
    return null;
  }
  final enemy = color.opposite;
  final attacked = {
    for (final s in Square.all)
      if (isSquareAttacked(position, s, enemy)) s,
  };
  final lastRank = color == PieceColor.white ? 7 : 0;
  final targets = {
    for (final s in Square.all)
      if (s.rank == lastRank && !attacked.contains(s)) s,
  };
  final path = shortestPath(position, king, targets, avoid: attacked);
  return path == null ? null : Move(king, path.first);
}

T _pick<T>(List<T> items, Random random) => items[random.nextInt(items.length)];

/// Pawn war opponent: promote, else capture (the most advanced), else push
/// the most advanced pawn to a square no enemy pawn attacks, else anything.
Move? pawnWarMove(
  Position position,
  PieceColor side,
  Random random, {
  GameRules rules = const GameRules(enPassant: false, castling: false),
  double blunder = 0,
}) {
  final p = position.sideToMove == side
      ? position
      : position.copyWith(sideToMove: side, clearEnPassant: true);
  final moves = legalMoves(p, rules: rules)
      .where((m) => m.promotion == null || m.promotion == PieceType.queen)
      .toList();
  if (moves.isEmpty) {
    return null;
  }
  if (blunder > 0 && random.nextDouble() < blunder) {
    // A careless opponent for the youngest: any legal move.
    return _pick(moves, random);
  }
  final promotions = moves.where((m) => m.promotion != null).toList();
  if (promotions.isNotEmpty) {
    return _pick(promotions, random);
  }
  List<Move> mostAdvanced(List<Move> list, int Function(Move) rank) {
    final top = list.map(rank).reduce(max);
    return list.where((m) => rank(m) == top).toList();
  }

  final captures = moves.where((m) => isCapture(p, m)).toList();
  if (captures.isNotEmpty) {
    return _pick(mostAdvanced(captures, (m) => _progress(m.to, side)), random);
  }
  final safe = moves
      .where((m) => !isSquareAttacked(p.play(m), m.to, side.opposite))
      .toList();
  if (safe.isNotEmpty) {
    return _pick(mostAdvanced(safe, (m) => _progress(m.to, side)), random);
  }
  return _pick(moves, random);
}

/// Whether [move] captures in [position] (including en passant).
bool isCapture(Position position, Move move) {
  if (position.pieceAt(move.to) != null) {
    return true;
  }
  final mover = position.pieceAt(move.from);
  return mover?.type == PieceType.pawn && move.from.file != move.to.file;
}

/// The prey's move (only the piece on [prey] when given): stay off squares
/// the hunter attacks and keep the hunter as many moves away as possible;
/// when nothing is safe, just get far away.
Move? fleeMove(
  Position position,
  PieceColor fleeing,
  Square hunter,
  Random random, {
  Square? prey,
}) {
  final p = position.sideToMove == fleeing
      ? position
      : position.copyWith(sideToMove: fleeing, clearEnPassant: true);
  final moves = legalMoves(p, from: prey)
      .where((m) => m.promotion == null || m.promotion == PieceType.queen)
      .where((m) => !isCapture(p, m))
      .toList();
  if (moves.isEmpty) {
    return null;
  }
  final hunterColor = fleeing.opposite;
  int hunterDistance(Position after, Square to) =>
      shortestPath(after, hunter, {to})?.length ?? 99;
  final safe = <(Move, int)>[];
  for (final m in moves) {
    final after = p.play(m);
    if (!isSquareAttacked(after, m.to, hunterColor)) {
      safe.add((m, hunterDistance(after, m.to)));
    }
  }
  if (safe.isNotEmpty) {
    final far = safe.map((e) => e.$2).reduce(max);
    return _pick([
      for (final e in safe)
        if (e.$2 == far) e.$1,
    ], random);
  }
  int chebyshev(Square s) =>
      max((s.file - hunter.file).abs(), (s.rank - hunter.rank).abs());
  final far = moves.map((m) => chebyshev(m.to)).reduce(max);
  return _pick([
    for (final m in moves)
      if (chebyshev(m.to) == far) m,
  ], random);
}

/// The hunter's move: capture the prey if it can; otherwise the move after
/// which the prey's best escape still leaves it closest (one move of
/// lookahead over every reply of the prey), ties broken by the shorter route.
Move? huntStep(Position position, Square hunter, Square prey) {
  final hunterPiece = position.pieceAt(hunter);
  final preyPiece = position.pieceAt(prey);
  if (hunterPiece == null || preyPiece == null) {
    return null;
  }
  final p = position.copyWith(
    sideToMove: hunterPiece.color,
    clearEnPassant: true,
  );
  final moves = legalMoves(p, from: hunter);
  for (final m in moves) {
    if (m.to == prey) {
      return m;
    }
  }
  Move? best;
  var bestKey = (1 << 30, 1 << 30);
  for (final m in moves) {
    final after = p
        .play(m)
        .copyWith(sideToMove: preyPiece.color, clearEnPassant: true);
    final replies = legalMoves(after, from: prey)
        .where((r) => !isCapture(after, r))
        .map((r) => (after.play(r), r.to))
        .toList();
    if (replies.isEmpty) {
      replies.add((after, prey));
    }
    var worst = 0;
    for (final (afterReply, preyAt) in replies) {
      final d = shortestPath(afterReply, m.to, {preyAt})?.length ?? 99;
      if (d > worst) {
        worst = d;
      }
    }
    final direct = shortestPath(p, hunter, {prey})?.length ?? 99;
    final onPath = shortestPath(p.play(m), m.to, {prey})?.length ?? 99;
    final key = (worst, onPath < direct ? 0 : 1);
    if (key.$1 < bestKey.$1 || (key.$1 == bestKey.$1 && key.$2 < bestKey.$2)) {
      bestKey = key;
      best = m;
    }
  }
  return best;
}

/// Breadth-first distance, in moves of [piece] standing on [from], to every
/// square it can reach over [board] (a position without the moving piece;
/// every other piece is a fixed obstacle, [avoid] squares are never entered).
Map<Square, int> reachDistances(
  Position board,
  Piece piece,
  Square from, {
  Set<Square> avoid = const {},
}) {
  final dist = <Square, int>{from: 0};
  final queue = [from];
  while (queue.isNotEmpty) {
    final s = queue.removeAt(0);
    final p = board.withPiece(s, piece).copyWith(sideToMove: piece.color);
    for (final m in pseudoLegalMoves(p, from: s)) {
      if (avoid.contains(m.to) || board.pieceAt(m.to) != null) {
        continue;
      }
      if (!dist.containsKey(m.to)) {
        dist[m.to] = dist[s]! + 1;
        queue.add(m.to);
      }
    }
  }
  return dist;
}

/// Fewest moves for the piece on [from] to visit every star, trying every
/// order; `null` when a star cannot be reached.
int? optimalTour(Position position, Square from, Set<Square> stars) {
  final piece = position.pieceAt(from);
  if (piece == null) {
    return null;
  }
  final board = position.withPiece(from, null);
  final cache = <Square, Map<Square, int>>{};
  Map<Square, int> from_(Square at) =>
      cache.putIfAbsent(at, () => reachDistances(board, piece, at));
  int? best;
  void visit(Square at, Set<Square> left, int moves) {
    if (best != null && moves >= best!) {
      return;
    }
    if (left.isEmpty) {
      best = moves;
      return;
    }
    final d = from_(at);
    for (final star in left) {
      final steps = d[star];
      if (steps != null) {
        visit(star, {...left}..remove(star), moves + steps);
      }
    }
  }

  visit(from, stars, 0);
  return best;
}
