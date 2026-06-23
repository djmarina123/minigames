/// Textos PT-BR da economia global (hub).
abstract final class EconomyCopy {
  static const helpTitle = 'Moedas e XP';

  static const profileSummary =
      'Jogue partidas para ganhar XP, subir de nível e receber moedas bônus.';

  static const howItWorks = [
    'Moedas — ganhe ao terminar partidas, no login diário e ao subir de nível. '
        'Use em dicas (Sudoku, Paciência) e, no futuro, em cosméticos.',
    'XP — sobe a cada partida conforme seu desempenho. Acumula até o próximo nível.',
    'Nível — sobe com XP. Cada nível novo dá moedas bônus automaticamente.',
    'Ranking — a pontuação de cada jogo é separada; não gasta moedas nem XP.',
  ];

  static String levelHeaderLabel(int level) => 'Nv. $level';

  static String levelProgressLabel({
    required int level,
    required int xpInLevel,
    required int xpNeeded,
  }) =>
      'Nível $level · $xpInLevel / $xpNeeded XP';

  static String sessionXpLabel(int xp) => '+$xp';

  static String levelUpMessage(int levels, int bonusCoins) {
    if (levels <= 1) {
      return bonusCoins > 0
          ? 'Nível up! +$bonusCoins moedas de bônus'
          : 'Nível up!';
    }
    return bonusCoins > 0
        ? '+$levels níveis! +$bonusCoins moedas de bônus'
        : '+$levels níveis!';
  }
}
