import 'package:chess_for_kids/ai/ai.dart';
import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('levels: easy is forgiving, normal is steady', () {
    expect(MatchLevel.easy.depth, 2);
    expect(MatchLevel.easy.noise, 100);
    expect(MatchLevel.easy.blunder, 0.25);
    expect(MatchLevel.normal.depth, 2);
    expect(MatchLevel.normal.noise, 60);
    expect(MatchLevel.normal.blunder, 0);
    expect(MatchLevel.veryEasy.depth, 2);
    expect(MatchLevel.veryEasy.noise, 300);
    expect(MatchLevel.veryEasy.blunder, 0.5);
    expect(MatchLevel.values, [
      MatchLevel.veryEasy,
      MatchLevel.easy,
      MatchLevel.normal,
    ]);
  });

  test('piece values are centipawns of the conventional values', () {
    expect(pieceValue(PieceType.pawn), 100);
    expect(pieceValue(PieceType.knight), 300);
    expect(pieceValue(PieceType.bishop), 300);
    expect(pieceValue(PieceType.rook), 500);
    expect(pieceValue(PieceType.queen), 900);
    expect(pieceValue(PieceType.king), 0);
  });

  test('the start position and bare kings are balanced', () {
    expect(evaluate(Position.initial(), PieceColor.white), 0);
    expect(evaluate(Position.initial(), PieceColor.black), 0);
    final kings = Position.fromFen('4k3/8/8/8/8/8/8/4K3 w - - 0 1');
    expect(evaluate(kings, PieceColor.white), 0);
  });

  test('an extra queen is worth about nine pawns, sign follows the side', () {
    final p = Position.fromFen('4k3/8/8/8/8/8/8/4K2Q w - - 0 1');
    expect(evaluate(p, PieceColor.white), greaterThanOrEqualTo(900));
    expect(evaluate(p, PieceColor.black), lessThanOrEqualTo(-900));
    expect(evaluate(p, PieceColor.white), -evaluate(p, PieceColor.black));
  });

  test(
    'a pawn in the centre scores a little more than on its start square',
    () {
      final home = Position.fromFen('4k3/8/8/8/8/8/4P3/4K3 w - - 0 1');
      final centre = Position.fromFen('4k3/8/8/8/4P3/8/8/4K3 w - - 0 1');
      final gain =
          evaluate(centre, PieceColor.white) - evaluate(home, PieceColor.white);
      expect(gain, greaterThan(0));
      expect(gain, lessThanOrEqualTo(30));
    },
  );

  test('an advanced pawn scores more the closer it is to promotion', () {
    final sixth = Position.fromFen('4k3/8/4P3/8/8/8/8/4K3 w - - 0 1');
    final seventh = Position.fromFen('4k3/4P3/8/8/8/8/8/4K3 w - - 0 1');
    expect(
      evaluate(seventh, PieceColor.white),
      greaterThan(evaluate(sixth, PieceColor.white)),
    );
  });
}
