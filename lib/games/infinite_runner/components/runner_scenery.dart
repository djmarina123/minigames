import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../infinite_runner_config.dart';

/// Céu, colinas e detalhes de fundo com parallax.
abstract final class RunnerScenery {
  static void paintSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            InfiniteRunnerConfig.skyTop,
            InfiniteRunnerConfig.skyMid,
            InfiniteRunnerConfig.skyBottom,
          ],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    // Sol
    final sunCenter = Offset(size.width * 0.78, size.height * 0.14);
    canvas.drawCircle(
      sunCenter,
      38,
      Paint()..color = InfiniteRunnerConfig.sunGlow.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      sunCenter,
      26,
      Paint()..color = InfiniteRunnerConfig.sunCore,
    );
    canvas.drawCircle(
      sunCenter,
      26,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  static void paintHills(
    Canvas canvas,
    Size size,
    double groundY, {
    required double scroll,
    required double speedFactor,
  }) {
    _paintHillLayer(
      canvas,
      size,
      groundY,
      offset: scroll * 0.18 * speedFactor,
      baseY: 0.14,
      amplitude: 0.09,
      color: InfiniteRunnerConfig.hillFar,
      frequency: 1.1,
    );
    _paintHillLayer(
      canvas,
      size,
      groundY,
      offset: scroll * 0.32 * speedFactor,
      baseY: 0.08,
      amplitude: 0.11,
      color: InfiniteRunnerConfig.hillNear,
      frequency: 1.6,
    );
  }

  static void _paintHillLayer(
    Canvas canvas,
    Size size,
    double groundY, {
    required double offset,
    required double baseY,
    required double amplitude,
    required Color color,
    required double frequency,
  }) {
    final path = Path()..moveTo(0, groundY);
    final hillTop = groundY - size.height * baseY;
    final amp = size.height * amplitude;

    for (var x = 0.0; x <= size.width; x += 6) {
      final nx = (x + offset) / size.width;
      final y = hillTop +
          math.sin(nx * math.pi * 2 * frequency) * amp * 0.55 +
          math.sin(nx * math.pi * 4.2 + 1.2) * amp * 0.3;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, groundY);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  static void paintClouds(
    Canvas canvas,
    Size size, {
    required double offset,
    required double layer,
  }) {
    final alpha = layer == 0 ? 0.55 : 0.35;
    final scale = layer == 0 ? 1.0 : 0.72;
    final speedMul = layer == 0 ? 1.0 : 0.55;
    final paint = Paint()..color = Colors.white.withValues(alpha: alpha);

    final specs = [
      (0.12, 0.16, 1.0),
      (0.42, 0.11, 0.85),
      (0.68, 0.19, 1.1),
      (0.88, 0.13, 0.75),
    ];

    for (final (fx, fy, fr) in specs) {
      final cx =
          ((fx * size.width - offset * speedMul) % (size.width + 120)) - 30;
      final cy = size.height * fy;
      _drawCloud(canvas, Offset(cx, cy), 22 * fr * scale, paint);
    }
  }

  static void _drawCloud(Canvas canvas, Offset c, double r, Paint paint) {
    canvas.drawCircle(c, r * 0.55, paint);
    canvas.drawCircle(c + Offset(r * 0.55, r * 0.05), r * 0.42, paint);
    canvas.drawCircle(c - Offset(r * 0.48, r * 0.08), r * 0.36, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c + Offset(0, r * 0.12),
          width: r * 1.5,
          height: r * 0.55,
        ),
        Radius.circular(r * 0.2),
      ),
      paint,
    );
  }

  static void paintGround(
    Canvas canvas,
    Size size,
    double groundY, {
    required double scrollOffset,
  }) {
    final groundRect = Rect.fromLTWH(0, groundY, size.width, size.height - groundY);
    canvas.drawRect(
      groundRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            InfiniteRunnerConfig.groundGrass,
            InfiniteRunnerConfig.groundTop,
            InfiniteRunnerConfig.groundBottom,
          ],
          stops: [0.0, 0.12, 1.0],
        ).createShader(groundRect),
    );

    // Faixa de grama no topo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-2, groundY - 3, size.width + 4, 10),
        const Radius.circular(4),
      ),
      Paint()..color = InfiniteRunnerConfig.groundGrass.withValues(alpha: 0.9),
    );

    canvas.drawLine(
      Offset(0, groundY),
      Offset(size.width, groundY),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..strokeWidth = 2.5,
    );

    // Pista compactada onde o personagem corre
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, 20),
      Paint()..color = InfiniteRunnerConfig.groundTop.withValues(alpha: 0.72),
    );
    canvas.drawLine(
      Offset(0, groundY + 20),
      Offset(size.width, groundY + 20),
      Paint()
        ..color = InfiniteRunnerConfig.blendColor.withValues(alpha: 0.2)
        ..strokeWidth = 1,
    );

    // Marcas no trilho
    final markPaint = Paint()
      ..color = InfiniteRunnerConfig.blendColor.withValues(alpha: 0.22);
    const spacing = 56.0;
    for (var x = -scrollOffset % spacing; x < size.width; x += spacing) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, groundY + 14, 24, 5),
          const Radius.circular(2.5),
        ),
        markPaint,
      );
    }

    // Tufos de grama
    final tuftPaint = Paint()..color = InfiniteRunnerConfig.groundGrassDark;
    for (var x = -scrollOffset % 34; x < size.width; x += 34) {
      for (var i = 0; i < 3; i++) {
        final tx = x + i * 7;
        final th = 6.0 + (i % 2) * 3;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(tx, groundY - th + 1, 4, th),
            const Radius.circular(2),
          ),
          tuftPaint,
        );
      }
    }
  }
}
