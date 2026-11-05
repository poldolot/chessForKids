import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../engine/engine.dart';
import 'board_highlights.dart';
import 'piece_image.dart';

typedef DragEndCallback = void Function(Square from, Square? to);

/// Draws a position with highlights and reports taps and drags.
///
/// Presentation only: it knows nothing about legality. Every square carries
/// `Key('sq-<name>')`; highlight children carry `move-dot`, `capture-frame`,
/// `selected-frame`, `last-move` and `check-<square>` keys. A piece being
/// dragged is drawn as `drag-ghost`, a piece sliding after a move as
/// `sliding-piece`; both live in an overlay above every square.
class BoardView extends StatefulWidget {
  /// How long a castling move takes to play out on the board (king, then
  /// rook); opponents wait for it before replying.
  static const Duration castlingAnimation = Duration(milliseconds: 900);

  const BoardView({
    super.key,
    required this.position,
    this.orientation = PieceColor.white,
    this.highlights = const BoardHighlights(),
    this.onSquareTap,
    this.onDragStart,
    this.onDragEnd,
    this.animateMove,
    this.size,
    this.shakeSquare,
  });

  final Position position;

  /// The color whose pieces are drawn at the bottom.
  final PieceColor orientation;
  final BoardHighlights highlights;
  final ValueChanged<Square>? onSquareTap;

  /// Called when a drag starts on a square; must return true to allow the
  /// drag. Without this callback pieces cannot be dragged at all.
  final bool Function(Square square)? onDragStart;
  final DragEndCallback? onDragEnd;

  /// A move whose piece slides from `from` to `to` when the board first
  /// shows this value.
  final Move? animateMove;

  /// Side length; defaults to the shorter side of the available space.
  final double? size;

  /// The piece on this square shakes its head (a short rotation) whenever
  /// the value changes to a non-null square.
  final Square? shakeSquare;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  Square? _dragFrom;
  Offset? _dragPosition;

  /// Where the finger first touched; onPanStart fires only after the pointer
  /// has already moved past the drag threshold.
  Offset? _touchDown;

  /// The move currently sliding, until its animation has finished.
  Move? _sliding;

  /// Bumped whenever shakeSquare changes so the shake restarts.
  int _shakeToken = 0;

  static const Duration _slideDuration = Duration(milliseconds: 220);

  /// Castling is shown in two slow steps: the king, then the rook.
  static const Duration _castleDuration = Duration(milliseconds: 450);

  /// The rook's half of a castling move, while the king or the rook slides.
  Move? _castleRook;
  bool _rookSliding = false;

  @override
  void initState() {
    super.initState();
    _startSlide(widget.animateMove);
  }

  void _startSlide(Move? move) {
    _sliding = move;
    _rookSliding = false;
    _castleRook = move == null ? null : _rookMoveOf(move);
  }

  /// For a king move of two files, the rook move that goes with it.
  Move? _rookMoveOf(Move move) {
    final piece = widget.position.pieceAt(move.to);
    if (piece == null ||
        piece.type != PieceType.king ||
        (move.to.file - move.from.file).abs() != 2) {
      return null;
    }
    final kingside = move.to.file > move.from.file;
    final rank = move.to.rank;
    return Move(
      Square.fromFileRank(kingside ? 7 : 0, rank),
      Square.fromFileRank(kingside ? 5 : 3, rank),
    );
  }

