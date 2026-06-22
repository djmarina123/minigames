import 'package:flutter/material.dart';

import '../game_prep.dart';
import '../../theme/game_card_art.dart';
import '../../theme/hub_theme.dart';

Future<void> showGameHelpDialog(
  BuildContext context, {
  required String gameId,
  required String gameTitle,
  required HubGameTheme theme,
  required GameHelpContent help,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _GameHelpSheet(
      gameId: gameId,
      gameTitle: gameTitle,
      theme: theme,
      help: help,
    ),
  );
}

class _GameHelpSheet extends StatelessWidget {
  const _GameHelpSheet({
    required this.gameId,
    required this.gameTitle,
    required this.theme,
    required this.help,
  });

  final String gameId;
  final String gameTitle;
  final HubGameTheme theme;
  final GameHelpContent help;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFE6E9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GameCatalogThumbnail(
                  gameId: gameId,
                  theme: theme,
                  title: gameTitle,
                  size: 72,
                  showTitle: true,
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                icon: Icons.sports_esports_outlined,
                title: 'Como jogar',
                body: help.howToPlay,
              ),
              const SizedBox(height: 16),
              _Section(
                icon: Icons.emoji_events_outlined,
                title: 'Pontuação',
                body: help.scoring,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: HubTheme.removeAdsPurple,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Entendi'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HubTheme.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: HubTheme.removeAdsPurple),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: HubTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HubTheme.textSecondary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
