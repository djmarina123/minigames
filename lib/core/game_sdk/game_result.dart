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

/// Vitória/derrota explícita quando o jogo grava `metadata['won']`.
/// `null` = sem resultado binário (arcade por pontos, ou só completa ao vencer).
bool? gameResultOutcomeWon(Map<String, Object?> metadata) {
  final value = metadata['won'];
  if (value == true) return true;
  if (value == false) return false;
  return null;
}
