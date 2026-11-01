import '../../data/models.dart';
import '../games/game_result_view.dart' show kCollectorStars;

/// Finished matches needed for the persistent badge.
const int kPersistentMatches = 10;

/// Badges [profile] has just earned after a finished match was recorded,
/// in award order; badges it already owns are left out.
List<String> matchBadges(Profile profile) => [
  if (profile.matchesPlayed >= 1) 'firstMatch',
  if (profile.matchesWon >= 1) 'firstWin',
  if (profile.matchesPlayed >= kPersistentMatches) 'persistent',
  if (profile.totalStars >= kCollectorStars) 'collector',
].where((b) => !profile.badges.contains(b)).toList();
