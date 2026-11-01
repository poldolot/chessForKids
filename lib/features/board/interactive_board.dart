import 'package:flutter/material.dart';

import '../../engine/engine.dart';
import 'board_highlights.dart';
import 'board_view.dart';
import 'promotion_picker.dart';

/// Asks which piece a pawn becomes; `null` cancels the move.
typedef PromotionChooser = Future<PieceType?> Function(
  BuildContext context,
  PieceColor color,
);

/// A board the child can move pieces on: tapping an own piece shows its
/// legal moves, tapping a target (or dragging onto it) plays the move.
class InteractiveBoard extends StatefulWidget {
  const InteractiveBoard({
    super.key,
    required this.position,
    required this.onMove,
    this.orientation = PieceColor.white,
    this.rules = GameRules.standard,
    this.movableColor,
    this.lastMove,
    this.enabled = true,
    this.size,
    this.promotionChooser = showPromotionPicker,
    this.onRejected,
    this.moveFilter,
    this.extraHighlights = const BoardHighlights(),
    this.shakeSquare,
  });

  final Position position;
  final ValueChanged<Move> onMove;
  final PieceColor orientation;
  final GameRules rules;

  /// Which side the user controls; `null` means whoever is to move.
  final PieceColor? movableColor;
  final Move? lastMove;
  final bool enabled;
  final double? size;
  final PromotionChooser promotionChooser;

  /// A tap that is neither an own piece nor an allowed target: an enemy
  /// piece, an empty square, or a legal move the [moveFilter] excludes.
  final ValueChanged<Square>? onRejected;

  /// Only legal moves passing this filter are offered as targets.
  final bool Function(Move move)? moveFilter;

  /// Highlights laid over the board's own (stars, danger, ghosts...).
  final BoardHighlights extraHighlights;

  /// See [BoardView.shakeSquare].
  final Square? shakeSquare;

  @override
  State<InteractiveBoard> createState() => _InteractiveBoardState();
}

class _InteractiveBoardState extends State<InteractiveBoard> {
  Square? _selected;
  List<Move> _targets = const [];

  /// The last move the user dragged; it is already on its square, so it is
  /// not slid there again.
  Move? _draggedMove;

  /// Set after a move is reported and cleared when the new position arrives
  /// (or after a frame), so a quick second tap is not read against the old
  /// position.
  bool _pendingMove = false;

  bool get _canMove {
    final mover = widget.movableColor ?? widget.position.sideToMove;
    return widget.enabled &&
        !_pendingMove &&
        mover == widget.position.sideToMove;
  }

  @override
  void didUpdateWidget(InteractiveBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position) {
      _clear();
      _pendingMove = false;
    }
  }

  void _clear() {
    _selected = null;
    _targets = const [];
  }

  bool _isOwnPiece(Square s) {
    final piece = widget.position.pieceAt(s);
    return piece != null && piece.color == widget.position.sideToMove;
  }

  bool _allowed(Move m) => widget.moveFilter?.call(m) ?? true;

  void _select(Square s) {
    setState(() {
      _selected = s;
      _targets = legalMoves(
        widget.position,
        from: s,
        rules: widget.rules,
      ).where(_allowed).toList();
    });
  }

  void _onTap(Square s) {
    if (!_canMove) {
      return;
    }
    final candidates = _targets.where((m) => m.to == s).toList();
    if (candidates.isNotEmpty) {
      _play(candidates);
    } else if (_isOwnPiece(s)) {
      _select(s);
    } else {
      setState(_clear);
      widget.onRejected?.call(s);
    }
  }

  bool _onDragStart(Square s) {
    if (!_canMove || !_isOwnPiece(s)) {
      return false;
    }
    _select(s);
    return true;
  }

  void _onDragEnd(Square from, Square? to) {
    final candidates = _targets
        .where((m) => m.from == from && m.to == to)
        .toList();
    if (candidates.isNotEmpty) {
      _play(candidates, dragged: true);
    } else {
      setState(_clear);
      if (to != null && to != from) {
        widget.onRejected?.call(to);
      }
    }
  }

  Future<void> _play(List<Move> candidates, {bool dragged = false}) async {
    final position = widget.position;
    var move = candidates.first;
    if (candidates.length > 1) {
      final piece = widget.position.pieceAt(move.from)!;
      final choice = await widget.promotionChooser(context, piece.color);
      if (!mounted || widget.position != position) {
        return;
      }
      if (choice == null) {
        setState(_clear);
        return;
      }
      move = candidates.firstWhere((m) => m.promotion == choice);
    }
    setState(() {
      _clear();
      _draggedMove = dragged ? move : null;
      _pendingMove = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pendingMove) {
        setState(() => _pendingMove = false);
      }
    });
    widget.onMove(move);
  }

  bool _isCapture(Move m) {
    final target = widget.position.pieceAt(m.to);
    if (target != null) {
      return true;
    }
    final mover = widget.position.pieceAt(m.from);
    return mover?.type == PieceType.pawn && m.from.file != m.to.file;
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.position;
    final checked = isInCheck(position)
        ? position.kingSquare(position.sideToMove)
        : null;
    final own = BoardHighlights(
      selected: _selected,
      moveTargets: {
        for (final m in _targets)
          if (!_isCapture(m)) m.to,
      },
      captureTargets: {
        for (final m in _targets)
          if (_isCapture(m)) m.to,
      },
      lastMove: widget.lastMove,
      checkedKing: checked,
    );
    return BoardView(
      position: position,
      orientation: widget.orientation,
      size: widget.size,
      animateMove: widget.lastMove == _draggedMove ? null : widget.lastMove,
      highlights: own.merge(widget.extraHighlights),
      shakeSquare: widget.shakeSquare,
      onSquareTap: _onTap,
      onDragStart: _onDragStart,
      onDragEnd: _onDragEnd,
    );
  }
}
