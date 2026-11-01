import 'attacks.dart';
import 'move_generator.dart';
import 'piece.dart';
import 'position.dart';

/// How a game ended, or [ongoing].
enum GameOutcome {
  ongoing,
  checkmate,
  stalemate,
  insufficientMaterial,
  threefoldRepetition,
  fiftyMoveRule,
  resignation,
}

/// The outcome of a game together with the winner, if any.
final class GameResult {
  const GameResult(this.outcome, {this.winner});

  static const GameResult ongoing = GameResult(GameOutcome.ongoing);

  final GameOutcome outcome;

  /// The winning side, or `null` for a draw or an ongoing game.
  final PieceColor? winner;

  /// The game has ended.
  bool get isOver => outcome != GameOutcome.ongoing;

  /// The game ended without a winner.
  bool get isDraw => isOver && winner == null;

  @override
  bool operator ==(Object other) =>
      other is GameResult && other.outcome == outcome && other.winner == winner;

  @override
  int get hashCode => Object.hash(outcome, winner);

  @override
  String toString() =>
      winner == null ? outcome.name : '${outcome.name} (${winner!.name} wins)';
}

/// Whether neither side can possibly deliver checkmate.
///
/// Recognises the certain cases only: K vs K, K+B vs K, K+N vs K and
/// K+B vs K+B with both bishops on the same square color. Returns false when
/// either side has no king (lesson and mini-game boards).
bool hasInsufficientMaterial(Position position) {
  if (position.kingSquare(PieceColor.white) == null ||
      position.kingSquare(PieceColor.black) == null) {
    return false;
  }
  final minors = <(PieceType, bool)>[];
  for (final (square, piece) in position.pieces()) {
    switch (piece.type) {
      case PieceType.king:
        break;
      case PieceType.bishop || PieceType.knight:
        minors.add((piece.type, square.isLight));
      case PieceType.pawn || PieceType.rook || PieceType.queen:
        return false;
    }
  }
  if (minors.length <= 1) {
    return true;
  }
  if (minors.length == 2) {
    final (typeA, lightA) = minors[0];
    final (typeB, lightB) = minors[1];
    final bothBishops = typeA == PieceType.bishop && typeB == PieceType.bishop;
    final oneEach = _oneBishopEachSide(position);
    return bothBishops && oneEach && lightA == lightB;
  }
  return false;
}

/// True when the two bishops on the board belong to different sides.
bool _oneBishopEachSide(Position position) {
  var white = 0;
  var black = 0;
  for (final (_, piece) in position.pieces()) {
    if (piece.type == PieceType.bishop) {
      piece.color == PieceColor.white ? white++ : black++;
    }
  }
  return white == 1 && black == 1;
}

/// Evaluates a position for a game-ending condition that needs no history:
/// checkmate, stalemate, insufficient material or the fifty-move rule.
/// Repetition is tracked by `Game`.
GameResult evaluatePosition(
  Position position, {
  GameRules rules = GameRules.standard,
}) {
  if (legalMoves(position, rules: rules).isEmpty) {
    if (isInCheck(position)) {
      return GameResult(
        GameOutcome.checkmate,
        winner: position.sideToMove.opposite,
      );
    }
    return const GameResult(GameOutcome.stalemate);
  }
  if (hasInsufficientMaterial(position)) {
    return const GameResult(GameOutcome.insufficientMaterial);
  }
  if (position.halfmoveClock >= 100) {
    return const GameResult(GameOutcome.fiftyMoveRule);
  }
  return GameResult.ongoing;
}
