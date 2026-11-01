import 'dart:math';

import 'package:chess_for_kids/ai/ai.dart';
import 'package:chess_for_kids/data/models.dart';
import 'package:chess_for_kids/engine/engine.dart';
import 'package:chess_for_kids/features/match/match_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Move uci(String u) => Move.parseUci(u);

  MatchSession white({int seed = 1}) =>
      MatchSession(childColor: PieceColor.white, random: Random(seed));

  test('the child moves first with white, the computer with black', () {
    final s = white();
    expect(s.childToMove, isTrue);
    expect(s.computerToMove, isFalse);
    expect(s.canUndo, isFalse);
    final b = MatchSession(childColor: PieceColor.black, random: Random(1));
    expect(b.childToMove, isFalse);
    expect(b.computerToMove, isTrue);
    expect(b.computerColor, PieceColor.white);
  });

  test('a child move hands the turn to the computer, whose reply is legal', () {
    final s = white();
    s.playChild(uci('e2e4'));
    expect(s.computerToMove, isTrue);
    expect(s.lastMove, uci('e2e4'));
    expect(() => s.playChild(uci('d2d4')), throwsStateError);
    final reply = s.playComputer();
    expect(reply, isNotNull);
    expect(s.position.pieceAt(reply!.to)?.color, PieceColor.black);
    expect(s.childToMove, isTrue);
    expect(s.playComputer(), isNull);
  });

  test('only the child pieces may be moved; illegal moves throw', () {
    final s = white();
    expect(s.allows(uci('e2e4')), isTrue);
    expect(s.allows(uci('e7e5')), isFalse);
    expect(() => s.playChild(uci('e2e5')), throwsArgumentError);
  });

  test('undo takes back the computer reply and the child move together', () {
    final s = white();
    s.playChild(uci('e2e4'));
    s.playComputer();
    expect(s.canUndo, isTrue);
    s.undo();
    expect(s.position, Position.initial());
    expect(s.canUndo, isFalse);
    expect(s.lastMove, isNull);
    expect(s.childToMove, isTrue);
  });

  test('undo before the computer replied takes back only the child move', () {
    final s = white();
    s.playChild(uci('e2e4'));
    s.undo();
    expect(s.position, Position.initial());
    expect(s.childToMove, isTrue);
  });

  test('undo at the start does nothing', () {
    final s = white();
    s.undo();
    expect(s.position, Position.initial());
  });

  test('hint is a legal child move and leaves the position alone', () {
    final s = white();
    final hint = s.hint();
    expect(hint, isNotNull);
    expect(s.legalMoves(), contains(hint));
    expect(s.position, Position.initial());
    expect(s.allows(hint!), isTrue);
  });

  test('checkmate by the child wins three stars', () {
    final s = MatchSession.fromJson({
      'version': 1,
      'child': 'black',
      'level': 'easy',
      'moves': ['f2f3', 'e7e5', 'g2g4'],
    }, random: Random(1));
    expect(s.childToMove, isTrue);
    expect(s.stars, 0);
    s.playChild(uci('d8h4'));
    expect(s.result.outcome, GameOutcome.checkmate);
    expect(s.childWon, isTrue);
    expect(s.stars, 3);
    expect(s.childToMove, isFalse);
    expect(s.computerToMove, isFalse);
    expect(s.canUndo, isFalse);
  });

  test('resigning loses with one star', () {
    final s = white();
    s.playChild(uci('e2e4'));
    s.resign();
    expect(s.result.outcome, GameOutcome.resignation);
    expect(s.result.winner, PieceColor.black);
    expect(s.childWon, isFalse);
    expect(s.stars, 1);
    expect(s.computerToMove, isFalse);
  });

  test('stalemate is a draw worth two stars', () {
    final s = MatchSession(
      childColor: PieceColor.white,
      start: Position.fromFen('7k/8/6Q1/8/8/8/8/K7 w - - 0 1'),
      random: Random(1),
    );
    s.playChild(uci('g6f7'));
    expect(s.result.outcome, GameOutcome.stalemate);
    expect(s.stars, 2);
    expect(s.childWon, isFalse);
  });

  test(
    'json round trip keeps position, colour, level, start and last move',
    () {
      final s = MatchSession(
        childColor: PieceColor.black,
        start: Position.fromFen('4k3/8/8/8/8/8/8/R3K3 w - - 0 1'),
        random: Random(1),
      );
      s.playComputer();
      final copy = MatchSession.fromJson(s.toJson(), random: Random(1));
      expect(copy.position, s.position);
      expect(copy.childColor, PieceColor.black);
      expect(copy.level, MatchLevel.easy);
      expect(copy.lastMove, s.lastMove);
      expect(copy.canUndo, isFalse);
      expect(s.toJson()['version'], 1);
      expect(s.toJson()['fen'], '4k3/8/8/8/8/8/8/R3K3 w - - 0 1');
      expect(white().toJson().containsKey('fen'), isFalse);
    },
  );

  test('the child colour follows the setting', () {
    expect(
      MatchSession.pickChildColor(ChildColor.white, Random(3)),
      PieceColor.white,
    );
    final seen = {
      for (var i = 0; i < 20; i++)
        MatchSession.pickChildColor(ChildColor.random, Random(i)),
    };
    expect(seen, {PieceColor.white, PieceColor.black});
  });

  test('the hint plays at the normal level whatever the profile level', () {
    for (final level in MatchLevel.values) {
      for (var seed = 0; seed < 40; seed++) {
        final s = MatchSession(
          childColor: PieceColor.white,
          level: level,
          // A free pawn: worth taking, but inside the very easy level's
          // window of "good enough" moves.
          start: Position.fromFen('4k3/8/8/3p4/8/8/8/3RK3 w - - 0 1'),
          random: Random(seed),
        );
        expect(s.hint(), uci('d1d5'), reason: '$level seed $seed');
      }
    }
    // A defended rook is left alone even when the computer itself is sloppy.
    for (var seed = 0; seed < 40; seed++) {
      final s = MatchSession(
        childColor: PieceColor.white,
        level: MatchLevel.veryEasy,
        start: Position.fromFen('3rk3/8/8/8/8/8/8/Q3K3 w - - 0 1'),
        random: Random(seed),
      );
      expect(s.hint(), isNot(uci('a1d8')), reason: 'seed $seed');
    }
  });
}
