import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Chess for Kids'**
  String get appTitle;

  /// No description provided for @whoIsPlaying.
  ///
  /// In en, this message translates to:
  /// **'Who is playing?'**
  String get whoIsPlaying;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! What shall we play today?'**
  String get greeting;

  /// No description provided for @greetingNamed.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}! What shall we play today?'**
  String greetingNamed(String name);

  /// No description provided for @learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// No description provided for @learnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'pieces and their moves'**
  String get learnSubtitle;

  /// No description provided for @miniGames.
  ///
  /// In en, this message translates to:
  /// **'Mini-games'**
  String get miniGames;

  /// No description provided for @miniGamesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'pawn war, bishop tracks...'**
  String get miniGamesSubtitle;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @playSubtitle.
  ///
  /// In en, this message translates to:
  /// **'play against the computer'**
  String get playSubtitle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @addProfile.
  ///
  /// In en, this message translates to:
  /// **'Add a player'**
  String get addProfile;

  /// No description provided for @chooseTeachers.
  ///
  /// In en, this message translates to:
  /// **'Choose your teachers'**
  String get chooseTeachers;

  /// No description provided for @chooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose your picture'**
  String get chooseAvatar;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Type it the way you call your child'**
  String get nameHint;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @parentZone.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get parentZone;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get stars;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @choosePromotion.
  ///
  /// In en, this message translates to:
  /// **'Your pawn grows up! Pick a piece.'**
  String get choosePromotion;

  /// No description provided for @gateTitle.
  ///
  /// In en, this message translates to:
  /// **'For parents: solve this'**
  String get gateTitle;

  /// No description provided for @gateWrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite, try another one'**
  String get gateWrong;

  /// No description provided for @profiles.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get profiles;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get systemLanguage;

  /// No description provided for @polish.
  ///
  /// In en, this message translates to:
  /// **'Polski'**
  String get polish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @voiceEnabled.
  ///
  /// In en, this message translates to:
  /// **'Speak out loud'**
  String get voiceEnabled;

  /// No description provided for @speechRate.
  ///
  /// In en, this message translates to:
  /// **'Speech speed'**
  String get speechRate;

  /// No description provided for @slow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get slow;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// No description provided for @testVoice.
  ///
  /// In en, this message translates to:
  /// **'Test voice'**
  String get testVoice;

  /// No description provided for @voiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No voice for this language is installed. Open your phone\'s text-to-speech settings and install one.'**
  String get voiceUnavailable;

  /// No description provided for @colors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get colors;

  /// No description provided for @uiColors.
  ///
  /// In en, this message translates to:
  /// **'App colors'**
  String get uiColors;

  /// No description provided for @boardColors.
  ///
  /// In en, this message translates to:
  /// **'Board colors'**
  String get boardColors;

  /// No description provided for @childPlays.
  ///
  /// In en, this message translates to:
  /// **'Child plays'**
  String get childPlays;

  /// No description provided for @alwaysWhite.
  ///
  /// In en, this message translates to:
  /// **'Always white'**
  String get alwaysWhite;

  /// No description provided for @randomColor.
  ///
  /// In en, this message translates to:
  /// **'Random color'**
  String get randomColor;

  /// No description provided for @miniGamesSettings.
  ///
  /// In en, this message translates to:
  /// **'Mini-games'**
  String get miniGamesSettings;

  /// No description provided for @unlockAllMiniGames.
  ///
  /// In en, this message translates to:
  /// **'Unlock all mini-games for this player'**
  String get unlockAllMiniGames;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editProfile;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get resetProgress;

  /// No description provided for @resetProgressQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove all stars and badges of {name}?'**
  String resetProgressQuestion(String name);

  /// No description provided for @deleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteProfile;

  /// No description provided for @deleteProfileQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete the player {name} and all their progress?'**
  String deleteProfileQuestion(String name);

  /// No description provided for @unnamedPlayer.
  ///
  /// In en, this message translates to:
  /// **'(no name)'**
  String get unnamedPlayer;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get confirm;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @offlineNotice.
  ///
  /// In en, this message translates to:
  /// **'This app never connects to the internet and collects no data.'**
  String get offlineNotice;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @sandboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Free play'**
  String get sandboxTitle;

  /// No description provided for @yourMove.
  ///
  /// In en, this message translates to:
  /// **'Your move!'**
  String get yourMove;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check! Save the king!'**
  String get check;

  /// No description provided for @checkmateWhite.
  ///
  /// In en, this message translates to:
  /// **'Checkmate! White wins!'**
  String get checkmateWhite;

  /// No description provided for @checkmateBlack.
  ///
  /// In en, this message translates to:
  /// **'Checkmate! Black wins!'**
  String get checkmateBlack;

  /// No description provided for @stalemate.
  ///
  /// In en, this message translates to:
  /// **'Stalemate. It\'s a draw!'**
  String get stalemate;

  /// No description provided for @draw.
  ///
  /// In en, this message translates to:
  /// **'It\'s a draw!'**
  String get draw;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get newGame;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
