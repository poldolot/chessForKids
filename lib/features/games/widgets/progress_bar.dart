import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

/// A rounded bar filling from left to right, animated between values.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value});

  /// 0..1
  final double value;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 16,
        color: palette.surface,
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: value.clamp(0, 1)),
            duration: const Duration(milliseconds: 200),
            builder: (context, v, _) => FractionallySizedBox(
              widthFactor: v,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [palette.accent, palette.accentDeep],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
