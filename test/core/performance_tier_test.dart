import 'package:flutter_test/flutter_test.dart';

import 'package:minigames_hub/core/economy/performance_tier.dart';

void main() {
  group('tierFromRatio', () {
    test('limiares de ouro, prata e bronze', () {
      expect(tierFromRatio(1.0), PerformanceTier.gold);
      expect(tierFromRatio(TierRubric.goldRatio), PerformanceTier.gold);
      expect(tierFromRatio(0.84), PerformanceTier.silver);
      expect(tierFromRatio(TierRubric.silverRatio), PerformanceTier.silver);
      expect(tierFromRatio(0.54), PerformanceTier.bronze);
      expect(tierFromRatio(0.0), PerformanceTier.bronze);
    });

    test('a régua é única (mesmos cortes para todos os jogos)', () {
      expect(TierRubric.goldRatio, greaterThan(TierRubric.silverRatio));
      expect(TierRubric.silverRatio, greaterThan(0.0));
    });
  });
}
