import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/speaker.dart';
import '../../../engine/engine.dart';
import '../../../l10n/app_localizations.dart';
import '../../board/piece_image.dart';
import '../lesson_model.dart';
import '../lesson_strings.dart';

/// "Which is worth more?": two cards, tap the more valuable piece.
class CompareStepView extends StatefulWidget {
  const CompareStepView({
    super.key,
    required this.step,
    required this.onDone,
    required this.onMistake,
  });

  final CompareStep step;
  final VoidCallback onDone;
  final VoidCallback onMistake;

  @override
  State<CompareStepView> createState() => _CompareStepViewState();
}

class _CompareStepViewState extends State<CompareStepView> {
  static const Duration _celebrate = Duration(milliseconds: 600);

  int _index = 0;
  String? _correctKey;
  String? _shakeKey;
  int _shakeToken = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  (Piece, Piece) get _pair => widget.step.pairs[_index];

  void _pick(String key, Piece chosen, Piece other) {
    if (_correctKey != null) {
      return;
    }
    if (chosen.type.value > other.type.value) {
      setState(() => _correctKey = key);
      _timer = Timer(_celebrate, _advance);
    } else {
      widget.onMistake();
      setState(() {
        _shakeKey = key;
        _shakeToken++;
      });
      final l10n = AppLocalizations.of(context);
      context.read<Speaker>().say(
        learnLine(l10n, 'learn.values.hint'),
        key: 'learn.values.hint',
        interrupt: false,
      );
    }
  }

  void _advance() {
    if (!mounted) {
      return;
    }
    if (_index + 1 >= widget.step.pairs.length) {
      widget.onDone();
      return;
    }
    setState(() {
      _index++;
      _correctKey = null;
      _shakeKey = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    final (a, b) = _pair;
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _card('compare-a', a, b, palette)),
              const SizedBox(width: 16),
              Expanded(child: _card('compare-b', b, a, palette)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.step.pairs.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  key: i < _index ? Key('compare-progress-$i') : null,
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _index
                        ? palette.games
                        : palette.muted.withValues(alpha: 0.3),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _card(String key, Piece piece, Piece other, UiPalette palette) {
    final correct = _correctKey == key;
    Widget card = Material(
      key: Key(key),
      color: correct ? palette.games : palette.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _pick(key, piece, other),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kMinTouchTarget),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PieceImage(piece, size: 96),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    for (var i = 0; i < piece.type.value; i++)
                      Icon(
                        Icons.star_rounded,
                        size: 20,
                        color: palette.accentDeep,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (_shakeKey == key) {
      card = TweenAnimationBuilder<double>(
        key: ValueKey('card-shake-$key-$_shakeToken'),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        builder: (context, t, child) => Transform.translate(
          offset: Offset(math.sin(t * math.pi * 4) * (1 - t) * 12, 0),
          child: child,
        ),
        child: card,
      );
    }
    return card;
  }
}
