import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../infinite_runner_config.dart';

/// Baixo = pular · Alto = agachar.
enum RunnerObstacleKind { low, high }

/// Corredor estilizado — mascot MiniPlay com boné e animação de corrida.
/// [anchor] bottomLeft — pés em `position.y` == linha do chão.
class RunnerPlayer extends PositionComponent {
  RunnerPlayer({
    required this.groundY,
    required double width,
    required double height,
    required double x,
  }) : _width = width,
       _height = height,
       super(
         position: Vector2(x, groundY),
         size: Vector2(width, height),
         anchor: Anchor.bottomLeft,
         priority: 5,
       );

  final double groundY;
  final double _width;
  final double _height;

  double _velocityY = 0;
  bool _grounded = true;
  bool _ducking = false;
  double _duckBlend = 0;
  double _squash = 1;
  double _runPhase = 0;
  double _landSquash = 0;

  bool get grounded => _grounded;
  bool get ducking => _ducking;

  void jump() {
    if (!_grounded || _ducking) return;
    _velocityY = InfiniteRunnerConfig.jumpVelocity;
    _grounded = false;
    _squash = 0.82;
  }

  void setDuck(bool active) {
    if (!_grounded) return;
    _ducking = active;
  }

  Rect get hitRect {
    final bottom = position.y;
    final duck = _duckBlend;

    if (duck > 0.55) {
      final h = _height * 0.42;
      return Rect.fromLTWH(
        position.x + _width * 0.08,
        bottom - h,
        _width * 0.84,
        h * 0.9,
      );
    }
    if (!_grounded) {
      return Rect.fromLTWH(
        position.x + _width * 0.14,
        bottom - _height * 0.78,
        _width * 0.72,
        _height * 0.68,
      );
    }
    return Rect.fromLTWH(
      position.x + _width * 0.12,
      bottom - _height * 0.9,
      _width * 0.76,
      _height * 0.86,
    );
  }

