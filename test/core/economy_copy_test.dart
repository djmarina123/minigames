import 'package:flutter_test/flutter_test.dart';

import 'package:minigames_hub/core/economy/economy_copy.dart';
import 'package:minigames_hub/core/economy/level_curve.dart';

void main() {
  group('EconomyCopy', () {
    test('rótulos de nível e sessão', () {
      expect(EconomyCopy.levelHeaderLabel(3), 'Nv. 3');
      expect(
        EconomyCopy.levelProgressLabel(level: 2, xpInLevel: 40, xpNeeded: 100),
        'Nível 2 · 40 / 100 XP',
      );
      expect(EconomyCopy.sessionXpLabel(25), '+25');
    });

    test('mensagem de level up', () {
      expect(
        EconomyCopy.levelUpMessage(1, 12),
        'Nível up! +12 moedas de bônus',
      );
    });
  });

  group('level_curve integration', () {
    test('nível 2 em 100 XP', () {
      expect(levelFromXp(100), 2);
    });
  });
}
