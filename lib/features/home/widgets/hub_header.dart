import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/player_profile.dart';
import '../../../core/progression/missions_repository.dart';
import '../../../core/storage/player_repository.dart';
import '../../../core/theme/hub_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'daily_missions_sheet.dart';

/// Barra superior do hub: menu, nível, moedas, presente, metas, remover ads.
class HubHeader extends StatelessWidget {
  const HubHeader({
    super.key,
    this.onMenuTap,
    this.onProfileTap,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = context.watch<PlayerRepository>().profile;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(Icons.menu_rounded, size: 28),
            color: HubTheme.headerIcon,
          ),
          const Spacer(),
          _LevelPill(
            profile: profile,
            onTap: onProfileTap,
          ),
          const SizedBox(width: 6),
          const _CoinPill(),
          const SizedBox(width: 6),
          const _DailyRewardButton(),
          const _MissionsButton(),
          const SizedBox(width: 6),
          _RemoveAdsButton(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.homeRemoveAdsComingSoon),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({
    required this.profile,
    this.onTap,
  });

  final PlayerProfile profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HubTheme.levelPillBg,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: _LevelRing(
            level: profile.level,
            progress: profile.levelProgress,
          ),
        ),
      ),
    );
  }
}

class _LevelRing extends StatelessWidget {
  const _LevelRing({
    required this.level,
    required this.progress,
  });

  final int level;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: 2.5,
            backgroundColor: HubTheme.removeAdsPurple.withValues(alpha: 0.18),
            color: HubTheme.removeAdsPurple,
          ),
          Text(
            '$level',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: HubTheme.removeAdsPurple,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinPill extends StatelessWidget {
  const _CoinPill();

  @override
  Widget build(BuildContext context) {
    final coins = context.watch<PlayerRepository>().profile.coins;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: HubTheme.coinPillBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: HubTheme.coinGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(HubTheme.coinIcon, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Text(
            '$coins',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: HubTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyRewardButton extends StatelessWidget {
  const _DailyRewardButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final playerRepo = context.watch<PlayerRepository>();
    if (!playerRepo.canClaimDaily) return const SizedBox.shrink();

    final amount = playerRepo.dailyRewardAmount;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Tooltip(
        message: l10n.hubDailyRewardTooltip(amount),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final reward =
                  await context.read<PlayerRepository>().claimDailyReward();
              if (context.mounted && reward != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.dailyRewardClaimed(reward)),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    HubTheme.dailyRewardIcon,
                    size: 28,
                    color: HubTheme.dailyRewardAccent,
                  ),
                  Positioned(
                    top: -5,
                    right: -10,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: HubTheme.dailyRewardAccent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        '+$amount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MissionsButton extends StatelessWidget {
  const _MissionsButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final missionsRepo = context.watch<MissionsRepository>();
    final missions = missionsRepo.todayMissions;
    if (missions.isEmpty || missions.every((mission) => mission.claimed)) {
      return const SizedBox.shrink();
    }

    final doneCount = missions.where((mission) => mission.isComplete).length;
    final hasClaimable = missionsRepo.hasClaimable;
    final badgeLabel = hasClaimable ? '!' : '$doneCount/${missions.length}';

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: _HubActionChip(
        tooltip: l10n.hubMissionsTooltip,
        leading: Icon(
          HubTheme.missionIcon,
          size: 22,
          color: HubTheme.missionAccent,
        ),
        backgroundColor: HubTheme.missionPillBg,
        borderColor: hasClaimable
            ? HubTheme.coinGold
            : HubTheme.missionAccent.withValues(alpha: 0.3),
        badgeLabel: badgeLabel,
        badgeColor: hasClaimable ? HubTheme.coinGold : HubTheme.missionAccent,
        badgeTextColor:
            hasClaimable ? HubTheme.textPrimary : Colors.white,
        onTap: () => showDailyMissionsSheet(context),
      ),
    );
  }
}

class _HubActionChip extends StatelessWidget {
  const _HubActionChip({
    required this.tooltip,
    required this.leading,
    required this.backgroundColor,
    required this.borderColor,
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.onTap,
  });

  final String tooltip;
  final Widget leading;
  final Color backgroundColor;
  final Color borderColor;
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                leading,
                Positioned(
                  top: -9,
                  right: -12,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      badgeLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: badgeTextColor,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoveAdsButton extends StatelessWidget {
  const _RemoveAdsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: AppLocalizations.of(context).homeRemoveAdsTooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: HubTheme.removeAdsPurple.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.campaign_outlined,
              size: 22,
              color: HubTheme.removeAdsPurple.withValues(alpha: 0.85),
            ),
          ),
        ),
      ),
    );
  }
}
