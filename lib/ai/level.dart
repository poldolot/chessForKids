/// Strength of the computer opponent. The match code takes the level as a
/// parameter so a picker can be added later without touching the engine.
enum MatchLevel {
  /// For a beginner child: shallow, a wide window of "good enough" moves
  /// and a real chance of a careless move, but it still takes a mate in
  /// one and never walks into one it could avoid.
  easy(depth: 2, noise: 100, blunder: 0.25),

  /// Steady play within a narrow window; no careless moves.
  normal(depth: 2, noise: 60, blunder: 0);

  const MatchLevel({
    required this.depth,
    required this.noise,
    required this.blunder,
  });

  /// Search depth in plies.
  final int depth;

  /// Window in centipawns below the best score; any root move inside it may
  /// be played, which keeps the computer human and a little unpredictable.
  final int noise;

  /// Chance (0..1) of playing a random move that does not allow an
  /// immediate mate, instead of searching.
  final double blunder;
}
