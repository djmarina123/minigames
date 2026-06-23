/// Curva de nível global — XP total necessário para *entrar* no nível [level].
int xpRequiredForLevel(int level) {
  if (level <= 1) return 0;
  return 50 * level * (level - 1);
}

/// Nível atual a partir do XP acumulado.
int levelFromXp(int xp) {
  var level = 1;
  while (xp >= xpRequiredForLevel(level + 1)) {
    level++;
  }
  return level;
}

/// XP que falta para o próximo nível (0 se no cap interno de exibição).
int xpToNextLevel(int xp) {
  final current = levelFromXp(xp);
  return xpRequiredForLevel(current + 1) - xp;
}

/// Progresso 0.0–1.0 dentro do nível atual.
double levelProgress(int xp) {
  final current = levelFromXp(xp);
  final floor = xpRequiredForLevel(current);
  final ceiling = xpRequiredForLevel(current + 1);
  final span = ceiling - floor;
  if (span <= 0) return 1;
  return ((xp - floor) / span).clamp(0.0, 1.0);
}

/// Moedas concedidas ao subir para [level] (nível de destino, não o anterior).
int levelUpCoinReward(int level) => 10 + level;

/// Soma de moedas por subir de [fromLevel] exclusivo até [toLevel] inclusivo.
int totalLevelUpCoins({required int fromLevel, required int toLevel}) {
  if (toLevel <= fromLevel) return 0;
  var total = 0;
  for (var l = fromLevel + 1; l <= toLevel; l++) {
    total += levelUpCoinReward(l);
  }
  return total;
}
