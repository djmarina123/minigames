/// Constantes e regras de pontuação do Jogo da Memória.
abstract final class MemoryConfig {
  static const optionKeyPairCount = 'pairCount';

  /// Pontos base por par encontrado.
  static const pointsPerPair = 150;

  /// Penalidade por jogada (cada tentativa de par).
  static const penaltyPerMove = 10;

  /// Bônus máximo por terminar rápido.
  static const timeBonusMax = 200;

  /// Perde bônus a cada segundo decorrido.
  static const timeBonusPerSecond = 4;

  /// Partida perfeita: todos os pares no mínimo de jogadas.
  static const perfectGameBonus = 100;

  static const maxScore = 9999;

  static const symbolPool = [
    '🎮',
    '🎯',
    '🎲',
    '🎪',
    '🎨',
    '🎭',
    '🎸',
    '🚀',
  ];
}

/// Layout do grid conforme quantidade de pares.
(int cols, int rows) memoryGridForPairs(int pairCount) {
  return switch (pairCount) {
    <= 4 => (4, 2),
    <= 6 => (4, 3),
    _ => (4, (pairCount / 2).ceil().clamp(2, 4)),
  };
}

/// Resultado detalhado da pontuação (útil no placar final).
class MemoryScoreBreakdown {
  const MemoryScoreBreakdown({
    required this.score,
    required this.basePoints,
    required this.movePenalty,
    required this.timeBonus,
    required this.perfectBonus,
  });

  final int score;
  final int basePoints;
  final int movePenalty;
  final int timeBonus;
  final int perfectBonus;
}

/// Placar parcial durante a partida (sem bônus de tempo/perfeição).
int memoryProgressScore({
  required int pairsFound,
  required int moves,
}) {
  final base = pairsFound * MemoryConfig.pointsPerPair;
  final penalty = moves * MemoryConfig.penaltyPerMove;
  return (base - penalty).clamp(0, MemoryConfig.maxScore);
}

/// Pontuação final ao completar o tabuleiro.
MemoryScoreBreakdown memoryFinalScore({
  required int pairCount,
  required int pairsFound,
  required int moves,
  required Duration duration,
}) {
  final base = pairsFound * MemoryConfig.pointsPerPair;
  final penalty = moves * MemoryConfig.penaltyPerMove;
  final elapsedSec = duration.inSeconds;
  final timeBonus = (MemoryConfig.timeBonusMax -
          elapsedSec * MemoryConfig.timeBonusPerSecond)
      .clamp(0, MemoryConfig.timeBonusMax);
  final perfectBonus = pairsFound == pairCount && moves == pairCount
      ? MemoryConfig.perfectGameBonus
      : 0;
  final score = (base - penalty + timeBonus + perfectBonus)
      .clamp(0, MemoryConfig.maxScore);

  return MemoryScoreBreakdown(
    score: score,
    basePoints: base,
    movePenalty: penalty,
    timeBonus: timeBonus,
    perfectBonus: perfectBonus,
  );
}
