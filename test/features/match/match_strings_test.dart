import 'package:chess_for_kids/features/match/match_strings.dart';
import 'package:chess_for_kids/l10n/app_localizations.dart';
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
    expect(matchLine(pl, 'match.title'), 'Partia');
    expect(matchLine(en, 'match.intro'), 'You play white. Your move!');
    expect(matchLine(pl, 'match.check'), 'Szach! Ratuj króla!');
    expect(matchLine(en, 'match.won'), 'Checkmate! You win! Well done!');
    expect(matchLine(pl, 'match.badgeCollector'), isNotEmpty);
  });

  test('every match key has text in both languages', () {
    for (final key in kMatchKeys) {
      expect(matchLine(en, key), isNotEmpty, reason: key);
      expect(matchLine(pl, key), isNotEmpty, reason: key);
    }
    expect(kMatchKeys.length, 24);
  });

  test('unknown keys throw', () {
    expect(() => matchLine(en, 'match.nope'), throwsArgumentError);
  });
}
