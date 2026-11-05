# Changelog

All notable changes to Chess for Kids are listed here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.2.0] - 2026-11-05

### Changed
- Menu greeting now says what to do: "Hi, NAME! Pick a lesson, a mini-game
  or a match."
- Teacher bubbles are lighter, with smaller text; avatars have no disc
  behind them.
- A lesson's first explanation holds the Next button until it has been
  spoken (first visit only, with a 20 s safety limit).
- Pawn lesson: the practice task ends as soon as every black pawn is taken,
  and no pawn task offers a promotion.
- Pawn War has three levels (3, 5 and 8 black pawns); on the easy ones the
  opponent plays carelessly, so a five-year-old can win.
- Capture squares show the move dot as well as the frame, in every lesson
  and game.
- The lesson path is tighter and shows a bouncing arrow while more lessons
  hide below the screen.

### Added
- Computer level per profile in the parent zone (very easy, easy, normal);
  match hints always use the normal level.
- Badge names and meanings: tapping a badge says what it is for; a badge
  list screen.
- The system back button on the menu returns to the profiles.

## [0.1.1] - 2026-11-01

### Changed
- Match hints always come from the normal computer level, however easy the
  child's opponent is set, so a hint is never a careless move.

### Added
- This changelog.

## [0.1.0] - 2026-11-01

First complete version for local testing (debug-signed APK).

### Added
- Child profiles with a name, a teacher theme (animals, robots, UFO, vehicles)
  and an avatar; everything is spoken by the system text-to-speech engine in
  Polish or English, nothing has to be read.
- Learn: 14 lessons (six pieces, eight rules) with stars, badges and spoken
  guidance; boards without kings for piece lessons.
- Mini-games: Pawn War, Rook Roads, Bishop Tracks, King Race and The Hunt, each
  with five difficulty levels; boards are generated and checked at play time,
  "Again" gives a fresh board, "Next level" moves on.
- Match against a simple computer (full FIDE rules, hints, undo, resign, saved
  and resumed games, stars and badges); computer level per profile: very easy,
  easy, normal.
- Twelve badges with names and meanings, a badge list screen.
- Parent zone: profiles, language, voice and speech rate, board and app colours,
  the child's colour, computer level, unlocking all mini-games.
- Pure Dart chess engine with perft-verified move generation.
- GitHub Actions: analysis, tests and an APK on every push; the APK is attached
  to the release for `v*` tags.

[Unreleased]: https://github.com/poldolot/chessForKids/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/poldolot/chessForKids/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/poldolot/chessForKids/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/poldolot/chessForKids/releases/tag/v0.1.0
