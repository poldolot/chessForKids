import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/features/games/game_catalog.dart';
import 'package:chess_for_kids/features/games/game_model.dart';
import 'package:chess_for_kids/features/games/game_progress.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const fresh = Profile(
  id: 'p',
  name: '',
  theme: TeacherTheme.animals,
  avatarIndex: 1,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<MiniGame> games;
  setUpAll(() async => games = await loadMiniGames(rootBundle));

  test('games unlock with their lesson or the parent switch', () {
    final pawnWar = gameById(games, 'pawnWar');
    expect(isGameUnlocked(pawnWar, fresh), isFalse);
    expect(
      isGameUnlocked(pawnWar, fresh.copyWith(lessonsDone: {'pawn'})),
      isTrue,
    );
    expect(
      isGameUnlocked(pawnWar, fresh.copyWith(unlockAllMiniGames: true)),
      isTrue,
    );
    expect(
      isGameUnlocked(
        gameById(games, 'hunt'),
        fresh.copyWith(lessonsDone: {'knight'}),
      ),
      isTrue,
    );
  });

  test('hunt boards with other pieces need the queen lesson', () {
    final hunt = gameById(games, 'hunt');
    final knightOnly = fresh.copyWith(lessonsDone: {'knight'});
    expect(isBoardUnlocked(hunt, hunt.boards[0], knightOnly), isTrue);
    expect(isBoardUnlocked(hunt, hunt.boards[2], knightOnly), isFalse);
    expect(
      isBoardUnlocked(
        hunt,
        hunt.boards[2],
        knightOnly.copyWith(lessonsDone: {'knight', 'queen'}),
      ),
      isTrue,
    );
    expect(
      isBoardUnlocked(
        hunt,
        hunt.boards[2],
        fresh.copyWith(unlockAllMiniGames: true),
      ),
      isTrue,
    );
    expect(nextBoard(hunt, hunt.boards[1], knightOnly), isNull);
    expect(nextBoard(hunt, hunt.boards[0], knightOnly)?.index, 1);
  });

  test('stars for moves follow par', () {
    expect(starsForMoves(5, 5), 3);
    expect(starsForMoves(7, 5), 2);
    expect(starsForMoves(8, 5), 1);
    expect(starsForMoves(9, null), 3);
  });

  test('section stars grow with earned stars', () {
    expect(gamesMaxStars(games), 21 * 3);
    expect(gamesSectionStars(fresh, games), 0);
    final one = fresh.copyWith(stars: {'game:rookRoads:0': 2});
    expect(gamesEarnedStars(one, games), 2);
    expect(gamesSectionStars(one, games), 1);
    final all = {
      for (final g in games)
        for (final b in g.boards) gameStarsKey(g, b): 3,
    };
    expect(gamesSectionStars(fresh.copyWith(stars: all), games), 3);
    expect(
      gameStarsKey(gameById(games, 'hunt'), gameById(games, 'hunt').boards[2]),
      'game:hunt:2',
    );
  });
}
