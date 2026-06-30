import 'package:flutter/material.dart';

import '../../../core/game_sdk/game_metadata.dart';
import '../../../core/game_sdk/game_registry.dart';
import '../../../core/theme/game_card_art.dart';
import '../../../core/theme/hub_theme.dart';
import 'favorite_button.dart';

/// Card de jogo no grid 2 colunas — ilustração grande, layout minimalista.
class GameCard extends StatefulWidget {
  const GameCard({
    super.key,
    required this.metadata,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.progress,
  });

  final GameMetadata metadata;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  /// Progresso opcional (0–1) para a barra do card; `null` = placeholder.
  final double? progress;

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = HubTheme.themeFor(widget.metadata);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              child: AnimatedScale(
                scale: _pressed ? 0.98 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(HubTheme.cardRadius),
                    boxShadow: HubTheme.cardShadow(
                      theme.cardColor,
                      pressed: _pressed,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(HubTheme.cardRadius),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: widget.onTap,
                      borderRadius:
                          BorderRadius.circular(HubTheme.cardRadius),
                      child: GameCatalogHero(
                        gameId: widget.metadata.id,
                        title: widget.metadata.title,
                        theme: theme,
                        showFeaturedBadge: GameRegistry.instance
                            .isFeatured(widget.metadata.id),
                        progress: widget.progress,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: HubTheme.cardPadding - 2,
              right: HubTheme.cardPadding - 2,
              child: FavoriteButton(
                isFavorite: widget.isFavorite,
                onTap: widget.onFavoriteToggle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
