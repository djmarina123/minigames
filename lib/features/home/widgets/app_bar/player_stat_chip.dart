import 'package:flutter/material.dart';

import '../../../../core/theme/hub_theme.dart';

/// Chip de informação do jogador — valor em destaque, rótulo secundário.
class PlayerStatChip extends StatefulWidget {
  const PlayerStatChip({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.backgroundColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color backgroundColor;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  State<PlayerStatChip> createState() => _PlayerStatChipState();
}

class _PlayerStatChipState extends State<PlayerStatChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bumpController;
  late final Animation<double> _bumpScale;
  String? _previousValue;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _bumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _bumpScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.06), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 55),
    ]).animate(CurvedAnimation(
      parent: _bumpController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(PlayerStatChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _previousValue) {
      _previousValue = widget.value;
      _bumpController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bumpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: _bumpScale,
      child: Material(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(HubTheme.chipRadius),
        elevation: 0,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(HubTheme.chipRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(HubTheme.chipRadius),
              boxShadow: HubTheme.chipShadow(),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: widget.iconBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        size: 12,
                        color: widget.iconColor,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.label.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: HubTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 0.6,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: HubTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
