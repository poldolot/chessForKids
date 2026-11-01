/// Movement offsets shared by attack detection and move generation.
///
/// Each entry is `(fileDelta, rankDelta)`.
library;

const List<(int, int)> orthogonalDirections = [
  (1, 0),
  (-1, 0),
  (0, 1),
  (0, -1),
];

const List<(int, int)> diagonalDirections = [
  (1, 1),
  (1, -1),
  (-1, 1),
  (-1, -1),
];

const List<(int, int)> royalDirections = [
  ...orthogonalDirections,
  ...diagonalDirections,
];

const List<(int, int)> knightJumps = [
  (1, 2),
  (2, 1),
  (2, -1),
  (1, -2),
  (-1, -2),
  (-2, -1),
  (-2, 1),
  (-1, 2),
];
