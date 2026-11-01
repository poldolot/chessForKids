import '../data/models.dart';
import '../engine/engine.dart';

/// Minimum size of anything a child is expected to tap.
const double kMinTouchTarget = 56;

/// How long the parent lock must be held before the parent zone opens.
const Duration kParentLockDuration = Duration(seconds: 3);

/// Name of the piece graphics set under `assets/pieces/`.
const String kPieceStyle = 'basic';

/// Asset path of the SVG for [piece], e.g. `assets/pieces/basic/wk.svg`.
String pieceAsset(Piece piece) {
  final colorLetter = piece.color == PieceColor.white ? 'w' : 'b';
  return 'assets/pieces/$kPieceStyle/$colorLetter${piece.type.letter}.svg';
}

/// Asset path of avatar number [index] (1-based) of [theme].
String avatarAsset(TeacherTheme theme, int index) =>
    'assets/avatars/${theme.name}/$index.svg';
