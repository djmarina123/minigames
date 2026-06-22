import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../memory_config.dart';

/// Partículas rápidas ao acertar um par.
class MemoryMatchBurst extends PositionComponent {
  MemoryMatchBurst({required super.position})
      : super(size: Vector2.all(8), anchor: Anchor.center);

  static const _duration = 0.38;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final alpha = (1 - t).clamp(0.0, 1.0);
    final expand = 10 + t * 32;
    final center = Offset(size.x / 2, size.y / 2);

    canvas.drawCircle(
      center,
      expand,
      Paint()
        ..color = MemoryConfig.accentColor.withValues(alpha: alpha * 0.55),
    );
    canvas.drawCircle(
      center,
      expand * 0.55,
      Paint()
        ..color = MemoryConfig.matchGlow.withValues(alpha: alpha * 0.85),
    );
  }
}

/// Texto flutuante "+150" ou feedback de erro.
class MemoryFloatingLabel extends PositionComponent {
  MemoryFloatingLabel({
    required super.position,
    required this.text,
    required this.color,
  }) : super(size: Vector2(96, 36), anchor: Anchor.center);

  final String text;
  final Color color;

  static const _duration = 0.75;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    position.y -= dt * 36;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final alpha = (1 - _age / _duration).clamp(0.0, 1.0);
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withValues(alpha: alpha),
          fontSize: 17,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: alpha * 0.35),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(
        (size.x - painter.width) / 2,
        (size.y - painter.height) / 2,
      ),
    );
  }
}
