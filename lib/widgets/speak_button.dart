import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/constants.dart';
import '../app/theme/app_theme.dart';
import '../core/speaker.dart';

/// Round yellow button that repeats the last spoken line.
class SpeakButton extends StatelessWidget {
  const SpeakButton({super.key, this.size = kMinTouchTarget});

  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: palette.accent,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => context.read<Speaker>().repeat(),
          child: Icon(
            Icons.volume_up_rounded,
            color: palette.text,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
