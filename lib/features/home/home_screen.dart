import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ads/ads_service.dart';
import '../../core/game_sdk/game_prep_screen.dart';
import '../../core/game_sdk/game_runner_screen.dart';
import '../../core/game_sdk/game_registry.dart';
import '../../core/game_sdk/hub_game.dart';
import '../../core/progression/achievements_repository.dart';
import '../../core/storage/favorite_games.dart';
import '../../core/storage/player_repository.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/hub_theme.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/app_bar/mini_play_app_bar.dart';
import 'widgets/game_card.dart';

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
    final l10n = AppLocalizations.of(context);
    final playerRepo = context.watch<PlayerRepository>();
    final games = sortGamesByFavorites(
      GameRegistry.instance.enabledInCatalogOrder,
      playerRepo.profile.favoriteGameIds,
    );

    return ColoredBox(
      color: HubTheme.background,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            automaticallyImplyLeading: false,
            backgroundColor: HubTheme.appBarBackground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            expandedHeight: MiniPlayAppBar.expandedHeight,
            collapsedHeight: MiniPlayAppBar.collapsedHeight,
            flexibleSpace: MiniPlayAppBar(
              onMenuTap: onMenuTap,
              onProfileTap: onProfileTap,
            ),
          ),
          if (games.isEmpty)
            SliverFillRemaining(
              child: Center(child: Text(l10n.homeNoGames)),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(HubTheme.gridPadding),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: HubTheme.gridSpacing,
                  crossAxisSpacing: HubTheme.gridSpacing,
                  childAspectRatio: HubTheme.cardAspectRatio,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final game = games[index];
                    return GameCard(
                      metadata: l10n.localizedMetadata(game.metadata),
                      isFavorite: playerRepo.isFavorite(game.metadata.id),
                      onFavoriteToggle: () =>
                          playerRepo.toggleFavorite(game.metadata.id),
                      onTap: () => _openGame(context, game),
                    );
                  },
                  childCount: games.length,
                ),
              ),
            ),
        ],
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
    if (!context.mounted) return;
    _showAchievementNotifications(context);
  }

  void _showAchievementNotifications(BuildContext context) {
    final repo = context.read<AchievementsRepository>();
    final pending = repo.pendingNotifications;
    if (pending.isEmpty) return;

    final l10n = AppLocalizations.of(context);
    final label = pending.length == 1
        ? l10n.homeAchievementUnlocked(
            l10n.localizedAchievement(pending.first.definition).title,
          )
        : l10n.homeAchievementsUnlockedPlural(pending.length);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label),
        behavior: SnackBarBehavior.floating,
      ),
    );
    repo.clearPendingNotifications();
  }
}
