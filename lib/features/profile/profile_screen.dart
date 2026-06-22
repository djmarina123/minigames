import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/storage/player_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerRepository>().profile;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CircleAvatar(
            radius: 40,
            child: Text(
              '${player.level}',
              style: theme.textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Jogador',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          _StatTile(
            icon: Icons.monetization_on,
            label: 'Moedas',
            value: '${player.coins}',
          ),
          _StatTile(
            icon: Icons.star,
            label: 'XP',
            value: '${player.xp}',
          ),
          _StatTile(
            icon: Icons.military_tech,
            label: 'Nível',
            value: '${player.level}',
          ),
          _StatTile(
            icon: Icons.videogame_asset,
            label: 'Partidas jogadas',
            value: '${player.gamesPlayed}',
          ),
          _StatTile(
            icon: Icons.local_fire_department,
            label: 'Sequência diária',
            value: '${player.dailyStreak} dias',
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
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
