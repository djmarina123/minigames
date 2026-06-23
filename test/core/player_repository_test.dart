import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minigames_hub/core/economy/economy_config.dart';
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
      expect(repo.dailyRewardAmount, EconomyConfig.dailyRewardForStreak(1));
      expect(repo.nextDailyStreak, 1);
      final reward = await repo.claimDailyReward();
      expect(reward, EconomyConfig.dailyRewardForStreak(1));
      expect(repo.profile.coins, EconomyConfig.startingCoins + reward!);
      expect(repo.canClaimDaily, isFalse);
    });

    test('recordGameSession incrementa moedas, xp e partidas', () async {
      final record = await repo.recordGameSession(coinsEarned: 10, xpEarned: 50);
      expect(repo.profile.coins, EconomyConfig.startingCoins + 10);
      expect(repo.profile.xp, 50);
      expect(repo.profile.gamesPlayed, 1);
      expect(record.didLevelUp, isFalse);
    });

    test('recordGameSession concede moedas ao subir de nível', () async {
      final record = await repo.recordGameSession(coinsEarned: 0, xpEarned: 100);
      expect(repo.profile.level, 2);
      expect(record.levelUpCoins, 12);
      expect(repo.profile.coins, EconomyConfig.startingCoins + 12);
    });

    test('addBonusCoins incrementa moedas sem contar partida', () async {
      await repo.recordGameSession(coinsEarned: 10, xpEarned: 50);
      await repo.addBonusCoins(5);

      expect(repo.profile.coins, EconomyConfig.startingCoins + 15);
      expect(repo.profile.gamesPlayed, 1);
    });

    test('trySpendCoins falha sem saldo e debita com saldo', () async {
      expect(repo.trySpendCoins(1000), isFalse);
      expect(repo.trySpendCoins(25), isTrue);
      expect(repo.profile.coins, EconomyConfig.startingCoins - 25);
    });

    test('isFirstGameToday — false após partida no mesmo dia', () async {
      expect(repo.isFirstGameToday, isTrue);
      await repo.recordGameSession(coinsEarned: 1, xpEarned: 1);
      expect(repo.isFirstGameToday, isFalse);
    });

    test('load usa perfil default com JSON inválido', () async {
      SharedPreferences.setMockInitialValues({'player_profile': '{bad json'});
      final prefs = await SharedPreferences.getInstance();
      repo = PlayerRepository(prefs);
      await repo.load();

      expect(repo.profile.coins, EconomyConfig.startingCoins);
      expect(repo.profile.gamesPlayed, 0);
    });
  });
}
