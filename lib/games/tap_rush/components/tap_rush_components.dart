import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../tap_rush_config.dart';

/// Alvo tocável — encolhe com o tempo e some se não for acertado.
class RushTarget extends PositionComponent with TapCallbacks {
  RushTarget({
    required this.radius,
    required this.lifetimeSec,
    required this.onHit,
    required this.onMissed,
    required super.position,
  }) : super(
          size: Vector2.all(radius * 2),
          anchor: Anchor.center,
        );

  final double radius;
  final double lifetimeSec;
  final void Function(RushTarget target, Vector2 worldPos) onHit;
  final VoidCallback onMissed;

  double _age = 0;
  double _spawnScale = 0;
  bool _resolved = false;

  double get lifeRatio =>
      (1 - _age / lifetimeSec).clamp(0.0, 1.0);

  double get visualRadius =>
      radius * _easeOutBack(_spawnScale) * (0.95 + 0.05 * lifeRatio);

  double get hitRadius => tapRushHitRadius(visualRadius);

  @override
  void update(double dt) {
    super.update(dt);
    _spawnScale = (_spawnScale + dt * 4).clamp(0.0, 1.0);
    _age += dt;
    final hr = hitRadius;
    size.setValues(hr * 2, hr * 2);
    if (!_resolved && _age >= lifetimeSec) {
      _resolved = true;
      onMissed();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final r = visualRadius;
    final center = Offset(size.x / 2, size.y / 2);

    // Anel externo (pulso)
    canvas.drawCircle(
      center,
      r + 6,
      Paint()
        ..color = TapRushConfig.targetOuter.withValues(alpha: 0.25 * lifeRatio)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.drawCircle(
      center,
      r,
      Paint()..color = TapRushConfig.targetOuter,
    );
    canvas.drawCircle(
      center,
      r * 0.72,
      Paint()..color = TapRushConfig.targetInner,
    );
    canvas.drawCircle(
      center,
      r * 0.35,
      Paint()..color = TapRushConfig.targetCore,
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_resolved) return;
    final local = event.localPosition;
    final dx = local.x - size.x / 2;
    final dy = local.y - size.y / 2;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist > hitRadius) {
      _resolved = true;
      onMissed();
      removeFromParent();
      return;
    }
    _resolved = true;
    final world = absoluteCenter;
    onHit(this, world);
    removeFromParent();
  }

  static double _easeOutBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * pow(t - 1, 3) + c1 * pow(t - 1, 2);
  }
}

/// Partículas rápidas ao acertar o alvo.
class HitBurst extends PositionComponent {
  HitBurst({required super.position})
      : super(size: Vector2.all(8), anchor: Anchor.center);

  static const _duration = 0.35;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final alpha = (1 - t).clamp(0.0, 1.0);
    final expand = 8 + t * 28;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      expand,
      Paint()
        ..color = TapRushConfig.targetCore.withValues(alpha: alpha * 0.7),
    );
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      expand * 0.5,
      Paint()
        ..color = TapRushConfig.comboGold.withValues(alpha: alpha),
    );
  }
}

/// Texto flutuante "+50" ou "MISS".
class FloatingLabel extends PositionComponent {
  FloatingLabel({
    required super.position,
    required this.text,
    required this.color,
  }) : super(size: Vector2(80, 32), anchor: Anchor.center);

  final String text;
  final Color color;

  static const _duration = 0.7;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    position.y -= dt * 40;
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
          fontSize: 18,
          fontWeight: FontWeight.bold,
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
