import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/bootstrap/games.dart';
import 'package:minigames_hub/core/firebase/firebase_bootstrap.dart';
import 'package:minigames_hub/core/game_sdk/game_registry.dart';
import 'package:minigames_hub/games/demo/demo_game.dart';
import 'package:minigames_hub/games/memory/memory_game.dart';
import 'package:minigames_hub/games/tap_rush/tap_rush_game.dart';

void main() {
  group('FirebaseBootstrap', () {
    test('isConfigured reflete firebase_config', () {
      expect(FirebaseBootstrap.isConfigured, isTrue);
    });

    test('initialize não lança em ambiente de teste', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await FirebaseBootstrap.initialize();
      expect(FirebaseBootstrap.isInitialized, isFalse);
    });
  });

  group('GameRegistry', () {
    setUp(() {
      GameRegistry.instance.resetForTesting();
      GameRegistry.instance.registerAll([
        DemoGame(),
        MemoryGame(),
        TapRushGame(),
      ]);
    });

    tearDown(() {
      GameRegistry.instance.resetForTesting();
    });

    test('registra e encontra jogo por id', () {
      final game = GameRegistry.instance.findById('demo_tap');
      expect(game, isNotNull);
      expect(game!.metadata.title, 'Demo Tap');
    });

    test('lista apenas jogos habilitados', () {
      final enabled = GameRegistry.instance.enabled;
      expect(enabled, isNotEmpty);
      expect(enabled.every((g) => g.metadata.enabled), isTrue);
    });

    test('enabledInCatalogOrder segue ordem de registro', () {
      expect(
        GameRegistry.instance.enabledInCatalogOrder
            .map((g) => g.metadata.id)
            .toList(),
        ['demo_tap', 'memory', 'tap_rush'],
      );
    });

    test('lista jogos em destaque pelos últimos registrados', () {
      final featured = GameRegistry.instance.featured;
      expect(
        featured.map((g) => g.metadata.id).toList(),
        ['tap_rush', 'memory', 'demo_tap'],
      );
    });

    test('registerBundledGames destaca os 3 jogos mais recentes', () {
      GameRegistry.instance.resetForTesting();
      registerBundledGames();

      expect(GameRegistry.instance.isFeatured('sudoku'), isFalse);
      expect(GameRegistry.instance.isFeatured('cross_sums'), isTrue);
      expect(GameRegistry.instance.isFeatured('color_blocks'), isTrue);
      expect(GameRegistry.instance.isFeatured('minesweeper'), isTrue);
      expect(GameRegistry.instance.isFeatured('memory'), isFalse);
      expect(GameRegistry.instance.isFeatured('tap_rush'), isFalse);
    });

    test('registerBundledGames registra jogos do hub', () {
      GameRegistry.instance.resetForTesting();
      registerBundledGames();

      expect(GameRegistry.instance.findById('memory'), isNotNull);
      expect(GameRegistry.instance.findById('tap_rush'), isNotNull);
      expect(GameRegistry.instance.findById('game_2048'), isNotNull);
      expect(GameRegistry.instance.findById('infinite_runner'), isNotNull);
      expect(GameRegistry.instance.findById('solitaire'), isNotNull);
      expect(GameRegistry.instance.findById('snake'), isNotNull);
      expect(GameRegistry.instance.findById('sudoku'), isNotNull);
      expect(GameRegistry.instance.findById('cross_sums'), isNotNull);
      expect(GameRegistry.instance.findById('color_blocks'), isNotNull);
      expect(GameRegistry.instance.findById('minesweeper'), isNotNull);
      expect(GameRegistry.instance.enabled, hasLength(10));
    });
  });
}
