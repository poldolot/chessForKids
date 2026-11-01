import '../../data/models.dart';
import 'game_model.dart';

export 'mini_game_session.dart' show starsForMoves;

/// A game opens with its lesson, or when the parent unlocked everything.
bool isGameUnlocked(MiniGame game, Profile profile) =>
    profile.unlockAllMiniGames ||
    profile.lessonsDone.contains(game.unlockedByLesson);

/// A board may need one more lesson than its game (hunting with other pieces).
bool isBoardUnlocked(MiniGame game, GameBoard board, Profile profile) {
  if (!isGameUnlocked(game, profile)) {
    return false;
  }
  final extra = board.unlockedByLesson;
  return extra == null ||
      profile.unlockAllMiniGames ||
      profile.lessonsDone.contains(extra);
}

String gameStarsKey(MiniGame game, GameBoard board) =>
    'game:${game.id}:${board.index}';

int gamesMaxStars(List<MiniGame> games) =>
    games.fold(0, (sum, g) => sum + g.boards.length * 3);

int gameEarnedStars(MiniGame game, Profile profile) => game.boards.fold(
  0,
  (sum, b) => sum + (profile.stars[gameStarsKey(game, b)] ?? 0),
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

/// The next board of [game] after [board] that the child may play, if any.
GameBoard? nextBoard(MiniGame game, GameBoard board, Profile profile) {
  for (final b in game.boards.skip(board.index + 1)) {
    if (isBoardUnlocked(game, b, profile)) {
      return b;
    }
  }
  return null;
}
