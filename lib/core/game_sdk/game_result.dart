/// Resultado final de uma partida.
class GameResult {
  const GameResult({
    required this.score,
    required this.duration,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.metadata = const {},
  });

  final int score;
  final Duration duration;
  final int coinsEarned;
  final int xpEarned;
  final Map<String, Object?> metadata;
}
