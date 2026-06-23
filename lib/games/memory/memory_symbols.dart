import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' show Colors;

/// Identificadores dos pares — ícones vetoriais desenhados na frente da carta.
enum MemorySymbolId {
  gamepad,
  target,
  dice,
  palette,
  mask,
  guitar,
  rocket,
  balloon,
  star,
}

class _SymbolStyle {
  const _SymbolStyle(this.bg, this.primary, this.secondary);

  /// Fundo saturado da carta (área colorida grande).
  final Color bg;
  final Color primary;
  final Color secondary;
}

/// Cores bem distintas entre si — não derivadas só do roxo/coral do hub.
const _symbolStyles = <MemorySymbolId, _SymbolStyle>{
  MemorySymbolId.gamepad: _SymbolStyle(
    Color(0xFF5C6BC0),
    Color(0xFFFFFFFF),
    Color(0xFFFFD54F),
  ),
  MemorySymbolId.target: _SymbolStyle(
    Color(0xFFE53935),
    Color(0xFFFFFFFF),
    Color(0xFFFFEB3B),
  ),
  MemorySymbolId.dice: _SymbolStyle(
    Color(0xFFFF7043),
    Color(0xFFFFFFFF),
    Color(0xFF5D4037),
  ),
  MemorySymbolId.palette: _SymbolStyle(
    Color(0xFF8E24AA),
    Color(0xFFFFFFFF),
    Color(0xFFFFEB3B),
  ),
  MemorySymbolId.mask: _SymbolStyle(
    Color(0xFF00897B),
    Color(0xFFFFFFFF),
    Color(0xFFFFB74D),
  ),
  MemorySymbolId.guitar: _SymbolStyle(
    Color(0xFF558B2F),
    Color(0xFFFFFFFF),
    Color(0xFF5D4037),
  ),
  MemorySymbolId.rocket: _SymbolStyle(
    Color(0xFF1E88E5),
    Color(0xFFFFFFFF),
    Color(0xFFFF7043),
  ),
  MemorySymbolId.balloon: _SymbolStyle(
    Color(0xFFD81B60),
    Color(0xFFFFFFFF),
    Color(0xFFFFCDD2),
  ),
  MemorySymbolId.star: _SymbolStyle(
    Color(0xFFF9A825),
    Color(0xFFFFFFFF),
    Color(0xFFFF6F00),
  ),
};

/// Pinta o símbolo preenchendo a frente inteira da carta.
void paintMemorySymbol(Canvas canvas, Rect cardRect, MemorySymbolId id) {
  final side = min(cardRect.width, cardRect.height);
  final center = cardRect.center;
  final style = _symbolStyles[id]!;
  final radius = Radius.circular(side * 0.14);

  canvas.drawRRect(
    RRect.fromRectAndRadius(cardRect, radius),
    Paint()..color = style.bg,
  );

  final iconSize = side * 0.82;
  final iconRect = Rect.fromCenter(
    center: center,
    width: iconSize,
    height: iconSize,
  );

  canvas.save();
  canvas.translate(iconRect.left, iconRect.top);
  canvas.scale(iconRect.width / 100, iconRect.height / 100);
  canvas.translate(50, 50);
  canvas.scale(1.18, 1.18);
  canvas.translate(-50, -50);

  switch (id) {
    case MemorySymbolId.gamepad:
      _paintGamepad(canvas, style);
    case MemorySymbolId.target:
      _paintTarget(canvas, style);
    case MemorySymbolId.dice:
      _paintDice(canvas, style);
    case MemorySymbolId.palette:
      _paintPalette(canvas, style);
    case MemorySymbolId.mask:
      _paintMask(canvas, style);
    case MemorySymbolId.guitar:
      _paintGuitar(canvas, style);
    case MemorySymbolId.rocket:
      _paintRocket(canvas, style);
    case MemorySymbolId.balloon:
      _paintBalloon(canvas, style);
    case MemorySymbolId.star:
      _paintStar(canvas, style);
  }

  canvas.restore();
}

void _paintGamepad(Canvas canvas, _SymbolStyle s) {
  final body = RRect.fromRectAndRadius(
    const Rect.fromLTWH(6, 38, 88, 48),
    const Radius.circular(16),
  );
  canvas.drawRRect(body, Paint()..color = s.primary);
  canvas.drawRRect(
    body,
    Paint()
      ..color = s.bg.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(18, 54, 12, 18),
      const Radius.circular(3),
    ),
    Paint()..color = s.bg,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(14, 58, 20, 10),
      const Radius.circular(3),
    ),
    Paint()..color = s.bg,
  );
  for (final o in [Offset(66, 54), Offset(80, 54), Offset(73, 68)]) {
    canvas.drawCircle(o, 7, Paint()..color = s.secondary);
  }
}

void _paintTarget(Canvas canvas, _SymbolStyle s) {
  const center = Offset(50, 50);
  final rings = [
    (38.0, s.primary),
    (28.0, s.bg.withValues(alpha: 0.85)),
    (18.0, s.primary),
    (8.0, s.secondary),
  ];
  for (final (r, color) in rings) {
    canvas.drawCircle(center, r, Paint()..color = color);
  }
}

