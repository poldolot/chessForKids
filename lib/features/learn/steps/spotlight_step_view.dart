import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/speaker.dart';
import '../../../engine/engine.dart';
import '../../../l10n/app_localizations.dart';
import '../../board/board_highlights.dart';
import '../../board/interactive_board.dart';
import '../lesson_model.dart';
import '../lesson_strings.dart';
import 'speech_pause.dart';

/// "Look here": the parts of a still position light up in turn, each
/// introduced by its own line, after the step's own line has been said.
class SpotlightStepView extends StatefulWidget {
  const SpotlightStepView({
    super.key,
    required this.step,
    required this.onDone,
  });

  final SpotlightStep step;
  final VoidCallback onDone;

  /// Quiet time before the first part lights up.
  static const Duration firstDelay = Duration(milliseconds: 600);

  /// Quiet time between one part's line ending and the next part.
  static const Duration partDelay = Duration(milliseconds: 900);

  @override
  State<SpotlightStepView> createState() => _SpotlightStepViewState();
}

class _SpotlightStepViewState extends State<SpotlightStepView> {
  late final Position _position = Position.fromFen(widget.step.fen);

  /// Index of the lit part; -1 before the first one.
  int _lit = -1;
  late final SpeechPause _pause = SpeechPause(context.read<Speaker>());

  @override
  void initState() {
    super.initState();
    _pause.schedule(SpotlightStepView.firstDelay, _tick);
  }

  @override
  void dispose() {
    _pause.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) {
      return;
    }
    final next = _lit + 1;
    if (next >= widget.step.parts.length) {
      widget.onDone();
      return;
    }
    setState(() => _lit = next);
    final lineKey = widget.step.parts[next].$2;
    final l10n = AppLocalizations.of(context);
    context.read<Speaker>().say(learnLine(l10n, lineKey), key: lineKey);
    _pause.schedule(SpotlightStepView.partDelay, _tick);
  }

  void _replay() {
    setState(() => _lit = -1);
    _pause.schedule(SpotlightStepView.firstDelay, _tick);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    final lit = _lit < 0 ? const <Square>{} : widget.step.parts[_lit].$1;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: InteractiveBoard(
              position: _position,
              onMove: (_) {},
              enabled: false,
              orientation: widget.step.orientation,
              extraHighlights: BoardHighlights(spotlight: lit),
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
