import 'package:flutter_test/flutter_test.dart';

import 'package:minigames_hub/core/economy/performance_tier.dart';
import 'package:minigames_hub/core/economy/session_rewards.dart';
import 'package:minigames_hub/core/game_sdk/game_result.dart';

void main() {
  group('computeSessionReward', () {
    test('bronze base — 8 moedas e 20 XP', () {
      final r = computeSessionReward(
        const SessionRewardInput(tier: PerformanceTier.bronze),
      );
      expect(r.coins, 8);
      expect(r.xp, 20);
    });

    test('ouro + recorde + primeira do dia — respeita caps', () {
      final r = computeSessionReward(
        const SessionRewardInput(
          tier: PerformanceTier.gold,
          isNewRecord: true,
          isFirstGameToday: true,
        ),
      );
      expect(r.coins, 20);
      expect(r.xp, 45);
    });

    test('prata com recorde — cap de moedas', () {
      final r = computeSessionReward(
        const SessionRewardInput(
          tier: PerformanceTier.silver,
          isNewRecord: true,
        ),
      );
      expect(r.coins, 20);
      expect(r.xp, 20 + 5 + 15);
    });
  });

  group('resolveSessionReward', () {
    test('lê tier do metadata do GameResult', () {
      final result = GameResult(
        score: 500,
        duration: Duration.zero,
        metadata: const {'performanceTier': 'gold'},
      );
      final r = resolveSessionReward(
        result: result,
        isNewRecord: false,
        isFirstGameToday: false,
      );
      expect(r.coins, 16);
      expect(r.tier, PerformanceTier.gold);
    });

    test('applySessionReward preenche coins e xp no resultado', () {
      const result = GameResult(score: 100, duration: Duration(seconds: 1));
      final reward = computeSessionReward(
        const SessionRewardInput(tier: PerformanceTier.bronze),
      );
      final enriched = applySessionReward(result, reward);
      expect(enriched.coinsEarned, 8);
      expect(enriched.xpEarned, 20);
    });
  });
}
