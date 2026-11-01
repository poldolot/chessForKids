import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

GameResult eval(String fen) => evaluatePosition(Position.fromFen(fen));
bool insufficient(String fen) => hasInsufficientMaterial(Position.fromFen(fen));

void main() {
  test('fools mate is checkmate for black', () {
    final r = eval(
      'rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3',
    );
    expect(r.outcome, GameOutcome.checkmate);
    expect(r.winner, PieceColor.black);
    expect(r.isOver, isTrue);
    expect(r.isDraw, isFalse);
  });

  test('stalemate is a draw', () {
    final r = eval('7k/5Q2/6K1/8/8/8/8/8 b - - 0 1');
    expect(r.outcome, GameOutcome.stalemate);
    expect(r.isDraw, isTrue);
    expect(r.winner, isNull);
  });

  test('ongoing position', () {
    final r = eval(kInitialFen);
    expect(r, GameResult.ongoing);
    expect(r.isOver, isFalse);
    expect(r.isDraw, isFalse);
  });

  test('insufficient material cases', () {
    expect(insufficient('4k3/8/8/8/8/8/8/4K3 w - - 0 1'), isTrue);
    expect(insufficient('4k3/8/8/8/8/8/8/4KB2 w - - 0 1'), isTrue);
    expect(insufficient('4k3/8/8/8/8/8/8/4KN2 w - - 0 1'), isTrue);
    expect(insufficient('4kb2/8/8/8/8/8/8/4KB2 w - - 0 1'), isFalse);
    expect(insufficient('2b1k3/8/8/8/8/8/8/4KB2 w - - 0 1'), isTrue);
    expect(insufficient('4k3/8/8/8/8/8/4P3/4K3 w - - 0 1'), isFalse);
    expect(insufficient('4k3/8/8/8/8/8/8/4KNN1 w - - 0 1'), isFalse);
    expect(insufficient('4k3/8/8/8/8/8/8/R3K3 w - - 0 1'), isFalse);
    expect(insufficient('8/pppppppp/8/8/8/8/PPPPPPPP/8 w - - 0 1'), isFalse);
  });

  test('insufficient material ends the game as a draw', () {
    expect(
      eval('4k3/8/8/8/8/8/8/4KN2 w - - 0 1').outcome,
      GameOutcome.insufficientMaterial,
    );
  });

  test('fifty-move rule at halfmove clock 100', () {
    expect(
      eval('4k3/8/8/8/8/8/8/R3K3 w - - 100 80').outcome,
      GameOutcome.fiftyMoveRule,
    );
    expect(
      eval('4k3/8/8/8/8/8/8/R3K3 w - - 99 80').outcome,
      GameOutcome.ongoing,
    );
  });

  test('checkmate takes precedence over the fifty-move rule', () {
    expect(
      eval('rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 100 3')
          .outcome,
      GameOutcome.checkmate,
    );
  });

  test(
    'kingless side with no moves is reported as stalemate, never checkmate',
    () {
      expect(
        eval('8/8/8/8/8/p7/P7/8 w - - 0 1').outcome,
        GameOutcome.stalemate,
      );
    },
  );
}
