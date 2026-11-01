/// Strength of the computer opponent. Only one level ships in v1; the
/// match code takes the level as a parameter so more can be added later.
enum MatchLevel {
  easy(depth: 2, noise: 60);

  const MatchLevel({required this.depth, required this.noise});

  /// Search depth in plies.
  final int depth;

  /// Window in centipawns below the best score; any root move inside it may
  /// be played, which keeps the computer human and a little unpredictable.
  final int noise;
}