  void updatePhysics(double dt) {
    _duckBlend += ((_ducking ? 1.0 : 0.0) - _duckBlend) * dt * 14;

    if (!_grounded) {
      _velocityY += InfiniteRunnerConfig.gravity * dt;
      position.y += _velocityY * dt;
      _squash = (_squash + (1 - _squash) * dt * 6).clamp(0.82, 1.0);

      if (position.y >= groundY) {
        position.y = groundY;
        _velocityY = 0;
        _grounded = true;
        _landSquash = 1;
      }
    } else {
      position.y = groundY;
      _runPhase += dt * (_ducking ? 7 : 17);
      _squash = (_squash + (1 - _squash) * dt * 8).clamp(0.88, 1.0);
      if (_landSquash > 0) {
        _landSquash = (_landSquash - dt * 5).clamp(0.0, 1.0);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final w = _width;
    final h = _height;
    final duck = _duckBlend;
    final grounded = _grounded;

    if (grounded) {
      _drawGroundShadow(canvas, w, h, duck > 0.5 ? 0.75 : 1.0, wide: duck > 0.5);
    } else {
      _drawGroundShadow(canvas, w, h, 0.35, wide: true, airborne: true);
    }

    if (duck > 0.08) {
      _renderDuckPose(canvas, w, h, duck);
    } else if (!grounded) {
      _renderJumpPose(canvas, w, h);
    } else {
      _renderRunPose(canvas, w, h);
    }
  }

  void _renderRunPose(Canvas canvas, double w, double h) {
    final sinPhase = math.sin(_runPhase);
    final cosPhase = math.cos(_runPhase);
    final squashY = 1.0 - _landSquash * 0.06;
    final lean = cosPhase * 0.04;

    canvas.save();
    canvas.translate(w / 2, h);
    canvas.scale(1.0 + _landSquash * 0.03, squashY);
    canvas.translate(-w / 2, -h);
    canvas.translate(w * 0.5, h * 0.72);
    canvas.rotate(lean);
    canvas.translate(-w * 0.5, -h * 0.72);

    // Perna de trás
    _drawRunLeg(canvas, w, h, w * 0.34, h * 0.86, -sinPhase, behind: true);
    _drawArm(canvas, w * 0.14, h * 0.5, w * 0.11, h * 0.17, sinPhase * 0.9);

    _drawTorso(canvas, w, h, top: h * 0.36, height: h * 0.44);
    _drawScarf(canvas, w, h, sinPhase);

    // Perna da frente
    _drawRunLeg(canvas, w, h, w * 0.54, h * 0.86, sinPhase, behind: false);
    _drawCapHead(canvas, Offset(w * 0.58, h * 0.3), w * 0.21, tilt: lean * 0.6);
    _drawArm(canvas, w * 0.62, h * 0.48, w * 0.11, h * 0.17, -sinPhase * 0.9);

    canvas.restore();
  }

  void _renderJumpPose(Canvas canvas, double w, double h) {
    canvas.save();
    canvas.translate(w / 2, h);
    canvas.scale(0.95, 1.05 / _squash);
    canvas.translate(-w / 2, -h);
    canvas.translate(w * 0.06, 0);
    canvas.rotate(-0.22);

    _drawSneaker(canvas, w * 0.18, h * 0.97, w * 0.2, h * 0.11, -0.55);
    _drawSneaker(canvas, w * 0.52, h * 0.95, w * 0.2, h * 0.11, 0.7);
    _drawShortLeg(canvas, w * 0.22, h * 0.84, w * 0.14, h * 0.18, -0.6);
    _drawShortLeg(canvas, w * 0.5, h * 0.82, w * 0.14, h * 0.16, 0.75);

    _drawTorso(canvas, w, h, top: h * 0.36, height: h * 0.42);
    _drawArm(canvas, w * 0.1, h * 0.4, w * 0.1, h * 0.19, -1.15);
    _drawArm(canvas, w * 0.72, h * 0.38, w * 0.1, h * 0.17, 0.95);
    _drawCapHead(canvas, Offset(w * 0.56, h * 0.28), w * 0.2, tilt: -0.12);

    canvas.restore();
  }

  void _renderDuckPose(Canvas canvas, double w, double h, double duck) {
    final crouch = duck.clamp(0.0, 1.0);
    final bodyTop = h * (0.52 - crouch * 0.03);

    _drawSneaker(canvas, w * 0.14, h, w * 0.22, h * 0.1, 0.1);
    _drawSneaker(canvas, w * 0.58, h, w * 0.22, h * 0.1, -0.06);

    final torso = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, bodyTop, w * 0.76, h * 0.28),
      Radius.circular(w * 0.14),
    );
    _drawOutlinedRRect(canvas, torso, InfiniteRunnerConfig.playerBody);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, bodyTop + h * 0.05, w * 0.38, h * 0.14),
        Radius.circular(w * 0.06),
      ),
      Paint()..color = InfiniteRunnerConfig.playerAccent.withValues(alpha: 0.85),
    );

    _drawCapHead(
      canvas,
      Offset(w * 0.7, bodyTop + h * 0.06),
      w * 0.2,
      tilt: 0.22,
      duck: true,
    );
  }

  void _drawTorso(Canvas canvas, double w, double h, {required double top, required double height}) {
    final torso = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.2, top, w * 0.52, height),
      Radius.circular(w * 0.16),
    );
    _drawOutlinedRRect(canvas, torso, InfiniteRunnerConfig.playerBody);

    // Faixa do colete — identidade laranja do card
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.24, top + height * 0.12, w * 0.28, height * 0.38),
        Radius.circular(w * 0.06),
      ),
      Paint()..color = InfiniteRunnerConfig.playerAccent.withValues(alpha: 0.9),
    );
    // Listras brancas no peito
    final stripe = Paint()
      ..color = InfiniteRunnerConfig.outlineWhite.withValues(alpha: 0.75)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final sx = w * (0.3 + i * 0.08);
      canvas.drawLine(
        Offset(sx, top + height * 0.18),
        Offset(sx - w * 0.03, top + height * 0.48),
        stripe,
      );
    }
  }

  void _drawCapHead(
    Canvas canvas,
    Offset center,
    double radius, {
    double tilt = 0,
    bool duck = false,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);
    final r = radius;

    // Rosto
    canvas.drawCircle(
      Offset(0, r * 0.12),
      r * 0.72,
      Paint()..color = InfiniteRunnerConfig.playerSkin,
    );
    canvas.drawCircle(
      Offset(0, r * 0.12),
      r * 0.72,
      Paint()
        ..color = InfiniteRunnerConfig.outlineWhite.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Boné laranja
    final cap = Path()
      ..moveTo(-r * 0.9, r * 0.02)
      ..quadraticBezierTo(0, -r * 1.05, r * 0.9, r * 0.02)
      ..lineTo(r * 0.95, r * 0.18)
      ..lineTo(-r * 0.35, r * 0.1)
      ..close();
    canvas.drawPath(cap, Paint()..color = InfiniteRunnerConfig.playerAccent);
    canvas.drawPath(
      cap,
      Paint()
        ..color = InfiniteRunnerConfig.outlineWhite.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Visor
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-r * 0.55, -r * 0.08, r * 1.1, r * 0.22),
        Radius.circular(r * 0.1),
      ),
      Paint()..color = InfiniteRunnerConfig.playerHead.withValues(alpha: 0.55),
    );

    // Olhos simples (2 pontos)
    final eyePaint = Paint()..color = InfiniteRunnerConfig.playerShorts;
    final eyeY = duck ? r * 0.18 : r * 0.14;
    canvas.drawCircle(Offset(-r * 0.22, eyeY), r * 0.09, eyePaint);
    canvas.drawCircle(Offset(r * 0.08, eyeY), r * 0.09, eyePaint);

    canvas.restore();
  }

  void _drawScarf(Canvas canvas, double w, double h, double sinPhase) {
    final paint = Paint()
      ..color = InfiniteRunnerConfig.playerHead
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final start = Offset(w * 0.22, h * 0.42);
    final path = Path()..moveTo(start.dx, start.dy);
    path.quadraticBezierTo(
      start.dx - w * 0.14,
      start.dy + h * 0.04 + sinPhase * 3,
      start.dx - w * 0.22,
      start.dy + h * 0.12 + math.sin(_runPhase + 0.8) * 4,
    );
    canvas.drawPath(path, paint);
    canvas.drawCircle(
      Offset(
        start.dx - w * 0.22,
        start.dy + h * 0.12 + math.sin(_runPhase + 0.8) * 4,
      ),
      3.5,
      Paint()..color = InfiniteRunnerConfig.playerHead,
    );
  }

  void _drawRunLeg(
    Canvas canvas,
    double w,
    double h,
    double hipX,
    double hipY,
    double swing, {
    required bool behind,
  }) {
    final thighLen = h * 0.2;
    final legW = w * 0.14;
    final angle = swing * 0.68;

    canvas.save();
    canvas.translate(hipX, hipY);
    canvas.rotate(angle);

    // Shorts
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, thighLen * 0.2),
          width: legW * 1.1,
          height: thighLen * 0.35,
        ),
        Radius.circular(legW * 0.3),
      ),
      Paint()..color = InfiniteRunnerConfig.playerShorts,
    );

    // Coxa
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, thighLen * 0.45),
          width: legW,
          height: thighLen * 0.82,
        ),
        Radius.circular(legW * 0.35),
      ),
      Paint()..color = behind
          ? InfiniteRunnerConfig.playerLeg.withValues(alpha: 0.75)
          : InfiniteRunnerConfig.playerLeg,
    );

    canvas.translate(0, thighLen * 0.88);
    canvas.rotate(-angle * 0.4 + swing * 0.1);
    _drawSneaker(canvas, -legW * 0.42, 0, legW * 1.35, h * 0.1, swing * 0.15);

    canvas.restore();
  }

  void _drawShortLeg(
    Canvas canvas,
    double x,
    double bottomY,
    double lw,
    double lh,
    double angle,
  ) {
    canvas.save();
    canvas.translate(x + lw / 2, bottomY);
    canvas.rotate(angle * 0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -lh * 0.45), width: lw, height: lh),
        Radius.circular(lw * 0.35),
      ),
      Paint()..color = InfiniteRunnerConfig.playerShorts,
    );
    canvas.restore();
  }

  void _drawSneaker(
    Canvas canvas,
    double x,
    double bottomY,
    double sw,
    double sh,
    double tilt,
  ) {
    canvas.save();
    canvas.translate(x + sw / 2, bottomY);
    canvas.rotate(tilt * 0.4);
    final sole = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, -sh * 0.42), width: sw, height: sh),
      Radius.circular(sh * 0.35),
    );
    canvas.drawRRect(sole, Paint()..color = InfiniteRunnerConfig.playerShoe);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -sh * 0.6), width: sw * 0.82, height: sh * 0.52),
        Radius.circular(sh * 0.25),
      ),
      Paint()..color = InfiniteRunnerConfig.playerAccent,
    );
    canvas.drawRRect(
      sole,
      Paint()
        ..color = InfiniteRunnerConfig.outlineWhite.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  void _drawArm(
    Canvas canvas,
    double x,
    double y,
    double aw,
    double ah,
    double swing,
  ) {
    canvas.save();
    canvas.translate(x + aw / 2, y);
    canvas.rotate(swing * 0.55);
    final arm = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, ah * 0.38), width: aw, height: ah),
      Radius.circular(aw * 0.4),
    );
    _drawOutlinedRRect(canvas, arm, InfiniteRunnerConfig.playerSkin);
    canvas.drawCircle(
      Offset(0, ah * 0.78),
      aw * 0.44,
      Paint()..color = InfiniteRunnerConfig.outlineWhite,
    );
    canvas.drawCircle(
      Offset(0, ah * 0.78),
      aw * 0.44,
      Paint()
        ..color = InfiniteRunnerConfig.outlineWhite.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.restore();
  }

  void _drawGroundShadow(
    Canvas canvas,
    double w,
    double h,
    double alpha, {
    bool wide = false,
    bool airborne = false,
  }) {
    final sw = wide ? w * 0.92 : w * 0.68;
    final y = airborne ? h * 0.99 : h;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, y), width: sw, height: h * 0.08),
      Paint()..color = Colors.black.withValues(alpha: 0.2 * alpha),
    );
  }

  void _drawOutlinedRRect(Canvas canvas, RRect rrect, Color fill) {
    canvas.drawRRect(
      rrect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );
    canvas.drawRRect(rrect, Paint()..color = fill);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = InfiniteRunnerConfig.outlineWhite.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }
}

