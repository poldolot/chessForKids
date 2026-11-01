import 'package:flutter/widgets.dart';

import '../../engine/engine.dart';

/// The five mini-games of the first version.
enum MiniGameKind { pawnWar, rookRoads, bishopTracks, kingRace, hunt }

/// One board of a mini-game, loaded from `assets/games/<game>.json`.
final class GameBoard {
  const GameBoard({
    required this.index,
    required this.fen,
    this.stars = const {},
    this.moveLimit,
    this.par,
    this.unlockedByLesson,
    this.rules = GameRules.standard,
  });

  factory GameBoard.fromJson(
    int index,
    Map<String, dynamic> json, {
    required GameRules rules,
  }) {
    final fen = json['fen'];
    if (fen is! String) {
      throw FormatException('Board $index has no fen', json);
    }
    return GameBoard(
      index: index,
      fen: fen,
      stars: (json['stars'] as List<dynamic>? ?? const [])
          .map((s) => Square.parse(s as String))
          .toSet(),
      moveLimit: json['limit'] as int?,
      par: json['par'] as int?,
      unlockedByLesson: json['unlock'] as String?,
      rules: rules,
    );
  }

  final int index;
  final String fen;
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

/// A mini-game: metadata in code, boards from assets.
final class MiniGame {
  const MiniGame({
    required this.kind,
    required this.unlockedByLesson,
    required this.boards,
    this.piece,
    this.icon,
  });

  final MiniGameKind kind;
  final String unlockedByLesson;
  final List<GameBoard> boards;
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
