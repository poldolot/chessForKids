import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/speaker.dart';
import '../../../engine/engine.dart';
import '../../../l10n/app_localizations.dart';
import '../../board/interactive_board.dart';
import '../lesson_model.dart';
import '../lesson_strings.dart';

/// "Watch": the board plays the step's moves by itself.
class DemoStepView extends StatefulWidget {
  const DemoStepView({
    super.key,
    required this.step,
    required this.onDone,
    this.stepDelay = const Duration(milliseconds: 1200),
  });

  final DemoStep step;
  final VoidCallback onDone;
  final Duration stepDelay;

  @override
  State<DemoStepView> createState() => _DemoStepViewState();
}

class _DemoStepViewState extends State<DemoStepView> {
  static const Duration _firstDelay = Duration(milliseconds: 600);

  late Position _position = Position.fromFen(widget.step.fen);
  Move? _lastMove;
  int _played = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _schedule(_firstDelay);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _schedule(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, _tick);
  }

  void _tick() {
    if (!mounted) {
      return;
    }
    if (_played >= widget.step.moves.length) {
      widget.onDone();
      return;
    }
    final (move, lineKey) = widget.step.moves[_played];
    setState(() {
      _position = _position.play(move);
      _lastMove = move;
      _played++;
    });
    if (lineKey != null) {
      final l10n = AppLocalizations.of(context);
      context.read<Speaker>().say(learnLine(l10n, lineKey), key: lineKey);
    }
    _schedule(widget.stepDelay);
  }

  void _replay() {
    setState(() {
      _position = Position.fromFen(widget.step.fen);
      _lastMove = null;
      _played = 0;
    });
    _schedule(_firstDelay);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: InteractiveBoard(
              position: _position,
              onMove: (_) {},
              enabled: false,
              rules: widget.step.rules,
              orientation: widget.step.orientation,
              lastMove: _lastMove,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: kMinTouchTarget,
          child: IconButton(
            key: const Key('demo-replay'),
            onPressed: _replay,
            iconSize: 32,
            color: palette.accentDeep,
            icon: const Icon(Icons.replay_rounded),
          ),
        ),
      ],
    );
  }
}
