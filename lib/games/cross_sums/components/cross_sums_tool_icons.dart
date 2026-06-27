import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../cross_sums_config.dart';

/// Ícones vetoriais dos botões de ferramenta (borracha, lápis, dica).
abstract final class CrossSumsToolIcons {
  static void paintEraser(
    Canvas canvas,
    Offset center, {
    required double size,
    required Color color,
    bool muted = false,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.18);

    final w = size * 0.78;
    final h = size * 0.46;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      Radius.circular(h * 0.22),
    );

    final bodyColor = muted ? color.withValues(alpha: 0.45) : color;
    canvas.drawRRect(body, Paint()..color = bodyColor);

    final sleeve = Rect.fromLTWH(-w * 0.34, -h * 0.5, w * 0.38, h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(sleeve, Radius.circular(h * 0.18)),
      Paint()..color = muted
          ? CrossSumsConfig.accentSoft.withValues(alpha: 0.35)
          : CrossSumsConfig.accentSoft,
    );

    canvas.drawLine(
      Offset(-w * 0.34, -h * 0.08),
      Offset(w * 0.38, -h * 0.08),
      Paint()
        ..color = bodyColor.withValues(alpha: muted ? 0.25 : 0.35)
        ..strokeWidth = 1.1,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.18, h * 0.14),
          width: w * 0.22,
          height: h * 0.16,
        ),
        Radius.circular(2),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: muted ? 0.15 : 0.28),
    );

    canvas.restore();
  }

  static void paintPencil(
    Canvas canvas,
    Offset center, {
    required double size,
    required Color color,
    bool muted = false,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.72);

    final len = size * 0.82;
    final halfW = size * 0.11;
    final tipLen = len * 0.22;

    final shaft = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, -tipLen * 0.35),
        width: halfW * 2,
        height: len * 0.62,
      ),
      Radius.circular(halfW),
    );
    canvas.drawRRect(
      shaft,
      Paint()
        ..color = muted
            ? CrossSumsConfig.accentColor.withValues(alpha: 0.35)
            : CrossSumsConfig.accentColor,
    );

    final tipPath = Path()
      ..moveTo(-halfW, len * 0.08)
      ..lineTo(halfW, len * 0.08)
      ..lineTo(0, len * 0.08 + tipLen)
      ..close();
    canvas.drawPath(
      tipPath,
      Paint()
        ..color = muted ? color.withValues(alpha: 0.35) : color,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -len * 0.34),
          width: halfW * 2.1,
          height: len * 0.18,
        ),
        Radius.circular(halfW * 0.6),
      ),
      Paint()
        ..color = muted
            ? CrossSumsConfig.hintPink.withValues(alpha: 0.35)
            : CrossSumsConfig.hintPink.withValues(alpha: 0.85),
    );

    canvas.restore();
  }

  static void paintHintBulb(
    Canvas canvas,
    Offset center, {
    required double size,
    Color color = Colors.white,
  }) {
    final bulbR = size * 0.28;
    final bulbCenter = center + Offset(0, -size * 0.06);

    canvas.drawCircle(
      bulbCenter,
      bulbR * 1.08,
      Paint()..color = color.withValues(alpha: 0.18),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: bulbCenter,
        width: bulbR * 2,
        height: bulbR * 2.15,
      ),
      Paint()..color = color,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + Offset(0, size * 0.24),
          width: size * 0.34,
          height: size * 0.14,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = color.withValues(alpha: 0.92),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + Offset(0, size * 0.34),
          width: size * 0.22,
          height: size * 0.05,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = color.withValues(alpha: 0.75),
    );

    for (var i = 0; i < 4; i++) {
      final angle = -math.pi / 2 + i * math.pi / 2;
      final start = bulbCenter +
          Offset(math.cos(angle), math.sin(angle)) * (bulbR + 2);
      final end = start + Offset(math.cos(angle), math.sin(angle)) * (size * 0.12);
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = color.withValues(alpha: 0.55)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}
