import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/economy/economy_copy.dart';
import '../../core/economy/economy_help_dialog.dart';
import '../../core/storage/player_repository.dart';
import '../../core/theme/hub_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerRepository>().profile;

    return ColoredBox(
      color: HubTheme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'PERFIL',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: HubTheme.textPrimary,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Como funcionam moedas e XP',
                    onPressed: () => showEconomyHelpDialog(context),
                    icon: const Icon(Icons.help_outline_rounded),
                    color: HubTheme.textSecondary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _ProfileHero(
                    level: player.level,
                    xpInLevel: player.xpInCurrentLevel,
                    xpNeeded: player.xpNeededForNextLevel,
                    progress: player.levelProgress,
                  ),
                  const SizedBox(height: 14),
                  _EconomySummaryCard(
                    onLearnMore: () => showEconomyHelpDialog(context),
                  ),
                  const SizedBox(height: 16),
                  _StatTile(
                    icon: HubTheme.coinIcon,
                    label: 'Moedas',
                    value: '${player.coins}',
                    accent: HubTheme.coinGold,
                  ),
                  _StatTile(
                    icon: HubTheme.levelIcon,
                    label: 'XP total',
                    value: '${player.xp}',
                    accent: HubTheme.removeAdsPurple,
                  ),
                  _StatTile(
                    icon: Icons.videogame_asset,
                    label: 'Partidas jogadas',
                    value: '${player.gamesPlayed}',
                    accent: const Color(0xFFE17055),
                  ),
                  _StatTile(
                    icon: Icons.local_fire_department,
                    label: 'Sequência diária',
                    value: '${player.dailyStreak} dias',
                    accent: const Color(0xFFFDCB6E),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.level,
    required this.xpInLevel,
    required this.xpNeeded,
    required this.progress,
  });

  final int level;
  final int xpInLevel;
  final int xpNeeded;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: HubTheme.removeAdsPurple,
        borderRadius: BorderRadius.circular(HubTheme.cardRadius),
        border: Border.all(color: HubTheme.cardBorder, width: 4),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              '$level',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Jogador',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: HubTheme.coinGold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            EconomyCopy.levelProgressLabel(
              level: level,
              xpInLevel: xpInLevel,
              xpNeeded: xpNeeded,
            ),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EconomySummaryCard extends StatelessWidget {
  const _EconomySummaryCard({required this.onLearnMore});

  final VoidCallback onLearnMore;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onLearnMore,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HubTheme.cardBorder, width: 3),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: HubTheme.removeAdsPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  HubTheme.levelIcon,
                  color: HubTheme.removeAdsPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Moedas e XP',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: HubTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      EconomyCopy.profileSummary,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: HubTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: HubTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HubTheme.cardBorder, width: 3),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accent),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: HubTheme.textSecondary,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: HubTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
