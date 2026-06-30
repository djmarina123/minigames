import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/hub_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Botão circular de favorito — canto inferior direito do card.
///
/// Scrim escuro quando inativo; pill dourado + brilho quando favorito.
/// Área de toque 48×48; visual [HubTheme.favoriteButtonSize].
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
  static const _hitAreaSize = 48.0;

  late final AnimationController _animController;
  late final Animation<double> _favoriteScaleAnim;
  late final Animation<double> _unfavoriteScaleAnim;
  late final Animation<double> _rotateAnim;
  bool _addingFavorite = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _favoriteScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 55),
    ]).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));
    _unfavoriteScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _rotateAnim = Tween<double>(begin: 0, end: 0.12).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite && !oldWidget.isFavorite) {
      _addingFavorite = true;
      _animController.forward(from: 0);
    } else if (!widget.isFavorite && oldWidget.isFavorite) {
      _addingFavorite = false;
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap();
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
      child: SizedBox(
        width: _hitAreaSize,
        height: _hitAreaSize,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleTap,
            customBorder: const CircleBorder(),
            splashColor: Colors.white.withValues(alpha: 0.14),
            highlightColor: Colors.white.withValues(alpha: 0.06),
            child: Center(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final scale = _animController.isAnimating
                      ? (_addingFavorite
                          ? _favoriteScaleAnim.value
                          : _unfavoriteScaleAnim.value)
                      : 1.0;
                  final rotate = _animController.isAnimating && _addingFavorite
                      ? _rotateAnim.value
                      : 0.0;
                  return Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: rotate,
                      child: child,
                    ),
                  );
                },
                child: _FavoriteButtonFace(
                  isFavorite: widget.isFavorite,
                  size: widget.size,
                  iconSize: iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteButtonFace extends StatelessWidget {
  const _FavoriteButtonFace({
    required this.isFavorite,
    required this.size,
    required this.iconSize,
  });

  final bool isFavorite;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isFavorite
            ? [
                BoxShadow(
                  color: HubTheme.coinGold.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: isFavorite ? _buildFavorited() : _buildUnfavorited(),
      ),
    );
  }

  Widget _buildUnfavorited() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.32),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 0.7,
          ),
        ),
        child: Icon(
          Icons.star_outline_rounded,
          size: iconSize,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }

  Widget _buildFavorited() {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            HubTheme.removeAdsGoldMid,
            HubTheme.removeAdsGoldBg,
          ],
        ),
        border: Border.all(
          color: HubTheme.removeAdsGoldBorder.withValues(alpha: 0.7),
          width: 0.8,
        ),
      ),
      child: Icon(
        Icons.star_rounded,
        size: iconSize,
        color: HubTheme.coinGold,
      ),
    );
  }
}
