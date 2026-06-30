import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hub_theme.dart';

/// Fundo do hub — gradiente lavanda quase imperceptível + textura orgânica sutil.
class HubBackground extends StatelessWidget {
  const HubBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HubTheme.backgroundTop,
            HubTheme.backgroundMid,
            HubTheme.backgroundBottom,
          ],
          stops: [0, 0.45, 1],
        ),
      ),
      child: CustomPaint(
        painter: const _HubBackgroundTexturePainter(),
        child: child,
      ),
    );
  }
}

/// Manchas orgânicas e círculos grandes — opacidade máx. 3%.
class _HubBackgroundTexturePainter extends CustomPainter {
  const _HubBackgroundTexturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final blobs = [
      (0.08, 0.12, 0.42, HubTheme.removeAdsPurple),
      (0.88, 0.08, 0.35, HubTheme.headerIcon),
      (0.72, 0.55, 0.55, HubTheme.removeAdsPurple),
      (0.15, 0.78, 0.38, HubTheme.coinGold),
      (0.55, 0.92, 0.48, HubTheme.removeAdsPurple),
    ];

    for (final (fx, fy, fr, color) in blobs) {
      paint.color = color.withValues(alpha: 0.03);
      canvas.drawCircle(
        Offset(size.width * fx, size.height * fy),
        size.width * fr,
        paint,
      );
    }

    // Formas orgânicas suaves.
    paint.color = HubTheme.removeAdsPurple.withValues(alpha: 0.025);
    final path = Path()
      ..moveTo(size.width * 0.0, size.height * 0.35)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.28,
        size.width * 0.45,
        size.height * 0.38,
      )
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.48,
        size.width * 1.0,
        size.height * 0.32,
      )
      ..lineTo(size.width, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.62,
        size.width * 0.3,
        size.height * 0.52,
      )
      ..close();
    canvas.drawPath(path, paint);

    // Pontos mínimos — quase invisíveis.
    paint.color = HubTheme.textPrimary.withValues(alpha: 0.02);
    final rng = math.Random(42);
    for (var i = 0; i < 18; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        1.2 + rng.nextDouble() * 1.8,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HubBackgroundTexturePainter oldDelegate) =>
      false;
}
