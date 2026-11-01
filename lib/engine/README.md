# Engine

Pure Dart chess rules. Nothing in this directory imports Flutter, so the
engine can be unit-tested and reused as is.

## Layout

| File | Responsibility |
|---|---|
| `square.dart` | `Square`: index 0..63, `index = rank * 8 + file`; a1 = 0, h1 = 7, a8 = 56, h8 = 63 |
| `piece.dart` | `PieceColor`, `PieceType` (with material values), `Piece`, FEN letters |
| `move.dart` | `Move(from, to, {promotion})`, UCI notation |
| `castling_rights.dart` | `CastlingRights` |
| `position.dart` | Immutable `Position`, FEN parsing and printing |
| `attacks.dart` | `isSquareAttacked`, `isInCheck` |
| `move_generator.dart` | `GameRules`, `pseudoLegalMoves`, `legalMoves` |
| `apply_move.dart` | `Position.play(Move)` |
| `outcome.dart` | `GameOutcome`, `GameResult`, `evaluatePosition`, `hasInsufficientMaterial` |
| `game.dart` | `Game`: history, undo, repetition, resignation |
| `perft.dart` | `perft` node counter for verification |

Import everything through `engine.dart`.

## Conventions

- Positions are immutable. `position.play(move)` returns a new position and
  never validates legality; use `legalMoves` (or `Game.play`) for that.
- Castling is a king move of two files; en passant is a diagonal pawn move
  onto the empty en passant square. Neither is flagged on `Move`.
- Boards without kings are valid. A side with no king is never in check and
  all of its pseudo-legal moves are legal. Lessons and mini-games rely on this.
- A passive opponent (king race, piece paths, the hunt) is modelled by calling
  `position.pass()` after the player's move: it hands the turn back and clears
  the en passant square. Never flip `sideToMove` with `copyWith` for this.
- `isSquareAttacked` is public on purpose: the king-race mini-game uses it to
  mark squares the king may not enter.
- `GameRules` can switch en passant and castling off for lessons that have
  not introduced them yet.
- Draws by threefold repetition and by the fifty-move rule are automatic.

## Verification

`test/engine/perft_test.dart` compares the move generator with published
perft values (start position to depth 4, Kiwipete and three further
positions to depth 3 or 4). Run `flutter test test/engine`.
