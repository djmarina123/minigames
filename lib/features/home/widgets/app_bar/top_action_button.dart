import 'package:flutter/material.dart';

import '../../../../core/theme/hub_theme.dart';

/// Botão de ação da linha 3 — ícone + rótulo, com badge opcional.
class TopActionButton extends StatefulWidget {
  const TopActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.highlighted = false,
    this.badge,
    this.tooltip,
    this.iconSize = 24,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool highlighted;
  final String? badge;
  final String? tooltip;
  final double iconSize;

  @override
  State<TopActionButton> createState() => _TopActionButtonState();
}

class _TopActionButtonState extends State<TopActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = widget.iconColor ?? HubTheme.textPrimary;
    final background = widget.backgroundColor ?? HubTheme.appBarBackground;
    final border = widget.borderColor ??
        HubTheme.textPrimary.withValues(alpha: 0.08);

    final child = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(HubTheme.chipRadius),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          borderRadius: BorderRadius.circular(HubTheme.chipRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(HubTheme.chipRadius),
              border: Border.all(
                color: border,
                width: widget.highlighted ? 1.5 : 1,
              ),
              boxShadow: widget.highlighted
                  ? [
                      BoxShadow(
                        color: HubTheme.coinGold.withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: HubTheme.coinGold.withValues(alpha: 0.12),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ]
                  : HubTheme.chipShadow(),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: widget.iconSize, color: iconColor),
                    const SizedBox(height: 4),
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: HubTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (widget.badge != null)
                  Positioned(
                    top: -2,
                    right: 4,
                    child: _AnimatedBadge(label: widget.badge!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip == null) return child;

    return Tooltip(message: widget.tooltip!, child: child);
  }
}

class _AnimatedBadge extends StatefulWidget {
  const _AnimatedBadge({required this.label});

  final String label;

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDot = widget.label == '●';
    final minSize = isDot ? 8.0 : 16.0;

    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
          padding: isDot
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: isDot ? HubTheme.featuredBadge : HubTheme.coinGold,
            shape: isDot ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isDot ? null : BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: isDot
              ? null
              : Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: HubTheme.textPrimary,
                    height: 1.2,
                  ),
                ),
        ),
      ),
    );
  }
}
