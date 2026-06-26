import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minigames_hub/core/progression/achievements_repository.dart';
import 'package:minigames_hub/core/progression/progression_models.dart';
import 'package:minigames_hub/core/storage/player_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AchievementsRepository', () {
    late PlayerRepository playerRepo;
    late AchievementsRepository achievementsRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      playerRepo = PlayerRepository(prefs);
      await playerRepo.load();
      achievementsRepo = AchievementsRepository(prefs, playerRepo);
      await achievementsRepo.load();
    });

    SessionEvent session({int gamesPlayed = 1, String? tier, bool record = false}) {
      return SessionEvent(
        gameId: 'memory',
        score: 100,
        tierName: tier,
        isNewRecord: record,
        gamesPlayed: gamesPlayed,
        level: playerRepo.profile.level,
        dailyStreak: playerRepo.profile.dailyStreak,
        uniqueGamesPlayed: 1,
      );
    }

    test('desbloqueia first_game na primeira partida', () async {
      await playerRepo.recordGameSession(coinsEarned: 5, xpEarned: 10);
      final unlocked = await achievementsRepo.onSession(
        session(gamesPlayed: playerRepo.profile.gamesPlayed),
      );

      expect(unlocked.any((u) => u.definition.id == 'first_game'), isTrue);
      expect(achievementsRepo.isUnlocked('first_game'), isTrue);
    });

    test('desbloqueia gold_once com faixa ouro', () async {
      await playerRepo.recordGameSession(coinsEarned: 5, xpEarned: 10);
      final unlocked = await achievementsRepo.onSession(
        session(gamesPlayed: 1, tier: 'gold'),
      );

      expect(unlocked.any((u) => u.definition.id == 'gold_once'), isTrue);
    });
  });
}
