import 'package:flutter/material.dart';

import '../../core/game_sdk/game_registry.dart';
import '../../core/game_sdk/game_runner_screen.dart';
import '../../core/game_sdk/hub_game.dart';
import '../../core/ads/ads_service.dart';
import '../../core/theme/hub_theme.dart';
import '../../games/memory/memory_game.dart';
import '../../games/tap_rush/tap_rush_game.dart';
import 'widgets/daily_reward_banner.dart';
import 'widgets/game_card.dart';
import 'widgets/hub_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    final games = GameRegistry.instance.enabled;

    return ColoredBox(
      color: HubTheme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HubHeader(onMenuTap: onMenuTap),
            const DailyRewardBanner(),
            Expanded(
              child: games.isEmpty
                  ? const Center(child: Text('Nenhum jogo disponível.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(HubTheme.gridPadding),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: HubTheme.gridSpacing,
                        crossAxisSpacing: HubTheme.gridSpacing,
                        childAspectRatio: HubTheme.cardAspectRatio,
                      ),
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final game = games[index];
                        return GameCard(
                          metadata: game.metadata,
                          onTap: () => _openGame(context, game),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGame(BuildContext context, HubGame game) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => GameRunnerScreen(game: game),
      ),
    );
    await AdsService.maybeShowInterstitial();
  }
}

void registerBundledGames() {
  GameRegistry.instance.registerAll([
    MemoryGame(),
    TapRushGame(),
  ]);
}
