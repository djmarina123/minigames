import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/hub_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Botão circular de favorito — glass discreto, canto superior direito do card.
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = HubTheme.favoriteButtonSize,
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
        tween: Tween(begin: 1.0, end: widget.isFavorite ? 1.15 : 1.0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: widget.isFavorite ? 1.0 : 0.9,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Material(
                color: Colors.white.withValues(alpha: 0.14),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: widget.onTap,
                  customBorder: const CircleBorder(),
                  splashColor: Colors.white.withValues(alpha: 0.18),
                  highlightColor: Colors.white.withValues(alpha: 0.08),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                        width: 0.8,
                      ),
                    ),
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
                            : Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
