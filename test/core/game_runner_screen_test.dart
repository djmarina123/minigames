import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/ads/ads_service.dart';
import 'package:minigames_hub/core/economy/economy_config.dart';
import 'package:minigames_hub/core/economy/session_rewards.dart';
import 'package:minigames_hub/core/game_sdk/game_result.dart';
import 'package:minigames_hub/core/game_sdk/game_runner_screen.dart';
import 'package:minigames_hub/core/l10n/l10n_scope.dart';
import 'package:minigames_hub/core/locale/locale_repository.dart';
import 'package:minigames_hub/core/leaderboard/leaderboard_repository.dart';
import 'package:minigames_hub/core/progression/achievements_repository.dart';
import 'package:minigames_hub/core/progression/missions_repository.dart';
import 'package:minigames_hub/core/storage/player_repository.dart';
import 'package:minigames_hub/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameRunnerScreen', () {
    late LocaleRepository localeRepo;
    late PlayerRepository playerRepo;
    late LeaderboardRepository leaderboardRepo;
    late AchievementsRepository achievementsRepo;
    late MissionsRepository missionsRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'app_locale': 'pt'});
      final prefs = await SharedPreferences.getInstance();
      localeRepo = LocaleRepository(
        prefs,
        initial: AppLocales.resolveInitial(prefs),
      );
      playerRepo = PlayerRepository(prefs);
      await playerRepo.load();
      leaderboardRepo = LeaderboardRepository(prefs);
      await leaderboardRepo.refresh();
      achievementsRepo = AchievementsRepository(prefs, playerRepo);
      await achievementsRepo.load();
      missionsRepo = MissionsRepository(prefs, playerRepo);
      await missionsRepo.load();
    });

    Widget buildRunner({MockInstantGame? game}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<LocaleRepository>.value(value: localeRepo),
          ChangeNotifierProvider<PlayerRepository>.value(value: playerRepo),
          ChangeNotifierProvider<LeaderboardRepository>.value(
            value: leaderboardRepo,
          ),
          ChangeNotifierProvider<AchievementsRepository>.value(
            value: achievementsRepo,
          ),
          ChangeNotifierProvider<MissionsRepository>.value(
            value: missionsRepo,
          ),
        ],
        child: MaterialApp(
          locale: localeRepo.locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) =>
              L10nScope.wrap(context, child ?? const SizedBox.shrink()),
          home: GameRunnerScreen(game: game ?? MockInstantGame()),
        ),
      );
    }

    testWidgets('recordGameSession aplica economia centralizada', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildRunner());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      final expected = resolveSessionReward(
        result: const GameResult(
          score: 100,
          duration: Duration(seconds: 5),
          metadata: {'performanceTier': 'gold'},
        ),
        isNewRecord: true,
        isFirstGameToday: true,
      );

      expect(playerRepo.profile.gamesPlayed, 1);
      // Inclui bônus de conquistas (first_game, gold_once, new_record).
      expect(playerRepo.profile.coins, 110);
      expect(playerRepo.profile.xp, expected.xp);
      expect(leaderboardRepo.allBest, hasLength(1));
    });
  });

  group('fluxo economia pós-partida (mesmo do runner)', () {
    test('double coins dobra o ganho da partida', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'pt'});
      final prefs = await SharedPreferences.getInstance();
      final repo = PlayerRepository(prefs);
      await repo.load();

      const sessionCoins = 16;
      await repo.recordGameSession(coinsEarned: sessionCoins, xpEarned: 30);
      final bonus = await AdsService.showRewardedAd();
      expect(bonus, greaterThan(0));
      await repo.addBonusCoins(sessionCoins);

      expect(repo.profile.gamesPlayed, 1);
      expect(repo.profile.coins, EconomyConfig.startingCoins + sessionCoins * 2);
    });
  });
}
