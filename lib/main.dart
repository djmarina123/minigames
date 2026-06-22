import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'bootstrap/games.dart';
import 'core/ads/ads_service.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/leaderboard/leaderboard_repository.dart';
import 'core/storage/player_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  await AdsService.initialize();
  registerBundledGames();

  final prefs = await SharedPreferences.getInstance();
  final playerRepo = PlayerRepository(prefs);
  await playerRepo.load();

  final leaderboardRepo = LeaderboardRepository(prefs);
  await leaderboardRepo.refresh();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PlayerRepository>.value(value: playerRepo),
        ChangeNotifierProvider<LeaderboardRepository>.value(
          value: leaderboardRepo,
        ),
      ],
      child: const MinigamesApp(),
    ),
  );
}
