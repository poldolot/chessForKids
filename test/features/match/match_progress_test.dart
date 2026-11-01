import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/features/match/match_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Profile profile({
    int played = 0,
    int won = 0,
    int matchStars = 0,
    Map<String, int> stars = const {},
    Set<String> badges = const {},
  }) => Profile(
    id: 'p',
    name: 'Zosia',
    theme: TeacherTheme.animals,
    avatarIndex: 1,
    matchesPlayed: played,
    matchesWon: won,
    matchStars: matchStars,
    stars: stars,
    badges: badges,
  );

  test('the first finished match earns the first-match badge', () {
    expect(matchBadges(profile(played: 1)), ['firstMatch']);
  });

  test('the first win earns both first badges', () {
    expect(matchBadges(profile(played: 1, won: 1)), ['firstMatch', 'firstWin']);
  });

  test('owned badges are not awarded again', () {
    expect(matchBadges(profile(played: 2, won: 1, badges: {'firstMatch'})), [
      'firstWin',
    ]);
    expect(
      matchBadges(
        profile(played: 2, won: 1, badges: {'firstMatch', 'firstWin'}),
      ),
      isEmpty,
    );
  });

  test('ten finished matches make a persistent player', () {
    expect(matchBadges(profile(played: 10, badges: {'firstMatch'})), [
      'persistent',
    ]);
    expect(matchBadges(profile(played: 9, badges: {'firstMatch'})), isEmpty);
  });

  test('fifty stars in total earn the collector badge', () {
    final p = profile(
      played: 3,
      matchStars: 5,
      stars: {'lesson:pawn': 45},
      badges: {'firstMatch'},
    );
    expect(matchBadges(p), ['collector']);
  });
}
