/// Faixa de desempenho numa partida — usada para calcular moedas e XP.
enum PerformanceTier {
  bronze,
  silver,
  gold;

  static PerformanceTier fromName(String? name) => switch (name) {
        'gold' => PerformanceTier.gold,
        'silver' => PerformanceTier.silver,
        _ => PerformanceTier.bronze,
      };
}

/// Régua única de desempenho do hub.
///
/// Cada jogo converte a partida num desempenho normalizado em `[0, 1]`
/// (1.0 = partida excelente/ótima para aquele jogo) e delega a [tierFromRatio].
/// Assim "ouro" significa o mesmo nível de excelência em todos os jogos, e a
/// moeda paga por faixa ([EconomyConfig]) fica justa entre jogos diferentes.
///
/// Calibração-alvo (referência para ajustar os limiares de cada jogo):
/// ouro ≈ top 10–15% das partidas, prata ≈ os ~30% seguintes, bronze = o resto.
abstract final class TierRubric {
  /// Desempenho `>=` este valor concede ouro.
  static const goldRatio = 0.85;

  /// Desempenho `>=` este valor concede prata.
  static const silverRatio = 0.55;
}

/// Converte um desempenho normalizado (`0.0`–`1.0`) na faixa do hub.
PerformanceTier tierFromRatio(double performance) {
  if (performance >= TierRubric.goldRatio) return PerformanceTier.gold;
  if (performance >= TierRubric.silverRatio) return PerformanceTier.silver;
  return PerformanceTier.bronze;
}
