import 'package:flutter_test/flutter_test.dart';

import 'package:minigames_hub/core/economy/level_curve.dart';

void main() {
  group('level_curve', () {
    test('nível 1 começa com 0 XP', () {
      expect(levelFromXp(0), 1);
      expect(xpRequiredForLevel(1), 0);
    });

    test('curva quadrática — nível 2 em 100 XP', () {
      expect(levelFromXp(99), 1);
      expect(levelFromXp(100), 2);
      expect(xpToNextLevel(50), 50);
    });

    test('levelUpCoinReward cresce com o nível', () {
      expect(levelUpCoinReward(2), 12);
      expect(totalLevelUpCoins(fromLevel: 1, toLevel: 3), 12 + 13);
    });

    test('levelProgress entre 0 e 1', () {
      expect(levelProgress(0), 0);
      expect(levelProgress(50), closeTo(0.5, 0.01));
      expect(levelProgress(100), closeTo(0, 0.01));
    });
  });
}
