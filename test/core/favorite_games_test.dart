import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/game_sdk/game_metadata.dart';
import 'package:minigames_hub/core/game_sdk/hub_game.dart';
import 'package:minigames_hub/core/storage/favorite_games.dart';
import 'package:minigames_hub/core/storage/player_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StubGame implements HubGame {
  _StubGame(this.id);

  final String id;

  @override
  GameMetadata get metadata => GameMetadata(
        id: id,
        title: id,
        description: '',
        category: 'test',
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('sortGamesByFavorites', () {
    test('mantém ordem original sem favoritos', () {
      final games = [
        _StubGame('a'),
        _StubGame('b'),
        _StubGame('c'),
      ];

      final sorted = sortGamesByFavorites(games, const []);

      expect(sorted.map((g) => g.metadata.id).toList(), ['a', 'b', 'c']);
    });

    test('coloca favoritos no topo na ordem marcada', () {
      final games = [
        _StubGame('memory'),
        _StubGame('tap_rush'),
        _StubGame('snake'),
        _StubGame('sudoku'),
      ];

      final sorted = sortGamesByFavorites(
        games,
        const ['snake', 'memory'],
      );

      expect(
        sorted.map((g) => g.metadata.id).toList(),
        ['snake', 'memory', 'tap_rush', 'sudoku'],
      );
    });
  });

  group('PlayerRepository favorites', () {
    late PlayerRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repo = PlayerRepository(prefs);
      await repo.load();
    });

    test('toggleFavorite adiciona e remove', () async {
      expect(repo.isFavorite('tap_rush'), isFalse);

      await repo.toggleFavorite('tap_rush');
      expect(repo.isFavorite('tap_rush'), isTrue);
      expect(repo.profile.favoriteGameIds, ['tap_rush']);

      await repo.toggleFavorite('tap_rush');
      expect(repo.isFavorite('tap_rush'), isFalse);
      expect(repo.profile.favoriteGameIds, isEmpty);
    });

    test('favoritos persistem após reload', () async {
      await repo.toggleFavorite('memory');
      await repo.toggleFavorite('game_2048');

      final prefs = await SharedPreferences.getInstance();
      final reloaded = PlayerRepository(prefs);
      await reloaded.load();

      expect(reloaded.profile.favoriteGameIds, ['memory', 'game_2048']);
    });
  });
}
