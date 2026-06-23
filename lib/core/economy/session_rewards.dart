import '../game_sdk/game_result.dart';
import 'economy_config.dart';
import 'performance_tier.dart';

/// Entrada para cálculo de recompensa — flags conhecidas pelo runner.
class SessionRewardInput {
  const SessionRewardInput({
    required this.tier,
    this.isNewRecord = false,
    this.isFirstGameToday = false,
  });

  final PerformanceTier tier;
  final bool isNewRecord;
  final bool isFirstGameToday;
}

/// Recompensa calculada para uma partida.
class SessionReward {
  const SessionReward({
    required this.coins,
    required this.xp,
    required this.tier,
    this.isNewRecord = false,
    this.isFirstGameToday = false,
  });

  final int coins;
  final int xp;
  final PerformanceTier tier;
  final bool isNewRecord;
  final bool isFirstGameToday;
}

/// Calcula moedas e XP a partir do desempenho e bônus de sessão.
SessionReward computeSessionReward(SessionRewardInput input) {
  var coins = EconomyConfig.sessionCoinBase + EconomyConfig.tierCoinBonus(input.tier);
  if (input.isNewRecord) coins += EconomyConfig.sessionCoinNewRecord;
  coins = coins.clamp(0, EconomyConfig.sessionCoinCap);

  var xp = EconomyConfig.sessionXpBase + EconomyConfig.tierXpBonus(input.tier);
  if (input.isNewRecord) xp += EconomyConfig.sessionXpNewRecord;
  if (input.isFirstGameToday) xp += EconomyConfig.sessionXpFirstGameToday;
  xp = xp.clamp(0, EconomyConfig.sessionXpCap);

  return SessionReward(
    coins: coins,
    xp: xp,
    tier: input.tier,
    isNewRecord: input.isNewRecord,
    isFirstGameToday: input.isFirstGameToday,
  );
}

/// Lê o tier gravado em [GameResult.metadata] (padrão bronze).
PerformanceTier performanceTierFromResult(GameResult result) =>
    PerformanceTier.fromName(result.metadata['performanceTier'] as String?);

/// Resolve recompensa completa a partir do resultado e flags do hub.
SessionReward resolveSessionReward({
  required GameResult result,
  required bool isNewRecord,
  required bool isFirstGameToday,
}) {
  return computeSessionReward(
    SessionRewardInput(
      tier: performanceTierFromResult(result),
      isNewRecord: isNewRecord,
      isFirstGameToday: isFirstGameToday,
    ),
  );
}

/// Aplica [reward] ao [result] para exibição no placar final.
GameResult applySessionReward(GameResult result, SessionReward reward) {
  return GameResult(
    score: result.score,
    duration: result.duration,
    coinsEarned: reward.coins,
    xpEarned: reward.xp,
    metadata: {
      ...result.metadata,
      'performanceTier': reward.tier.name,
      'rewardNewRecord': reward.isNewRecord,
      'rewardFirstGameToday': reward.isFirstGameToday,
    },
  );
}
