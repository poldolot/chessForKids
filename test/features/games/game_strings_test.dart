import 'package:chess_for_kids/features/games/game_catalog.dart';
import 'package:chess_for_kids/features/games/game_strings.dart';
import 'package:chess_for_kids/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppLocalizations en;
  late AppLocalizations pl;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    pl = await AppLocalizations.delegate.load(const Locale('pl'));
  });

  test('lines resolve in both languages', () {
    expect(gameLine(en, 'games.rookRoads.title'), 'Rook Roads');
    expect(gameLine(pl, 'games.common.won'), 'Wygrana! Brawo!');
    expect(gameLine(pl, 'games.title'), 'Mini-gry');
    expect(
      gameLine(en, 'games.common.locked', lesson: 'Rook'),
      'First the lesson: Rook. Come, I\'ll show you!',
    );
    expect(
      gameLine(pl, 'games.common.locked', lesson: 'Wieża'),
      'Najpierw lekcja: Wieża. Chodź, pokażę!',
    );
  });

  test('unknown keys throw', () {
    expect(() => gameLine(en, 'games.nope'), throwsArgumentError);
  });

  test('every game in the catalog has its title, intro and hint', () async {
    final games = await loadMiniGames(rootBundle);
    for (final g in games) {
      for (final key in [g.titleKey, g.introKey, g.hintKey]) {
        expect(gameLine(en, key), isNotEmpty, reason: key);
        expect(gameLine(pl, key), isNotEmpty, reason: key);
      }
    }
  });
}
