import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'bootstrap/games.dart';
import 'core/ads/ads_service.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/iap/purchase_service.dart';
import 'core/leaderboard/leaderboard_repository.dart';
import 'core/progression/achievements_repository.dart';
import 'core/progression/missions_repository.dart';
import 'core/storage/player_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  await AdsService.initialize();
  registerBundledGames();

  final prefs = await SharedPreferences.getInstance();
  final playerRepo = PlayerRepository(prefs);
  await playerRepo.load();

  AdsService.setAdsRemoved(playerRepo.profile.adsRemoved);

  final leaderboardRepo = LeaderboardRepository(prefs);
  await leaderboardRepo.refresh();

  final achievementsRepo = AchievementsRepository(prefs, playerRepo);
  await achievementsRepo.load();

  final missionsRepo = MissionsRepository(prefs, playerRepo);
  await missionsRepo.load();

  final purchaseService = PurchaseService(playerRepo);
  await purchaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
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
    ),
  );
}
