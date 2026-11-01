import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../data/models.dart';
import '../../engine/engine.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/teacher_bubble.dart';
import '../board/interactive_board.dart';

/// Temporary two-player board behind the Play tile, used to try the board
/// widget on a device. Replaced by the real match screen in plan 5.
class SandboxScreen extends StatefulWidget {
  const SandboxScreen({super.key});

  @override
  State<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends State<SandboxScreen> {
  Game _game = Game();

  void _play(Move move) => setState(() => _game.play(move));

  void _undo() => setState(() => _game.undo());

  void _reset() => setState(() => _game = Game());

  String _status(AppLocalizations l10n) {
    final result = _game.result;
    return switch (result.outcome) {
      GameOutcome.checkmate =>
        result.winner == PieceColor.white
            ? l10n.checkmateWhite
            : l10n.checkmateBlack,
      GameOutcome.stalemate => l10n.stalemate,
      GameOutcome.insufficientMaterial ||
      GameOutcome.threefoldRepetition ||
      GameOutcome.fiftyMoveRule ||
      GameOutcome.resignation => l10n.draw,
      GameOutcome.ongoing => _game.isCheck ? l10n.check : l10n.yourMove,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppTheme.of(context).ui;
    final profile = context.watch<AppState>().currentProfile;
    final status = _status(l10n);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sandboxTitle),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TeacherBubble(
                theme: profile?.theme ?? TeacherTheme.animals,
                avatarIndex: 4,
                text: status,
                speechKey: 'sandbox.status',
                speakOnShow: status != l10n.yourMove,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: InteractiveBoard(
                    position: _game.position,
                    onMove: _play,
                    lastMove: _game.moves.isEmpty ? null : _game.moves.last,
                    enabled: !_game.result.isOver,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('sandbox-undo'),
                      onPressed: _game.moves.isEmpty ? null : _undo,
                      icon: const Icon(Icons.undo_rounded),
                      label: Text(l10n.undo),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('sandbox-new'),
                      onPressed: _reset,
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.games,
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.newGame),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
