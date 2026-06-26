import 'package:flutter/material.dart';

import '../../../core/game_sdk/game_metadata.dart';
import '../../../core/game_sdk/game_registry.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/game_card_art.dart';
import '../../../core/theme/hub_theme.dart';

/// Card de jogo no grid 2 colunas — ilustração grande integrada ao fundo.
class GameCard extends StatefulWidget {
  const GameCard({
    super.key,
    required this.metadata,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final GameMetadata metadata;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = HubTheme.themeFor(widget.metadata);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
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
                showFeaturedBadge:
                    GameRegistry.instance.isFeatured(widget.metadata.id),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: _FavoriteButton(
            isFavorite: widget.isFavorite,
            onTap: widget.onFavoriteToggle,
          ),
        ),
      ],
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.onTap,
  });

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = isFavorite
        ? AppLocalizations.of(context).favoriteRemove
        : AppLocalizations.of(context).favoriteAdd;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.black.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 22,
              color: isFavorite ? HubTheme.coinGold : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
