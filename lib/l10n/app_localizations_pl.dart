// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Szachy dla dzieci';

  @override
  String get whoIsPlaying => 'Kto gra?';

  @override
  String get greeting => 'Cześć! W co dziś gramy?';

  @override
  String greetingNamed(String name) {
    return 'Cześć, $name! W co dziś gramy?';
  }

  @override
  String get learn => 'Nauka';

  @override
  String get learnSubtitle => 'figury i ich ruchy';

  @override
  String get miniGames => 'Mini-gry';

  @override
  String get miniGamesSubtitle => 'wojna pionów, tory gońca…';

  @override
  String get play => 'Partia';

  @override
  String get playSubtitle => 'zagraj z komputerem';

  @override
  String get comingSoon => 'Już wkrótce!';

  @override
  String get addProfile => 'Dodaj gracza';

  @override
  String get chooseTeachers => 'Wybierz swoich nauczycieli';

  @override
  String get chooseAvatar => 'Wybierz swój obrazek';

  @override
  String get yourName => 'Twoje imię';

  @override
  String get nameHint => 'Wpisz tak, jak wołasz na dziecko';

  @override
  String get done => 'Gotowe';

  @override
  String get back => 'Wstecz';

  @override
  String get parentZone => 'Rodzice';

  @override
  String get stars => 'Gwiazdki';

  @override
  String get badges => 'Odznaki';

  @override
  String get choosePromotion => 'Twój pionek dorósł! Wybierz figurę.';

  @override
  String get gateTitle => 'Dla rodzica: rozwiąż';

  @override
  String get gateWrong => 'Nie tym razem, spróbuj jeszcze raz';

  @override
  String get profiles => 'Gracze';

  @override
  String get language => 'Język';

  @override
  String get systemLanguage => 'Auto';

  @override
  String get polish => 'Polski';

  @override
  String get english => 'English';

  @override
  String get voice => 'Głos';

  @override
  String get voiceEnabled => 'Czytaj na głos';

  @override
  String get speechRate => 'Tempo mowy';

  @override
  String get slow => 'Wolno';

  @override
  String get normal => 'Normalnie';

  @override
  String get fast => 'Szybko';

  @override
  String get testVoice => 'Sprawdź głos';

  @override
  String get voiceUnavailable =>
      'Brak zainstalowanego głosu dla tego języka. Otwórz ustawienia syntezy mowy w telefonie i zainstaluj głos.';

  @override
  String get colors => 'Kolory';

  @override
  String get uiColors => 'Kolory aplikacji';

  @override
  String get boardColors => 'Kolory planszy';

  @override
  String get childPlays => 'Dziecko gra';

  @override
  String get alwaysWhite => 'Zawsze białymi';

  @override
  String get randomColor => 'Losowym kolorem';

  @override
  String get miniGamesSettings => 'Mini-gry';

  @override
  String get unlockAllMiniGames =>
      'Odblokuj wszystkie mini-gry dla tego gracza';

  @override
  String get editProfile => 'Edytuj';

  @override
  String get resetProgress => 'Wyzeruj postęp';

  @override
  String resetProgressQuestion(String name) {
    return 'Usunąć wszystkie gwiazdki i odznaki gracza $name?';
  }

  @override
  String get deleteProfile => 'Usuń';

  @override
  String deleteProfileQuestion(String name) {
    return 'Usunąć gracza $name i cały postęp?';
  }

  @override
  String get unnamedPlayer => '(bez imienia)';

  @override
  String get cancel => 'Anuluj';

  @override
  String get confirm => 'Tak';

  @override
  String get about => 'O aplikacji';

  @override
  String get offlineNotice =>
      'Ta aplikacja nigdy nie łączy się z internetem i nie zbiera żadnych danych.';

  @override
  String get licenses => 'Licencje';

  @override
  String version(String version) {
    return 'Wersja $version';
  }

  @override
  String get sandboxTitle => 'Wolna gra';

  @override
  String get yourMove => 'Twój ruch!';

  @override
  String get check => 'Szach! Ratuj króla!';

  @override
  String get checkmateWhite => 'Mat! Wygrały białe!';

  @override
  String get checkmateBlack => 'Mat! Wygrały czarne!';

  @override
  String get stalemate => 'Pat. Remis!';

  @override
  String get draw => 'Remis!';

  @override
  String get newGame => 'Nowa partia';

  @override
  String get undo => 'Cofnij';
}
