import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../color_blocks_config.dart';

/// Brilho ao limpar linha ou coluna.
class ColorBlocksLineBurst extends PositionComponent {
  ColorBlocksLineBurst({required super.position})
      : super(size: Vector2.all(8), anchor: Anchor.center);

  static const _duration = 0.34;
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
    final expand = 10 + t * 36;
    final center = Offset(size.x / 2, size.y / 2);

    canvas.drawCircle(
      center,
      expand,
      Paint()
        ..color = ColorBlocksConfig.lineGlow.withValues(alpha: alpha * 0.55),
    );
    canvas.drawCircle(
      center,
      expand * 0.55,
      Paint()
        ..color = ColorBlocksConfig.accentColor.withValues(alpha: alpha * 0.8),
    );
  }
}

/// Texto flutuante de pontos ou feedback de erro.
class ColorBlocksFloatingLabel extends PositionComponent {
  ColorBlocksFloatingLabel({
    required super.position,
    required this.text,
    required this.color,
    this.emphasis = false,
  }) : super(
          size: Vector2(emphasis ? 160 : 96, emphasis ? 44 : 36),
          anchor: Anchor.center,
        );

  final String text;
  final Color color;
  final bool emphasis;

  static const _duration = 0.72;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    position.y -= dt * (emphasis ? 28 : 34);
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
          fontSize: emphasis ? 20 : 16,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: alpha * 0.45),
              blurRadius: emphasis ? 6 : 4,
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

/// Pulso vermelho ao errar a colocação.
class ColorBlocksInvalidBurst extends PositionComponent {
  ColorBlocksInvalidBurst({required super.position})
      : super(size: Vector2.all(8), anchor: Anchor.center);

  static const _duration = 0.36;
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
    final expand = 12 + t * 34;
    final center = Offset(size.x / 2, size.y / 2);

    canvas.drawCircle(
      center,
      expand,
      Paint()
        ..color = ColorBlocksConfig.conflictRed.withValues(alpha: alpha * 0.55),
    );
    canvas.drawCircle(
      center,
      expand * 0.5,
      Paint()
        ..color = ColorBlocksConfig.missRed.withValues(alpha: alpha * 0.85),
    );
  }
}
