import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/leaderboard/leaderboard_repository.dart';
import 'package:minigames_hub/core/storage/player_repository.dart';

import 'helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PlayerRepository playerRepo;
  late LeaderboardRepository leaderboardRepo;

  setUp(() async {
    final repos = await setupTestRepositories();
    playerRepo = repos.playerRepo;
    leaderboardRepo = repos.leaderboardRepo;
  });

  testWidgets('Home exibe jogos da Fase 1', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildTestApp(
        playerRepo: playerRepo,
        leaderboardRepo: leaderboardRepo,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('REMOVER ADS'), findsOneWidget);
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

  testWidgets('navega para aba Perfil', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        playerRepo: playerRepo,
        leaderboardRepo: leaderboardRepo,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('PERFIL'), findsOneWidget);
    expect(find.text('Moedas'), findsOneWidget);
    expect(find.text('XP'), findsOneWidget);
  });
}