void _paintDice(Canvas canvas, _SymbolStyle s) {
  final rect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(16, 16, 68, 68),
    const Radius.circular(14),
  );
  canvas.drawRRect(rect, Paint()..color = s.primary);
  canvas.drawRRect(
    rect,
    Paint()
      ..color = s.secondary.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3,
  );
  final dot = Paint()..color = s.secondary;
  for (final o in [
    const Offset(32, 32),
    const Offset(68, 32),
    const Offset(50, 50),
    const Offset(32, 68),
    const Offset(68, 68),
  ]) {
    canvas.drawCircle(o, 7, dot);
  }
}

void _paintPalette(Canvas canvas, _SymbolStyle s) {
  final path = Path()
    ..moveTo(78, 32)
    ..quadraticBezierTo(96, 52, 78, 78)
    ..quadraticBezierTo(44, 96, 16, 70)
    ..quadraticBezierTo(2, 48, 24, 24)
    ..quadraticBezierTo(48, 6, 78, 32)
    ..close();
  canvas.drawPath(path, Paint()..color = s.primary);
  canvas.drawPath(
    path,
    Paint()
      ..color = s.bg.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3,
  );
  final dotColors = [
    const Color(0xFFE53935),
    const Color(0xFF43A047),
    const Color(0xFF1E88E5),
    s.secondary,
  ];
  final positions = [
    const Offset(34, 40),
    const Offset(54, 32),
    const Offset(62, 54),
    const Offset(38, 62),
  ];
  for (var i = 0; i < dotColors.length; i++) {
    canvas.drawCircle(positions[i], 8, Paint()..color = dotColors[i]);
  }
}

void _paintMask(Canvas canvas, _SymbolStyle s) {
  final path = Path()
    ..moveTo(12, 44)
    ..quadraticBezierTo(50, 10, 88, 44)
    ..quadraticBezierTo(96, 72, 50, 92)
    ..quadraticBezierTo(4, 72, 12, 44)
    ..close();
  canvas.drawPath(path, Paint()..color = s.primary);
  canvas.drawPath(
    path,
    Paint()
      ..color = s.bg.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5,
  );
  canvas.drawOval(
    const Rect.fromLTWH(28, 46, 18, 24),
    Paint()..color = s.bg,
  );
  canvas.drawOval(
    const Rect.fromLTWH(54, 46, 18, 24),
    Paint()..color = s.bg,
  );
  final smile = Path()
    ..moveTo(32, 72)
    ..quadraticBezierTo(50, 86, 68, 72);
  canvas.drawPath(
    smile,
    Paint()
      ..color = s.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round,
  );
}

void _paintGuitar(Canvas canvas, _SymbolStyle s) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(40, 6, 20, 54),
      const Radius.circular(5),
    ),
    Paint()..color = s.secondary,
  );
  final body = RRect.fromRectAndRadius(
    const Rect.fromLTWH(12, 54, 76, 40),
    const Radius.circular(20),
  );
  canvas.drawRRect(body, Paint()..color = s.primary);
  canvas.drawCircle(
    const Offset(50, 64),
    12,
    Paint()..color = s.bg.withValues(alpha: 0.45),
  );
  canvas.drawLine(
    const Offset(50, 12),
    const Offset(50, 54),
    Paint()
      ..color = s.primary.withValues(alpha: 0.7)
      ..strokeWidth = 3,
  );
}

void _paintRocket(Canvas canvas, _SymbolStyle s) {
  final body = Path()
    ..moveTo(50, 8)
    ..lineTo(78, 62)
    ..lineTo(22, 62)
    ..close();
  canvas.drawPath(body, Paint()..color = s.primary);
  canvas.drawCircle(
    const Offset(50, 38),
    12,
    Paint()..color = s.bg.withValues(alpha: 0.55),
  );
  for (final path in [
    Path()
      ..moveTo(22, 62)
      ..lineTo(8, 82)
      ..lineTo(34, 66)
      ..close(),
    Path()
      ..moveTo(78, 62)
      ..lineTo(92, 82)
      ..lineTo(66, 66)
      ..close(),
  ]) {
    canvas.drawPath(path, Paint()..color = s.secondary);
  }
  canvas.drawOval(
    const Rect.fromLTWH(42, 62, 16, 22),
    Paint()..color = s.secondary,
  );
}

void _paintBalloon(Canvas canvas, _SymbolStyle s) {
  canvas.drawOval(
    const Rect.fromLTWH(22, 6, 56, 68),
    Paint()..color = s.primary,
  );
  canvas.drawOval(
    const Rect.fromLTWH(30, 14, 18, 26),
    Paint()..color = s.secondary.withValues(alpha: 0.45),
  );
  final knot = Path()
    ..moveTo(50, 74)
    ..lineTo(42, 86)
    ..lineTo(58, 86)
    ..close();
  canvas.drawPath(knot, Paint()..color = s.primary);
  canvas.drawLine(
    const Offset(50, 86),
    const Offset(50, 98),
    Paint()
      ..color = s.primary
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round,
  );
}

void _paintStar(Canvas canvas, _SymbolStyle s) {
  final path = _starPath(const Offset(50, 48), 40, 17, 5);
  canvas.drawPath(path, Paint()..color = s.primary);
  canvas.drawPath(
    path,
    Paint()
      ..color = s.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3,
  );
}

Path _starPath(Offset center, double outerR, double innerR, int points) {
  final path = Path();
  final step = pi / points;
  for (var i = 0; i < points * 2; i++) {
    final r = i.isEven ? outerR : innerR;
    final angle = -pi / 2 + i * step;
    final point = Offset(
      center.dx + cos(angle) * r,
      center.dy + sin(angle) * r,
    );
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  path.close();
  return path;
}