/// Obstáculo plantado no chão — [anchor] bottomLeft.
class RunnerObstacle extends PositionComponent {
  RunnerObstacle({
    required Vector2 groundPosition,
    required Vector2 obstacleSize,
    required this.kind,
  }) : super(
          position: groundPosition,
          size: obstacleSize,
          anchor: Anchor.bottomLeft,
        );

  final RunnerObstacleKind kind;
  bool cleared = false;

  Rect get hitRect {
    final bottom = position.y;
    final top = bottom - size.y;
    if (kind == RunnerObstacleKind.high) {
      return Rect.fromLTWH(
        position.x + size.x * 0.02,
        top + size.y * 0.08,
        size.x * 0.96,
        size.y * 0.42,
      );
    }
    return Rect.fromLTWH(
      position.x + size.x * 0.1,
      top + size.y * 0.06,
      size.x * 0.8,
      size.y * 0.88,
    );
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    _drawGroundShadow(canvas, w, h);

    switch (kind) {
      case RunnerObstacleKind.low:
        _paintCactus(canvas, w, h);
      case RunnerObstacleKind.high:
        _paintBeam(canvas, w, h);
    }
  }

  void _drawGroundShadow(Canvas canvas, double w, double h) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h),
        width: w * 0.9,
        height: h * 0.12,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );
  }

  /// Cacto vertical — mesma leitura visual do card do catálogo.
  void _paintCactus(Canvas canvas, double w, double h) {
    final trunkW = w * 0.42;
    final trunkX = (w - trunkW) / 2;
    final trunkH = h * 0.92;

    final trunk = RRect.fromRectAndRadius(
      Rect.fromLTWH(trunkX, h - trunkH, trunkW, trunkH),
      Radius.circular(trunkW * 0.24),
    );
    _drawOutlinedRRect(canvas, trunk, InfiniteRunnerConfig.obstacleGreen);

    // Braço esquerdo
    final armH = h * 0.28;
    final armW = w * 0.28;
    final armY = h - h * 0.62;
    final leftArm = RRect.fromRectAndRadius(
      Rect.fromLTWH(trunkX - armW * 0.55, armY, armW, armH),
      Radius.circular(armW * 0.28),
    );
    _drawOutlinedRRect(canvas, leftArm, InfiniteRunnerConfig.obstacleMid);

    // Conector do braço ao tronco
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(trunkX - armW * 0.12, armY + armH * 0.15, armW * 0.35, armH * 0.35),
        Radius.circular(4),
      ),
      Paint()..color = InfiniteRunnerConfig.obstacleMid,
    );

    // Listras para contraste sobre a grama
    final stripePaint = Paint()
      ..color = InfiniteRunnerConfig.obstacleDark.withValues(alpha: 0.35)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 4; i++) {
      final sx = trunkX + trunkW * (0.2 + i * 0.2);
      canvas.drawLine(
        Offset(sx, h - trunkH * 0.85),
        Offset(sx, h - trunkH * 0.15),
        stripePaint,
      );
    }
  }

  void _drawOutlinedRRect(Canvas canvas, RRect rrect, Color fill) {
    canvas.drawRRect(
      rrect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    canvas.drawRRect(rrect, Paint()..color = fill);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = InfiniteRunnerConfig.outlineWhite.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  /// Viga suspensa por postes até o chão.
  void _paintBeam(Canvas canvas, double w, double h) {
    final postW = w * 0.13;
    final postPaint = Paint()..color = InfiniteRunnerConfig.obstacleDark;

    for (final fx in [0.02, 0.85]) {
      final postRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * fx, h * 0.28, postW, h * 0.72),
        Radius.circular(postW * 0.25),
      );
      canvas.drawRRect(
        postRect.shift(const Offset(0, 2)),
        Paint()..color = Colors.black.withValues(alpha: 0.18),
      );
      canvas.drawRRect(postRect, postPaint);
      canvas.drawRRect(
        postRect,
        Paint()
          ..color = InfiniteRunnerConfig.outlineWhite.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    final beamTop = h * 0.18;
    final beamH = h * 0.3;
    final beamRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, beamTop, w, beamH),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(
      beamRect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );
    canvas.drawRRect(beamRect, Paint()..color = InfiniteRunnerConfig.hazardYellow);

    final stripe = Paint()..color = InfiniteRunnerConfig.hazardOrange;
    for (var i = 0; i < 6; i++) {
      final path = Path()
        ..moveTo(w * (i / 6), beamTop)
        ..lineTo(w * ((i + 0.5) / 6), beamTop)
        ..lineTo(w * ((i + 0.35) / 6), beamTop + beamH)
        ..lineTo(w * ((i - 0.15) / 6), beamTop + beamH)
        ..close();
      canvas.drawPath(path, stripe);
    }

    canvas.drawRRect(
      beamRect,
      Paint()
        ..color = InfiniteRunnerConfig.outlineWhite.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Base dos postes
    for (final fx in [0.02, 0.85]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * fx - w * 0.015, h - h * 0.07, postW + w * 0.03, h * 0.07),
          const Radius.circular(4),
        ),
        Paint()..color = InfiniteRunnerConfig.obstacleDark,
      );
    }
  }
}
