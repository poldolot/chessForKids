import 'dart:convert';

import 'package:flutter/material.dart';

import '../../engine/engine.dart';
import 'game_model.dart';

/// The game order on the Mini-games screen.
const List<MiniGameKind> kGameOrder = [
  MiniGameKind.pawnWar,
  MiniGameKind.rookRoads,
  MiniGameKind.bishopTracks,
  MiniGameKind.kingRace,
  MiniGameKind.hunt,
];

/// Asset file of a game's levels.
String gameAssetPath(MiniGameKind kind) {
  final file = switch (kind) {
    MiniGameKind.pawnWar => 'pawn_war',
    MiniGameKind.rookRoads => 'rook_roads',
    MiniGameKind.bishopTracks => 'bishop_tracks',
    MiniGameKind.kingRace => 'king_race',
    MiniGameKind.hunt => 'hunt',
  };
  return 'assets/games/$file.json';
}

/// The lesson that opens each game (spec §5.4).
String gameUnlockLesson(MiniGameKind kind) => switch (kind) {
  MiniGameKind.pawnWar => 'pawn',
  MiniGameKind.rookRoads => 'rook',
  MiniGameKind.bishopTracks => 'bishop',
  MiniGameKind.kingRace => 'king',
  MiniGameKind.hunt => 'knight',
};

/// Pawn war has no en passant and no castling (rules catalogue §9); the
/// other games use the standard rules.
GameRules gameRules(MiniGameKind kind) => kind == MiniGameKind.pawnWar
    ? const GameRules(enPassant: false, castling: false)
    : GameRules.standard;

Piece? _gamePiece(MiniGameKind kind) => switch (kind) {
  MiniGameKind.pawnWar => const Piece(PieceColor.white, PieceType.pawn),
  MiniGameKind.rookRoads => const Piece(PieceColor.white, PieceType.rook),
  MiniGameKind.bishopTracks => const Piece(PieceColor.white, PieceType.bishop),
  MiniGameKind.kingRace => const Piece(PieceColor.white, PieceType.king),
  MiniGameKind.hunt => const Piece(PieceColor.white, PieceType.knight),
};

IconData _gameIcon(MiniGameKind kind) => switch (kind) {
  MiniGameKind.pawnWar => Icons.sports_kabaddi_rounded,
  MiniGameKind.rookRoads => Icons.route_rounded,
  MiniGameKind.bishopTracks => Icons.timeline_rounded,
  MiniGameKind.kingRace => Icons.flag_rounded,
  MiniGameKind.hunt => Icons.track_changes_rounded,
};

/// Loads every game with its levels from [bundle].
Future<List<MiniGame>> loadMiniGames(AssetBundle bundle) async {
  final games = <MiniGame>[];
  for (final kind in kGameOrder) {
    final text = await bundle.loadString(gameAssetPath(kind));
    final json = jsonDecode(text) as Map<String, dynamic>;
    final levels = [
      for (final (i, l) in (json['levels'] as List<dynamic>).indexed)
        GameLevel.fromJson(i, l as Map<String, dynamic>),
    ];
    games.add(
      MiniGame(
        kind: kind,
        unlockedByLesson: gameUnlockLesson(kind),
        levels: levels,
        piece: _gamePiece(kind),
        icon: _gameIcon(kind),
      ),
    );
  }
  return games;
}

MiniGame gameById(List<MiniGame> games, String id) => games.firstWhere(
  (g) => g.id == id,
  orElse: () => throw ArgumentError.value(id, 'id', 'Unknown game'),
);