  @override
  void didUpdateWidget(BoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animateMove != oldWidget.animateMove) {
      _startSlide(widget.animateMove);
    }
    if (widget.shakeSquare != null &&
        widget.shakeSquare != oldWidget.shakeSquare) {
      _shakeToken++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side =
            widget.size ??
            math.min(constraints.maxWidth, constraints.maxHeight);
        final square = side / 8;
        final reduceMotion = MediaQuery.disableAnimationsOf(context);
        final sliding = reduceMotion ? null : _sliding;
        final rook = reduceMotion ? null : _castleRook;
        return SizedBox(
          width: side,
          height: side,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) {
              final s = _squareAt(d.localPosition, square);
              if (s != null) {
                widget.onSquareTap?.call(s);
              }
            },
            onPanDown: (d) => _touchDown = d.localPosition,
            onPanStart: (d) => _startDrag(
              _touchDown ?? d.localPosition,
              d.localPosition,
              square,
            ),
            onPanUpdate: (d) {
              if (_dragFrom != null) {
                setState(() => _dragPosition = d.localPosition);
              }
            },
            onPanEnd: (_) => _endDrag(square),
            onPanCancel: () => _endDrag(square, cancelled: true),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _grid(
                  square,
                  hidden: {
                    ?_dragFrom,
                    if (sliding != null && !_rookSliding) sliding.to,
                    if (rook != null) rook.to,
                  },
                ),
                if (sliding != null && !_rookSliding)
                  _slidingPiece(
                    sliding,
                    square,
                    duration: rook == null ? _slideDuration : _castleDuration,
                    onDone: rook == null
                        ? () => setState(() => _sliding = null)
                        : () => setState(() => _rookSliding = true),
                  ),
                if (rook != null && !_rookSliding)
                  _restingPiece(rook.from, rook, square),
                if (rook != null && _rookSliding)
                  _slidingPiece(
                    rook,
                    square,
                    duration: _castleDuration,
                    onDone: () => setState(() {
                      _sliding = null;
                      _castleRook = null;
                      _rookSliding = false;
                    }),
                    key: const Key('castle-rook'),
                  ),
                if (_dragFrom != null && _dragPosition != null)
                  Positioned(
                    left: _dragPosition!.dx - square * 0.6,
                    top: _dragPosition!.dy - square * 0.6,
                    child: IgnorePointer(
                      child: PieceImage(
                        widget.position.pieceAt(_dragFrom!)!,
                        key: const Key('drag-ghost'),
                        size: square * 1.2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _slidingPiece(
    Move move,
    double square, {
    required Duration duration,
    required VoidCallback onDone,
    Key key = const Key('sliding-piece'),
  }) {
    final piece = widget.position.pieceAt(move.to);
    if (piece == null) {
      return const SizedBox.shrink();
    }
    final from = _offsetOf(move.from, square);
    final to = _offsetOf(move.to, square);
    return TweenAnimationBuilder<double>(
      key: ValueKey('slide-${move.uci}'),
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      onEnd: () {
        if (mounted) {
          onDone();
        }
      },
      builder: (context, t, child) {
        final at = Offset.lerp(from, to, t)!;
        return Positioned(left: at.dx, top: at.dy, child: child!);
      },
      child: IgnorePointer(
        child: SizedBox(
          width: square,
          height: square,
          child: Padding(
            padding: EdgeInsets.all(square * 0.06),
            child: PieceImage(piece, key: key),
          ),
        ),
      ),
    );
  }

  /// The castling rook waiting on its old square while the king slides.
  Widget _restingPiece(Square at, Move move, double square) {
    final piece = widget.position.pieceAt(move.to);
    if (piece == null) {
      return const SizedBox.shrink();
    }
    final offset = _offsetOf(at, square);
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: IgnorePointer(
        child: SizedBox(
          width: square,
          height: square,
          child: Padding(
            padding: EdgeInsets.all(square * 0.06),
            child: PieceImage(piece, key: const Key('castle-rook')),
          ),
        ),
      ),
    );
  }

  void _startDrag(Offset origin, Offset current, double square) {
    final s = _squareAt(origin, square);
    if (s == null || widget.position.pieceAt(s) == null) {
      return;
    }
    if (widget.onDragStart?.call(s) != true) {
      return;
    }
    setState(() {
      _dragFrom = s;
      _dragPosition = current;
    });
  }

  void _endDrag(double square, {bool cancelled = false}) {
    _touchDown = null;
    final from = _dragFrom;
    if (from == null) {
      return;
    }
    final to = cancelled || _dragPosition == null
        ? null
        : _squareAt(_dragPosition!, square);
    setState(() {
      _dragFrom = null;
      _dragPosition = null;
    });
    widget.onDragEnd?.call(from, to);
  }

  Square? _squareAt(Offset local, double square) {
    final c = (local.dx / square).floor();
    final r = (local.dy / square).floor();
    if (c < 0 || c > 7 || r < 0 || r > 7) {
      return null;
    }
    return widget.orientation == PieceColor.white
        ? Square.fromFileRank(c, 7 - r)
        : Square.fromFileRank(7 - c, r);
  }

  Offset _offsetOf(Square s, double square) {
    final white = widget.orientation == PieceColor.white;
    final c = white ? s.file : 7 - s.file;
    final r = white ? 7 - s.rank : s.rank;
    return Offset(c * square, r * square);
  }

  Widget _grid(double square, {required Set<Square> hidden}) {
    final palette = AppTheme.of(context).board;
    return Column(
      children: [
        for (var row = 0; row < 8; row++)
          Expanded(
            child: Row(
              children: [
                for (var col = 0; col < 8; col++)
                  Expanded(
                    child: _squareWidget(
                      widget.orientation == PieceColor.white
                          ? Square.fromFileRank(col, 7 - row)
                          : Square.fromFileRank(7 - col, row),
                      square,
                      palette,
                      hidden,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  /// Wraps the piece on [widget.shakeSquare] in a short "no" rotation.
  Widget _maybeShake(Square s, Widget child) {
    if (widget.shakeSquare != s) {
      return child;
    }
    return TweenAnimationBuilder<double>(
      key: ValueKey('shake-${s.name}-$_shakeToken'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, t, child) => Transform.rotate(
        key: const Key('shake'),
        angle: math.sin(t * math.pi * 3) * (1 - t) * 0.14,
        child: child,
      ),
      child: child,
    );
  }

  Widget _squareWidget(
    Square s,
    double square,
    BoardPalette palette,
    Set<Square> hidden,
  ) {
    final h = widget.highlights;
    final piece = widget.position.pieceAt(s);
    final isLast =
        h.lastMove != null && (h.lastMove!.from == s || h.lastMove!.to == s);
    final isCheck = h.checkedKing == s;
    Color background = s.isLight ? palette.light : palette.dark;
    if (isLast) {
      background = Color.alphaBlend(
        palette.lastMove.withValues(alpha: 0.6),
        background,
      );
    }
    if (isCheck) {
      background = Color.alphaBlend(
        palette.check.withValues(alpha: 0.7),
        background,
      );
    }
    return Container(
      key: Key('sq-${s.name}'),
      color: background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isLast) const SizedBox.shrink(key: Key('last-move')),
          if (isCheck) SizedBox.shrink(key: Key('check-${s.name}')),
          if (h.selected == s)
            Container(
              key: const Key('selected-frame'),
              decoration: BoxDecoration(
                border: Border.all(
                  color: palette.selected,
                  width: square * 0.09,
                ),
              ),
            ),
          if (h.captureTargets.contains(s))
            Container(
              key: const Key('capture-frame'),
              decoration: BoxDecoration(
                border: Border.all(
                  color: palette.capture,
                  width: square * 0.09,
                ),
              ),
            ),
          if (h.danger.contains(s))
            Center(
              child: Container(
                key: const Key('danger-dot'),
                width: square * 0.4,
                height: square * 0.4,
                decoration: BoxDecoration(
                  color: palette.check.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          if (h.stars.contains(s))
            Center(
              child: Icon(
                Icons.star_rounded,
                key: Key('star-${s.name}'),
                size: square * 0.7,
                color: palette.selected,
              ),
            ),
          if (h.ghosts[s] case final ghost? when piece == null)
            Opacity(
              key: Key('ghost-${s.name}'),
              opacity: 0.35,
              child: Padding(
                padding: EdgeInsets.all(square * 0.06),
                child: PieceImage(ghost),
              ),
            ),
          if (piece != null && !hidden.contains(s))
            _maybeShake(
              s,
              Padding(
                padding: EdgeInsets.all(square * 0.06),
                child: PieceImage(piece),
              ),
            ),
          // A star is the dot's colour, so a target on a star gets a frame.
          if (h.moveTargets.contains(s) && h.stars.contains(s))
            Container(
              key: const Key('move-dot'),
              decoration: BoxDecoration(
                border: Border.all(
                  color: palette.moveDot,
                  width: square * 0.09,
                ),
              ),
            )
          else if (h.moveTargets.contains(s) || h.captureTargets.contains(s))
            Center(
              child: Container(
                key: const Key('move-dot'),
                width: square * 0.34,
                height: square * 0.34,
                decoration: BoxDecoration(
                  color: palette.moveDot,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
