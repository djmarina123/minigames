import 'package:flutter/material.dart';

import '../../core/game_sdk/game_registry.dart';
import '../../core/game_sdk/game_runner_screen.dart';
import '../../games/demo/demo_game.dart';
import 'widgets/game_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = GameRegistry.instance.enabled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minigames Hub'),
      ),
      body: games.isEmpty
          ? const Center(child: Text('Nenhum jogo disponível.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return GameCard(
                  metadata: game.metadata,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => GameRunnerScreen(game: game),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

void registerBundledGames() {
  GameRegistry.instance.registerAll([
    DemoGame(),
  ]);
}
