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
  String get whoIsPlaying => 'Choose a profile or add a new one.';

  @override
  String get greeting => 'Hi! Pick a lesson, a mini-game or a match.';

  @override
  String greetingNamed(String name) {
    return 'Hi, $name! Pick a lesson, a mini-game or a match.';
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
  String get undo => 'Undo';

  @override
  String get learnTitle => 'Learn';

  @override
  String get learnCommonNext => 'Next';

  @override
  String get learnCommonTryAgain => 'Try again!';

  @override
  String get learnCommonWellDone => 'Well done!';

  @override
  String get learnCommonTapDot => 'Tap a yellow dot to move.';

  @override
  String get learnCommonCaptureFrame =>
      'Capture the black piece in the red frame.';

  @override
  String get learnCommonLocked => 'Finish the previous lesson first.';

  @override
  String get learnCommonStarsCollect => 'Collect all the stars!';

  @override
  String get learnCommonLimitHint =>
      'Few moves left! Aim straight for the stars.';

  @override
  String get learnCommonBadge => 'You earned a new badge!';

  @override
  String get learnCommonAllDone => 'All lessons done. You are a champion!';

  @override
  String get learnChessTitle => 'What chess is';

  @override
  String get learnChessIntro =>
      'Chess is a game for two. One has the white army, the other the black one. See what it is about.';

  @override
  String get learnChessArmy =>
      'This is the board at the start. Each army has sixteen pieces.';

  @override
  String get learnChessPawns => 'Eight pawns stand in front.';

  @override
  String get learnChessRooks => 'Two rooks stand in the corners.';

  @override
  String get learnChessKnights =>
      'Next to them two knights, the little horses.';

  @override
  String get learnChessBishops => 'Then two bishops.';

  @override
  String get learnChessQueens => 'One queen.';

  @override
  String get learnChessKings =>
      'And one king. You will meet them all, one by one.';

  @override
  String get learnChessFindKing => 'The king matters most. Tap the white king.';

  @override
  String get learnChessFindBlackKing => 'Well done! Now tap the black king.';

  @override
  String get learnChessKingsFound =>
      'Great! Each player guards their own king.';

  @override
  String get learnChessFindHint =>
      'That is not the king. The king has a little cross on its crown. Try again.';

  @override
  String get learnChessTurns => 'The players take turns. White always starts.';

  @override
  String get learnChessTurnWhite => 'White made a move.';

  @override
  String get learnChessTurnBlack => 'Now black.';

  @override
  String get learnChessTurnWhiteAgain => 'White again.';

  @override
  String get learnChessTurnRule =>
      'And black. Always one move each, taking turns.';

  @override
  String get learnChessCapture =>
      'When you step onto a square where an enemy stands, you take it off the board. That is a capture.';

  @override
  String get learnChessCaptureWhite =>
      'The white pawn captured the black pawn.';

  @override
  String get learnChessCaptureBlack =>
      'And the black queen captured the white pawn. Captured pieces leave the board.';

  @override
  String get learnChessGoal =>
      'The aim is to catch the other king. Watch a short game.';

  @override
  String get learnChessQueenAims => 'The white queen aims at the black king.';

  @override
  String get learnChessMate => 'Check! The queen attacks the king.';

  @override
  String get learnChessWhyMate => 'Can the king save himself? Look.';

  @override
  String get learnChessWhyGuard =>
      'The king would like to capture the queen, but the bishop guards her. A king may never step onto a square where he would be captured.';

  @override
  String get learnChessWhyNoEscape =>
      'He cannot run away either. His own pieces stand next to him, and the queen attacks the free square too.';

  @override
  String get learnChessWhyMateEnd =>
      'The king has no move at all. That is checkmate. White wins!';

  @override
  String get learnChessTask =>
      'Now you! Tap the white queen and capture the pawn next to the black king. Checkmate!';

  @override
  String get learnChessTaskHint =>
      'Tap the white queen, then the pawn in the red frame next to the black king.';

  @override
  String get learnChessOutro =>
      'Sometimes nobody wins and it is a draw. More on that later. Now meet the first piece: the pawn!';

  @override
  String get learnPawnTitle => 'Pawn';

  @override
  String get learnPawnIntro =>
      'This is the pawn. Small but brave. It only moves forward.';

  @override
  String get learnPawnMove =>
      'A pawn moves one square. From its start it may move two! Try it: make three moves.';

  @override
  String get learnPawnCapture =>
      'A pawn captures diagonally. Never straight ahead! Capture the two black pawns.';

  @override
  String get learnPawnPractice => 'Move your pawns and capture what you can!';

  @override
  String get learnPawnHint => 'A pawn captures only diagonally.';

  @override
  String get learnPawnMoveHint => 'From its first square a pawn can jump two!';

  @override
  String get learnRookTitle => 'Rook';

  @override
  String get learnRookIntro => 'This is the rook. Strong as a castle.';

  @override
  String get learnRookMove =>
      'The rook goes straight: up, down, left, right. Try it: make three moves.';

  @override
  String get learnRookCapture =>
      'The rook captures what stands in its way. Capture the two black pawns.';

  @override
  String get learnRookPractice => 'Collect the stars in five moves!';

  @override
  String get learnRookHint => 'A rook never moves diagonally.';

  @override
  String get learnBishopTitle => 'Bishop';

  @override
  String get learnBishopIntro => 'This is the bishop. It runs on diagonals.';

  @override
  String get learnBishopMove =>
      'The bishop moves only diagonally and always stays on its color. Try it: make three moves.';

  @override
  String get learnBishopCapture =>
      'The bishop captures along a diagonal. Capture the two black pawns.';

  @override
  String get learnBishopPractice => 'Collect the stars along the diagonals!';

  @override
  String get learnBishopHint => 'A bishop moves only diagonally.';

  @override
  String get learnQueenTitle => 'Queen';

  @override
  String get learnQueenIntro => 'This is the queen. The strongest piece!';

  @override
  String get learnQueenMove =>
      'The queen moves straight and diagonally, like a rook and bishop together. Try it: make three moves.';

  @override
  String get learnQueenCapture =>
      'The queen captures in every direction. Capture the two black pawns.';

  @override
  String get learnQueenPractice => 'Collect the stars from every corner!';

  @override
  String get learnQueenHint =>
      'A queen moves straight or diagonally, never like a knight.';

  @override
  String get learnKingTitle => 'King';

  @override
  String get learnKingIntro =>
      'This is the king. The most important one. Protect him!';

  @override
  String get learnKingMove =>
      'The king takes just one step, in any direction. Try it: take three steps.';

  @override
  String get learnKingCapture =>
      'The king can capture a piece next to him. Capture the two black pawns.';

  @override
  String get learnKingPractice =>
      'Cross to the other side. Avoid the red squares, they are attacked!';

  @override
  String get learnKingHint => 'The king would be in danger there.';

  @override
  String get learnKnightTitle => 'Knight';

  @override
  String get learnKnightIntro =>
      'This is the knight, the horse. It jumps over other pieces!';

  @override
  String get learnKnightMove =>
      'The knight jumps in an L: two squares straight and one to the side. Try it: make three jumps.';

  @override
  String get learnKnightCapture =>
      'The knight captures where it lands. Capture the two black pawns.';

  @override
  String get learnKnightPractice => 'Hop through the maze to the stars!';

  @override
  String get learnKnightHint => 'A knight only jumps in an L.';

  @override
  String get learnSetupTitle => 'Setup';

  @override
  String get learnSetupIntro =>
      'Every piece has its place. The queen likes her own color!';

  @override
  String get learnSetupTask => 'Drag the pieces onto their shadows.';

  @override
  String get learnSetupPawns => 'The pawns line up by themselves. Done!';

  @override
  String get learnCheckTitle => 'Check';

  @override
  String get learnCheckIntro =>
      'When someone attacks the king, it\'s check. Save the king!';

  @override
  String get learnCheckDemo => 'The rook attacks the king. Check!';

  @override
  String get learnCheckEscape => 'Run with the king!';

  @override
  String get learnCheckCapture => 'Capture the piece that gives check!';

  @override
  String get learnCheckBlock => 'Shield the king with another piece!';

  @override
  String get learnCheckHint => 'The king is still in danger. Try another way.';

  @override
  String get learnMateTitle => 'Checkmate';

  @override
  String get learnMateIntro =>
      'When the king cannot escape, it\'s checkmate. Game over!';

  @override
  String get learnMateTask => 'Give checkmate in one move!';

  @override
  String get learnMateHint =>
      'That was not checkmate. The king can still escape.';

  @override
  String get learnStalemateTitle => 'Stalemate';

  @override
  String get learnStalemateIntro =>
      'When the king is not in check but has no move, it\'s stalemate. A draw!';

  @override
  String get learnStalemateDemo =>
      'Look: the black king has no move. Stalemate, a draw!';

  @override
  String get learnStalemateTask => 'Now you: give checkmate, not stalemate!';

  @override
  String get learnStalemateHint =>
      'Oops, that\'s stalemate. A draw! Try another move.';

  @override
  String get learnCastlingTitle => 'Castling';

  @override
  String get learnCastlingIntro =>
      'The king and rook can hide together. That\'s castling.';

  @override
  String get learnCastlingDemo =>
      'The king moves two squares and the rook jumps beside him.';

  @override
  String get learnCastlingTask =>
      'Castle: tap the king, then the square two away.';

  @override
  String get learnCastlingHint =>
      'That\'s not castling. The king must move two squares.';

  @override
  String get learnEnPassantTitle => 'En passant';

  @override
  String get learnEnPassantIntro =>
      'A pawn that jumped two squares can be captured in passing.';

  @override
  String get learnEnPassantDemo =>
      'The black pawn jumped two squares next to the white one.';

  @override
  String get learnEnPassantTask => 'Capture it in passing, diagonally!';

  @override
  String get learnEnPassantHint =>
      'Capture diagonally, where the pawn would have stopped after one step.';

  @override
  String get learnPromotionTitle => 'Promotion';

  @override
  String get learnPromotionIntro =>
      'A pawn that reaches the end turns into another piece!';

  @override
  String get learnPromotionTask => 'Take the pawn to the end and pick a piece.';

  @override
  String get learnPromotionKnight => 'Now turn the pawn into a knight!';

  @override
  String get learnValuesTitle => 'Values';

  @override
  String get learnValuesIntro =>
      'Every piece is worth something. The queen the most!';

  @override
  String get learnValuesTask => 'Which piece is worth more? Tap it.';

  @override
  String get learnValuesHint => 'No, the other one is worth more.';

  @override
  String get gamesTitle => 'Mini-games';

  @override
  String get gamesCommonBoards => 'Levels';

  @override
  String get gamesCommonHint => 'Try this!';

  @override
  String get gamesCommonUndo => 'Undo';

  @override
  String get gamesCommonAgain => 'Again';

  @override
  String get gamesCommonNext => 'Next level';

  @override
  String get gamesCommonBack => 'Back';

  @override
  String get gamesCommonWon => 'You won! Well done!';

  @override
  String get gamesCommonLost => 'Not this time. Try again!';

  @override
  String get gamesCommonLimit => 'Out of moves. One more time!';

  @override
  String get gamesCommonYourMove => 'Your move!';

  @override
  String get gamesCommonOpponentMoves => 'My turn.';

  @override
  String get gamesCommonBadgeHunter => 'Hunter badge! Ten wins!';

  @override
  String get gamesCommonBadgeCollector => 'Fifty stars! Collector!';

  @override
  String get gamesPawnWarTitle => 'Pawn War';

  @override
  String get gamesPawnWarIntro =>
      'Your pawns against mine. Reach the far side or capture all of mine!';

  @override
  String get gamesPawnWarWonReached =>
      'You win! Your pawn reached the end. Well done!';

  @override
  String get gamesPawnWarWonBlocked =>
      'You win! The black pawns cannot move, and whoever has no move loses. Well done!';

  @override
  String get gamesPawnWarLostReached =>
      'A black pawn reached the end first. Try again!';

  @override
  String get gamesPawnWarLostBlocked =>
      'Your pawns are blocked and you have no move. Whoever cannot move loses. Try again!';

  @override
  String get gamesPawnWarHint =>
      'A pawn that reaches the end wins. Capture diagonally!';

  @override
  String get gamesRookRoadsTitle => 'Rook Roads';

  @override
  String get gamesRookRoadsIntro =>
      'Collect every star with the rook. As few moves as you can!';

  @override
  String get gamesRookRoadsHint =>
      'The rook goes straight. Go around your own pawns.';

  @override
  String get gamesBishopTracksTitle => 'Bishop Tracks';

  @override
  String get gamesBishopTracksIntro =>
      'Collect the stars with the bishop. It stays on its color!';

  @override
  String get gamesBishopTracksHint => 'The bishop moves only diagonally.';

  @override
  String get gamesKingRaceTitle => 'King Race';

  @override
  String get gamesKingRaceIntro =>
      'Walk the king to the other side. The red squares are dangerous!';

  @override
  String get gamesKingRaceHint => 'Step by step. Avoid the red squares.';

  @override
  String get gamesHuntTitle => 'The Hunt';

  @override
  String get gamesHuntIntro =>
      'Catch the fleeing piece before you run out of moves!';

  @override
  String get gamesHuntHint => 'Chase it! Capture when it is in reach.';

  @override
  String gamesCommonLocked(String lesson) {
    return 'First the lesson: $lesson. Come, I\'ll show you!';
  }

  @override
  String get matchTitle => 'Match';

  @override
  String get matchIntro => 'You play white. Your move!';

  @override
  String get matchIntroBlack => 'You play black. The computer starts.';

  @override
  String get matchThinking => 'Thinking…';

  @override
  String get matchCheckByYou => 'Check! The king must run!';

  @override
  String get matchHint => 'Try this!';

  @override
  String get matchResign => 'Resign';

  @override
  String get matchResignQuestion => 'Give up the game?';

  @override
  String get matchYes => 'Yes';

  @override
  String get matchNo => 'No';

  @override
  String get matchWon => 'Checkmate! You win! Well done!';

  @override
  String get matchLost => 'Checkmate. The computer won this time. Try again!';

  @override
  String get matchResigned => 'You gave up. Next time!';

  @override
  String get matchAgain => 'Play again';

  @override
  String get matchBack => 'Back';

  @override
  String get matchBadgeFirstMatch => 'Badge: first match!';

  @override
  String get matchBadgeFirstWin => 'Badge: first win!';

  @override
  String get matchBadgePersistent => 'Badge: persistent player!';

  @override
  String get badgesAll => 'All badges';

  @override
  String get badgesYours =>
      'Your badges. Tap one and I will tell you what it is for!';

  @override
  String get badgePawnName => 'Pawn';

  @override
  String get badgePawnDesc => 'For the pawn lesson.';

  @override
  String get badgeRookName => 'Rook';

  @override
  String get badgeRookDesc => 'For the rook lesson.';

  @override
  String get badgeBishopName => 'Bishop';

  @override
  String get badgeBishopDesc => 'For the bishop lesson.';

  @override
  String get badgeQueenName => 'Queen';

  @override
  String get badgeQueenDesc => 'For the queen lesson.';

  @override
  String get badgeKingName => 'King';

  @override
  String get badgeKingDesc => 'For the king lesson.';

  @override
  String get badgeKnightName => 'Knight';

  @override
  String get badgeKnightDesc => 'For the knight lesson.';

  @override
  String get badgeChessPlayerName => 'Chess player';

  @override
  String get badgeChessPlayerDesc => 'For every lesson about the rules.';

  @override
  String get badgeFirstMatchName => 'First match';

  @override
  String get badgeFirstMatchDesc => 'For the first finished match.';

  @override
  String get badgeFirstWinName => 'First win';

  @override
  String get badgeFirstWinDesc => 'For the first match you won.';

  @override
  String get badgePersistentName => 'Persistent';

  @override
  String get badgePersistentDesc => 'For ten finished matches.';

  @override
  String get badgeHunterName => 'Hunter';

  @override
  String get badgeHunterDesc => 'For ten mini-games won.';

  @override
  String get badgeCollectorName => 'Collector';

  @override
  String get badgeCollectorDesc => 'For fifty stars.';

  @override
  String get computerLevel => 'Computer level in matches';

  @override
  String get levelVeryEasy => 'Very easy';

  @override
  String get levelEasy => 'Easy';

  @override
  String get levelNormal => 'Normal';

  @override
  String get learnPawnPromotionNote =>
      'The pawn reached the end and became a queen. You will learn that in the promotion lesson!';
}
