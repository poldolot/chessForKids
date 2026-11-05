import 'package:chess_for_kids/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('both locales provide the menu strings', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final pl = await AppLocalizations.delegate.load(const Locale('pl'));
    expect(en.learn, 'Learn');
    expect(pl.learn, 'Nauka');
    expect(
      pl.greetingNamed('Zosia'),
      'Cześć, Zosia! Wybierz naukę, mini-grę lub partię.',
    );
    expect(
      AppLocalizations.supportedLocales,
      containsAll([const Locale('en'), const Locale('pl')]),
    );
  });
}
