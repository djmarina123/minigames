import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/app.dart';
import 'package:minigames_hub/bootstrap/games.dart';
import 'package:minigames_hub/core/game_sdk/game_registry.dart';
import 'package:minigames_hub/core/iap/purchase_service.dart';
import 'package:minigames_hub/core/leaderboard/leaderboard_repository.dart';
import 'package:minigames_hub/core/locale/locale_repository.dart';
import 'package:minigames_hub/core/progression/achievements_repository.dart';
import 'package:minigames_hub/core/progression/missions_repository.dart';
import 'package:minigames_hub/core/storage/player_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock do canal nativo de [PackageInfo] para widget/golden tests.
void mockPackageInfoPlatform() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/package_info'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{
          'appName': 'MiniPlay',
          'packageName': 'com.miniplay.games',
          'version': '1.0.0',
          'buildNumber': '1',
          'buildSignature': '',
        };
      }
      return null;
    },
  );
}

/// Repositórios e registry prontos para widget/golden tests.
Future<({
  LocaleRepository localeRepo,
  PlayerRepository playerRepo,
  LeaderboardRepository leaderboardRepo,
  AchievementsRepository achievementsRepo,
  MissionsRepository missionsRepo,
  PurchaseService purchaseService,
})> setupTestRepositories() async {
  mockPackageInfoPlatform();
  SharedPreferences.setMockInitialValues({'app_locale': 'pt'});
  final prefs = await SharedPreferences.getInstance();
  final localeRepo = LocaleRepository(
    prefs,
    initial: AppLocales.resolveInitial(prefs),
  );
  final playerRepo = PlayerRepository(prefs);
  await playerRepo.load();
  final leaderboardRepo = LeaderboardRepository(prefs);
  await leaderboardRepo.refresh();

  final achievementsRepo = AchievementsRepository(prefs, playerRepo);
  await achievementsRepo.load();

  final missionsRepo = MissionsRepository(prefs, playerRepo);
  await missionsRepo.load();

  final purchaseService = PurchaseService(playerRepo);

  GameRegistry.instance.resetForTesting();
  registerBundledGames();

  return (
    localeRepo: localeRepo,
    playerRepo: playerRepo,
    leaderboardRepo: leaderboardRepo,
    achievementsRepo: achievementsRepo,
    missionsRepo: missionsRepo,
    purchaseService: purchaseService,
  );
}

Widget buildTestApp({
  required LocaleRepository localeRepo,
  required PlayerRepository playerRepo,
  required LeaderboardRepository leaderboardRepo,
  required AchievementsRepository achievementsRepo,
  required MissionsRepository missionsRepo,
  required PurchaseService purchaseService,
}) {
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
      ChangeNotifierProvider<MissionsRepository>.value(value: missionsRepo),
      ChangeNotifierProvider<PurchaseService>.value(value: purchaseService),
    ],
    child: const MinigamesApp(),
  );
}

/// Fixa viewport e bombeia o app para captura golden.
Future<void> pumpGoldenApp(
  WidgetTester tester, {
  required Widget app,
  required Size surfaceSize,
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}
