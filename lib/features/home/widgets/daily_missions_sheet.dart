import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/progression/mission_models.dart';
import '../../../core/progression/missions_repository.dart';
import '../../../core/theme/hub_theme.dart';
import '../../../l10n/app_localizations.dart';

const _missionCompleteGreen = Color(0xFF00B894);

Future<void> showDailyMissionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: HubTheme.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => const _DailyMissionsSheet(),
  );
}

class _DailyMissionsSheet extends StatelessWidget {
  const _DailyMissionsSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final missionsRepo = context.watch<MissionsRepository>();
    final missions = missionsRepo.todayMissions;
    final doneCount = missions.where((mission) => mission.isComplete).length;
    final overallProgress = missions.isEmpty
        ? 0.0
        : doneCount / missions.length;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return SafeArea(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: HubTheme.textSecondary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: HubTheme.missionPillBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      HubTheme.missionIcon,
                      color: HubTheme.missionAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.missionsTodayTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: HubTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.missionsProgressSummary(doneCount, missions.length),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: HubTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: overallProgress,
                  minHeight: 8,
                  backgroundColor: Colors.white,
                  color: doneCount == missions.length
                      ? _missionCompleteGreen
                      : HubTheme.missionAccent,
                ),
              ),
              const SizedBox(height: 18),
              for (var i = 0; i < missions.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _MissionDetailCard(
                  progress: missions[i],
                  onClaim: () async {
                    final reward = await missionsRepo.claimMission(
                      missions[i].definition.id,
                    );
                    if (context.mounted && reward != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.missionCompletedReward(reward)),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MissionDetailCard extends StatelessWidget {
  const _MissionDetailCard({
    required this.progress,
    required this.onClaim,
  });

  final MissionProgress progress;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final def = l10n.localizedMission(progress.definition);
    final done = progress.isComplete;
    final claimed = progress.claimed;
    final progressColor = claimed || done
        ? _missionCompleteGreen
        : HubTheme.missionAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: progress.canClaim ? HubTheme.coinGold : HubTheme.cardBorder,
          width: progress.canClaim ? 2 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(def.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      def.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: HubTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      def.description,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: HubTheme.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (claimed)
                const Icon(
                  Icons.check_circle_rounded,
                  color: _missionCompleteGreen,
                  size: 24,
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      HubTheme.coinIcon,
                      size: 16,
                      color: HubTheme.coinGold,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '+${def.coinReward}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: HubTheme.coinGold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: claimed ? 1 : progress.ratio,
              minHeight: 8,
              backgroundColor: HubTheme.background,
              color: progressColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.current.clamp(0, def.target)} / ${def.target}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: HubTheme.textSecondary,
            ),
          ),
          if (progress.canClaim) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onClaim,
              style: FilledButton.styleFrom(
                backgroundColor: HubTheme.coinGold,
                foregroundColor: HubTheme.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.missionClaim,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
