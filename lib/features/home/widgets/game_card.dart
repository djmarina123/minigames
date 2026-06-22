import 'package:flutter/material.dart';

import '../../../core/game_sdk/game_metadata.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.metadata,
    required this.onTap,
  });

  final GameMetadata metadata;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(metadata.icon),
        ),
        title: Text(metadata.title),
        subtitle: Text(metadata.description),
        trailing: metadata.featured
            ? Chip(
                label: const Text('Destaque'),
                visualDensity: VisualDensity.compact,
                labelStyle: theme.textTheme.labelSmall,
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
