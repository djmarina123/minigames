import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/app.dart';
import 'package:minigames_hub/core/game_sdk/game_registry.dart';
import 'package:minigames_hub/core/leaderboard/leaderboard_repository.dart';
import 'package:minigames_hub/core/storage/player_repository.dart';
import 'package:minigames_hub/games/memory/memory_game.dart';
import 'package:minigames_hub/games/tap_rush/tap_rush_game.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PlayerRepository playerRepo;
  late LeaderboardRepository leaderboardRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    playerRepo = PlayerRepository(prefs);
    await playerRepo.load();
    leaderboardRepo = LeaderboardRepository(prefs);

    GameRegistry.instance.registerAll([
      MemoryGame(),
      TapRushGame(),
    ]);
  });

  Widget buildApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlayerRepository>.value(value: playerRepo),
        Provider<LeaderboardRepository>.value(value: leaderboardRepo),
      ],
      child: const MinigamesApp(),
    );
  }

  testWidgets('Home exibe jogos da Fase 1', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('REMOVER ADS'), findsOneWidget);
    expect(find.text('TAP RUSH'), findsOneWidget);
    expect(find.text('JOGO DA MEMÓRIA'), findsOneWidget);
  });

  testWidgets('navega para aba Perfil', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Moedas'), findsOneWidget);
    expect(find.text('XP'), findsOneWidget);
  });
}
