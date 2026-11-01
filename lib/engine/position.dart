import 'castling_rights.dart';
import 'piece.dart';
import 'square.dart';

/// FEN of the standard starting position.
const String kInitialFen =
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

/// An immutable chess position.
///
/// Positions without kings are valid: lessons and mini-games use them.
final class Position {
  Position({
    required List<Piece?> squares,
    required this.sideToMove,
    this.castling = CastlingRights.none,
    this.enPassant,
    this.halfmoveClock = 0,
    this.fullmoveNumber = 1,
  }) : assert(squares.length == 64),
       squares = List.unmodifiable(squares);

  factory Position.initial() => Position.fromFen(kInitialFen);

  factory Position.empty({PieceColor sideToMove = PieceColor.white}) =>
      Position(squares: List.filled(64, null), sideToMove: sideToMove);

  /// Parses a FEN string. Throws [FormatException] on malformed input.
  factory Position.fromFen(String fen) {
    final fields = fen.trim().split(RegExp(r'\s+'));
    if (fields.length != 6) {
      throw FormatException('FEN must have six fields', fen);
    }
    final ranks = fields[0].split('/');
    if (ranks.length != 8) {
      throw FormatException('FEN must have eight ranks', fen);
    }
    final squares = List<Piece?>.filled(64, null);
    for (var rank = 7; rank >= 0; rank--) {
      var file = 0;
      for (final char in ranks[7 - rank].split('')) {
        final digit = int.tryParse(char);
        if (digit != null) {
          file += digit;
        } else {
          if (file > 7) {
            throw FormatException('Too many squares in rank', fen);
          }
          squares[rank * 8 + file] = Piece.fromFenChar(char);
          file++;
        }
      }
      if (file != 8) {
        throw FormatException('Rank does not have eight squares', fen);
      }
    }
    final sideToMove = switch (fields[1]) {
      'w' => PieceColor.white,
      'b' => PieceColor.black,
      _ => throw FormatException('Invalid side to move', fen),
    };
    final enPassant = fields[3] == '-' ? null : Square.parse(fields[3]);
    final halfmove = int.tryParse(fields[4]);
    final fullmove = int.tryParse(fields[5]);
    if (halfmove == null || fullmove == null) {
      throw FormatException('Invalid move counters', fen);
    }
    return Position(
      squares: squares,
      sideToMove: sideToMove,
      castling: CastlingRights.fromFen(fields[2]),
      enPassant: enPassant,
      halfmoveClock: halfmove,
      fullmoveNumber: fullmove,
    );
  }

  /// Pieces by square index; `null` for empty squares. Unmodifiable.
  final List<Piece?> squares;

  /// The side that makes the next move.
  final PieceColor sideToMove;

  /// Castling rights still available.
  final CastlingRights castling;

  /// The square a pawn may capture onto en passant, if any.
  final Square? enPassant;

  /// Half-moves since the last pawn move or capture (fifty-move rule).
  final int halfmoveClock;

  /// Starts at 1 and increments after every black move.
  final int fullmoveNumber;

  /// The piece on [square], or `null` when empty.
  Piece? pieceAt(Square square) => squares[square.index];

  /// The king's square, or `null` when that side has no king.
  Square? kingSquare(PieceColor color) {
    final king = Piece(color, PieceType.king);
    for (var i = 0; i < 64; i++) {
      if (squares[i] == king) {
        return Square(i);
      }
    }
    return null;
  }

  /// All pieces on the board, optionally only those of one color.
  Iterable<(Square, Piece)> pieces([PieceColor? color]) sync* {
    for (var i = 0; i < 64; i++) {
      final piece = squares[i];
      if (piece != null && (color == null || piece.color == color)) {
        yield (Square(i), piece);
      }
    }
  }

  /// The position in FEN notation.
  String get fen {
    final buffer = StringBuffer();
    for (var rank = 7; rank >= 0; rank--) {
      var empty = 0;
      for (var file = 0; file < 8; file++) {
        final piece = squares[rank * 8 + file];
        if (piece == null) {
          empty++;
        } else {
          if (empty > 0) {
            buffer.write(empty);
            empty = 0;
          }
          buffer.write(piece.fenChar);
        }
      }
      if (empty > 0) {
        buffer.write(empty);
      }
      if (rank > 0) {
        buffer.write('/');
      }
    }
    buffer
      ..write(' ')
      ..write(sideToMove == PieceColor.white ? 'w' : 'b')
      ..write(' ')
      ..write(castling.fen)
      ..write(' ')
      ..write(enPassant?.name ?? '-')
      ..write(' $halfmoveClock $fullmoveNumber');
    return buffer.toString();
  }

  /// FEN without the move counters; equal keys mean a repeated position.
  ///
  /// The en passant square is included only when a pawn of the side to move
  /// could actually capture on it, so a double push nobody can answer does
  /// not make the position count as new (FIDE art. 9.2).
  String get repetitionKey {
    final full = fen;
    final key = full.substring(
      0,
      full.lastIndexOf(' ', full.lastIndexOf(' ') - 1),
    );
    final ep = enPassant;
    if (ep == null || _canCaptureEnPassant(ep)) {
      return key;
    }
    return '${key.substring(0, key.lastIndexOf(' ') + 1)}-';
  }

  bool _canCaptureEnPassant(Square ep) {
    final capturingRank = sideToMove == PieceColor.black
        ? ep.rank + 1
        : ep.rank - 1;
    final pawn = Piece(sideToMove, PieceType.pawn);
    for (final fileDelta in const [-1, 1]) {
      final file = ep.file + fileDelta;
      if (file >= 0 &&
          file < 8 &&
          pieceAt(Square.fromFileRank(file, capturingRank)) == pawn) {
        return true;
      }
    }
    return false;
  }

  /// Gives the move to the other side without playing anything.
  ///
  /// For mini-games with a passive opponent: the player moves again. Clears
  /// the en passant square (a stale one would allow a phantom capture) and
  /// leaves pieces, castling rights and clocks untouched.
  Position pass() =>
      copyWith(sideToMove: sideToMove.opposite, clearEnPassant: true);

  /// A copy with the given fields replaced. `clearEnPassant` removes the
  /// en passant square, which `enPassant: null` cannot express.
  Position copyWith({
    List<Piece?>? squares,
    PieceColor? sideToMove,
    CastlingRights? castling,
    Square? enPassant,
    bool clearEnPassant = false,
    int? halfmoveClock,
    int? fullmoveNumber,
  }) {
    return Position(
      squares: squares ?? this.squares,
      sideToMove: sideToMove ?? this.sideToMove,
      castling: castling ?? this.castling,
      enPassant: clearEnPassant ? null : (enPassant ?? this.enPassant),
      halfmoveClock: halfmoveClock ?? this.halfmoveClock,
      fullmoveNumber: fullmoveNumber ?? this.fullmoveNumber,
    );
  }

  /// A copy with [piece] placed on [square] (`null` clears the square).
  Position withPiece(Square square, Piece? piece) {
    final copy = List<Piece?>.of(squares);
    copy[square.index] = piece;
    return copyWith(squares: copy);
  }

  @override
  String toString() => fen;
}
