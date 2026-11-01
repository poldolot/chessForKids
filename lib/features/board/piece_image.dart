import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/constants.dart';
import '../../engine/engine.dart';

/// The SVG picture of a chess piece from the active piece set.
class PieceImage extends StatelessWidget {
  const PieceImage(this.piece, {super.key, this.size});

  final Piece piece;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      pieceAsset(piece),
      width: size,
      height: size,
      semanticsLabel: '${piece.color.name} ${piece.type.name}',
    );
  }
}
