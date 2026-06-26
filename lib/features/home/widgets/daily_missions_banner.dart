import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/progression/mission_models.dart';
import '../../../core/progression/missions_repository.dart';
import '../../../core/theme/hub_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Missões diárias compactas — abaixo da recompensa diária.
class DailyMissionsBanner extends StatelessWidget {
  const DailyMissionsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final missionsRepo = context.watch<MissionsRepository>();
    final missions = missionsRepo.todayMissions;
    if (missions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HubTheme.cardBorder, width: 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_rounded, color: HubTheme.removeAdsPurple, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.missionsTodayTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: HubTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < missions.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _MissionRow(
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
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({
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

    return Row(
      children: [
        Text(def.emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                def.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: HubTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.ratio,
                  minHeight: 6,
                  backgroundColor: HubTheme.background,
                  color: done ? const Color(0xFF00B894) : HubTheme.removeAdsPurple,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${progress.current.clamp(0, def.target)} / ${def.target}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: HubTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (progress.canClaim)
          FilledButton(
            onPressed: onClaim,
            style: FilledButton.styleFrom(
              backgroundColor: HubTheme.coinGold,
              foregroundColor: HubTheme.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.missionClaim,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          )
        else if (claimed)
          const Icon(Icons.check_circle, color: Color(0xFF00B894), size: 22)
        else
          Text(
            '+${def.coinReward}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: HubTheme.coinGold,
            ),
          ),
      ],
    );
  }
}
