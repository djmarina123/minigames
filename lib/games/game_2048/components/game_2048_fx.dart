import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_2048_config.dart';

/// Brilho rápido ao fundir duas peças.
class Game2048MergeBurst extends PositionComponent {
  Game2048MergeBurst({required super.position})
      : super(size: Vector2.all(8), anchor: Anchor.center);

  static const _duration = 0.32;
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
    final expand = 8 + t * 28;
    final center = Offset(size.x / 2, size.y / 2);

    canvas.drawCircle(
      center,
      expand,
      Paint()
        ..color = Game2048Config.mergeGlow.withValues(alpha: alpha * 0.5),
    );
    canvas.drawCircle(
      center,
      expand * 0.55,
      Paint()
        ..color = Game2048Config.accentColor.withValues(alpha: alpha * 0.75),
    );
  }
}

/// Texto flutuante "+8" ou feedback de movimento inválido.
class Game2048FloatingLabel extends PositionComponent {
  Game2048FloatingLabel({
    required super.position,
    required this.text,
    required this.color,
  }) : super(size: Vector2(96, 36), anchor: Anchor.center);

  final String text;
  final Color color;

  static const _duration = 0.7;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    position.y -= dt * 32;
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
          fontSize: 16,
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
      Offset(size.x / 2 - painter.width / 2, size.y / 2 - painter.height / 2),
    );
  }
}
