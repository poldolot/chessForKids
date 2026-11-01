import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  });

  final TeacherTheme theme;
  final int avatarIndex;
  final String text;
  final String speechKey;
  final bool speakOnShow;
  final bool showSpeakButton;
  final double avatarSize;

  @override
  State<TeacherBubble> createState() => _TeacherBubbleState();
}

class _TeacherBubbleState extends State<TeacherBubble> {
  @override
  void initState() {
    super.initState();
    if (widget.speakOnShow) {
      _speak();
    }
  }

  @override
  void didUpdateWidget(TeacherBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.speakOnShow && widget.text != oldWidget.text) {
      _speak();
    }
  }

  void _speak() {
    final speaker = context.read<Speaker>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        speaker.say(widget.text, key: widget.speechKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AvatarImage(widget.theme, widget.avatarIndex, size: widget.avatarSize),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                color: palette.text,
                fontSize: 17,
                fontWeight: FontWeight.w600,
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
