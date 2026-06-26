import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/progression/achievements_repository.dart';
import '../../../core/progression/progression_models.dart';
import '../../../core/theme/hub_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Resumo de conquistas no perfil.
class AchievementsPanel extends StatelessWidget {
  const AchievementsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = context.watch<AchievementsRepository>();
    final unlocked = repo.allUnlocked();
    final locked = repo.lockedDefinitions();

    return Container(
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.emoji_events_rounded, color: HubTheme.coinGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.achievementsTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: HubTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                '${repo.unlockedCount}/${repo.totalCount}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: HubTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (unlocked.isEmpty && locked.isEmpty)
            Text(
              l10n.achievementsEmpty,
              style: const TextStyle(color: HubTheme.textSecondary),
            ),
          for (final item in unlocked.take(4))
            _AchievementTile(
              unlocked: item,
              locked: false,
              localized: l10n.localizedAchievement(item.definition),
            ),
          for (final def in locked.take(4 - unlocked.length.clamp(0, 4)))
            _AchievementTile(
              definition: def,
              locked: true,
              localized: l10n.localizedAchievement(def),
            ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    this.unlocked,
    this.definition,
    required this.locked,
    required this.localized,
  }) : assert((unlocked != null) ^ (definition != null));

  final UnlockedAchievement? unlocked;
  final AchievementDefinition? definition;
  final bool locked;
  final AchievementDefinition localized;

  @override
  Widget build(BuildContext context) {
    final def = localized;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Opacity(
            opacity: locked ? 0.35 : 1,
            child: Text(def.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  def.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: locked
                        ? HubTheme.textSecondary
                        : HubTheme.textPrimary,
                  ),
                ),
                Text(
                  def.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: HubTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!locked)
            Text(
              '+${def.coinReward}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: HubTheme.coinGold,
              ),
            ),
        ],
      ),
    );
  }
}
