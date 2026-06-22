import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minigames_hub/core/storage/player_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlayerRepository', () {
    late PlayerRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repo = PlayerRepository(prefs);
      await repo.load();
    });

    test('claimDailyReward concede moedas na primeira vez', () async {
      expect(repo.canClaimDaily, isTrue);
      final reward = await repo.claimDailyReward();
      expect(reward, isNotNull);
      expect(repo.profile.coins, greaterThan(0));
      expect(repo.canClaimDaily, isFalse);
    });

    test('applyGameResult incrementa moedas e xp', () async {
      await repo.applyGameResult(coinsEarned: 10, xpEarned: 50);
      expect(repo.profile.coins, 10);
      expect(repo.profile.xp, 50);
      expect(repo.profile.gamesPlayed, 1);
    });
  });
}
