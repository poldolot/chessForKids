import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

Position play(String fen, String uci) =>
    Position.fromFen(fen).play(Move.parseUci(uci));

void main() {
  test('simple move updates side, clocks and fullmove number', () {
    final p = Position.initial().play(Move.parseUci('g1f3'));
    expect(p.sideToMove, PieceColor.black);
    expect(p.halfmoveClock, 1);
    expect(p.fullmoveNumber, 1);
    expect(
      p.pieceAt(Square.parse('f3')),
      const Piece(PieceColor.white, PieceType.knight),
    );
    expect(p.pieceAt(Square.parse('g1')), isNull);
    final q = p.play(Move.parseUci('g8f6'));
    expect(q.fullmoveNumber, 2);
    expect(q.halfmoveClock, 2);
  });

  test('double pawn push sets en passant square, next move clears it', () {
    final p = Position.initial().play(Move.parseUci('e2e4'));
    expect(p.enPassant, Square.parse('e3'));
    expect(p.halfmoveClock, 0);
    expect(p.play(Move.parseUci('g8f6')).enPassant, isNull);
    expect(Position.initial().play(Move.parseUci('e2e3')).enPassant, isNull);
  });

  test('en passant capture removes the passed pawn', () {
    final p = play('8/8/8/3pP3/8/8/8/8 w - d6 0 1', 'e5d6');
    expect(p.pieceAt(Square.parse('d5')), isNull);
    expect(
      p.pieceAt(Square.parse('d6')),
      const Piece(PieceColor.white, PieceType.pawn),
    );
    expect(p.halfmoveClock, 0);
    final b = play('8/8/8/8/3Pp3/8/8/8 b - d3 0 1', 'e4d3');
    expect(b.pieceAt(Square.parse('d4')), isNull);
  });

  test('castling moves the rook and clears the rights', () {
    final p = play('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1', 'e1g1');
    expect(p.pieceAt(Square.parse('f1'))?.type, PieceType.rook);
    expect(p.pieceAt(Square.parse('g1'))?.type, PieceType.king);
    expect(p.pieceAt(Square.parse('h1')), isNull);
    expect(p.pieceAt(Square.parse('e1')), isNull);
    expect(p.castling.fen, 'kq');
    final q = play('r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 1', 'e8c8');
    expect(q.pieceAt(Square.parse('d8'))?.type, PieceType.rook);
    expect(q.pieceAt(Square.parse('a8')), isNull);
    expect(q.castling.fen, 'KQ');
  });

  test('king move without castling also clears both rights', () {
    expect(
      play('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1', 'e1e2').castling.fen,
      'kq',
    );
  });

  test('rook move and rook capture remove the matching right', () {
    expect(
      play('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1', 'h1h2').castling.fen,
      'Qkq',
    );
    expect(
      play('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1', 'a1a2').castling.fen,
      'Kkq',
    );
    expect(
      play('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1', 'a1a8').castling.fen,
      'Kk',
    );
  });

  test('promotion replaces the pawn and requires a piece', () {
    expect(
      play('8/4P3/8/8/8/8/8/8 w - - 0 1', 'e7e8q').pieceAt(Square.parse('e8')),
      const Piece(PieceColor.white, PieceType.queen),
    );
    expect(
      play(
        '3r4/4P3/8/8/8/8/8/8 w - - 0 1',
        'e7d8n',
      ).pieceAt(Square.parse('d8')),
      const Piece(PieceColor.white, PieceType.knight),
    );
    expect(
      () => play('8/4P3/8/8/8/8/8/8 w - - 0 1', 'e7e8'),
      throwsArgumentError,
    );
    expect(
      () => play('8/8/8/8/8/8/4P3/8 w - - 0 1', 'e2e3q'),
      throwsArgumentError,
    );
  });

  test('capture resets the halfmove clock', () {
    expect(play('8/8/8/3p4/3R4/8/8/8 w - - 7 1', 'd4d5').halfmoveClock, 0);
    expect(play('8/8/8/3p4/3R4/8/8/8 w - - 7 1', 'd4d1').halfmoveClock, 8);
  });

  test('moving a piece of the wrong color or an empty square throws', () {
    expect(
      () => Position.initial().play(Move.parseUci('e7e5')),
      throwsArgumentError,
    );
    expect(
      () => Position.initial().play(Move.parseUci('e3e4')),
      throwsArgumentError,
    );
  });
}
