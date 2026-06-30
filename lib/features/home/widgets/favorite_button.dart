import 'package:flutter/material.dart';

import '../../../core/theme/hub_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Botão circular de favorito — discreto, canto superior direito do card.
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 26,
  });

  final bool isFavorite;
  final VoidCallback onTap;
  final double size;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    final label = widget.isFavorite
        ? AppLocalizations.of(context).favoriteRemove
        : AppLocalizations.of(context).favoriteAdd;
    final iconSize = widget.size * 0.54;

    return Semantics(
      button: true,
      label: label,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(widget.isFavorite),
        tween: Tween(begin: 1.0, end: widget.isFavorite ? 1.18 : 1.0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: widget.isFavorite ? 1.0 : 0.88,
          child: Material(
            color: Colors.black.withValues(alpha: 0.12),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Icon(
                  widget.isFavorite
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: iconSize,
                  color: widget.isFavorite
                      ? HubTheme.coinGold
                      : Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
