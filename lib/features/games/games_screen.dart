import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/speaker.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/teacher_bubble.dart';
import '../learn/lesson_screen.dart';
import '../learn/lesson_strings.dart';
import '../learn/lessons/catalog.dart';
import '../profiles/profile_picker_screen.dart';
import 'game_levels_screen.dart';
import 'game_model.dart';
import 'game_play_screen.dart';
import 'game_progress.dart';
import 'game_strings.dart';
import 'widgets/game_card.dart';

/// Says that a game or board is locked and takes the child to the lesson
/// that opens it.
void openLockedLesson(BuildContext context, String lessonId) {
  final l10n = AppLocalizations.of(context);
  final lesson = lessonById(lessonId);
  // A new situation: this line interrupts, and the lesson's first line
  // queues behind it so the child hears why the screen changed.
  context.read<Speaker>().say(
    gameLine(
      l10n,
      'games.common.locked',
      lesson: learnLine(l10n, lesson.titleKey),
    ),
    key: 'games.common.locked',
  );
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => LessonScreen(lesson: lesson, queueFirstLine: true),
    ),
  );
}

/// Where a game starts: straight into play for a single level, otherwise
/// the level list.
Widget gameEntryScreen(MiniGame game) => game.levels.length == 1
    ? GamePlayScreen(game: game, level: game.levels.first)
    : GameLevelsScreen(game: game);

/// The list of mini-games.
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  void _open(BuildContext context, MiniGame game, bool unlocked) {
    if (!unlocked) {
      openLockedLesson(context, game.unlockedByLesson);
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => gameEntryScreen(game)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = context.watch<AppState>().currentProfile;
    final games = context.watch<List<MiniGame>>();
    if (profile == null) {
      return const ProfilePickerScreen();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(gameLine(l10n, 'games.title')),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            TeacherBubble(
              theme: profile.theme,
              avatarIndex: 3,
              text: gameLine(l10n, 'games.title'),
              speechKey: 'games.title',
            ),
            const SizedBox(height: 16),
            for (final game in games) ...[
              GameCard(
                key: Key('game-${game.id}'),
                game: game,
                title: gameLine(l10n, game.titleKey),
                unlocked: isGameUnlocked(game, profile),
                earnedStars: gameEarnedStars(game, profile),
                maxStars: game.levels.length * 3,
                onTap: () =>
                    _open(context, game, isGameUnlocked(game, profile)),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
