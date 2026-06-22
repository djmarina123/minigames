import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../game_metadata.dart';
import '../../theme/game_card_art.dart';
import '../../theme/game_ui.dart';
import '../../theme/hub_theme.dart';

/// AppBar estilizada para sessões de jogo — título + placar ao vivo.
class GameSessionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GameSessionAppBar({
    super.key,
    required this.metadata,
    required this.scoreListenable,
  });

  final GameMetadata metadata;
  final ValueListenable<int> scoreListenable;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: GameUi.surfaceDark,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameCatalogThumbnail(
            gameId: metadata.id,
            theme: HubTheme.themeFor(metadata),
            size: 38,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  metadata.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  metadata.category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ValueListenableBuilder<int>(
          valueListenable: scoreListenable,
          builder: (_, score, child) => _LiveScoreBadge(score: score),
        ),
        const SizedBox(width: 12),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [GameUi.purple, GameUi.teal, GameUi.gold],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveScoreBadge extends StatelessWidget {
  const _LiveScoreBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Container(
        key: ValueKey(score),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              GameUi.purple.withValues(alpha: 0.45),
              GameUi.purpleLight.withValues(alpha: 0.25),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GameUi.gold.withValues(alpha: 0.45)),
          boxShadow: [
            BoxShadow(
              color: GameUi.purple.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, size: 16, color: GameUi.gold.withValues(alpha: 0.95)),
            const SizedBox(width: 5),
            Text(
              _formatScore(score),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatScore(int score) {
    if (score >= 10000) return '${(score / 1000).toStringAsFixed(1)}k';
    return score.toString();
  }
}
