import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/economy/performance_tier.dart';
import 'package:minigames_hub/games/memory/memory_config.dart';

void main() {
  group('memoryFinalScore', () {
    test('partida perfeita rápida atinge score alto', () {
      final result = memoryFinalScore(
        pairCount: 4,
        pairsFound: 4,
        moves: 4,
        duration: const Duration(seconds: 10),
      );

      expect(result.basePoints, 600);
      expect(result.movePenalty, 40);
      expect(result.perfectBonus, 100);
      expect(result.timeBonus, 160);
      expect(result.score, 820);
    });

    test('muitas jogadas reduzem a pontuação', () {
      final result = memoryFinalScore(
        pairCount: 4,
        pairsFound: 4,
        moves: 12,
        duration: const Duration(seconds: 60),
      );

      expect(result.movePenalty, 120);
      expect(result.timeBonus, 0);
      expect(result.perfectBonus, 0);
      expect(result.score, 480);
    });
  });

  group('memoryProgressScore', () {
    test('nunca fica negativo durante a partida', () {
      expect(
        memoryProgressScore(pairsFound: 1, moves: 20),
        0,
      );
      expect(
        memoryProgressScore(pairsFound: 2, moves: 5),
        250,
      );
    });
  });

  group('memoryPerformanceTier', () {
    test('partida perfeita é ouro', () {
      expect(
        memoryPerformanceTier(pairCount: 4, moves: 4, perfectBonus: 100),
        PerformanceTier.gold,
      );
    });

    test('muitas jogadas é bronze', () {
      expect(
        memoryPerformanceTier(pairCount: 4, moves: 12, perfectBonus: 0),
        PerformanceTier.bronze,
      );
    });
  });
}
