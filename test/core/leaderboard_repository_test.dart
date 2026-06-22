import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minigames_hub/core/leaderboard/leaderboard_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LeaderboardRepository', () {
    late LeaderboardRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repo = LeaderboardRepository(prefs);
    });

    test('submitScore persiste e refresh atualiza allBest', () async {
      await repo.submitScore(
        gameId: 'memory',
        gameTitle: 'Jogo da Memória',
        score: 500,
      );

      expect(repo.allBest, hasLength(1));
      expect(repo.allBest.first.score, 500);
    });

    test('getAllBest retorna melhor score por jogo ordenado por título', () async {
      await repo.submitScore(
        gameId: 'tap_rush',
        gameTitle: 'Tap Rush',
        score: 300,
      );
      await repo.submitScore(
        gameId: 'memory',
        gameTitle: 'Jogo da Memória',
        score: 900,
      );

      final best = await repo.getAllBest();
      expect(best, hasLength(2));
      expect(best.first.gameId, 'memory');
      expect(best.last.gameId, 'tap_rush');
    });

    test('submitScore mantém apenas top maxEntries', () async {
      for (var i = 1; i <= 12; i++) {
        await repo.submitScore(
          gameId: 'memory',
          gameTitle: 'Jogo da Memória',
          score: i * 10,
        );
      }

      final entries = await repo.getEntries('memory');
      expect(entries.length, LeaderboardRepository.maxEntries);
      expect(entries.first.score, 120);
    });

    test('getEntries retorna lista vazia com JSON inválido', () async {
      SharedPreferences.setMockInitialValues({
        'leaderboard_memory': 'not-json',
      });
      final prefs = await SharedPreferences.getInstance();
      repo = LeaderboardRepository(prefs);

      final entries = await repo.getEntries('memory');
      expect(entries, isEmpty);
    });
  });
}
