# Changelog

All notable changes to Chess for Kids are listed here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.3.1] - 2026-11-11

### Changed
- The "how it moves" and "how it captures" steps of the piece lessons end
  with a clear instruction ("Try it: make three moves", "Capture the two
  black pawns").
- Pawn War says how the board ended: a pawn reached the end, or one side
  had no move left and whoever cannot move loses.

## [0.3.0] - 2026-11-11

### Added
- Opening lesson "What chess is", first on the Learn path: two armies, the
  pieces lit up one group at a time, find the kings, taking turns, capturing,
  a whole short game to checkmate with an explanation of why the king cannot
  escape, and the child plays the mating move. 15 lessons, 45 stars in all.
- Two new lesson step types: "look here" (parts of a position light up with
  their own line) and "find it" (tap the asked squares in order).
- A blinking cursor in the answer field of the parent gate.

### Changed
- Demos and narrated steps wait for the teacher to finish talking before the
  next move or part; the Next button also waits for the closing words of a
  step on the first visit.
- The teacher bubble keeps a minimum height and every board step shares the
  same strip under the board, so the board stays in one place between steps.
- A lesson once finished never locks again, even when a new lesson is placed
  before it on the path.

### Fixed
- Two demos in a row no longer share state: the second one starts from its
  own position.
- The speech engine no longer reports silence for a moment while one line is
  replaced by the next, which let demos run ahead of the voice.

## [0.2.3] - 2026-11-05

### Changed
- The parent zone button is a gear instead of a lock.
- The version shown in the parent zone follows the real one (a test keeps it
  equal to pubspec.yaml).
- The result card after a match or a mini-game sits above the board on tall
  screens; on short screens it lies over the board and a tap closes it.
- The Partia tile earns its first star with the first finished match, the
  second at 10 points and the third at 30.

### Added
- Every menu tile shows a progress bar and an "earned/total" counter under
  its stars.

## [0.2.2] - 2026-11-05

### Changed
- Lesson tasks show every legal move of the chosen piece, even the ones the
  task does not accept (for example plain steps in a capture task); tapping
  one is explained by the hint.
- The set-up lesson keeps the tray at full height, so the board no longer
  jumps as the tray empties.
- Pawn lesson: a pawn reaching the last rank becomes a queen without a
  choice, and the teacher says it will be explained in the promotion lesson.
- A lesson's first line starts with the lesson's name.
- Castling is shown slowly in two steps: the king first, then the rook; in a
  match the computer waits for the animation before replying.
- Every lesson is played as white (the check defences used to be black).
- A coloured queen (gold crown, red jewels, grey base) stands for the
  profiles: on the profile screen next to "Choose a profile or add a new
  one." and in the menu as the way back to it; the menu bubble shows the
  child's own avatar.

## [0.2.1] - 2026-11-05

### Changed
- The lesson celebration names the badge it announces: "You earned a new
  badge: Rook!"
- The lesson path winds tighter: each icon starts a fifth of the way up the
  previous one.

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

[Unreleased]: https://github.com/poldolot/chessForKids/compare/v0.3.1...HEAD
[0.3.1]: https://github.com/poldolot/chessForKids/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/poldolot/chessForKids/compare/v0.2.3...v0.3.0
[0.2.3]: https://github.com/poldolot/chessForKids/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/poldolot/chessForKids/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/poldolot/chessForKids/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/poldolot/chessForKids/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/poldolot/chessForKids/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/poldolot/chessForKids/releases/tag/v0.1.0
