import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/firebase/firebase_bootstrap.dart';
import 'package:minigames_hub/core/game_sdk/game_registry.dart';
import 'package:minigames_hub/games/demo/demo_game.dart';
import 'package:minigames_hub/games/memory/memory_game.dart';
import 'package:minigames_hub/games/tap_rush/tap_rush_game.dart';

void main() {
  group('FirebaseBootstrap', () {
    test('não inicializa sem configuração', () async {
      await FirebaseBootstrap.initialize();
      expect(FirebaseBootstrap.isInitialized, isFalse);
      expect(FirebaseBootstrap.isConfigured, isFalse);
    });
  });

  group('GameRegistry', () {
    setUp(() {
      GameRegistry.instance.registerAll([
        DemoGame(),
        MemoryGame(),
        TapRushGame(),
      ]);
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

    test('lista jogos em destaque', () {
      final featured = GameRegistry.instance.featured;
      expect(featured.any((g) => g.metadata.id == 'demo_tap'), isTrue);
    });
  });
}
