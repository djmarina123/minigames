import 'package:flutter/material.dart';

import '../../../../core/theme/hub_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'daily_gift_button.dart';
import 'goals_button.dart';
import 'player_stats_row.dart';
import 'remove_ads_button.dart';

/// Top app bar do hub — 3 linhas com colapso suave da linha de ações.
class MiniPlayAppBar extends StatelessWidget {
  const MiniPlayAppBar({
    super.key,
    this.onMenuTap,
    this.onProfileTap,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;

  /// Altura total expandida (3 linhas + padding + status bar).
  static const expandedHeight = 252.0;

  /// Altura colapsada (linhas 1 e 2 + padding + status bar).
  static const collapsedHeight = 172.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final expandRange = expandedHeight - collapsedHeight;
        final t = expandRange <= 0
            ? 1.0
            : ((maxHeight - collapsedHeight) / expandRange).clamp(0.0, 1.0);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: HubTheme.appBarBackground,
            boxShadow: HubTheme.appBarShadow(),
          ),
          child: SafeArea(
            bottom: false,
            minimum: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                HubTheme.appBarHPaddingLeft,
                HubTheme.appBarVPadding,
                HubTheme.appBarHPadding,
                HubTheme.appBarVPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TitleRow(onMenuTap: onMenuTap),
                  const SizedBox(height: HubTheme.appBarLineSpacing),
                  PlayerStatsRow(onProfileTap: onProfileTap),
                  SizedBox(height: HubTheme.appBarLineSpacing * t),
                  if (t > 0.55) ...[
                    Opacity(
                      opacity: ((t - 0.55) / 0.45).clamp(0.0, 1.0),
                      child: const _ActionButtonsRow(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                onPressed: onMenuTap,
                icon: const Icon(Icons.menu_rounded, size: 26),
                color: HubTheme.headerIcon,
                tooltip:
                    MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      HubTheme.removeAdsPurple,
                      HubTheme.removeAdsPurple.withValues(alpha: 0.75),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.sports_esports_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.appName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: HubTheme.textPrimary,
                  height: 1,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: DailyGiftButton()),
        SizedBox(width: HubTheme.appBarButtonSpacing),
        Expanded(child: GoalsButton()),
        SizedBox(width: HubTheme.appBarButtonSpacing),
        Expanded(child: RemoveAdsButton()),
      ],
    );
  }
}
