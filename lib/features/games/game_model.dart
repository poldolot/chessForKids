import 'package:flutter/widgets.dart';

import '../../engine/engine.dart';

/// The five mini-games of the first version.
enum MiniGameKind { pawnWar, rookRoads, bishopTracks, kingRace, hunt }

/// One playable board of a mini-game, generated for a level (or fixed).
final class GameBoard {
  const GameBoard({
    required this.index,
    required this.fen,
    this.stars = const {},
    this.moveLimit,
    this.par,
    this.unlockedByLesson,
    this.rules = GameRules.standard,
    this.blunder = 0,
  });

  final int index;
  final String fen;

  /// Pawn war: chance (0..1) that the opponent plays a random move.
  final double blunder;
  final Set<Square> stars;

  /// Moves allowed before the board resets; `null` means unlimited.
  final int? moveLimit;

  /// Moves needed for three stars.
  final int? par;

  /// A lesson this board needs beyond the game's own; `null` inherits.
  final String? unlockedByLesson;
  final GameRules rules;

  Position get startPosition => Position.fromFen(fen);

  /// The piece the child hunts on a Hunt board: the black piece that is not a
  /// pawn, or the black pawn when the prey is a pawn.
  Square? preySquare(Position position) {
    final black = position.pieces(PieceColor.black).toList();
    if (black.isEmpty) {
      return null;
    }
    for (final (square, piece) in black) {
      if (piece.type != PieceType.pawn) {
        return square;
      }
    }
    return black.first.$1;
  }

  /// The child's hunting piece on a Hunt board.
  Square? hunterSquare(Position position) {
    for (final (square, piece) in position.pieces(PieceColor.white)) {
      if (piece.type != PieceType.pawn) {
        return square;
      }
    }
    return null;
  }
}

/// Difficulty of one level of a mini-game, from `assets/games/<game>.json`.
final class GameLevel {
  const GameLevel({
    required this.index,
    this.stars = 0,
    this.obstacles = 0,
    this.slack = 3,
    this.blockers = const {},
    this.hunter,
    this.prey,
    this.trapped = false,
    this.limit,
    this.fen,
    this.blunder = 0,
    this.unlockedByLesson,
  });

  factory GameLevel.fromJson(int index, Map<String, dynamic> json) {
    PieceType? type(Object? letter) =>
        letter is String ? PieceType.fromLetter(letter) : null;
    final blockers = <PieceType, int>{};
    if (json['blockers'] case final Map<String, dynamic> raw) {
      for (final e in raw.entries) {
        final t = PieceType.fromLetter(e.key);
        if (t == null) {
          throw FormatException('Unknown blocker ${e.key}', json);
        }
        blockers[t] = e.value as int;
      }
    }
    return GameLevel(
      index: index,
      stars: json['stars'] as int? ?? 0,
      obstacles: json['obstacles'] as int? ?? 0,
      slack: json['slack'] as int? ?? 3,
      blockers: blockers,
      hunter: type(json['hunter']),
      prey: type(json['prey']),
      trapped: json['trapped'] as bool? ?? false,
      limit: json['limit'] as int?,
      fen: json['fen'] as String?,
      blunder: (json['blunder'] as num?)?.toDouble() ?? 0,
      unlockedByLesson: json['unlock'] as String?,
    );
  }

  final int index;

  /// Collect games: stars to place.
  final int stars;

  /// Collect games: white pawns in the way.
  final int obstacles;

  /// Moves allowed beyond par.
  final int slack;

  /// King race: black pieces in the way, by type.
  final Map<PieceType, int> blockers;

  /// Hunt: the child's piece and the fleeing piece.
  final PieceType? hunter;
  final PieceType? prey;

  /// Hunt: the prey is boxed in by its own pawns.
  final bool trapped;

  /// Hunt: fixed move limit.
  final int? limit;

  /// A fixed board instead of a generated one (pawn war).
  final String? fen;

  /// Pawn war: chance (0..1) that the opponent plays a random move.
  final double blunder;

  /// A lesson this level needs beyond the game's own.
  final String? unlockedByLesson;
}

/// A mini-game: metadata in code, levels from assets; boards are generated
/// per level when the child plays.
final class MiniGame {
  const MiniGame({
    required this.kind,
    required this.unlockedByLesson,
    required this.levels,
    this.piece,
    this.icon,
  });

  final MiniGameKind kind;
  final String unlockedByLesson;
  final List<GameLevel> levels;
  final Piece? piece;
  final IconData? icon;

  String get id => kind.name;
  String get titleKey => 'games.$id.title';
  String get introKey => 'games.$id.intro';
  String get hintKey => 'games.$id.hint';

  /// Whether an opponent answers every move of the child.
  bool get alternating =>
      kind == MiniGameKind.pawnWar || kind == MiniGameKind.hunt;

  /// Whether the child collects stars on the board.
  bool get collectsStars =>
      kind == MiniGameKind.rookRoads || kind == MiniGameKind.bishopTracks;
}
