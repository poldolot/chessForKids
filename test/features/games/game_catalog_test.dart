import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/games/game_catalog.dart';
import 'package:chess_for_kids/features/games/game_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MiniGame> games;
  setUpAll(() async => games = await loadMiniGames(rootBundle));

  test('five games in spec order with their boards', () {
    expect(games.map((g) => g.kind), kGameOrder);
    expect(games.map((g) => g.id), [
      'pawnWar',
      'rookRoads',
      'bishopTracks',
      'kingRace',
      'hunt',
    ]);
    expect(gameById(games, 'pawnWar').boards.length, 1);
    for (final g in games.skip(1)) {
      expect(g.boards.length, 5, reason: g.id);
    }
    expect(() => gameById(games, 'nope'), throwsArgumentError);
  });

  test('boards parse, stars sit on empty squares and limits cover par', () {
    for (final g in games) {
      for (final b in g.boards) {
        final position = b.startPosition;
        expect(
          position.sideToMove,
          PieceColor.white,
          reason: '${g.id} ${b.index}',
        );
        for (final s in b.stars) {
          expect(
            position.pieceAt(s),
            isNull,
            reason: '${g.id} ${b.index} star on $s',
          );
        }
        if (b.par != null && b.moveLimit != null) {
          expect(
            b.moveLimit,
            greaterThanOrEqualTo(b.par!),
            reason: '${g.id} ${b.index}',
          );
        }
        expect(b.index, g.boards.indexOf(b));
      }
    }
  });

  test('metadata: keys, unlocking lessons, rules and hunt board unlocks', () {
    final hunt = gameById(games, 'hunt');
    expect(hunt.unlockedByLesson, 'knight');
    expect(hunt.boards[0].unlockedByLesson, isNull);
    expect(hunt.boards[2].unlockedByLesson, 'queen');
    expect(gameById(games, 'pawnWar').boards.single.rules.enPassant, isFalse);
    expect(gameById(games, 'rookRoads').boards.first.rules.enPassant, isTrue);
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
