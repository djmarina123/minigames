import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../domino_config.dart';

class DominoFloatingLabel extends PositionComponent {
  DominoFloatingLabel({
    required super.position,
    required this.text,
    required this.color,
    this.fontSize = 15,
  }) : super(size: Vector2(160, 40), anchor: Anchor.center);

  final String text;
  final Color color;
  final double fontSize;

  static const _duration = 0.9;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    position.y -= dt * 24;
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
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: alpha * 0.45),
              blurRadius: 6,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: 200);
    painter.paint(
      canvas,
      Offset(-painter.width / 2, -painter.height / 2),
    );
  }
}

class DominoPlaceBurst extends PositionComponent {
  DominoPlaceBurst({
    required super.position,
    this.color,
  }) : super(size: Vector2.all(8), anchor: Anchor.center);

  final Color? color;

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
    final expand = 8 + t * 28;
    final center = Offset(size.x / 2, size.y / 2);
    final glow = color ?? DominoConfig.successGlow;
    canvas.drawCircle(
      center,
      expand,
      Paint()..color = glow.withValues(alpha: alpha * 0.5),
    );
    canvas.drawCircle(
      center,
      expand * 0.55,
      Paint()..color = DominoConfig.accentColor.withValues(alpha: alpha * 0.75),
    );
  }
}
