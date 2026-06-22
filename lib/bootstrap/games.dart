import '../core/game_sdk/game_registry.dart';
import '../games/memory/memory_game.dart';
import '../games/tap_rush/tap_rush_game.dart';

/// Registra jogos empacotados no hub. Chamado uma vez no bootstrap (`main.dart`).
void registerBundledGames() {
  GameRegistry.instance.registerAll([
    MemoryGame(),
    TapRushGame(),
  ]);
}
