import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/player_repository.dart';
import '../../../../core/theme/hub_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'player_stat_chip.dart';

/// Linha 2 da app bar — chips de nível e moedas.
class PlayerStatsRow extends StatelessWidget {
  const PlayerStatsRow({
    super.key,
    this.onProfileTap,
  });

  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = context.watch<PlayerRepository>().profile;

    return Row(
      children: [
        Expanded(
          child: PlayerStatChip(
            icon: HubTheme.levelIcon,
            iconColor: HubTheme.removeAdsPurple,
            iconBackground: HubTheme.removeAdsPurple.withValues(alpha: 0.15),
            backgroundColor: HubTheme.levelPillBg,
            label: l10n.hubStatLevel,
            value: '${profile.level}',
            onTap: onProfileTap,
          ),
        ),
        const SizedBox(width: HubTheme.appBarChipSpacing),
        Expanded(
          child: PlayerStatChip(
            icon: HubTheme.coinIcon,
            iconColor: Colors.white,
            iconBackground: HubTheme.coinGold,
            backgroundColor: HubTheme.coinPillBg,
            label: l10n.hubStatCoins,
            value: '${profile.coins}',
          ),
        ),
      ],
    );
  }
}
