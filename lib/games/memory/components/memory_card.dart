import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

/// Carta do Jogo da Memória — componente Flame reutilizável.
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

  void reveal() => isFaceUp = true;
  void hide() => isFaceUp = false;

  void markMatched() {
    isMatched = true;
    isFaceUp = true;
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final bg = isMatched
        ? const Color(0xFF00B894)
        : isFaceUp
            ? const Color(0xFFdfe6e9)
            : const Color(0xFF6C5CE7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = bg,
    );

    if (isFaceUp) {
      final fontSize = size.x * 0.42;
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
  }

  @override
  void onTapUp(TapUpEvent event) {
    onTap(this);
  }
}
