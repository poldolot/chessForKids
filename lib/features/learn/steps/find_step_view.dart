import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/constants.dart';
import '../../../core/speaker.dart';
import '../../../engine/engine.dart';
import '../../../l10n/app_localizations.dart';
import '../../board/board_highlights.dart';
import '../../board/board_view.dart';
import '../lesson_model.dart';
import '../lesson_strings.dart';
import 'speech_pause.dart';

/// "Find it": a still board; the child taps the asked squares in order.
class FindStepView extends StatefulWidget {
  const FindStepView({
    super.key,
    required this.step,
    required this.onDone,
    required this.onMistake,
  });

  final FindStep step;
  final VoidCallback onDone;
  final VoidCallback onMistake;

  /// Quiet time after the closing line before the step reports done, so
  /// Next does not light up while the teacher is still talking.
  static const Duration doneDelay = Duration(milliseconds: 300);

  @override
  State<FindStepView> createState() => _FindStepViewState();
}

class _FindStepViewState extends State<FindStepView> {
  late final Position _position = Position.fromFen(widget.step.fen);
  final Set<Square> _found = {};
  Square? _shake;
  late final SpeechPause _pause;

  bool get _done => _found.length >= widget.step.targets.length;

  @override
  void initState() {
    super.initState();
    _pause = SpeechPause(context.read<Speaker>());
  }

  @override
  void dispose() {
    _pause.cancel();
    super.dispose();
  }

  void _onTap(Square square) {
    if (_done) {
      return;
    }
    final (target, lineKey) = widget.step.targets[_found.length];
    final speaker = context.read<Speaker>();
    final l10n = AppLocalizations.of(context);
    if (square != target) {
      widget.onMistake();
      setState(() => _shake = square);
      speaker.say(
        learnLine(l10n, widget.step.hintKey),
        key: widget.step.hintKey,
        interrupt: false,
      );
      return;
    }
    setState(() {
      _found.add(square);
      _shake = null;
    });
    if (lineKey != null) {
      speaker.say(learnLine(l10n, lineKey), key: lineKey);
    }
    if (_done) {
      _pause.schedule(FindStepView.doneDelay, widget.onDone);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Same column as the demo steps, so the board sits where it did a
    // moment ago; the empty strip below is where the replay button was.
    return Column(
      children: [
        Expanded(
          child: Center(
            child: BoardView(
              position: _position,
              orientation: widget.step.orientation,
              highlights: BoardHighlights(spotlight: _found),
              shakeSquare: _shake,
              onSquareTap: _onTap,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: kMinTouchTarget),
      ],
    );
  }
}
