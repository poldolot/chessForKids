import '../../engine/engine.dart';

/// What the board should emphasise on top of the position.
final class BoardHighlights {
  const BoardHighlights({
    this.selected,
    this.moveTargets = const {},
    this.captureTargets = const {},
    this.lastMove,
    this.checkedKing,
    this.danger = const {},
    this.stars = const {},
    this.ghosts = const {},
  });

  final Square? selected;
  final Set<Square> moveTargets;
  final Set<Square> captureTargets;
  final Move? lastMove;
  final Square? checkedKing;

  /// Squares the opponent attacks; shown as red dots in the king race.
  final Set<Square> danger;

  /// Squares with a star to collect; drawn under the piece.
  final Set<Square> stars;

  /// Faded pieces marking where a piece belongs (setup lesson).
  final Map<Square, Piece> ghosts;

  /// This set of highlights with [other]'s non-empty fields laid on top.
  BoardHighlights merge(BoardHighlights other) {
    return BoardHighlights(
      selected: other.selected ?? selected,
      moveTargets: {...moveTargets, ...other.moveTargets},
      captureTargets: {...captureTargets, ...other.captureTargets},
      lastMove: other.lastMove ?? lastMove,
      checkedKing: other.checkedKing ?? checkedKing,
      danger: {...danger, ...other.danger},
      stars: {...stars, ...other.stars},
      ghosts: {...ghosts, ...other.ghosts},
    );
  }
}
