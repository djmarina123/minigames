import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/economy/performance_tier.dart';
import 'package:minigames_hub/games/memory/memory_config.dart';

void main() {
  group('memoryFinalScore', () {
    test('partida perfeita atinge score alto', () {
      final result = memoryFinalScore(
        pairCount: 4,
        pairsFound: 4,
        moves: 4,
      );

      expect(result.basePoints, 600);
      expect(result.movePenalty, 40);
      expect(result.perfectBonus, 100);
      expect(result.score, 660);
    });

    test('muitas jogadas reduzem a pontuação', () {
      final result = memoryFinalScore(
        pairCount: 4,
        pairsFound: 4,
        moves: 12,
      );

      expect(result.movePenalty, 120);
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

    test('primeiro par com várias jogadas reflete penalidade acumulada', () {
      expect(
        memoryProgressScore(pairsFound: 1, moves: 6),
        90,
      );
    });
  });

  group('memoryProgressScoreDelta', () {
    test('acerto após erros mostra ganho líquido no placar', () {
      expect(
        memoryProgressScoreDelta(
          previousScore: 0,
          pairsFound: 1,
          moves: 6,
        ),
        90,
      );
    });

    test('erro após pares encontrados reduz o placar', () {
      expect(
        memoryProgressScoreDelta(
          previousScore: memoryProgressScore(pairsFound: 2, moves: 5),
          pairsFound: 2,
          moves: 6,
        ),
        -10,
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
