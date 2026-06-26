import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minigames_hub/core/progression/missions_repository.dart';
import 'package:minigames_hub/core/progression/progression_models.dart';
import 'package:minigames_hub/core/storage/player_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MissionsRepository', () {
    late PlayerRepository playerRepo;
    late MissionsRepository missionsRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      playerRepo = PlayerRepository(prefs);
      await playerRepo.load();
      missionsRepo = MissionsRepository(prefs, playerRepo);
      await missionsRepo.load();
    });

    SessionEvent session({int score = 100, String? tier}) {
      return SessionEvent(
        gameId: 'tap_rush',
        score: score,
        tierName: tier,
        isNewRecord: false,
        gamesPlayed: playerRepo.profile.gamesPlayed,
        level: playerRepo.profile.level,
        dailyStreak: playerRepo.profile.dailyStreak,
        uniqueGamesPlayed: 1,
      );
    }

    test('avança missão de partidas jogadas', () async {
      await missionsRepo.onSession(session());
      final playMission = missionsRepo.todayMissions
          .firstWhere((m) => m.definition.id == 'daily_play_3');

      expect(playMission.current, 1);
    });

    test('permite resgatar missão concluída', () async {
      for (var i = 0; i < 3; i++) {
        await missionsRepo.onSession(session());
      }

      final reward = await missionsRepo.claimMission('daily_play_3');
      expect(reward, 15);
      expect(playerRepo.profile.coins, greaterThan(50));
    });
  });
}
