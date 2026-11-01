import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/teacher_bubble.dart';
import '../menu/menu_tile.dart';
import '../profiles/profile_picker_screen.dart';
import 'game_model.dart';
import 'game_play_screen.dart';
import 'game_progress.dart';
import 'game_strings.dart';
import 'games_screen.dart';

/// The boards of one game, with stars and locks.
class GameBoardsScreen extends StatelessWidget {
  const GameBoardsScreen({super.key, required this.game});

  final MiniGame game;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppTheme.of(context).ui;
    final profile = context.watch<AppState>().currentProfile;
    if (profile == null) {
      return const ProfilePickerScreen();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(gameLine(l10n, game.titleKey)),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: TeacherBubble(
                theme: profile.theme,
                avatarIndex: 3,
                text: gameLine(l10n, 'games.common.boards'),
                speechKey: 'games.common.boards',
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final board in game.boards)
                      SizedBox(
                        width: 150,
                        height: 120,
                        child: _BoardTile(
                          game: game,
                          board: board,
                          unlocked: isBoardUnlocked(game, board, profile),
                          stars: profile.stars[gameStarsKey(game, board)] ?? 0,
                          palette: palette,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardTile extends StatelessWidget {
  const _BoardTile({
    required this.game,
    required this.board,
    required this.unlocked,
    required this.stars,
    required this.palette,
  });

  final MiniGame game;
  final GameBoard board;
  final bool unlocked;
  final int stars;
  final UiPalette palette;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: Key('board-${board.index}'),
      color: unlocked ? palette.surface : palette.muted.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          if (!unlocked) {
            openLockedLesson(
              context,
              board.unlockedByLesson ?? game.unlockedByLesson,
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => GamePlayScreen(game: game, board: board),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The board number as dots, nothing to read.
            Wrap(
              spacing: 4,
              children: [
                for (var i = 0; i <= board.index; i++)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unlocked ? palette.accentDeep : palette.muted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (unlocked)
              StarRow(stars: stars, size: 22)
            else
              Icon(
                Icons.lock_rounded,
                key: Key('board-${board.index}-locked'),
                color: palette.muted,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
