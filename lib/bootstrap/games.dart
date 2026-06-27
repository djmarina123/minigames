import '../core/game_sdk/game_registry.dart';
import '../games/game_2048/game_2048_game.dart';
import '../games/infinite_runner/infinite_runner_game.dart';
import '../games/memory/memory_game.dart';
import '../games/snake/snake_game.dart';
import '../games/solitaire/solitaire_game.dart';
import '../games/sudoku/sudoku_game.dart';
import '../games/tap_rush/tap_rush_game.dart';

/// Registra jogos empacotados no hub. Chamado uma vez no bootstrap (`main.dart`).
///
/// A ordem da lista define a idade no catálogo: jogos novos vão **no final**
/// para receberem automaticamente a badge "NOVO!" (ver [HubCatalogConfig]).
void registerBundledGames() {
  GameRegistry.instance.registerAll([
    MemoryGame(),
    TapRushGame(),
    Game2048Game(),
    InfiniteRunnerGame(),
    SolitaireGame(),
    SnakeGame(),
    SudokuGame(),
  ]);
}
