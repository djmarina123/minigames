import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/progression/mission_models.dart';
import '../../../core/progression/missions_repository.dart';
import '../../../core/theme/hub_theme.dart';
import '../../../l10n/app_localizations.dart';

const _missionCompleteGreen = Color(0xFF00B894);

/// Faixa compacta de missões diárias — toque abre detalhes no bottom sheet.
class DailyMissionsBanner extends StatelessWidget {
  const DailyMissionsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final missionsRepo = context.watch<MissionsRepository>();
    final missions = missionsRepo.todayMissions;
    if (missions.isEmpty) return const SizedBox.shrink();
    if (missions.every((mission) => mission.claimed)) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final doneCount = missions.where((mission) => mission.isComplete).length;
    final hasClaimable = missionsRepo.hasClaimable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => showDailyMissionsSheet(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasClaimable ? HubTheme.coinGold : HubTheme.cardBorder,
                width: hasClaimable ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.flag_rounded,
                  color: HubTheme.removeAdsPurple,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.missionsTodayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: HubTheme.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '$doneCount/${missions.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: HubTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                for (var i = 0; i < missions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  _MissionProgressChip(progress: missions[i]),
                ],
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: HubTheme.textSecondary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MissionProgressChip extends StatelessWidget {
  const _MissionProgressChip({required this.progress});

  final MissionProgress progress;

  @override
  Widget build(BuildContext context) {
    final def = AppLocalizations.of(context).localizedMission(progress.definition);
    final done = progress.isComplete;
    final claimed = progress.claimed;
    final ringColor = claimed || done
        ? _missionCompleteGreen
        : HubTheme.removeAdsPurple;

    return SizedBox(
      width: 34,
      height: 34,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: claimed ? 1 : progress.ratio,
              strokeWidth: 2.5,
              backgroundColor: HubTheme.background,
              color: ringColor,
            ),
          ),
          Center(
            child: claimed
                ? const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: _missionCompleteGreen,
                  )
                : Text(def.emoji, style: const TextStyle(fontSize: 14)),
          ),
          if (progress.canClaim)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: HubTheme.coinGold,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> showDailyMissionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    color: HubTheme.removeAdsPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: HubTheme.removeAdsPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.missionsTodayTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: HubTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < missions.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _MissionDetailRow(
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
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: HubTheme.removeAdsPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l10n.dialogGotIt,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionDetailRow extends StatelessWidget {
  const _MissionDetailRow({
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HubTheme.cardBorder, width: 2),
      ),
      child: Row(
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
                    fontSize: 14,
                    color: HubTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  def.description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: HubTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.ratio,
                    minHeight: 6,
                    backgroundColor: HubTheme.background,
                    color: done ? _missionCompleteGreen : HubTheme.removeAdsPurple,
                  ),
                ),
                const SizedBox(height: 4),
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
            const Icon(Icons.check_circle, color: _missionCompleteGreen, size: 22)
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
      ),
    );
  }
}
