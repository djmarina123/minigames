import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/player_repository.dart';
import '../../../../core/theme/hub_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'top_action_button.dart';

/// Botão de presente diário na linha 3 da app bar.
class DailyGiftButton extends StatelessWidget {
  const DailyGiftButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final playerRepo = context.watch<PlayerRepository>();
    final canClaim = playerRepo.canClaimDaily;
    final amount = playerRepo.dailyRewardAmount;

    return TopActionButton(
      icon: HubTheme.dailyRewardIcon,
      label: l10n.hubActionDaily,
      iconColor: HubTheme.dailyRewardAccent,
      tooltip: canClaim ? l10n.hubDailyRewardTooltip(amount) : null,
      badge: canClaim ? '●' : null,
      onTap: () async {
        if (!canClaim) return;
        final reward = await context.read<PlayerRepository>().claimDailyReward();
        if (context.mounted && reward != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.dailyRewardClaimed(reward)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }
}
