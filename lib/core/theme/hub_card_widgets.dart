import 'package:flutter/material.dart';

/// Barra fina de progresso no card — placeholder ou valor real (0–1).
class GameCardProgressBar extends StatelessWidget {
  const GameCardProgressBar({
    super.key,
    this.progress,
    this.trackColor,
    this.fillColor,
  });

  /// `null` = placeholder vazio; `0.0`–`1.0` = progresso real.
  final double? progress;
  final Color? trackColor;
  final Color? fillColor;

  static const _height = 4.0;

  @override
  Widget build(BuildContext context) {
    final track = trackColor ?? Colors.white.withValues(alpha: 0.22);
    final fill = fillColor ?? Colors.white.withValues(alpha: 0.72);
    final value = progress?.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: _height,
        child: value == null
            ? ColoredBox(color: track)
            : Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: track),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: ColoredBox(color: fill),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Badge secundário pequeno no card (ex.: NEW, Popular).
class GameBadge extends StatelessWidget {
  const GameBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor = Colors.white,
  });

  const GameBadge.featured({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.textColor = Colors.white,
  });

  final String label;
  final Color? backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          height: 1,
        ),
      ),
    );
  }
}
