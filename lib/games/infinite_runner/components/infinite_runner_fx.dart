import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../infinite_runner_config.dart';

/// Partículas ao ultrapassar um obstáculo.
class RunnerPassBurst extends PositionComponent {
  RunnerPassBurst({required super.position})
      : super(anchor: Anchor.center, priority: 10);

  double _age = 0;
  final _particles = <_Particle>[];
  final _random = Random();

  @override
  Future<void> onLoad() async {
    for (var i = 0; i < 14; i++) {
      final angle = _random.nextDouble() * pi * 2;
      final speed = 50 + _random.nextDouble() * 100;
      _particles.add(
        _Particle(
          dx: cos(angle) * speed,
          dy: sin(angle) * speed - 40,
          color: i.isEven
              ? InfiniteRunnerConfig.passGreen
              : InfiniteRunnerConfig.playerAccent,
          size: 3 + _random.nextDouble() * 5,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    for (final p in _particles) {
      p.dx *= 0.9;
      p.dy += 200 * dt;
      p.x += p.dx * dt;
      p.y += p.dy * dt;
    }
    if (_age > 0.5) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final alpha = (1 - _age / 0.5).clamp(0.0, 1.0);
    for (final p in _particles) {
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.size,
        Paint()..color = p.color.withValues(alpha: alpha),
      );
    }
  }
}

/// Poeira ao correr / pousar.
class RunnerDustPuff extends PositionComponent {
  RunnerDustPuff({required super.position, this.small = false})
      : super(anchor: Anchor.center, priority: 4);

  final bool small;
  double _age = 0;
  final _particles = <_Particle>[];
  final _random = Random();

  @override
  Future<void> onLoad() async {
    final count = small ? 4 : 7;
    for (var i = 0; i < count; i++) {
      _particles.add(
        _Particle(
          dx: -20 - _random.nextDouble() * 40,
          dy: -10 - _random.nextDouble() * 20,
          color: InfiniteRunnerConfig.groundBottom,
          size: small ? 2 + _random.nextDouble() * 2 : 3 + _random.nextDouble() * 4,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    for (final p in _particles) {
      p.x += p.dx * dt;
      p.y += p.dy * dt;
      p.dy += 60 * dt;
    }
    if (_age > 0.35) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final alpha = (1 - _age / 0.35).clamp(0.0, 1.0) * 0.55;
    for (final p in _particles) {
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.size,
        Paint()..color = p.color.withValues(alpha: alpha),
      );
    }
  }
}

class _Particle {
  _Particle({
    required this.dx,
    required this.dy,
    required this.color,
    required this.size,
  });

  double dx;
  double dy;
  double x = 0;
  double y = 0;
  final Color color;
  final double size;
}

/// Label flutuante (+pts, Game Over, etc.).
class RunnerFloatingLabel extends PositionComponent {
  RunnerFloatingLabel({
    required super.position,
    required this.text,
    required this.color,
  }) : super(anchor: Anchor.center, priority: 11);

  final String text;
  final Color color;

  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    position.y -= 42 * dt;
    if (_age > 0.9) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final alpha = (1 - _age / 0.9).clamp(0.0, 1.0);
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withValues(alpha: alpha),
          fontSize: 18,
          fontWeight: FontWeight.w800,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.25 * alpha),
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
