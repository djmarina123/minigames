import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/iap/purchase_service.dart';
import 'package:minigames_hub/core/leaderboard/leaderboard_repository.dart';
import 'package:minigames_hub/core/progression/achievements_repository.dart';
import 'package:minigames_hub/core/progression/missions_repository.dart';
import 'package:minigames_hub/core/storage/player_repository.dart';

import 'helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PlayerRepository playerRepo;
  late LeaderboardRepository leaderboardRepo;
  late AchievementsRepository achievementsRepo;
  late MissionsRepository missionsRepo;
  late PurchaseService purchaseService;

  setUp(() async {
    final repos = await setupTestRepositories();
    playerRepo = repos.playerRepo;
    leaderboardRepo = repos.leaderboardRepo;
    achievementsRepo = repos.achievementsRepo;
    missionsRepo = repos.missionsRepo;
    purchaseService = repos.purchaseService;
  });

  Widget testApp() => buildTestApp(
        playerRepo: playerRepo,
        leaderboardRepo: leaderboardRepo,
        achievementsRepo: achievementsRepo,
        missionsRepo: missionsRepo,
        purchaseService: purchaseService,
      );

  testWidgets('Home exibe jogos da Fase 1', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    expect(find.text('REMOVER ADS'), findsNothing);
    expect(find.byTooltip('Remover anúncios'), findsOneWidget);
    expect(find.text('TAP RUSH'), findsOneWidget);
    expect(find.text('JOGO DA MEMÓRIA'), findsOneWidget);

    final grid = find.byType(Scrollable);
    await tester.scrollUntilVisible(
      find.text('CORRIDA INFINITA'),
      120,
      scrollable: grid.first,
    );
    expect(find.text('CORRIDA INFINITA'), findsOneWidget);
    expect(find.text('2048'), findsOneWidget);
  });

  testWidgets('favorito sobe para o topo do grid', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await playerRepo.toggleFavorite('infinite_runner');

    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    final runnerPos = tester.getTopLeft(find.text('CORRIDA INFINITA'));
    final memoryPos = tester.getTopLeft(find.text('JOGO DA MEMÓRIA'));
    expect(runnerPos.dx, lessThan(memoryPos.dx));
  });

  testWidgets('navega para aba Perfil', (tester) async {
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('PERFIL'), findsOneWidget);
    expect(find.textContaining('Nível 1'), findsOneWidget);

    final scrollable = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(find.text('Loja'), 120, scrollable: scrollable);
    expect(find.text('Loja'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Conquistas'), 120, scrollable: scrollable);
    expect(find.text('Conquistas'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Moedas'), 120, scrollable: scrollable);
    expect(find.text('Moedas'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('XP total'), 120, scrollable: scrollable);
    expect(find.text('XP total'), findsOneWidget);
  });
}
