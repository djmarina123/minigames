import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
              child: Text(
                'PERFIL',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: HubTheme.textPrimary,
                    ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _ProfileHero(level: player.level),
                  const SizedBox(height: 24),
                  _StatTile(
                    icon: Icons.monetization_on,
                    label: 'Moedas',
                    value: '${player.coins}',
                    accent: HubTheme.coinGold,
                  ),
                  _StatTile(
                    icon: Icons.star,
                    label: 'XP',
                    value: '${player.xp}',
                    accent: HubTheme.removeAdsPurple,
                  ),
                  _StatTile(
                    icon: Icons.military_tech,
                    label: 'Nível',
                    value: '${player.level}',
                    accent: const Color(0xFF00B894),
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
  const _ProfileHero({required this.level});

  final int level;

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
        ],
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
