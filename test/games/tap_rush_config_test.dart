import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/economy/performance_tier.dart';
import 'package:minigames_hub/games/tap_rush/tap_rush_config.dart';

void main() {
  group('TapRushConfig', () {
    test('combo aumenta pontos até o teto', () {
      expect(tapRushPointsForHit(1), 10);
      expect(tapRushPointsForHit(3), 30);
      expect(tapRushPointsForHit(5), 50);
      expect(tapRushPointsForHit(99), 50);
    });

    test('dificuldade progride com o tempo', () {
      expect(tapRushTargetRadius(0), TapRushConfig.baseTargetRadius);
      expect(tapRushTargetRadius(1), TapRushConfig.minTargetRadius);
      expect(
        tapRushTargetLifetimeMs(1),
        lessThan(tapRushTargetLifetimeMs(0)),
      );
      expect(tapRushProgress(7.5, 15), 0.5);
      expect(tapRushProgress(30, 60), 0.5);
    });

    test('curva acelera dificuldade no final da partida', () {
      expect(tapRushDifficultyProgress(0), 0);
      expect(tapRushDifficultyProgress(1), 1);
      expect(tapRushDifficultyProgress(0.5), lessThan(0.5));
      expect(
        tapRushTargetLifetimeMs(0.8),
        lessThan(tapRushTargetLifetimeMs(0.5)),
      );
    });

    test('performance tier calibrado', () {
      expect(tapRushPerformanceTier(450), PerformanceTier.gold);
      expect(tapRushPerformanceTier(383), PerformanceTier.gold);
      expect(tapRushPerformanceTier(200), PerformanceTier.bronze);
    });
  });
}
