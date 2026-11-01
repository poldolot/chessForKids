import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../board/piece_image.dart';
import '../lesson_model.dart';

/// "Meet the piece": a big picture that breathes a few times.
class IntroStepView extends StatefulWidget {
  const IntroStepView({super.key, required this.step});

  final IntroStep step;

  @override
  State<IntroStepView> createState() => _IntroStepViewState();
}

class _IntroStepViewState extends State<IntroStepView>
    with SingleTickerProviderStateMixin {
  static const int _breaths = 4;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1,
    end: 1.06,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  int _cycles = 0;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (!MediaQuery.disableAnimationsOf(context)) {
      _controller.addStatusListener(_onStatus);
      _controller.forward();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controller.reverse();
    } else if (status == AnimationStatus.dismissed) {
      _cycles++;
      if (_cycles < _breaths) {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    final step = widget.step;
    final Widget picture = step.piece != null
        ? PieceImage(step.piece!, size: 160)
        : Icon(
            step.icon ?? Icons.school_rounded,
            size: 140,
            color: palette.accentDeep,
          );
    final card = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: picture,
    );
    if (MediaQuery.disableAnimationsOf(context)) {
      return Center(child: card);
    }
    return Center(
      child: ScaleTransition(
        key: const Key('breathe'),
        scale: _scale,
        child: card,
      ),
    );
  }
}
