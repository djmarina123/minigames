import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../memory_config.dart';

/// Carta do Jogo da Memória — flip animado, estilo hub.
class MemoryCard extends PositionComponent with TapCallbacks {
  MemoryCard({
    required this.symbol,
    required super.position,
    required super.size,
    required this.onTap,
  });

  final String symbol;
  final Future<void> Function(MemoryCard) onTap;

  bool isFaceUp = false;
  bool isMatched = false;

  double _flipProgress = 0;
  double _flipTarget = 0;
  double _shakeTime = 0;
  double _matchPulse = 0;

  void reveal() {
    if (isMatched) return;
    isFaceUp = true;
    _flipTarget = 1;
  }

  void hide() {
    if (isMatched) return;
    isFaceUp = false;
    _flipTarget = 0;
  }

  void markMatched() {
    isMatched = true;
    isFaceUp = true;
    _flipTarget = 1;
    _flipProgress = 1;
    _matchPulse = 1;
  }

  void shake() {
    _shakeTime = MemoryConfig.shakeDurationSec;
  }

  bool get isFlipSettled => (_flipProgress - _flipTarget).abs() < 0.02;

  @override
  void update(double dt) {
    super.update(dt);
    final speed = 1 / MemoryConfig.flipDurationSec;
    if (_flipProgress < _flipTarget) {
      _flipProgress = min(_flipTarget, _flipProgress + speed * dt);
    } else if (_flipProgress > _flipTarget) {
      _flipProgress = max(_flipTarget, _flipProgress - speed * dt);
    }

    if (_shakeTime > 0) {
      _shakeTime = max(0, _shakeTime - dt);
    }

    if (_matchPulse > 0) {
      _matchPulse = max(0, _matchPulse - dt * 2.4);
    }
  }

  double get _shakeOffset {
    if (_shakeTime <= 0) return 0;
    final ratio = _shakeTime / MemoryConfig.shakeDurationSec;
    return sin(_shakeTime * 48) * 5 * ratio;
  }

  double get _matchScale => isMatched ? 1 + _matchPulse * 0.08 : 1;

  @override
  void render(Canvas canvas) {
    final shakeX = _shakeOffset;
    final center = Offset(size.x / 2 + shakeX, size.y / 2);
    final scaleX = cos(_flipProgress * pi).abs().clamp(0.05, 1.0);
    final showFront = _flipProgress >= 0.5;
    final matchScale = _matchScale;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scaleX * matchScale, matchScale);
    canvas.translate(-size.x / 2, -size.y / 2);

    final rect = size.toRect();
    final radius = Radius.circular(size.x * 0.14);

    // Sombra
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.shift(const Offset(0, 3)),
        radius,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );

    final bg = isMatched
        ? MemoryConfig.accentColor
        : showFront
            ? MemoryConfig.faceFront
            : MemoryConfig.cardColor;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, radius),
      Paint()..color = bg,
    );

    if (!showFront) {
      _paintCardBack(canvas, rect, radius);
    } else {
      _paintCardFront(canvas, rect);
    }

    // Borda branca (estilo hub)
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, radius),
      Paint()
        ..color = MemoryConfig.cardBorder.withValues(
          alpha: isMatched ? 0.85 : 0.55,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.x * 0.05,
    );

    if (isMatched && _matchPulse > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(2), radius),
        Paint()
          ..color = MemoryConfig.matchGlow.withValues(alpha: _matchPulse * 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    canvas.restore();
  }

  void _paintCardBack(Canvas canvas, Rect rect, Radius radius) {
    final dotR = size.x * 0.045;
    final cols = 3;
    final rows = 3;
    final gapX = rect.width / (cols + 1);
    final gapY = rect.height / (rows + 1);
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        canvas.drawCircle(
          Offset(gapX * (col + 1), gapY * (row + 1)),
          dotR,
          Paint()
            ..color = MemoryConfig.accentSoft.withValues(alpha: 0.35),
        );
      }
    }
  }

  void _paintCardFront(Canvas canvas, Rect rect) {
    final fontSize = size.x * 0.44;
    final painter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(fontSize: fontSize),
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

  @override
  void onTapUp(TapUpEvent event) {
    onTap(this);
  }
}
