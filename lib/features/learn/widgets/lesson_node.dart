import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../board/piece_image.dart';
import '../../menu/menu_tile.dart';
import '../lesson_model.dart';

/// One stop on the lesson path: picture, lock, stars and a pulse on the
/// lesson the child should do next.
class LessonNode extends StatefulWidget {
  const LessonNode({
    super.key,
    required this.lesson,
    required this.unlocked,
    required this.stars,
    required this.isNext,
    required this.onTap,
  });

  final Lesson lesson;
  final bool unlocked;
  final int stars;
  final bool isNext;
  final VoidCallback onTap;

  @override
  State<LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<LessonNode> {
  int _shakeToken = 0;

  void _tap() {
    if (!widget.unlocked) {
      setState(() => _shakeToken++);
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    final lesson = widget.lesson;
    final Widget picture = lesson.piece != null
        ? PieceImage(lesson.piece!, size: 52)
        : Icon(lesson.icon, size: 44, color: palette.text);
    Widget circle = Material(
      color: widget.unlocked
          ? palette.surface
          : palette.muted.withValues(alpha: 0.15),
      shape: CircleBorder(
        side: BorderSide(
          color: widget.isNext ? palette.accentDeep : Colors.transparent,
          width: 4,
        ),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _tap,
        child: SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(opacity: widget.unlocked ? 1 : 0.35, child: picture),
              if (!widget.unlocked)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 22,
                      color: palette.muted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (!widget.unlocked && _shakeToken > 0) {
      circle = TweenAnimationBuilder<double>(
        key: ValueKey('node-shake-$_shakeToken'),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        builder: (context, t, child) => Transform.translate(
          offset: Offset(_wiggle(t) * 10, 0),
          child: child,
        ),
        child: circle,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        circle,
        const SizedBox(height: 4),
        StarRow(stars: widget.unlocked ? widget.stars : 0, size: 18),
      ],
    );
  }

  static double _wiggle(double t) {
    final phase = t * 4;
    final v = phase - phase.floor();
    final tri = v < 0.5 ? v * 4 - 1 : 3 - v * 4;
    return tri * (1 - t);
  }
}
