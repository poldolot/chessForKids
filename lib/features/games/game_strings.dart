import '../../l10n/app_localizations.dart';

/// Resolves a mini-game speech key such as `games.rookRoads.intro` to its
/// localized text. [lesson] fills the placeholder of `games.common.locked`.
String gameLine(AppLocalizations l10n, String key, {String? lesson}) {
  if (key == 'games.common.locked') {
    return l10n.gamesCommonLocked(lesson ?? '');
  }
  return switch (key) {
    'games.title' => l10n.gamesTitle,
    'games.common.boards' => l10n.gamesCommonBoards,
    'games.common.hint' => l10n.gamesCommonHint,
    'games.common.undo' => l10n.gamesCommonUndo,
    'games.common.again' => l10n.gamesCommonAgain,
    'games.common.next' => l10n.gamesCommonNext,
    'games.common.back' => l10n.gamesCommonBack,
    'games.common.won' => l10n.gamesCommonWon,
    'games.common.lost' => l10n.gamesCommonLost,
    'games.common.limit' => l10n.gamesCommonLimit,
    'games.common.yourMove' => l10n.gamesCommonYourMove,
    'games.common.opponentMoves' => l10n.gamesCommonOpponentMoves,
    'games.common.badgeHunter' => l10n.gamesCommonBadgeHunter,
    'games.common.badgeCollector' => l10n.gamesCommonBadgeCollector,
    'games.pawnWar.title' => l10n.gamesPawnWarTitle,
    'games.pawnWar.intro' => l10n.gamesPawnWarIntro,
    'games.pawnWar.hint' => l10n.gamesPawnWarHint,
    'games.pawnWar.wonReached' => l10n.gamesPawnWarWonReached,
    'games.pawnWar.wonBlocked' => l10n.gamesPawnWarWonBlocked,
    'games.pawnWar.lostReached' => l10n.gamesPawnWarLostReached,
    'games.pawnWar.lostBlocked' => l10n.gamesPawnWarLostBlocked,
    'games.rookRoads.title' => l10n.gamesRookRoadsTitle,
    'games.rookRoads.intro' => l10n.gamesRookRoadsIntro,
    'games.rookRoads.hint' => l10n.gamesRookRoadsHint,
    'games.bishopTracks.title' => l10n.gamesBishopTracksTitle,
    'games.bishopTracks.intro' => l10n.gamesBishopTracksIntro,
    'games.bishopTracks.hint' => l10n.gamesBishopTracksHint,
    'games.kingRace.title' => l10n.gamesKingRaceTitle,
    'games.kingRace.intro' => l10n.gamesKingRaceIntro,
    'games.kingRace.hint' => l10n.gamesKingRaceHint,
    'games.hunt.title' => l10n.gamesHuntTitle,
    'games.hunt.intro' => l10n.gamesHuntIntro,
    'games.hunt.hint' => l10n.gamesHuntHint,
    _ => throw ArgumentError.value(key, 'key', 'Unknown game line'),
  };
}
