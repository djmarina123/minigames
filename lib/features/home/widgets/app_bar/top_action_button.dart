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
    this.premium = false,
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
  final bool premium;
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
      scale: _pressed ? 0.96 : 1.0,
      duration: HubTheme.interactionDuration,
      curve: Curves.easeOut,
      child: Material(
        color: widget.premium ? Colors.transparent : background,
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
              gradient: widget.premium
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        HubTheme.removeAdsGoldBg,
                        HubTheme.removeAdsGoldMid,
                        HubTheme.removeAdsGoldBg,
                      ],
                      stops: [0, 0.5, 1],
                    )
                  : null,
              color: widget.premium ? null : background,
              border: Border.all(
                color: border,
                width: widget.highlighted ? 1.5 : 1,
              ),
              boxShadow: widget.premium
                  ? [
                      BoxShadow(
                        color: HubTheme.removeAdsGoldBorder
                            .withValues(alpha: 0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : widget.highlighted
                      ? [
                          BoxShadow(
                            color: const Color(0xFFE8A820)
                                .withValues(alpha: 0.22),
                            blurRadius: 8,
                            offset: const Offset(0, 1.5),
                          ),
                        ]
                      : HubTheme.chipShadow(),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (widget.premium)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(HubTheme.chipRadius),
                        gradient: LinearGradient(
                          begin: const Alignment(-1.2, -1.0),
                          end: const Alignment(0.6, 1.0),
                          colors: [
                            Colors.white.withValues(alpha: 0.35),
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0, 0.35, 1],
                        ),
                      ),
                    ),
                  )
                else if (widget.highlighted)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(HubTheme.chipRadius),
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.35),
                          radius: 1.1,
                          colors: [
                            const Color(0xFFFFE9A8).withValues(alpha: 0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
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
