import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../solitaire_config.dart';

class SolitaireFloatingLabel extends PositionComponent {
  SolitaireFloatingLabel({
    required super.position,
    required this.text,
    required this.color,
  }) : super(size: Vector2(120, 36), anchor: Anchor.center);

  final String text;
  final Color color;

  static const _duration = 0.75;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    position.y -= dt * 28;
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
          fontSize: 15,
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
      Offset(-painter.width / 2, -painter.height / 2),
    );
  }
}

class SolitaireMoveBurst extends PositionComponent {
  SolitaireMoveBurst({required super.position})
      : super(size: Vector2.all(8), anchor: Anchor.center);

  static const _duration = 0.3;
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
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(
      center,
      expand,
      Paint()
        ..color = SolitaireConfig.successGlow.withValues(alpha: alpha * 0.55),
    );
  }
}
