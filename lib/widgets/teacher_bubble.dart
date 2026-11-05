import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/route_observer.dart';
import '../app/theme/app_theme.dart';
import '../core/speaker.dart';
import '../data/models.dart';
import '../features/profiles/avatar_image.dart';
import 'speak_button.dart';

/// A teacher avatar with a speech bubble. The text is spoken when the bubble
/// appears and whenever it changes; the speaker button repeats it.
class TeacherBubble extends StatefulWidget {
  const TeacherBubble({
    super.key,
    required this.theme,
    required this.avatarIndex,
    required this.text,
    required this.speechKey,
    this.speakOnShow = true,
    this.showSpeakButton = true,
    this.avatarSize = 64,
    this.interrupt = true,
    this.leading,
  });

  final TeacherTheme theme;
  final int avatarIndex;
  final String text;
  final String speechKey;
  final bool speakOnShow;
  final bool showSpeakButton;
  final double avatarSize;

  /// Whether the line cuts off whatever is being spoken; `false` queues it
  /// behind the current main line instead.
  final bool interrupt;

  /// Shown instead of the teacher avatar (the profile picker shows a queen,
  /// as no child is chosen yet).
  final Widget? leading;

  @override
  State<TeacherBubble> createState() => _TeacherBubbleState();
}

class _TeacherBubbleState extends State<TeacherBubble> with RouteAware {
  /// A line that arrived while another screen covered this one; spoken
  /// when the child comes back.
  bool _pending = false;
  ModalRoute<void>? _route;

  @override
  void initState() {
    super.initState();
    if (widget.speakOnShow) {
      _speak();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != _route) {
      if (_route != null) {
        appRouteObserver.unsubscribe(this);
      }
      _route = route;
      if (route != null) {
        appRouteObserver.subscribe(this, route);
      }
    }
  }

  @override
  void didUpdateWidget(TeacherBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.speakOnShow && widget.text != oldWidget.text) {
      _speak();
    }
  }

  @override
  void didPopNext() {
    if (_pending) {
      _pending = false;
      _speak();
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  void _speak() {
    final speaker = context.read<Speaker>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) {
        _pending = true;
        return;
      }
      speaker.say(
        widget.text,
        key: widget.speechKey,
        interrupt: widget.interrupt,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widget.leading ??
            AvatarImage(
              widget.theme,
              widget.avatarIndex,
              size: widget.avatarSize,
            ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                color: palette.text,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ),
        ),
        if (widget.showSpeakButton) ...[
          const SizedBox(width: 10),
          const SpeakButton(),
        ],
      ],
    );
  }
}
