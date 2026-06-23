import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../snake_config.dart';

/// Partículas ao comer fruta.
class SnakeEatBurst extends PositionComponent {
  SnakeEatBurst({required super.position, required this.color})
      : super(size: Vector2.all(12), anchor: Anchor.center);

  final Color color;

  static const _duration = 0.35;
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
    final expand = 6 + t * 22;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      expand,
      Paint()..color = color.withValues(alpha: alpha * 0.65),
    );
    for (var i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      final dist = expand * 0.7;
      canvas.drawCircle(
        Offset(
          size.x / 2 + cos(angle) * dist,
          size.y / 2 + sin(angle) * dist,
        ),
        3 * (1 - t),
        Paint()..color = SnakeConfig.eatGold.withValues(alpha: alpha),
      );
    }
  }
}

/// Texto flutuante "+20" ou "Bateu!".
class SnakeFloatingLabel extends PositionComponent {
  SnakeFloatingLabel({
    required super.position,
    required this.text,
    required this.color,
  }) : super(size: Vector2(96, 32), anchor: Anchor.center);

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
          fontWeight: FontWeight.w800,
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
