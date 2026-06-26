import 'dart:ui';

import '../../core/economy/performance_tier.dart';
import '../../core/l10n/l10n_scope.dart';
import 'memory_symbols.dart';

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

  /// Paleta alinhada ao card do hub (`HubTheme` id `memory`).
  static const cardColor = Color(0xFF5B4BB7);
  static const accentColor = Color(0xFFFF7675);
  static const blendColor = Color(0xFFBF6289);
  static const accentSoft = Color(0xFFFF9A99);
  static const faceFront = Color(0xFFF5F0E8);
  static const bgTop = Color(0xFF3D3489);
  static const bgBottom = Color(0xFF2A2468);
  static const cardBorder = Color(0xFFFFFFFF);
  static const missRed = Color(0xFFFF7675);
  static const matchGlow = Color(0xFFFDCB6E);
  static const hudText = Color(0xFFF8F9FA);
  static const hudMuted = Color(0xFFD4CFF0);

  static const flipDurationSec = 0.22;
  static const shakeDurationSec = 0.35;
  static const mismatchViewSec = 0.65;
  static const matchSettleSec = 0.28;

  static const symbolPool = [
    MemorySymbolId.gamepad,
    MemorySymbolId.target,
    MemorySymbolId.dice,
    MemorySymbolId.palette,
    MemorySymbolId.mask,
    MemorySymbolId.guitar,
    MemorySymbolId.rocket,
    MemorySymbolId.balloon,
    MemorySymbolId.star,
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

/// Variação do placar após uma jogada (para FX e testes).
int memoryProgressScoreDelta({
  required int previousScore,
  required int pairsFound,
  required int moves,
}) {
  return memoryProgressScore(pairsFound: pairsFound, moves: moves) -
      previousScore;
}

/// Bônus de tempo restante no momento da partida (preview no HUD).
int memoryTimeBonusRemaining(Duration elapsed) {
  final elapsedSec = elapsed.inSeconds;
  return (MemoryConfig.timeBonusMax -
          elapsedSec * MemoryConfig.timeBonusPerSecond)
      .clamp(0, MemoryConfig.timeBonusMax);
}

/// Razão `0..1` do bônus de tempo ainda disponível.
double memoryTimeBonusRatio(Duration elapsed) =>
    memoryTimeBonusRemaining(elapsed) / MemoryConfig.timeBonusMax;

/// Timer do HUD (`m:ss`).
String memoryFormatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Nota do HUD para a coluna de tempo (`+160 tempo` ou vazio).
String? memoryHudTimeBonusFootnote(Duration elapsed) {
  final bonus = memoryTimeBonusRemaining(elapsed);
  if (bonus <= 0) return null;
  return L10nScope.of.hudTimeBonus(bonus);
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

/// Desempenho normalizado (`0.0`–`1.0`) pela eficiência de jogadas.
///
/// `1.0` = partida perfeita (uma jogada por par); cai conforme jogadas extras
/// até `pairCount * 2.5` jogadas (ineficiente) chegar a `0.0`.
double memoryPerformanceRatio({
  required int pairCount,
  required int moves,
  required int perfectBonus,
}) {
  if (perfectBonus > 0) return 1.0;
  final perfectMoves = pairCount;
  final worstMoves = (pairCount * 2.5).round();
  if (moves <= perfectMoves) return 1.0;
  final span = worstMoves - perfectMoves;
  if (span <= 0) return 1.0;
  return ((worstMoves - moves) / span).clamp(0.0, 1.0);
}

/// Faixa de desempenho para recompensa da sessão.
PerformanceTier memoryPerformanceTier({
  required int pairCount,
  required int moves,
  required int perfectBonus,
}) =>
    tierFromRatio(memoryPerformanceRatio(
      pairCount: pairCount,
      moves: moves,
      perfectBonus: perfectBonus,
    ));
