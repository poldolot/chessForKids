# Changelog

All notable changes to Chess for Kids are listed here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

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

[Unreleased]: https://github.com/poldolot/chessForKids/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/poldolot/chessForKids/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/poldolot/chessForKids/releases/tag/v0.1.0
