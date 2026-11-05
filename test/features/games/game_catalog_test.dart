import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/games/game_catalog.dart';
import 'package:chess_for_kids/features/games/game_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MiniGame> games;
  setUpAll(() async => games = await loadMiniGames(rootBundle));

  test('five games in spec order with their levels', () {
    expect(games.map((g) => g.kind), kGameOrder);
    expect(games.map((g) => g.id), [
      'pawnWar',
      'rookRoads',
      'bishopTracks',
      'kingRace',
      'hunt',
    ]);
    final pawnWar = gameById(games, 'pawnWar');
    expect(pawnWar.levels.length, 3);
    for (final (i, l) in pawnWar.levels.indexed) {
      final black = Position.fromFen(l.fen!).pieces(PieceColor.black).length;
      expect(black, [3, 5, 8][i], reason: 'pawn war level $i');
      expect(l.blunder, [0.6, 0.35, 0.0][i]);
    }
    for (final g in games.skip(1)) {
      expect(g.levels.length, 5, reason: g.id);
      for (final (i, l) in g.levels.indexed) {
        expect(l.index, i);
        expect(l.fen, isNull);
      }
    }
    expect(() => gameById(games, 'nope'), throwsArgumentError);
  });

  test('level specs get harder and hunt levels name their pieces', () {
    for (final id in ['rookRoads', 'bishopTracks']) {
      final stars = gameById(games, id).levels.map((l) => l.stars).toList();
      expect(stars.first, 3);
      expect(stars.last, 6);
      for (var i = 1; i < stars.length; i++) {
        expect(stars[i], greaterThanOrEqualTo(stars[i - 1]), reason: id);
      }
    }
    for (final l in gameById(games, 'kingRace').levels) {
      expect(l.blockers[PieceType.pawn], greaterThanOrEqualTo(3));
    }
    final hunt = gameById(games, 'hunt');
    for (final l in hunt.levels) {
      expect(l.hunter, isNotNull);
      expect(l.prey, isNotNull);
      expect(l.limit, isNotNull);
    }
    expect(hunt.levels[0].hunter, PieceType.knight);
    expect(hunt.levels[0].unlockedByLesson, isNull);
    expect(hunt.levels[1].unlockedByLesson, isNull);
    for (final i in [2, 3, 4]) {
      expect(hunt.levels[i].unlockedByLesson, 'queen', reason: '$i');
    }
  });

  test('metadata: keys, unlocking lessons and rules', () {
    expect(gameById(games, 'hunt').unlockedByLesson, 'knight');
    expect(gameRules(MiniGameKind.pawnWar).enPassant, isFalse);
    expect(gameRules(MiniGameKind.rookRoads).enPassant, isTrue);
    for (final g in games) {
      expect(g.titleKey, 'games.${g.id}.title');
      expect(g.piece, isNotNull);
      expect(g.icon, isNotNull);
    }
    expect(gameById(games, 'pawnWar').alternating, isTrue);
    expect(gameById(games, 'hunt').alternating, isTrue);
    expect(gameById(games, 'rookRoads').collectsStars, isTrue);
    expect(gameById(games, 'kingRace').collectsStars, isFalse);
  });

  test('every game asset path exists', () async {
    for (final kind in kGameOrder) {
      await expectLater(rootBundle.loadString(gameAssetPath(kind)), completes);
    }
  });
}
