import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

/// Progress dots: done steps green, the current one orange, the rest grey.
class StepDots extends StatelessWidget {
  const StepDots({super.key, required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              key: Key('dot-$i'),
              duration: const Duration(milliseconds: 200),
              width: i == current ? 16 : 12,
              height: i == current ? 16 : 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < current
                    ? palette.games
                    : i == current
                    ? palette.accentDeep
                    : palette.muted.withValues(alpha: 0.3),
              ),
            ),
          ),
      ],
    );
  }
}
