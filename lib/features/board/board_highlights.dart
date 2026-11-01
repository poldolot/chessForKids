import '../../engine/engine.dart';

/// What the board should emphasise on top of the position.
final class BoardHighlights {
  const BoardHighlights({
    this.selected,
    this.moveTargets = const {},
    this.captureTargets = const {},
    this.lastMove,
    this.checkedKing,
  });

  final Square? selected;
  final Set<Square> moveTargets;
  final Set<Square> captureTargets;
  final Move? lastMove;
  final Square? checkedKing;
}
