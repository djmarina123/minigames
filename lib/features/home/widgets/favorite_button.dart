import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/hub_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Botão circular de favorito — glass, canto inferior direito do card.
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

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _rotateAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 55),
    ]).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));
    _rotateAnim = Tween<double>(begin: 0, end: 0.12).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _opacityAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite && !oldWidget.isFavorite) {
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.isFavorite
        ? AppLocalizations.of(context).favoriteRemove
        : AppLocalizations.of(context).favoriteAdd;
    final iconSize = widget.size * 0.54;

    return Semantics(
      button: true,
      label: label,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Transform.scale(
            scale: _animController.isAnimating
                ? _scaleAnim.value
                : 1.0,
            child: Transform.rotate(
              angle: _animController.isAnimating ? _rotateAnim.value : 0,
              child: child,
            ),
          );
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: widget.isFavorite
              ? (_animController.isAnimating ? _opacityAnim.value : 1.0)
              : 0.88,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Material(
                color: Colors.white.withValues(alpha: 0.12),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                shadowColor: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  customBorder: const CircleBorder(),
                  splashColor: Colors.white.withValues(alpha: 0.16),
                  highlightColor: Colors.white.withValues(alpha: 0.06),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 0.7,
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
                            : Colors.white.withValues(alpha: 0.80),
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
