import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  passTests();

  test('initial position matches the start FEN', () {
    final p = Position.initial();
    expect(p.fen, kInitialFen);
    expect(
      p.pieceAt(Square.parse('e1')),
      const Piece(PieceColor.white, PieceType.king),
    );
    expect(
      p.pieceAt(Square.parse('d8')),
      const Piece(PieceColor.black, PieceType.queen),
    );
    expect(p.pieces().length, 32);
    expect(p.pieces(PieceColor.black).length, 16);
    expect(p.kingSquare(PieceColor.black), Square.parse('e8'));
  });

  test('fen round-trips including en passant and clocks', () {
    const fen = 'rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 3';
    expect(Position.fromFen(fen).fen, fen);
    expect(Position.fromFen(fen).enPassant, Square.parse('d6'));
    expect(Position.fromFen(fen).fullmoveNumber, 3);
  });

  test('kingless position is valid and kingSquare is null', () {
    final p = Position.fromFen('8/pppppppp/8/8/8/8/PPPPPPPP/8 w - - 0 1');
    expect(p.kingSquare(PieceColor.white), isNull);
    expect(p.pieces().length, 16);
  });

  test('empty position has no pieces', () {
    expect(Position.empty().pieces(), isEmpty);
    expect(
      Position.empty(sideToMove: PieceColor.black).fen,
      '8/8/8/8/8/8/8/8 b - - 0 1',
    );
  });

  test('invalid fens throw', () {
    expect(
      () => Position.fromFen('8/8/8/8/8/8/8 w - - 0 1'),
      throwsFormatException,
    );
    expect(
      () => Position.fromFen('9/8/8/8/8/8/8/8 w - - 0 1'),
      throwsFormatException,
    );
    expect(
      () => Position.fromFen('8/8/8/8/8/8/8/8 x - - 0 1'),
      throwsFormatException,
    );
    expect(
      () => Position.fromFen('7z/8/8/8/8/8/8/8 w - - 0 1'),
      throwsFormatException,
    );
    expect(() => Position.fromFen('8/8/8/8/8/8/8/8 w'), throwsFormatException);
  });

  test('repetitionKey ignores clocks', () {
    final a = Position.fromFen(kInitialFen.replaceFirst('0 1', '5 9'));
    expect(a.repetitionKey, Position.initial().repetitionKey);
    expect(a.fen, isNot(Position.initial().fen));
  });

  test('withPiece and copyWith do not mutate the original', () {
    final p = Position.initial();
    final q = p.withPiece(Square.parse('e2'), null);
    expect(p.pieceAt(Square.parse('e2')), isNotNull);
    expect(q.pieceAt(Square.parse('e2')), isNull);
    final withEp = p.copyWith(enPassant: Square.parse('e3'));
    expect(withEp.enPassant, Square.parse('e3'));
    expect(withEp.copyWith(clearEnPassant: true).enPassant, isNull);
    expect(
      p.copyWith(sideToMove: PieceColor.black).sideToMove,
      PieceColor.black,
    );
  });
}

void passTests() {
  test('positions with the same content are equal', () {
    expect(Position.fromFen(kInitialFen), Position.initial());
    expect(Position.fromFen(kInitialFen).hashCode, Position.initial().hashCode);
    expect(
      Position.initial(),
      isNot(Position.initial().play(Move.parseUci('e2e4'))),
    );
    expect(
      Position.initial(),
      isNot(Position.initial().copyWith(sideToMove: PieceColor.black)),
    );
  });

  test('pass flips the side to move and clears the en passant square', () {
    final afterE4 = Position.initial().play(Move.parseUci('e2e4'));
    final passed = afterE4.pass();
    expect(passed.sideToMove, PieceColor.white);
    expect(passed.enPassant, isNull);
    expect(passed.squares, afterE4.squares);
    expect(passed.castling, afterE4.castling);
    expect(legalMoves(passed, from: Square.parse('d2')).map((m) => m.uci), [
      'd2d3',
      'd2d4',
    ]);
  });

  test('repetitionKey drops an en passant square no pawn can use', () {
    final afterE4 = Position.initial().play(Move.parseUci('e2e4'));
    final sameWithoutEp = Position.fromFen(
      afterE4.fen.replaceFirst(' e3 ', ' - '),
    );
    expect(afterE4.repetitionKey, sameWithoutEp.repetitionKey);
    final capturable = Position.fromFen(
      'rnbqkbnr/ppp1pppp/8/8/3pP3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 2',
    );
    final capturableWithoutEp = Position.fromFen(
      capturable.fen.replaceFirst(' e3 ', ' - '),
    );
    expect(capturable.repetitionKey, isNot(capturableWithoutEp.repetitionKey));
  });
}
