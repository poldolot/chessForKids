// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Chess for Kids';

  @override
  String get whoIsPlaying => 'Who is playing?';

  @override
  String get greeting => 'Hi! What shall we play today?';

  @override
  String greetingNamed(String name) {
    return 'Hi, $name! What shall we play today?';
  }

  @override
  String get learn => 'Learn';

  @override
  String get learnSubtitle => 'pieces and their moves';

  @override
  String get miniGames => 'Mini-games';

  @override
  String get miniGamesSubtitle => 'pawn war, bishop tracks...';

  @override
  String get play => 'Play';

  @override
  String get playSubtitle => 'play against the computer';

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String get addProfile => 'Add a player';

  @override
  String get chooseTeachers => 'Choose your teachers';

  @override
  String get chooseAvatar => 'Choose your picture';

  @override
  String get yourName => 'Your name';

  @override
  String get nameHint => 'Type it the way you call your child';

  @override
  String get done => 'Done';

  @override
  String get back => 'Back';

  @override
  String get parentZone => 'Parents';

  @override
  String get stars => 'Stars';

  @override
  String get badges => 'Badges';

  @override
  String get choosePromotion => 'Your pawn grows up! Pick a piece.';

  @override
  String get gateTitle => 'For parents: solve this';

  @override
  String get gateWrong => 'Not quite, try another one';

  @override
  String get profiles => 'Players';

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'Auto';

  @override
  String get polish => 'Polski';

  @override
  String get english => 'English';

  @override
  String get voice => 'Voice';

  @override
  String get voiceEnabled => 'Speak out loud';

  @override
  String get speechRate => 'Speech speed';

  @override
  String get slow => 'Slow';

  @override
  String get normal => 'Normal';

  @override
  String get fast => 'Fast';

  @override
  String get testVoice => 'Test voice';

  @override
  String get voiceUnavailable =>
      'No voice for this language is installed. Open your phone\'s text-to-speech settings and install one.';

  @override
  String get colors => 'Colors';

  @override
  String get uiColors => 'App colors';

  @override
  String get boardColors => 'Board colors';

  @override
  String get childPlays => 'Child plays';

  @override
  String get alwaysWhite => 'Always white';

  @override
  String get randomColor => 'Random color';

  @override
  String get miniGamesSettings => 'Mini-games';

  @override
  String get unlockAllMiniGames => 'Unlock all mini-games for this player';

  @override
  String get editProfile => 'Edit';

  @override
  String get resetProgress => 'Reset progress';

  @override
  String resetProgressQuestion(String name) {
    return 'Remove all stars and badges of $name?';
  }

  @override
  String get deleteProfile => 'Delete';

  @override
  String deleteProfileQuestion(String name) {
    return 'Delete the player $name and all their progress?';
  }

  @override
  String get unnamedPlayer => '(no name)';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Yes';

  @override
  String get about => 'About';

  @override
  String get offlineNotice =>
      'This app never connects to the internet and collects no data.';

  @override
  String get licenses => 'Licenses';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get sandboxTitle => 'Free play';

  @override
  String get yourMove => 'Your move!';

  @override
  String get check => 'Check! Save the king!';

  @override
  String get checkmateWhite => 'Checkmate! White wins!';

  @override
  String get checkmateBlack => 'Checkmate! Black wins!';

  @override
  String get stalemate => 'Stalemate. It\'s a draw!';

  @override
  String get draw => 'It\'s a draw!';

  @override
  String get newGame => 'New game';

  @override
  String get undo => 'Undo';
}
