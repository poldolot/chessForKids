import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../app/constants.dart';
import '../../app/theme/app_theme.dart';

/// A small padlock a parent holds for [kParentLockDuration] to open the
/// parent zone. A short tap does nothing; a ring shows the hold progress.
class ParentLockButton extends StatefulWidget {
  const ParentLockButton({
    super.key,
    required this.onUnlocked,
    this.size = kMinTouchTarget,
  });

  final VoidCallback onUnlocked;
  final double size;

  @override
  State<ParentLockButton> createState() => _ParentLockButtonState();
}

class _ParentLockButtonState extends State<ParentLockButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: kParentLockDuration,
  );

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _start() => _progress.forward(from: 0);

  void _cancel() =>
      _progress.animateBack(0, duration: const Duration(milliseconds: 200));

  void _unlock() {
    _progress.value = 0;
    widget.onUnlocked();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return RawGestureDetector(
      gestures: {
        LongPressGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(duration: kParentLockDuration),
              (recognizer) {
                recognizer.onLongPressDown = (_) => _start();
                recognizer.onLongPressCancel = _cancel;
                recognizer.onLongPress = _unlock;
              },
            ),
      },
      child: Semantics(
        button: true,
        label: 'parent zone',
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _progress,
            builder: (context, _) => CustomPaint(
              painter: _RingPainter(
                progress: _progress.value,
                color: palette.accentDeep,
                track: palette.muted,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: palette.muted,
                size: widget.size * 0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = rect.deflate(4);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      inset,
      0,
      6.2832,
      false,
      paint..color = track.withValues(alpha: 0.35),
    );
    if (progress > 0) {
      canvas.drawArc(
        inset,
        -1.5708,
        6.2832 * progress,
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
