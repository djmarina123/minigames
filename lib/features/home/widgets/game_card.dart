import 'package:flutter/material.dart';

import '../../../core/game_sdk/game_metadata.dart';
import '../../../core/theme/game_card_art.dart';
import '../../../core/theme/hub_theme.dart';

/// Card de jogo no grid 2 colunas — ilustração grande integrada ao fundo.
class GameCard extends StatefulWidget {
  const GameCard({
    super.key,
    required this.metadata,
    required this.onTap,
  });

  final GameMetadata metadata;
  final VoidCallback onTap;

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = HubTheme.themeFor(widget.metadata);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HubTheme.cardRadius),
            boxShadow: [
              BoxShadow(
                color: theme.cardColor.withValues(alpha: 0.35),
                blurRadius: _pressed ? 4 : 12,
                offset: Offset(0, _pressed ? 2 : 6),
              ),
            ],
          ),
          child: GameCatalogHero(
            gameId: widget.metadata.id,
            title: widget.metadata.title,
            theme: theme,
            showFeaturedBadge: widget.metadata.featured,
          ),
        ),
      ),
    );
  }
}
