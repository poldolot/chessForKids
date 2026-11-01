import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

/// Three dots pulsing one after another while the computer "thinks".
class ThinkingDots extends StatefulWidget {
  const ThinkingDots({super.key});

  @override
  State<ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<ThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Opacity(
                opacity: reduceMotion
                    ? 1
                    : 0.35 +
                          0.65 *
                              (0.5 +
                                  0.5 *
                                      _wave((_controller.value - i / 3) % 1.0)),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: palette.accentDeep,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// A smooth bump: 1 at t = 0, down to -1 at t = 0.5 and back.
  static double _wave(double t) => t < 0.5 ? 1 - 4 * t : -3 + 4 * t;
}
