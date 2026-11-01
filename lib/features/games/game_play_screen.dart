import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../core/speaker.dart';
import '../../data/models.dart';
import '../../engine/engine.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../widgets/teacher_bubble.dart';
import '../board/board_highlights.dart';
import '../board/interactive_board.dart';
import 'game_model.dart';
import 'game_result_view.dart';
import 'game_strings.dart';
import 'mini_game_session.dart';
import 'widgets/game_layout.dart';
import 'widgets/progress_bar.dart';

/// One board of a mini-game being played.
class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({
    super.key,
    required this.game,
    required this.board,
    this.opponentDelay = const Duration(milliseconds: 600),
    this.random,
  });

  final MiniGame game;
  final GameBoard board;
  final Duration opponentDelay;
  final Random? random;

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  static const Duration _hintDuration = Duration(seconds: 2);

  late final MiniGameSession _session = MiniGameSession(
    widget.game,
    widget.board,
    random: widget.random,
  );
  Move? _hint;
  Timer? _hintTimer;
  Timer? _opponentTimer;
  late final String _openingKey;

  @override
  void initState() {
    super.initState();
    _session.addListener(_onSession);
    final state = context.read<AppState>();
    final introduced =
        state.currentProfile?.introducedGames.contains(widget.game.id) ?? true;
    _openingKey = introduced ? 'games.common.yourMove' : widget.game.introKey;
    if (!introduced) {
      // Writing the profile notifies listeners; not during the first build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          state.markGameIntroduced(widget.game.id);
        }
      });
    }
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _opponentTimer?.cancel();
    _session.removeListener(_onSession);
    _session.dispose();
    super.dispose();
  }

  void _onSession() {
    if (mounted) {
      setState(() {});
    }
  }

  void _say(String key) {
    final l10n = AppLocalizations.of(context);
    context.read<Speaker>().say(
      gameLine(l10n, key),
      key: key,
      interrupt: false,
    );
  }

  void _onMove(Move move) {
    final event = _session.playChild(move);
    _clearHint();
    if (event == SessionEvent.limitReset) {
      _say('games.common.limit');
    }
    if (_session.awaitingOpponent) {
      _opponentTimer?.cancel();
      _opponentTimer = Timer(widget.opponentDelay, () {
        if (mounted) {
          _session.playOpponent();
        }
      });
    }
  }

  void _onRejected(Square square) {
    _session.onRejected();
    _say(widget.game.hintKey);
  }

  void _showHint() {
    final hint = _session.hint();
    if (hint == null) {
      return;
    }
    setState(() => _hint = hint);
    _say('games.common.hint');
    _hintTimer?.cancel();
    _hintTimer = Timer(_hintDuration, _clearHint);
  }

  void _clearHint() {
    _hintTimer?.cancel();
    if (_hint != null && mounted) {
      setState(() => _hint = null);
    }
  }

  void _undo() {
    _clearHint();
    _session.undo();
  }

  void _again() {
    _clearHint();
    _opponentTimer?.cancel();
    _session.restart();
  }

  void _next(GameBoard board) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => GamePlayScreen(
          game: widget.game,
          board: board,
          opponentDelay: widget.opponentDelay,
          random: widget.random,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppTheme.of(context).ui;
    final profile = context.watch<AppState>().currentProfile;
    final session = _session;
    final playing = session.outcome == SessionOutcome.playing;
    final hint = _hint;
    return Scaffold(
      appBar: AppBar(
        title: Text(gameLine(l10n, widget.game.titleKey)),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: playing
              ? _buildPlay(context, l10n, palette, profile, session, hint)
              : GameResultView(
                  key: ValueKey(session.position),
                  game: widget.game,
                  board: widget.board,
                  session: session,
                  onAgain: _again,
                  onNext: _next,
                  onBack: () => Navigator.of(context).pop(),
                ),
        ),
      ),
    );
  }

  Widget _buildPlay(
    BuildContext context,
    AppLocalizations l10n,
    UiPalette palette,
    Profile? profile,
    MiniGameSession session,
    Move? hint,
  ) {
    return GameLayout(
      bubble: TeacherBubble(
        theme: profile?.theme ?? TeacherTheme.animals,
        avatarIndex: 3,
        text: gameLine(l10n, _openingKey),
        speechKey: _openingKey,
      ),
      slot: ProgressBar(
        key: const Key('game-progress'),
        value: session.progress,
      ),
      board: InteractiveBoard(
        position: session.position,
        onMove: _onMove,
        rules: widget.board.rules,
        movableColor: MiniGameSession.childColor,
        moveFilter: session.allows,
        onRejected: _onRejected,
        lastMove: session.lastMove,
        enabled: !session.awaitingOpponent,
        extraHighlights: BoardHighlights(
          stars: session.starsLeft,
          danger: session.danger,
          selected: hint?.from,
          moveTargets: hint == null ? const {} : {hint.to},
        ),
      ),
      controls: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              key: const Key('game-undo'),
              onPressed: session.canUndo ? _undo : null,
              icon: const Icon(Icons.undo_rounded),
              label: Text(gameLine(l10n, 'games.common.undo')),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(GameLayout.controlsHeight),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              key: const Key('game-hint'),
              onPressed: session.awaitingOpponent ? null : _showHint,
              icon: const Icon(Icons.lightbulb_rounded),
              label: Text(gameLine(l10n, 'games.common.hint')),
              style: FilledButton.styleFrom(
                backgroundColor: palette.accent,
                minimumSize: const Size.fromHeight(GameLayout.controlsHeight),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
