import 'package:flutter_test/flutter_test.dart';
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
  });
}
