import 'dart:math';

import 'package:flutter/material.dart';

/// The frame shared by the play and result screens.
///
/// The board side is computed from the screen alone (never from the bubble's
/// text), the slot under the bubble (progress bar while playing, stars
/// afterwards) and the controls strip have fixed heights, so the board stays
/// exactly where it was when the result appears. Whatever height is left
/// goes to the bubble; on a very small screen a long line scrolls there.
class GameLayout extends StatefulWidget {
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

  /// A card for the result or a badge: shown above the board when the
  /// screen is tall enough, otherwise over it; a tap closes it so the
  /// board can be looked at.
  final Widget? overlay;

  /// Room above the board needed to keep the card off the board.
  static const double _cardRoom = 230;

  @override
  State<GameLayout> createState() => _GameLayoutState();
}

class _GameLayoutState extends State<GameLayout> {
  Key? _closedOverlay;

  @override
  void didUpdateWidget(GameLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.overlay?.key != oldWidget.overlay?.key) {
      _closedOverlay = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    const slotHeight = GameLayout.slotHeight;
    const controlsHeight = GameLayout.controlsHeight;
    const gap = GameLayout._gap;
    const minBubbleHeight = GameLayout._minBubbleHeight;
    final bubble = widget.bubble;
    final slot = widget.slot;
    final board = widget.board;
    final controls = widget.controls;
    final overlay = widget.overlay;
    final closed = _closedOverlay != null && overlay?.key == _closedOverlay;
    final card = overlay == null || closed
        ? null
        : GestureDetector(
            key: const Key('overlay-card'),
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _closedOverlay = overlay.key),
            child: overlay,
          );
    return LayoutBuilder(
      builder: (context, constraints) {
        const fixed = slotHeight + controlsHeight + 3 * gap;
        final side = max(
          0.0,
          min(
            constraints.maxWidth,
            constraints.maxHeight - fixed - minBubbleHeight,
          ),
        );
        final bubbleHeight = max(0.0, constraints.maxHeight - fixed - side);
        final cardAbove = card != null && bubbleHeight >= GameLayout._cardRoom;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: bubbleHeight,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: bubble,
                  ),
                  if (cardAbove)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Center(child: card),
                    ),
                ],
              ),
            ),
            const SizedBox(height: gap),
            SizedBox(
              height: slotHeight,
              child: Center(child: slot),
            ),
            const SizedBox(height: gap),
            SizedBox(
              height: side,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(width: side, height: side, child: board),
                  ),
                  if (card != null && !cardAbove)
                    Positioned.fill(child: Center(child: card)),
                ],
              ),
            ),
            const SizedBox(height: gap),
            SizedBox(height: controlsHeight, child: controls),
          ],
        );
      },
    );
  }
}
