import 'package:flutter/material.dart';

import '../../../../core/theme/hub_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'top_action_button.dart';

/// Botão destacado para remover anúncios na linha 3 da app bar.
class RemoveAdsButton extends StatelessWidget {
  const RemoveAdsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TopActionButton(
      icon: Icons.block_rounded,
      label: l10n.hubActionNoAds,
      iconColor: HubTheme.removeAdsPurple,
      iconSize: 28,
      backgroundColor: HubTheme.removeAdsGoldBg,
      borderColor: HubTheme.removeAdsGoldBorder.withValues(alpha: 0.72),
      highlighted: true,
      premium: true,
      tooltip: l10n.homeRemoveAdsTooltip,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.homeRemoveAdsComingSoon),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}
