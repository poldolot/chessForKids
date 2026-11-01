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

  @override
  String get learnTitle => 'Nauka';

  @override
  String get learnCommonNext => 'Dalej';

  @override
  String get learnCommonTryAgain => 'Spróbuj jeszcze raz!';

  @override
  String get learnCommonWellDone => 'Brawo!';

  @override
  String get learnCommonTapDot => 'Dotknij żółtej kropki, żeby się ruszyć.';

  @override
  String get learnCommonCaptureFrame => 'Zbij czarną figurę w czerwonej ramce.';

  @override
  String get learnCommonLocked => 'Najpierw skończ poprzednią lekcję.';

  @override
  String get learnCommonStarsCollect => 'Zbierz wszystkie gwiazdki!';

  @override
  String get learnCommonLimitHint => 'Mało ruchów! Celuj prosto w gwiazdki.';

  @override
  String get learnCommonBadge => 'Masz nową odznakę!';

  @override
  String get learnCommonPlay => 'Zagraj';

  @override
  String get learnCommonAllDone =>
      'Wszystkie lekcje zrobione. Jesteś mistrzem!';

  @override
  String get learnPawnTitle => 'Pion';

  @override
  String get learnPawnIntro =>
      'To jest pion. Jest mały, ale dzielny. Idzie tylko do przodu.';

  @override
  String get learnPawnMove =>
      'Pion idzie o jedno pole. Z początku może iść o dwa!';

  @override
  String get learnPawnCapture => 'Pion bije na ukos. Prosto nie bije!';

  @override
  String get learnPawnPractice => 'Ruszaj pionkami i bij, co się da!';

  @override
  String get learnPawnHint => 'Pion bije tylko na ukos.';

  @override
  String get learnRookTitle => 'Wieża';

  @override
  String get learnRookIntro => 'To jest wieża. Mocna jak zamek.';

  @override
  String get learnRookMove =>
      'Wieża jedzie prosto: w górę, w dół, w lewo, w prawo.';

  @override
  String get learnRookCapture => 'Wieża bije to, co stoi na jej drodze.';

  @override
  String get learnRookPractice => 'Zbierz gwiazdki w pięciu ruchach!';

  @override
  String get learnRookHint => 'Wieża nie jeździ na ukos.';

  @override
  String get learnBishopTitle => 'Goniec';

  @override
  String get learnBishopIntro => 'To jest goniec. Biega po skosie.';

  @override
  String get learnBishopMove =>
      'Goniec jedzie tylko na ukos i zawsze zostaje na swoim kolorze.';

  @override
  String get learnBishopCapture => 'Goniec bije po skosie.';

  @override
  String get learnBishopPractice => 'Zbierz gwiazdki po skosie!';

  @override
  String get learnBishopHint => 'Goniec jeździ tylko na ukos.';

  @override
  String get learnQueenTitle => 'Hetman';

  @override
  String get learnQueenIntro => 'To jest hetman. Najsilniejsza figura!';

  @override
  String get learnQueenMove =>
      'Hetman jedzie prosto i na ukos, jak wieża i goniec razem.';

  @override
  String get learnQueenCapture => 'Hetman bije we wszystkich kierunkach.';

  @override
  String get learnQueenPractice => 'Zbierz gwiazdki ze wszystkich rogów!';

  @override
  String get learnQueenHint =>
      'Hetman jedzie prosto albo na ukos, nie jak skoczek.';

  @override
  String get learnKingTitle => 'Król';

  @override
  String get learnKingIntro =>
      'To jest król. Najważniejszy. Trzeba go chronić!';

  @override
  String get learnKingMove => 'Król robi tylko jeden krok, w każdą stronę.';

  @override
  String get learnKingCapture => 'Król może zbić figurę obok siebie.';

  @override
  String get learnKingPractice =>
      'Przejdź na drugą stronę. Omijaj czerwone pola, tam biją!';

  @override
  String get learnKingHint => 'Tam król byłby w niebezpieczeństwie.';

  @override
  String get learnKnightTitle => 'Skoczek';

  @override
  String get learnKnightIntro =>
      'To jest skoczek, konik. Skacze przez inne figury!';

  @override
  String get learnKnightMove =>
      'Skoczek skacze literą L: dwa pola prosto i jedno w bok.';

  @override
  String get learnKnightCapture => 'Skoczek bije tam, gdzie wyląduje.';

  @override
  String get learnKnightPractice => 'Przeskocz przez labirynt po gwiazdki!';

  @override
  String get learnKnightHint => 'Skoczek skacze tylko literą L.';

  @override
  String get learnSetupTitle => 'Ustawienie';

  @override
  String get learnSetupIntro =>
      'Każda figura ma swoje miejsce. Hetman lubi swój kolor!';

  @override
  String get learnSetupTask => 'Przeciągnij figury na ich cienie.';

  @override
  String get learnSetupPawns => 'Pionki ustawiają się same. Gotowe!';

  @override
  String get learnCheckTitle => 'Szach';

  @override
  String get learnCheckIntro =>
      'Gdy ktoś atakuje króla, to szach. Króla trzeba ratować!';

  @override
  String get learnCheckDemo => 'Wieża atakuje króla. Szach!';

  @override
  String get learnCheckEscape => 'Uciekaj królem!';

  @override
  String get learnCheckCapture => 'Zbij figurę, która szachuje!';

  @override
  String get learnCheckBlock => 'Zasłoń króla inną figurą!';

  @override
  String get learnCheckHint =>
      'Król wciąż w niebezpieczeństwie. Spróbuj inaczej.';

  @override
  String get learnMateTitle => 'Mat';

  @override
  String get learnMateIntro => 'Gdy król nie ma ucieczki, to mat. Koniec gry!';

  @override
  String get learnMateTask => 'Daj mata jednym ruchem!';

  @override
  String get learnMateHint => 'To nie był mat. Król jeszcze ucieknie.';

  @override
  String get learnStalemateTitle => 'Pat';

  @override
  String get learnStalemateIntro =>
      'Gdy król nie jest w szachu, ale nie ma ruchu, to pat. Remis!';

  @override
  String get learnStalemateDemo =>
      'Patrz: czarny król nie ma ruchu. Pat, remis!';

  @override
  String get learnStalemateTask => 'Teraz ty: daj mata, nie pata!';

  @override
  String get learnStalemateHint => 'Ojej, to pat. Remis! Spróbuj inaczej.';

  @override
  String get learnCastlingTitle => 'Roszada';

  @override
  String get learnCastlingIntro =>
      'Król i wieża mogą się razem schować. To roszada.';

  @override
  String get learnCastlingDemo =>
      'Król idzie dwa pola, a wieża przeskakuje obok.';

  @override
  String get learnCastlingTask =>
      'Zrób roszadę: dotknij króla, potem pole dwa dalej.';

  @override
  String get learnCastlingHint => 'To nie roszada. Król musi pójść o dwa pola.';

  @override
  String get learnEnPassantTitle => 'Bicie w przelocie';

  @override
  String get learnEnPassantIntro =>
      'Pion, który przeskoczył dwa pola, można zbić w przelocie.';

  @override
  String get learnEnPassantDemo =>
      'Czarny pion skoczył o dwa pola obok białego.';

  @override
  String get learnEnPassantTask => 'Zbij go w przelocie, na ukos!';

  @override
  String get learnEnPassantHint =>
      'Zbij na ukos, tam gdzie pion by stanął po jednym kroku.';

  @override
  String get learnPromotionTitle => 'Promocja';

  @override
  String get learnPromotionIntro =>
      'Pion, który dojdzie na koniec, zamienia się w inną figurę!';

  @override
  String get learnPromotionTask => 'Dojdź pionkiem na koniec i wybierz figurę.';

  @override
  String get learnPromotionKnight => 'A teraz zamień pionka w skoczka!';

  @override
  String get learnValuesTitle => 'Ile warte';

  @override
  String get learnValuesIntro =>
      'Każda figura jest coś warta. Hetman najwięcej!';

  @override
  String get learnValuesTask => 'Która figura jest cenniejsza? Dotknij ją.';

  @override
  String get learnValuesHint => 'Nie, ta druga jest cenniejsza.';

  @override
  String get gamesTitle => 'Mini-gry';

  @override
  String get gamesCommonBoards => 'Plansze';

  @override
  String get gamesCommonHint => 'Spróbuj tak!';

  @override
  String get gamesCommonUndo => 'Cofnij';

  @override
  String get gamesCommonAgain => 'Jeszcze raz';

  @override
  String get gamesCommonNext => 'Następna';

  @override
  String get gamesCommonBack => 'Wróć';

  @override
  String get gamesCommonWon => 'Wygrana! Brawo!';

  @override
  String get gamesCommonLost => 'Tym razem nie wyszło. Spróbuj jeszcze raz!';

  @override
  String get gamesCommonLimit => 'Skończyły się ruchy. Jeszcze raz!';

  @override
  String get gamesCommonYourMove => 'Twój ruch!';

  @override
  String get gamesCommonOpponentMoves => 'Teraz ja.';

  @override
  String get gamesCommonBadgeHunter => 'Odznaka Łowcy! Dziesięć wygranych!';

  @override
  String get gamesCommonBadgeCollector => 'Pięćdziesiąt gwiazdek! Kolekcjoner!';

  @override
  String get gamesPawnWarTitle => 'Wojna pionów';

  @override
  String get gamesPawnWarIntro =>
      'Twoje pionki kontra moje. Dojdź pionkiem na drugi koniec albo zbij wszystkie moje!';

  @override
  String get gamesPawnWarHint =>
      'Pionek, który dojdzie na koniec, wygrywa. Bij na ukos!';

  @override
  String get gamesRookRoadsTitle => 'Drogi wieży';

  @override
  String get gamesRookRoadsIntro =>
      'Zbierz wieżą wszystkie gwiazdki. Jak najmniej ruchów!';

  @override
  String get gamesRookRoadsHint => 'Wieża jedzie prosto. Omijaj swoje pionki.';

  @override
  String get gamesBishopTracksTitle => 'Tory gońca';

  @override
  String get gamesBishopTracksIntro =>
      'Zbierz gońcem gwiazdki. Goniec zostaje na swoim kolorze!';

  @override
  String get gamesBishopTracksHint => 'Goniec jeździ tylko na ukos.';

  @override
  String get gamesKingRaceTitle => 'Wyścig królem';

  @override
  String get gamesKingRaceIntro =>
      'Przeprowadź króla na drugą stronę. Czerwone pola są niebezpieczne!';

  @override
  String get gamesKingRaceHint => 'Krok po kroku. Omijaj czerwone pola.';

  @override
  String get gamesHuntTitle => 'Polowanie';

  @override
  String get gamesHuntIntro =>
      'Złap uciekającą figurę, zanim skończą się ruchy!';

  @override
  String get gamesHuntHint => 'Goń ją! Zbij, gdy będzie w zasięgu.';

  @override
  String gamesCommonLocked(String lesson) {
    return 'Najpierw lekcja: $lesson. Chodź, pokażę!';
  }
}
