import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hub_theme.dart';

/// Ilustração vetorial desenhada no card — escala com o tamanho, sem PNG.
class GameCardArt extends StatelessWidget {
  const GameCardArt({
    super.key,
    required this.gameId,
    required this.theme,
  });

  final String gameId;
  final HubGameTheme theme;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: switch (gameId) {
        'tap_rush' => _TapRushArt(theme),
        'memory' => _MemoryArt(theme),
        _ => _GenericArt(theme, gameId),
      },
      size: Size.infinite,
    );
  }
}

sealed class _CardArtPainter extends CustomPainter {
  _CardArtPainter(this.theme);

  final HubGameTheme theme;

  void drawBackgroundBubbles(Canvas canvas, Size size) {
    final bubbles = [
      (0.85, 0.18, 0.42, 0.12),
      (0.12, 0.35, 0.28, 0.10),
      (0.72, 0.72, 0.55, 0.08),
      (0.08, 0.82, 0.22, 0.07),
    ];
    for (final (fx, fy, fr, alpha) in bubbles) {
      canvas.drawCircle(
        Offset(size.width * fx, size.height * fy),
        size.width * fr,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }
}

class _TapRushArt extends _CardArtPainter {
  _TapRushArt(super.theme);

  @override
  void paint(Canvas canvas, Size size) {
    drawBackgroundBubbles(canvas, size);

    final cx = size.width * 0.5;
    final cy = size.height * 0.56;
    final r = math.min(size.width, size.height) * 0.36;

    canvas.drawCircle(
      Offset(cx, cy),
      r * 1.15,
      Paint()..color = theme.accentColor.withValues(alpha: 0.22),
    );

    final rings = [
      (r, Colors.white.withValues(alpha: 0.25)),
      (r * 0.82, const Color(0xFF9B59B6)),
      (r * 0.60, theme.accentColor),
      (r * 0.38, const Color(0xFFFD79A8)),
      (r * 0.16, Colors.white),
    ];
    for (final (radius, color) in rings) {
      canvas.drawCircle(Offset(cx, cy), radius, Paint()..color = color);
    }

    canvas.save();
    canvas.translate(cx + r * 0.12, cy + r * 0.08);
    canvas.rotate(-0.35);
    final fingerW = r * 0.55;
    final fingerH = r * 0.95;
    final fingerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(fingerW * 0.15, -fingerH * 0.15),
        width: fingerW,
        height: fingerH,
      ),
      Radius.circular(fingerW * 0.45),
    );
    canvas.drawRRect(
      fingerRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      fingerRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();

    _sparkle(canvas, Offset(cx - r * 0.85, cy - r * 0.55), 7, theme.accentColor);
    _sparkle(canvas, Offset(cx + r * 0.9, cy - r * 0.2), 6, Colors.white);
    _sparkle(canvas, Offset(cx - r * 0.5, cy + r * 0.65), 5, Colors.white70);
  }

  void _sparkle(Canvas canvas, Offset p, double size, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(p, size * 0.35, paint);
    canvas.drawRect(
      Rect.fromCenter(center: p, width: size * 1.6, height: size * 0.35),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: p, width: size * 0.35, height: size * 1.6),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TapRushArt oldDelegate) => false;
}

class _MemoryArt extends _CardArtPainter {
  _MemoryArt(super.theme);

  @override
  void paint(Canvas canvas, Size size) {
    drawBackgroundBubbles(canvas, size);

    final cards = <_CardSpec>[
      _CardSpec('🎮', -0.28, 0.08, -0.22, const Color(0xFF6C5CE7)),
      _CardSpec('🎯', 0.02, 0.02, 0.08, const Color(0xFFE17055)),
      _CardSpec('🎲', -0.12, 0.18, -0.05, const Color(0xFF00CEC9)),
      _CardSpec('🎪', 0.22, 0.12, 0.18, const Color(0xFFFDCB6E)),
    ];

    final cardW = size.width * 0.42;
    final cardH = size.width * 0.54;
    final baseX = size.width * 0.48;
    final baseY = size.height * 0.58;

    for (final c in cards) {
      canvas.save();
      canvas.translate(baseX + c.dx * size.width, baseY + c.dy * size.height);
      canvas.rotate(c.angle);

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: cardW, height: cardH),
        const Radius.circular(12),
      );
      canvas.drawRRect(
        rect.shift(const Offset(0, 4)),
        Paint()..color = Colors.black.withValues(alpha: 0.15),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = c.color
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      _drawEmoji(canvas, c.emoji, cardH * 0.42);
      canvas.restore();
    }
  }

  void _drawEmoji(Canvas canvas, String emoji, double fontSize) {
    final painter = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(-painter.width / 2, -painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _MemoryArt oldDelegate) => false;
}

class _CardSpec {
  const _CardSpec(this.emoji, this.dx, this.dy, this.angle, this.color);
  final String emoji;
  final double dx;
  final double dy;
  final double angle;
  final Color color;
}

class _GenericArt extends _CardArtPainter {
  _GenericArt(super.theme, this.gameId);

  final String gameId;

  @override
  void paint(Canvas canvas, Size size) {
    drawBackgroundBubbles(canvas, size);

    const icons = {'demo_tap': '👆'};
    final emoji = icons[gameId] ?? '🎮';
    final painter = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: size.width * 0.5)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(
        (size.width - painter.width) / 2,
        size.height * 0.52 - painter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _GenericArt oldDelegate) => false;
}

/// Banner do jogo — mesma identidade visual do [GameCard] do catálogo.
class GameCatalogHero extends StatelessWidget {
  const GameCatalogHero({
    super.key,
    required this.gameId,
    required this.title,
    required this.theme,
    this.height = 200,
    this.showFeaturedBadge = false,
  });

  final String gameId;
  final String title;
  final HubGameTheme theme;
  final double height;
  final bool showFeaturedBadge;

  @override
  Widget build(BuildContext context) {
    final displayTitle = hubDisplayTitle(title);
    final titleLead = hubTitleLead(title);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(HubTheme.cardRadius),
        border: Border.all(color: HubTheme.cardBorder, width: 4),
        boxShadow: [
          BoxShadow(
            color: theme.cardColor.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GameCardArt(gameId: gameId, theme: theme),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 72,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.cardColor.withValues(alpha: 0.95),
                    theme.cardColor.withValues(alpha: 0.35),
                    theme.cardColor.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: 0.2,
                    shadows: [
                      Shadow(
                        color: Color(0x66000000),
                        blurRadius: 6,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: _underlineWidth(titleLead),
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          if (showFeaturedBadge)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4757),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'NOVO!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _underlineWidth(String word) {
    final len = word.length.clamp(3, 10);
    return 24.0 + len * 4.5;
  }
}
