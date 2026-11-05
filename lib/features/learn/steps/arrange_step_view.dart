import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/speaker.dart';
import '../../../engine/engine.dart';
import '../../../l10n/app_localizations.dart';
import '../../board/board_highlights.dart';
import '../../board/board_view.dart';
import '../../board/piece_image.dart';
import '../lesson_model.dart';
import '../lesson_strings.dart';

/// "Set up the pieces": drag each piece from the tray onto one of its
/// shadows. When the tray is empty the pawns line up by themselves.
class ArrangeStepView extends StatefulWidget {
  const ArrangeStepView({
    super.key,
    required this.step,
    required this.onDone,
    required this.onMistake,
  });

  final ArrangeStep step;
  final VoidCallback onDone;
  final VoidCallback onMistake;

  @override
  State<ArrangeStepView> createState() => _ArrangeStepViewState();
}

final class _TrayItem {
  const _TrayItem(this.piece, this.key);

  final Piece piece;
  final String key;
}

class _ArrangeStepViewState extends State<ArrangeStepView> {
  static const double _feedbackSize = 64;
  static const Duration _pawnDelay = Duration(milliseconds: 80);

  final GlobalKey _boardKey = GlobalKey();
  late final Position _target = Position.fromFen(widget.step.targetFen);
  late Position _position = Position.empty();
  static const double _pieceSize = 56;
  static const double _traySpacing = 4;

  late final List<_TrayItem> _tray = _buildTray();

  /// Height of the tray when it holds every piece of the step.
  double _trayHeight(double width) {
    final inner = width - 16;
    final perRow = ((inner + _traySpacing) / (_pieceSize + _traySpacing))
        .floor()
        .clamp(1, 64);
    final rows = (widget.step.tray.length / perRow).ceil();
    return rows * _pieceSize + (rows - 1) * _traySpacing + 16;
  }

  Timer? _pawnTimer;
  bool _finished = false;

  List<_TrayItem> _buildTray() {
    final counts = <String, int>{};
    return [
      for (final piece in widget.step.tray)
        _TrayItem(
          piece,
          'tray-${piece.fenChar}${counts.update(piece.fenChar, (n) => n + 1, ifAbsent: () => 0)}',
        ),
    ];
  }

  @override
  void dispose() {
    _pawnTimer?.cancel();
    super.dispose();
  }

  /// Target squares still waiting for a piece.
  Map<Square, Piece> get _ghosts => {
    for (final (square, piece) in _target.pieces())
      if (_position.pieceAt(square) == null) square: piece,
  };

  Square? _squareAt(Offset globalCenter) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return null;
    }
    final local = box.globalToLocal(globalCenter);
    final square = box.size.width / 8;
    final c = (local.dx / square).floor();
    final r = (local.dy / square).floor();
    if (c < 0 || c > 7 || r < 0 || r > 7) {
      return null;
    }
    return Square.fromFileRank(c, 7 - r);
  }

  void _onDrop(DragTargetDetails<_TrayItem> details) {
    final center =
        details.offset + const Offset(_feedbackSize / 2, _feedbackSize / 2);
    final square = _squareAt(center);
    if (square == null) {
      return;
    }
    final wanted = _ghosts[square];
    if (wanted != details.data.piece) {
      widget.onMistake();
      _say('learn.setup.task');
      return;
    }
    setState(() {
      _position = _position.withPiece(square, details.data.piece);
      _tray.remove(details.data);
    });
    if (_tray.isEmpty) {
      _startPawns();
    }
  }

  void _startPawns() {
    var file = 0;
    _pawnTimer = Timer.periodic(_pawnDelay, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _position = _position.withPiece(
          Square.fromFileRank(file, 1),
          const Piece(PieceColor.white, PieceType.pawn),
        );
      });
      file++;
      if (file == 8) {
        timer.cancel();
        _finished = true;
        _say('learn.setup.pawns');
        widget.onDone();
      }
    });
  }

  void _say(String key) {
    final l10n = AppLocalizations.of(context);
    context.read<Speaker>().say(
      learnLine(l10n, key),
      key: key,
      interrupt: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.of(context).ui;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: DragTarget<_TrayItem>(
              onAcceptWithDetails: _onDrop,
              builder: (context, candidates, rejected) => BoardView(
                key: _boardKey,
                position: _position,
                highlights: BoardHighlights(ghosts: _ghosts),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // The tray keeps the height it needs for the full set of pieces, so
        // the board above does not move as the tray empties.
        LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: _trayHeight(constraints.maxWidth),
            child: _finished
                ? null
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: _traySpacing,
                        runSpacing: _traySpacing,
                        children: [
                          for (final item in _tray)
                            Draggable<_TrayItem>(
                              key: ValueKey(item.key),
                              data: item,
                              feedback: PieceImage(
                                item.piece,
                                size: _feedbackSize,
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: PieceImage(item.piece, size: _pieceSize),
                              ),
                              child: PieceImage(item.piece, size: _pieceSize),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
