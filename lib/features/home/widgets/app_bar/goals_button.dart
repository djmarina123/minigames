import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/progression/missions_repository.dart';
import '../../../../core/theme/hub_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../daily_missions_sheet.dart';
import 'top_action_button.dart';

/// Botão de metas diárias na linha 3 da app bar.
class GoalsButton extends StatelessWidget {
  const GoalsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final missionsRepo = context.watch<MissionsRepository>();
    final missions = missionsRepo.todayMissions;
    final hasClaimable = missionsRepo.hasClaimable;
    final claimableCount =
        missions.where((mission) => mission.canClaim).length;
    final doneCount = missions.where((mission) => mission.isComplete).length;

    String? badge;
    if (hasClaimable) {
      badge = claimableCount > 1 ? '$claimableCount' : '!';
    } else if (doneCount > 0 && missions.any((m) => !m.claimed)) {
      badge = '$doneCount';
    }

    return TopActionButton(
      icon: HubTheme.missionIcon,
      label: l10n.hubActionGoals,
      iconColor: HubTheme.missionAccent,
      tooltip: l10n.hubMissionsTooltip,
      badge: badge,
      onTap: () => showDailyMissionsSheet(context),
    );
  }
}
