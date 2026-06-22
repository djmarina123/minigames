import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minigames_hub/core/ads/ads_service.dart';
import 'package:minigames_hub/core/game_sdk/game_runner_screen.dart';
import 'package:minigames_hub/core/leaderboard/leaderboard_repository.dart';
import 'package:minigames_hub/core/storage/player_repository.dart';

import '../helpers/mock_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameRunnerScreen', () {
    late PlayerRepository playerRepo;
    late LeaderboardRepository leaderboardRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      playerRepo = PlayerRepository(prefs);
      await playerRepo.load();
      leaderboardRepo = LeaderboardRepository(prefs);
      await leaderboardRepo.refresh();
    });

    Widget buildRunner({MockInstantGame? game}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<PlayerRepository>.value(value: playerRepo),
          ChangeNotifierProvider<LeaderboardRepository>.value(
            value: leaderboardRepo,
          ),
        ],
        child: MaterialApp(
          home: GameRunnerScreen(game: game ?? MockInstantGame()),
        ),
      );
    }

    testWidgets('recordGameSession incrementa partidas ao terminar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildRunner());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(playerRepo.profile.gamesPlayed, 1);
      expect(playerRepo.profile.coins, 10);
      expect(playerRepo.profile.xp, 50);
      expect(leaderboardRepo.allBest, hasLength(1));
    });
  });

  group('fluxo economia pós-partida (mesmo do runner)', () {
    test('double coins usa addBonusCoins sem nova partida', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = PlayerRepository(prefs);
      await repo.load();

      await repo.recordGameSession(coinsEarned: 10, xpEarned: 50);
      final bonus = await AdsService.showRewardedAd();
      await repo.addBonusCoins(bonus);

      expect(repo.profile.gamesPlayed, 1);
      expect(repo.profile.coins, 15);
    });
  });
}
