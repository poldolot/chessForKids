import 'dart:math';

import 'package:flutter/material.dart';

/// The frame shared by the play and result screens.
///
/// The board side is computed from the screen alone (never from the bubble's
/// text), the slot under the bubble (progress bar while playing, stars
/// afterwards) and the controls strip have fixed heights, so the board stays
/// exactly where it was when the result appears. Whatever height is left
/// goes to the bubble; on a very small screen a long line scrolls there.
class GameLayout extends StatelessWidget {
  const GameLayout({
    super.key,
    required this.bubble,
    required this.slot,
    required this.board,
    required this.controls,
    this.overlay,
  });

  static const double slotHeight = 44;
  static const double controlsHeight = 60;
  static const double _gap = 10;

  /// Room always kept for the bubble (one avatar row).
  static const double _minBubbleHeight = 72;

  final Widget bubble;
  final Widget slot;
  final Widget board;
  final Widget controls;

  /// Drawn over the board, centred (a badge that was just earned).
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const fixed = slotHeight + controlsHeight + 3 * _gap;
        final side = max(
          0.0,
          min(
            constraints.maxWidth,
            constraints.maxHeight - fixed - _minBubbleHeight,
          ),
        );
        final bubbleHeight = max(0.0, constraints.maxHeight - fixed - side);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: bubbleHeight,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: bubble,
              ),
            ),
            const SizedBox(height: _gap),
            SizedBox(
              height: slotHeight,
              child: Center(child: slot),
            ),
            const SizedBox(height: _gap),
            SizedBox(
              height: side,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(width: side, height: side, child: board),
                  ),
                  if (overlay case final badge?)
                    Positioned.fill(child: Center(child: badge)),
                ],
              ),
            ),
            const SizedBox(height: _gap),
            SizedBox(height: controlsHeight, child: controls),
          ],
        );
      },
    );
  }
}
