import 'performance_tier.dart';

/// Constantes da economia global do hub.
abstract final class EconomyConfig {
  /// Moedas base ao concluir uma partida.
  static const sessionCoinBase = 8;

  /// Bônus de moedas por faixa de desempenho.
  static const sessionCoinBonusSilver = 4;
  static const sessionCoinBonusGold = 8;

  /// Bônus por novo recorde pessoal no jogo.
  static const sessionCoinNewRecord = 10;

  /// Teto de moedas ganhas numa partida (sem contar ad).
  static const sessionCoinCap = 20;

  /// XP base por partida concluída.
  static const sessionXpBase = 20;

  static const sessionXpBonusSilver = 5;
  static const sessionXpBonusGold = 10;
  static const sessionXpNewRecord = 15;
  static const sessionXpFirstGameToday = 10;

  static const sessionXpCap = 45;

  /// Recompensa diária: 15 + 3 × streak (streak limitado a 30 dias).
  static const dailyCoinBase = 15;
  static const dailyCoinPerStreakDay = 3;
  static const dailyStreakCap = 30;

  /// Dica paga no Sudoku.
  static const hintCoinCostSudoku = 25;

  /// Dica paga no Cross Sums.
  static const hintCoinCostCrossSums = 25;

  /// Dica paga na Paciência (destaca uma jogada válida).
  static const hintCoinCostSolitaire = 20;

  /// Dica paga no Campo Minado (revela célula segura).
  static const hintCoinCostMinesweeper = 20;

  /// Saldo inicial para novos jogadores (cobre algumas dicas).
  static const startingCoins = 50;

  static int tierCoinBonus(PerformanceTier tier) => switch (tier) {
        PerformanceTier.gold => sessionCoinBonusGold,
        PerformanceTier.silver => sessionCoinBonusSilver,
        PerformanceTier.bronze => 0,
      };

  static int tierXpBonus(PerformanceTier tier) => switch (tier) {
        PerformanceTier.gold => sessionXpBonusGold,
        PerformanceTier.silver => sessionXpBonusSilver,
        PerformanceTier.bronze => 0,
      };

  static int dailyRewardForStreak(int streak) =>
      dailyCoinBase +
      dailyCoinPerStreakDay * streak.clamp(1, dailyStreakCap);
}
