import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/speaker.dart';
import '../../../engine/engine.dart';
import '../../../l10n/app_localizations.dart';
import '../../board/board_highlights.dart';
import '../../board/interactive_board.dart';
import '../board_task_controller.dart';
import '../lesson_model.dart';
import '../lesson_strings.dart';

/// "Try": an interactive board driven by a [BoardTaskController].
class BoardTaskView extends StatefulWidget {
  const BoardTaskView({
    super.key,
    required this.step,
    required this.onDone,
    required this.onMistake,
    this.onEvent,
  });

  final BoardTaskStep step;
  final VoidCallback onDone;

  /// Called once per mistake (wasted move, rejected tap, reset).
  final VoidCallback onMistake;
  final ValueChanged<TaskEvent>? onEvent;

  @override
  State<BoardTaskView> createState() => _BoardTaskViewState();
}

class _BoardTaskViewState extends State<BoardTaskView> {
  late final BoardTaskController _controller = BoardTaskController(widget.step);
  int _reportedMistakes = 0;
  Square? _shake;
  Timer? _resetTimer;

  /// How long a wrong one-move answer stays on the board before it is
  /// taken back.
  static const Duration _failPause = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
    while (_reportedMistakes < _controller.mistakes) {
      _reportedMistakes++;
      widget.onMistake();
    }
  }

  /// Hints never cut the teacher's current line short.
  void _say(String key) {
    final l10n = AppLocalizations.of(context);
    context.read<Speaker>().say(
      learnLine(l10n, key),
      key: key,
      interrupt: false,
    );
  }

  String get _hintKey => widget.step.hintKey ?? 'learn.common.tryAgain';

  void _onMove(Move move) {
    final wasComplete = _controller.isComplete;
    final event = _controller.onMove(move);
    if (move.promotion != null && widget.step.promotionNoteKey != null) {
      _say(widget.step.promotionNoteKey!);
      return;
    }
    if (wasComplete) {
      return;
    }
    widget.onEvent?.call(event);
    switch (event) {
      case TaskEvent.good:
        break;
      case TaskEvent.wasted:
        setState(() => _shake = move.to);
        _say(_hintKey);
      case TaskEvent.fail:
        _say(_hintKey);
        _resetTimer?.cancel();
        _resetTimer = Timer(_failPause, () {
          if (mounted) {
            _controller.reset();
          }
        });
      case TaskEvent.reset:
        setState(() => _shake = null);
        _say('learn.common.tryAgain');
      case TaskEvent.complete:
        widget.onDone();
    }
  }

  void _onRejected(Square square) {
    if (_controller.isComplete) {
      return;
    }
    _controller.onRejected();
    setState(() => _shake = square);
    _say(_hintKey);
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final step = widget.step;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: InteractiveBoard(
              position: state.position,
              onMove: _onMove,
              rules: step.rules,
              orientation: step.orientation,
              movableColor: _controller.childColor,
              enabled: !_controller.isAwaitingReset,
              lastMove: state.lastMove,
              moveFilter: _controller.allows,
              showFilteredMoves: true,
              onRejected: _onRejected,
              shakeSquare: _shake,
              extraHighlights: BoardHighlights(
                stars: _controller.starsLeft,
                danger: _controller.danger,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (step.moveLimit case final limit?)
          _MovesLeft(left: limit - state.movesMade, total: limit)
        else if (step.stars.isNotEmpty)
          _StarsLeft(
            left: _controller.starsLeft.length,
            total: step.stars.length,
          ),
      ],
    );
  }
}

class _MovesLeft extends StatelessWidget {
  const _MovesLeft({required this.left, required this.total});

  final int left;
  final int total;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Row(
      key: const Key('moves-left'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              key: i < left ? Key('move-left-dot-$i') : null,
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < left
                    ? palette.accentDeep
                    : palette.muted.withValues(alpha: 0.3),
              ),
            ),
          ),
      ],
    );
  }
}

class _StarsLeft extends StatelessWidget {
  const _StarsLeft({required this.left, required this.total});

  final int left;
  final int total;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Row(
      key: const Key('stars-left'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          Icon(
            i < total - left ? Icons.star_rounded : Icons.star_outline_rounded,
            color: palette.accentDeep,
            size: 24,
          ),
      ],
    );
  }
}
