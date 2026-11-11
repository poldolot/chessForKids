# Chess for Kids

A free, offline chess tutor for children aged 5 and up who cannot read yet.
Everything is driven by pictures and voice: no text is ever required to navigate.

Polish version: [README.pl.md](README.pl.md)

## What it will do

- **Learn** – an opening story about what chess is (two armies, the king, taking
  turns, capturing, a whole short game to checkmate), one lesson per piece (pawn,
  rook, bishop, queen, king, knight), then the rules: setup, check, checkmate,
  stalemate, castling, en passant, promotion, piece values.
- **Mini-games** – Pawn War, Rook Roads, Bishop Tracks, King Race, The Hunt.
- **Play** – a full game against a deliberately gentle computer opponent.
- Stars, progress bars and badges; several child profiles on one device.
- Fully offline. No accounts, no analytics, no ads, no network permission.

## Tech

Flutter (Android first, iOS-ready), with a custom chess engine written in Dart so that
lessons can use boards without kings. Speech via the system text-to-speech engine,
with recorded voice planned later. Polish and English at launch.

## Status

All three sections of v1 are in place: Learn (15 lessons), Mini-games (five games with five generated levels each: every board is drawn fresh and checked to be solvable) and
Match against a simple computer opponent (full FIDE rules, hints, undo, resign, saved
and resumed games, stars and badges), with spoken guidance in Polish and English on top
of the app shell (profiles, menu, parent zone) and a tested chess rules engine. Next:
polish, sounds and a release build.

## License

MIT, see [LICENSE](LICENSE).
