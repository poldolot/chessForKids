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
  /// **'Choose a profile or add a new one.'**
  String get whoIsPlaying;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! Pick a lesson, a mini-game or a match.'**
  String get greeting;

  /// No description provided for @greetingNamed.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}! Pick a lesson, a mini-game or a match.'**
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

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @learnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnTitle;

  /// No description provided for @learnCommonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get learnCommonNext;

  /// No description provided for @learnCommonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again!'**
  String get learnCommonTryAgain;

  /// No description provided for @learnCommonWellDone.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get learnCommonWellDone;

  /// No description provided for @learnCommonTapDot.
  ///
  /// In en, this message translates to:
  /// **'Tap a yellow dot to move.'**
  String get learnCommonTapDot;

  /// No description provided for @learnCommonCaptureFrame.
  ///
  /// In en, this message translates to:
  /// **'Capture the black piece in the red frame.'**
  String get learnCommonCaptureFrame;

  /// No description provided for @learnCommonLocked.
  ///
  /// In en, this message translates to:
  /// **'Finish the previous lesson first.'**
  String get learnCommonLocked;

  /// No description provided for @learnCommonStarsCollect.
  ///
  /// In en, this message translates to:
  /// **'Collect all the stars!'**
  String get learnCommonStarsCollect;

  /// No description provided for @learnCommonLimitHint.
  ///
  /// In en, this message translates to:
  /// **'Few moves left! Aim straight for the stars.'**
  String get learnCommonLimitHint;

  /// No description provided for @learnCommonBadge.
  ///
  /// In en, this message translates to:
  /// **'You earned a new badge!'**
  String get learnCommonBadge;

  /// No description provided for @learnCommonAllDone.
  ///
  /// In en, this message translates to:
  /// **'All lessons done. You are a champion!'**
  String get learnCommonAllDone;

  /// No description provided for @learnPawnTitle.
  ///
  /// In en, this message translates to:
  /// **'Pawn'**
  String get learnPawnTitle;

  /// No description provided for @learnPawnIntro.
  ///
  /// In en, this message translates to:
  /// **'This is the pawn. Small but brave. It only moves forward.'**
  String get learnPawnIntro;

  /// No description provided for @learnPawnMove.
  ///
  /// In en, this message translates to:
  /// **'A pawn moves one square. From its start it may move two!'**
  String get learnPawnMove;

  /// No description provided for @learnPawnCapture.
  ///
  /// In en, this message translates to:
  /// **'A pawn captures diagonally. Never straight ahead!'**
  String get learnPawnCapture;

  /// No description provided for @learnPawnPractice.
  ///
  /// In en, this message translates to:
  /// **'Move your pawns and capture what you can!'**
  String get learnPawnPractice;

  /// No description provided for @learnPawnHint.
  ///
  /// In en, this message translates to:
  /// **'A pawn captures only diagonally.'**
  String get learnPawnHint;

  /// No description provided for @learnPawnMoveHint.
  ///
  /// In en, this message translates to:
  /// **'From its first square a pawn can jump two!'**
  String get learnPawnMoveHint;

  /// No description provided for @learnRookTitle.
  ///
  /// In en, this message translates to:
  /// **'Rook'**
  String get learnRookTitle;

  /// No description provided for @learnRookIntro.
  ///
  /// In en, this message translates to:
  /// **'This is the rook. Strong as a castle.'**
  String get learnRookIntro;

  /// No description provided for @learnRookMove.
  ///
  /// In en, this message translates to:
  /// **'The rook goes straight: up, down, left, right.'**
  String get learnRookMove;

  /// No description provided for @learnRookCapture.
  ///
  /// In en, this message translates to:
  /// **'The rook captures what stands in its way.'**
  String get learnRookCapture;

  /// No description provided for @learnRookPractice.
  ///
  /// In en, this message translates to:
  /// **'Collect the stars in five moves!'**
  String get learnRookPractice;

  /// No description provided for @learnRookHint.
  ///
  /// In en, this message translates to:
  /// **'A rook never moves diagonally.'**
  String get learnRookHint;

  /// No description provided for @learnBishopTitle.
  ///
  /// In en, this message translates to:
  /// **'Bishop'**
  String get learnBishopTitle;

  /// No description provided for @learnBishopIntro.
  ///
  /// In en, this message translates to:
  /// **'This is the bishop. It runs on diagonals.'**
  String get learnBishopIntro;

  /// No description provided for @learnBishopMove.
  ///
  /// In en, this message translates to:
  /// **'The bishop moves only diagonally and always stays on its color.'**
  String get learnBishopMove;

  /// No description provided for @learnBishopCapture.
  ///
  /// In en, this message translates to:
  /// **'The bishop captures along a diagonal.'**
  String get learnBishopCapture;

  /// No description provided for @learnBishopPractice.
  ///
  /// In en, this message translates to:
  /// **'Collect the stars along the diagonals!'**
  String get learnBishopPractice;

  /// No description provided for @learnBishopHint.
  ///
  /// In en, this message translates to:
  /// **'A bishop moves only diagonally.'**
  String get learnBishopHint;

  /// No description provided for @learnQueenTitle.
  ///
  /// In en, this message translates to:
  /// **'Queen'**
  String get learnQueenTitle;

  /// No description provided for @learnQueenIntro.
  ///
  /// In en, this message translates to:
  /// **'This is the queen. The strongest piece!'**
  String get learnQueenIntro;

  /// No description provided for @learnQueenMove.
  ///
  /// In en, this message translates to:
  /// **'The queen moves straight and diagonally, like a rook and bishop together.'**
  String get learnQueenMove;

  /// No description provided for @learnQueenCapture.
  ///
  /// In en, this message translates to:
  /// **'The queen captures in every direction.'**
  String get learnQueenCapture;

  /// No description provided for @learnQueenPractice.
  ///
  /// In en, this message translates to:
  /// **'Collect the stars from every corner!'**
  String get learnQueenPractice;

  /// No description provided for @learnQueenHint.
  ///
  /// In en, this message translates to:
  /// **'A queen moves straight or diagonally, never like a knight.'**
  String get learnQueenHint;

  /// No description provided for @learnKingTitle.
  ///
  /// In en, this message translates to:
  /// **'King'**
  String get learnKingTitle;

  /// No description provided for @learnKingIntro.
  ///
  /// In en, this message translates to:
  /// **'This is the king. The most important one. Protect him!'**
  String get learnKingIntro;

  /// No description provided for @learnKingMove.
  ///
  /// In en, this message translates to:
  /// **'The king takes just one step, in any direction.'**
  String get learnKingMove;

  /// No description provided for @learnKingCapture.
  ///
  /// In en, this message translates to:
  /// **'The king can capture a piece next to him.'**
  String get learnKingCapture;

  /// No description provided for @learnKingPractice.
  ///
  /// In en, this message translates to:
  /// **'Cross to the other side. Avoid the red squares, they are attacked!'**
  String get learnKingPractice;

  /// No description provided for @learnKingHint.
  ///
  /// In en, this message translates to:
  /// **'The king would be in danger there.'**
  String get learnKingHint;

  /// No description provided for @learnKnightTitle.
  ///
  /// In en, this message translates to:
  /// **'Knight'**
  String get learnKnightTitle;

  /// No description provided for @learnKnightIntro.
  ///
  /// In en, this message translates to:
  /// **'This is the knight, the horse. It jumps over other pieces!'**
  String get learnKnightIntro;

  /// No description provided for @learnKnightMove.
  ///
  /// In en, this message translates to:
  /// **'The knight jumps in an L: two squares straight and one to the side.'**
  String get learnKnightMove;

  /// No description provided for @learnKnightCapture.
  ///
  /// In en, this message translates to:
  /// **'The knight captures where it lands.'**
  String get learnKnightCapture;

  /// No description provided for @learnKnightPractice.
  ///
  /// In en, this message translates to:
  /// **'Hop through the maze to the stars!'**
  String get learnKnightPractice;

  /// No description provided for @learnKnightHint.
  ///
  /// In en, this message translates to:
  /// **'A knight only jumps in an L.'**
  String get learnKnightHint;

  /// No description provided for @learnSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get learnSetupTitle;

  /// No description provided for @learnSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'Every piece has its place. The queen likes her own color!'**
  String get learnSetupIntro;

  /// No description provided for @learnSetupTask.
  ///
  /// In en, this message translates to:
  /// **'Drag the pieces onto their shadows.'**
  String get learnSetupTask;

  /// No description provided for @learnSetupPawns.
  ///
  /// In en, this message translates to:
  /// **'The pawns line up by themselves. Done!'**
  String get learnSetupPawns;

  /// No description provided for @learnCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get learnCheckTitle;

  /// No description provided for @learnCheckIntro.
  ///
  /// In en, this message translates to:
  /// **'When someone attacks the king, it\'s check. Save the king!'**
  String get learnCheckIntro;

  /// No description provided for @learnCheckDemo.
  ///
  /// In en, this message translates to:
  /// **'The rook attacks the king. Check!'**
  String get learnCheckDemo;

  /// No description provided for @learnCheckEscape.
  ///
  /// In en, this message translates to:
  /// **'Run with the king!'**
  String get learnCheckEscape;

  /// No description provided for @learnCheckCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture the piece that gives check!'**
  String get learnCheckCapture;

  /// No description provided for @learnCheckBlock.
  ///
  /// In en, this message translates to:
  /// **'Shield the king with another piece!'**
  String get learnCheckBlock;

  /// No description provided for @learnCheckHint.
  ///
  /// In en, this message translates to:
  /// **'The king is still in danger. Try another way.'**
  String get learnCheckHint;

  /// No description provided for @learnMateTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkmate'**
  String get learnMateTitle;

  /// No description provided for @learnMateIntro.
  ///
  /// In en, this message translates to:
  /// **'When the king cannot escape, it\'s checkmate. Game over!'**
  String get learnMateIntro;

  /// No description provided for @learnMateTask.
  ///
  /// In en, this message translates to:
  /// **'Give checkmate in one move!'**
  String get learnMateTask;

  /// No description provided for @learnMateHint.
  ///
  /// In en, this message translates to:
  /// **'That was not checkmate. The king can still escape.'**
  String get learnMateHint;

  /// No description provided for @learnStalemateTitle.
  ///
  /// In en, this message translates to:
  /// **'Stalemate'**
  String get learnStalemateTitle;

  /// No description provided for @learnStalemateIntro.
  ///
  /// In en, this message translates to:
  /// **'When the king is not in check but has no move, it\'s stalemate. A draw!'**
  String get learnStalemateIntro;

  /// No description provided for @learnStalemateDemo.
  ///
  /// In en, this message translates to:
  /// **'Look: the black king has no move. Stalemate, a draw!'**
  String get learnStalemateDemo;

  /// No description provided for @learnStalemateTask.
  ///
  /// In en, this message translates to:
  /// **'Now you: give checkmate, not stalemate!'**
  String get learnStalemateTask;

  /// No description provided for @learnStalemateHint.
  ///
  /// In en, this message translates to:
  /// **'Oops, that\'s stalemate. A draw! Try another move.'**
  String get learnStalemateHint;

  /// No description provided for @learnCastlingTitle.
  ///
  /// In en, this message translates to:
  /// **'Castling'**
  String get learnCastlingTitle;

  /// No description provided for @learnCastlingIntro.
  ///
  /// In en, this message translates to:
  /// **'The king and rook can hide together. That\'s castling.'**
  String get learnCastlingIntro;

  /// No description provided for @learnCastlingDemo.
  ///
  /// In en, this message translates to:
  /// **'The king moves two squares and the rook jumps beside him.'**
  String get learnCastlingDemo;

  /// No description provided for @learnCastlingTask.
  ///
  /// In en, this message translates to:
  /// **'Castle: tap the king, then the square two away.'**
  String get learnCastlingTask;

  /// No description provided for @learnCastlingHint.
  ///
  /// In en, this message translates to:
  /// **'That\'s not castling. The king must move two squares.'**
  String get learnCastlingHint;

  /// No description provided for @learnEnPassantTitle.
  ///
  /// In en, this message translates to:
  /// **'En passant'**
  String get learnEnPassantTitle;

  /// No description provided for @learnEnPassantIntro.
  ///
  /// In en, this message translates to:
  /// **'A pawn that jumped two squares can be captured in passing.'**
  String get learnEnPassantIntro;

  /// No description provided for @learnEnPassantDemo.
  ///
  /// In en, this message translates to:
  /// **'The black pawn jumped two squares next to the white one.'**
  String get learnEnPassantDemo;

  /// No description provided for @learnEnPassantTask.
  ///
  /// In en, this message translates to:
  /// **'Capture it in passing, diagonally!'**
  String get learnEnPassantTask;

  /// No description provided for @learnEnPassantHint.
  ///
  /// In en, this message translates to:
  /// **'Capture diagonally, where the pawn would have stopped after one step.'**
  String get learnEnPassantHint;

  /// No description provided for @learnPromotionTitle.
  ///
  /// In en, this message translates to:
  /// **'Promotion'**
  String get learnPromotionTitle;

  /// No description provided for @learnPromotionIntro.
  ///
  /// In en, this message translates to:
  /// **'A pawn that reaches the end turns into another piece!'**
  String get learnPromotionIntro;

  /// No description provided for @learnPromotionTask.
  ///
  /// In en, this message translates to:
  /// **'Take the pawn to the end and pick a piece.'**
  String get learnPromotionTask;

  /// No description provided for @learnPromotionKnight.
  ///
  /// In en, this message translates to:
  /// **'Now turn the pawn into a knight!'**
  String get learnPromotionKnight;

  /// No description provided for @learnValuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Values'**
  String get learnValuesTitle;

  /// No description provided for @learnValuesIntro.
  ///
  /// In en, this message translates to:
  /// **'Every piece is worth something. The queen the most!'**
  String get learnValuesIntro;

  /// No description provided for @learnValuesTask.
  ///
  /// In en, this message translates to:
  /// **'Which piece is worth more? Tap it.'**
  String get learnValuesTask;

  /// No description provided for @learnValuesHint.
  ///
  /// In en, this message translates to:
  /// **'No, the other one is worth more.'**
  String get learnValuesHint;

  /// No description provided for @gamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Mini-games'**
  String get gamesTitle;

  /// No description provided for @gamesCommonBoards.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get gamesCommonBoards;

  /// No description provided for @gamesCommonHint.
  ///
  /// In en, this message translates to:
  /// **'Try this!'**
  String get gamesCommonHint;

  /// No description provided for @gamesCommonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get gamesCommonUndo;

  /// No description provided for @gamesCommonAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get gamesCommonAgain;

  /// No description provided for @gamesCommonNext.
  ///
  /// In en, this message translates to:
  /// **'Next level'**
  String get gamesCommonNext;

  /// No description provided for @gamesCommonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get gamesCommonBack;

  /// No description provided for @gamesCommonWon.
  ///
  /// In en, this message translates to:
  /// **'You won! Well done!'**
  String get gamesCommonWon;

  /// No description provided for @gamesCommonLost.
  ///
  /// In en, this message translates to:
  /// **'Not this time. Try again!'**
  String get gamesCommonLost;

  /// No description provided for @gamesCommonLimit.
  ///
  /// In en, this message translates to:
  /// **'Out of moves. One more time!'**
  String get gamesCommonLimit;

  /// No description provided for @gamesCommonYourMove.
  ///
  /// In en, this message translates to:
  /// **'Your move!'**
  String get gamesCommonYourMove;

  /// No description provided for @gamesCommonOpponentMoves.
  ///
  /// In en, this message translates to:
  /// **'My turn.'**
  String get gamesCommonOpponentMoves;

  /// No description provided for @gamesCommonBadgeHunter.
  ///
  /// In en, this message translates to:
  /// **'Hunter badge! Ten wins!'**
  String get gamesCommonBadgeHunter;

  /// No description provided for @gamesCommonBadgeCollector.
  ///
  /// In en, this message translates to:
  /// **'Fifty stars! Collector!'**
  String get gamesCommonBadgeCollector;

  /// No description provided for @gamesPawnWarTitle.
  ///
  /// In en, this message translates to:
  /// **'Pawn War'**
  String get gamesPawnWarTitle;

  /// No description provided for @gamesPawnWarIntro.
  ///
  /// In en, this message translates to:
  /// **'Your pawns against mine. Reach the far side or capture all of mine!'**
  String get gamesPawnWarIntro;

  /// No description provided for @gamesPawnWarHint.
  ///
  /// In en, this message translates to:
  /// **'A pawn that reaches the end wins. Capture diagonally!'**
  String get gamesPawnWarHint;

  /// No description provided for @gamesRookRoadsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rook Roads'**
  String get gamesRookRoadsTitle;

  /// No description provided for @gamesRookRoadsIntro.
  ///
  /// In en, this message translates to:
  /// **'Collect every star with the rook. As few moves as you can!'**
  String get gamesRookRoadsIntro;

  /// No description provided for @gamesRookRoadsHint.
  ///
  /// In en, this message translates to:
  /// **'The rook goes straight. Go around your own pawns.'**
  String get gamesRookRoadsHint;

  /// No description provided for @gamesBishopTracksTitle.
  ///
  /// In en, this message translates to:
  /// **'Bishop Tracks'**
  String get gamesBishopTracksTitle;

  /// No description provided for @gamesBishopTracksIntro.
  ///
  /// In en, this message translates to:
  /// **'Collect the stars with the bishop. It stays on its color!'**
  String get gamesBishopTracksIntro;

  /// No description provided for @gamesBishopTracksHint.
  ///
  /// In en, this message translates to:
  /// **'The bishop moves only diagonally.'**
  String get gamesBishopTracksHint;

  /// No description provided for @gamesKingRaceTitle.
  ///
  /// In en, this message translates to:
  /// **'King Race'**
  String get gamesKingRaceTitle;

  /// No description provided for @gamesKingRaceIntro.
  ///
  /// In en, this message translates to:
  /// **'Walk the king to the other side. The red squares are dangerous!'**
  String get gamesKingRaceIntro;

  /// No description provided for @gamesKingRaceHint.
  ///
  /// In en, this message translates to:
  /// **'Step by step. Avoid the red squares.'**
  String get gamesKingRaceHint;

  /// No description provided for @gamesHuntTitle.
  ///
  /// In en, this message translates to:
  /// **'The Hunt'**
  String get gamesHuntTitle;

  /// No description provided for @gamesHuntIntro.
  ///
  /// In en, this message translates to:
  /// **'Catch the fleeing piece before you run out of moves!'**
  String get gamesHuntIntro;

  /// No description provided for @gamesHuntHint.
  ///
  /// In en, this message translates to:
  /// **'Chase it! Capture when it is in reach.'**
  String get gamesHuntHint;

  /// No description provided for @gamesCommonLocked.
  ///
  /// In en, this message translates to:
  /// **'First the lesson: {lesson}. Come, I\'ll show you!'**
  String gamesCommonLocked(String lesson);

  /// No description provided for @matchTitle.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get matchTitle;

  /// No description provided for @matchIntro.
  ///
  /// In en, this message translates to:
  /// **'You play white. Your move!'**
  String get matchIntro;

  /// No description provided for @matchIntroBlack.
  ///
  /// In en, this message translates to:
  /// **'You play black. The computer starts.'**
  String get matchIntroBlack;

  /// No description provided for @matchThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get matchThinking;

  /// No description provided for @matchCheckByYou.
  ///
  /// In en, this message translates to:
  /// **'Check! The king must run!'**
  String get matchCheckByYou;

  /// No description provided for @matchHint.
  ///
  /// In en, this message translates to:
  /// **'Try this!'**
  String get matchHint;

  /// No description provided for @matchResign.
  ///
  /// In en, this message translates to:
  /// **'Resign'**
  String get matchResign;

  /// No description provided for @matchResignQuestion.
  ///
  /// In en, this message translates to:
  /// **'Give up the game?'**
  String get matchResignQuestion;

  /// No description provided for @matchYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get matchYes;

  /// No description provided for @matchNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get matchNo;

  /// No description provided for @matchWon.
  ///
  /// In en, this message translates to:
  /// **'Checkmate! You win! Well done!'**
  String get matchWon;

  /// No description provided for @matchLost.
  ///
  /// In en, this message translates to:
  /// **'Checkmate. The computer won this time. Try again!'**
  String get matchLost;

  /// No description provided for @matchResigned.
  ///
  /// In en, this message translates to:
  /// **'You gave up. Next time!'**
  String get matchResigned;

  /// No description provided for @matchAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get matchAgain;

  /// No description provided for @matchBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get matchBack;

  /// No description provided for @matchBadgeFirstMatch.
  ///
  /// In en, this message translates to:
  /// **'Badge: first match!'**
  String get matchBadgeFirstMatch;

  /// No description provided for @matchBadgeFirstWin.
  ///
  /// In en, this message translates to:
  /// **'Badge: first win!'**
  String get matchBadgeFirstWin;

  /// No description provided for @matchBadgePersistent.
  ///
  /// In en, this message translates to:
  /// **'Badge: persistent player!'**
  String get matchBadgePersistent;

  /// No description provided for @badgesAll.
  ///
  /// In en, this message translates to:
  /// **'All badges'**
  String get badgesAll;

  /// No description provided for @badgesYours.
  ///
  /// In en, this message translates to:
  /// **'Your badges. Tap one and I will tell you what it is for!'**
  String get badgesYours;

  /// No description provided for @badgePawnName.
  ///
  /// In en, this message translates to:
  /// **'Pawn'**
  String get badgePawnName;

  /// No description provided for @badgePawnDesc.
  ///
  /// In en, this message translates to:
  /// **'For the pawn lesson.'**
  String get badgePawnDesc;

  /// No description provided for @badgeRookName.
  ///
  /// In en, this message translates to:
  /// **'Rook'**
  String get badgeRookName;

  /// No description provided for @badgeRookDesc.
  ///
  /// In en, this message translates to:
  /// **'For the rook lesson.'**
  String get badgeRookDesc;

  /// No description provided for @badgeBishopName.
  ///
  /// In en, this message translates to:
  /// **'Bishop'**
  String get badgeBishopName;

  /// No description provided for @badgeBishopDesc.
  ///
  /// In en, this message translates to:
  /// **'For the bishop lesson.'**
  String get badgeBishopDesc;

  /// No description provided for @badgeQueenName.
  ///
  /// In en, this message translates to:
  /// **'Queen'**
  String get badgeQueenName;

  /// No description provided for @badgeQueenDesc.
  ///
  /// In en, this message translates to:
  /// **'For the queen lesson.'**
  String get badgeQueenDesc;

  /// No description provided for @badgeKingName.
  ///
  /// In en, this message translates to:
  /// **'King'**
  String get badgeKingName;

  /// No description provided for @badgeKingDesc.
  ///
  /// In en, this message translates to:
  /// **'For the king lesson.'**
  String get badgeKingDesc;

  /// No description provided for @badgeKnightName.
  ///
  /// In en, this message translates to:
  /// **'Knight'**
  String get badgeKnightName;

  /// No description provided for @badgeKnightDesc.
  ///
  /// In en, this message translates to:
  /// **'For the knight lesson.'**
  String get badgeKnightDesc;

  /// No description provided for @badgeChessPlayerName.
  ///
  /// In en, this message translates to:
  /// **'Chess player'**
  String get badgeChessPlayerName;

  /// No description provided for @badgeChessPlayerDesc.
  ///
  /// In en, this message translates to:
  /// **'For every lesson about the rules.'**
  String get badgeChessPlayerDesc;

  /// No description provided for @badgeFirstMatchName.
  ///
  /// In en, this message translates to:
  /// **'First match'**
  String get badgeFirstMatchName;

  /// No description provided for @badgeFirstMatchDesc.
  ///
  /// In en, this message translates to:
  /// **'For the first finished match.'**
  String get badgeFirstMatchDesc;

  /// No description provided for @badgeFirstWinName.
  ///
  /// In en, this message translates to:
  /// **'First win'**
  String get badgeFirstWinName;

  /// No description provided for @badgeFirstWinDesc.
  ///
  /// In en, this message translates to:
  /// **'For the first match you won.'**
  String get badgeFirstWinDesc;

  /// No description provided for @badgePersistentName.
  ///
  /// In en, this message translates to:
  /// **'Persistent'**
  String get badgePersistentName;

  /// No description provided for @badgePersistentDesc.
  ///
  /// In en, this message translates to:
  /// **'For ten finished matches.'**
  String get badgePersistentDesc;

  /// No description provided for @badgeHunterName.
  ///
  /// In en, this message translates to:
  /// **'Hunter'**
  String get badgeHunterName;

  /// No description provided for @badgeHunterDesc.
  ///
  /// In en, this message translates to:
  /// **'For ten mini-games won.'**
  String get badgeHunterDesc;

  /// No description provided for @badgeCollectorName.
  ///
  /// In en, this message translates to:
  /// **'Collector'**
  String get badgeCollectorName;

  /// No description provided for @badgeCollectorDesc.
  ///
  /// In en, this message translates to:
  /// **'For fifty stars.'**
  String get badgeCollectorDesc;

  /// No description provided for @computerLevel.
  ///
  /// In en, this message translates to:
  /// **'Computer level in matches'**
  String get computerLevel;

  /// No description provided for @levelVeryEasy.
  ///
  /// In en, this message translates to:
  /// **'Very easy'**
  String get levelVeryEasy;

  /// No description provided for @levelEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get levelEasy;

  /// No description provided for @levelNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get levelNormal;

  /// No description provided for @learnPawnPromotionNote.
  ///
  /// In en, this message translates to:
  /// **'The pawn reached the end and became a queen. You will learn that in the promotion lesson!'**
  String get learnPawnPromotionNote;
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
