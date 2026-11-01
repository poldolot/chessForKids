import 'package:chess_for_kids/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fen round-trip', () {
    expect(CastlingRights.fromFen('KQkq'), CastlingRights.all);
    expect(CastlingRights.fromFen('-'), CastlingRights.none);
    expect(CastlingRights.fromFen('Kq').fen, 'Kq');
    expect(CastlingRights.none.fen, '-');
  });

  test('without removes only the requested rights', () {
    final r = CastlingRights.all.without(
      color: PieceColor.white,
      queenSide: false,
    );
    expect(r.kingSide(PieceColor.white), isFalse);
    expect(r.queenSide(PieceColor.white), isTrue);
    expect(r.fen, 'Qkq');
    expect(CastlingRights.all.without(color: PieceColor.black).fen, 'KQ');
    expect(CastlingRights.all.without().fen, '-');
  });
}
