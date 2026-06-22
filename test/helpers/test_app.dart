import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/app.dart';
import 'package:minigames_hub/bootstrap/games.dart';
import 'package:minigames_hub/core/game_sdk/game_registry.dart';
import 'package:minigames_hub/core/leaderboard/leaderboard_repository.dart';
import 'package:minigames_hub/core/storage/player_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repositórios e registry prontos para widget/golden tests.
Future<({
  PlayerRepository playerRepo,
  LeaderboardRepository leaderboardRepo,
})> setupTestRepositories() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final playerRepo = PlayerRepository(prefs);
  await playerRepo.load();
  final leaderboardRepo = LeaderboardRepository(prefs);
  await leaderboardRepo.refresh();

  GameRegistry.instance.resetForTesting();
  registerBundledGames();

  return (playerRepo: playerRepo, leaderboardRepo: leaderboardRepo);
}

Widget buildTestApp({
  required PlayerRepository playerRepo,
  required LeaderboardRepository leaderboardRepo,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<PlayerRepository>.value(value: playerRepo),
      ChangeNotifierProvider<LeaderboardRepository>.value(
        value: leaderboardRepo,
      ),
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
