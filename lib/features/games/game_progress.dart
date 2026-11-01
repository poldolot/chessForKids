import '../../data/models.dart';
import 'game_model.dart';

export 'mini_game_session.dart' show starsForMoves;

/// A game opens with its lesson, or when the parent unlocked everything.
bool isGameUnlocked(MiniGame game, Profile profile) =>
    profile.unlockAllMiniGames ||
    profile.lessonsDone.contains(game.unlockedByLesson);

/// A level may need one more lesson than its game (hunting with other
/// pieces).
bool isLevelUnlocked(MiniGame game, GameLevel level, Profile profile) {
  if (!isGameUnlocked(game, profile)) {
    return false;
  }
  final extra = level.unlockedByLesson;
  return extra == null ||
      profile.unlockAllMiniGames ||
      profile.lessonsDone.contains(extra);
}

/// Key of the best stars of level [index] of [game] in `Profile.stars`.
String gameStarsKey(MiniGame game, int index) => 'game:${game.id}:$index';

int gamesMaxStars(List<MiniGame> games) =>
    games.fold(0, (sum, g) => sum + g.levels.length * 3);

int gameEarnedStars(MiniGame game, Profile profile) => game.levels.fold(
  0,
  (sum, l) => sum + (profile.stars[gameStarsKey(game, l.index)] ?? 0),
);

int gamesEarnedStars(Profile profile, List<MiniGame> games) =>
    games.fold(0, (sum, g) => sum + gameEarnedStars(g, profile));

/// Stars on the Mini-games tile: none until the first star, then 1–3 in
/// proportion to the stars earned.
int gamesSectionStars(Profile profile, List<MiniGame> games) {
  final earned = gamesEarnedStars(profile, games);
  final total = gamesMaxStars(games);
  if (earned == 0 || total == 0) {
    return 0;
  }
  return (1 + (2 * earned) ~/ total).clamp(1, 3);
}

/// The next level of [game] after [level] that the child may play, if any.
GameLevel? nextLevel(MiniGame game, GameLevel level, Profile profile) {
  for (final l in game.levels.skip(level.index + 1)) {
    if (isLevelUnlocked(game, l, profile)) {
      return l;
    }
  }
  return null;
}
