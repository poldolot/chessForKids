import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

Game g([String? fen]) =>
    Game(start: fen == null ? null : Position.fromFen(fen));

void playUci(Game game, String sequence) {
  for (final uci in sequence.split(' ')) {
    game.play(Move.parseUci(uci));
  }
}

void main() {
  test('plays legal moves and rejects illegal ones', () {
    final game = g();
    playUci(game, 'e2e4 e7e5');
    expect(game.moves.length, 2);
    expect(game.history.length, 3);
    expect(game.position.sideToMove, PieceColor.white);
    expect(() => game.play(Move.parseUci('e4e5')), throwsArgumentError);
    expect(game.moves.length, 2);
  });

  test('legalMoves and isCheck reflect the current position', () {
    final game = g('4k3/8/8/8/8/8/4r3/4K3 w - - 0 1');
    expect(game.isCheck, isTrue);
    expect(game.legalMoves().map((m) => m.uci).toList()..sort(), [
      'e1d1',
      'e1e2',
      'e1f1',
    ]);
    expect(game.legalMoves(from: Square.parse('e1')).length, 3);
  });

  test('undo restores the previous position', () {
    final game = g();
    playUci(game, 'e2e4');
    expect(game.undo(), Move.parseUci('e2e4'));
    expect(game.position.fen, kInitialFen);
    expect(game.history.length, 1);
    expect(game.moves, isEmpty);
    expect(game.undo(), isNull);
  });

  test('threefold repetition is a draw', () {
    final game = g();
    playUci(game, 'g1f3 g8f6 f3g1 f6g8 g1f3 g8f6 f3g1');
    expect(game.result.outcome, GameOutcome.ongoing);
    playUci(game, 'f6g8');
    expect(game.result.outcome, GameOutcome.threefoldRepetition);
    expect(game.result.isDraw, isTrue);
  });

  test('repetition key includes castling rights', () {
    final game = g('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1');
    playUci(game, 'e1e2 e8e7 e2e1 e7e8 e1e2 e8e7 e2e1 e7e8');
    expect(game.result.outcome, GameOutcome.ongoing);
  });

  test('repetition after an unusable double push is counted from the push', () {
    final game = g();
    playUci(game, 'e2e4 g8f6 g1f3 f6g8 f3g1 g8f6 g1f3 f6g8');
    expect(game.result.outcome, GameOutcome.ongoing);
    playUci(game, 'f3g1');
    expect(game.result.outcome, GameOutcome.threefoldRepetition);
  });

  test('checkmate ends the game and play throws afterwards', () {
    final game = g();
    playUci(game, 'f2f3 e7e5 g2g4 d8h4');
    expect(game.result.outcome, GameOutcome.checkmate);
    expect(game.result.winner, PieceColor.black);
    expect(() => game.play(Move.parseUci('a2a3')), throwsStateError);
  });

  test('undo after game over reopens the game', () {
    final game = g();
    playUci(game, 'f2f3 e7e5 g2g4 d8h4');
    game.undo();
    expect(game.result.isOver, isFalse);
  });

  test('resignation gives the win to the other side and can be undone', () {
    final game = g();
    game.resign(PieceColor.white);
    expect(game.result.outcome, GameOutcome.resignation);
    expect(game.result.winner, PieceColor.black);
    expect(() => game.resign(PieceColor.black), throwsStateError);
    expect(() => game.play(Move.parseUci('e2e4')), throwsStateError);
    playUci(g(), 'e2e4');
    final resigned = g();
    playUci(resigned, 'e2e4');
    resigned.resign(PieceColor.black);
    expect(resigned.undo(), Move.parseUci('e2e4'));
    expect(resigned.result.isOver, isFalse);
  });

  test('rules are passed through to move generation', () {
    final game = Game(
      start: Position.fromFen('8/8/8/3pP3/8/8/8/8 w - d6 0 1'),
      rules: const GameRules(enPassant: false),
    );
    expect(game.legalMoves(from: Square.parse('e5')).map((m) => m.uci), [
      'e5e6',
    ]);
    expect(game.rules.enPassant, isFalse);
  });

  test('history is not modifiable from outside', () {
    final game = g();
    expect(() => game.history.add(Position.initial()), throwsUnsupportedError);
    expect(() => game.moves.add(Move.parseUci('e2e4')), throwsUnsupportedError);
  });
}
