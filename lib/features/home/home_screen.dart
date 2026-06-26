import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ads/ads_service.dart';
import '../../core/game_sdk/game_prep_screen.dart';
import '../../core/game_sdk/game_runner_screen.dart';
import '../../core/game_sdk/game_registry.dart';
import '../../core/game_sdk/hub_game.dart';
import '../../core/storage/favorite_games.dart';
import '../../core/storage/player_repository.dart';
import '../../core/theme/hub_theme.dart';
import 'widgets/daily_reward_banner.dart';
import 'widgets/game_card.dart';
import 'widgets/hub_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onMenuTap,
    this.onProfileTap,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final playerRepo = context.watch<PlayerRepository>();
    final games = sortGamesByFavorites(
      GameRegistry.instance.enabledInCatalogOrder,
      playerRepo.profile.favoriteGameIds,
    );

    return ColoredBox(
      color: HubTheme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HubHeader(
              onMenuTap: onMenuTap,
              onProfileTap: onProfileTap,
            ),
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
                          isFavorite: playerRepo.isFavorite(game.metadata.id),
                          onFavoriteToggle: () =>
                              playerRepo.toggleFavorite(game.metadata.id),
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
    final route = game.prep != null
        ? MaterialPageRoute<void>(builder: (_) => GamePrepScreen(game: game))
        : MaterialPageRoute<void>(
            builder: (_) => GameRunnerScreen(game: game),
          );

    await Navigator.of(context).push<void>(route);
    await AdsService.maybeShowInterstitial();
  }
}
