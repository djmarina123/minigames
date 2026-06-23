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
