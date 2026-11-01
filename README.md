# Chess for Kids

A free, offline chess tutor for children aged 5 and up who cannot read yet.
Everything is driven by pictures and voice: no text is ever required to navigate.

Polish version: [README.pl.md](README.pl.md)

## What it will do

- **Learn** – one lesson per piece (pawn, rook, bishop, queen, king, knight), then the
  rules: setup, check, checkmate, stalemate, castling, en passant, promotion.
- **Mini-games** – Pawn War, Rook Roads, Bishop Tracks, King Race, The Hunt.
- **Play** – a full game against a deliberately gentle computer opponent.
- Stars, progress bars and badges; several child profiles on one device.
- Fully offline. No accounts, no analytics, no ads, no network permission.

## Tech

Flutter (Android first, iOS-ready), with a custom chess engine written in Dart so that
lessons can use boards without kings. Speech via the system text-to-speech engine,
with recorded voice planned later. Polish and English at launch.

## Status

App shell ready: profiles, main menu, parent zone, speech, Polish and English, and
an interactive board widget. The chess rules engine is complete and tested. Lessons,
mini-games and the computer opponent come next.

## License

MIT, see [LICENSE](LICENSE).
