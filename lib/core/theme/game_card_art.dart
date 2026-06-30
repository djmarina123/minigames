import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/l10n_scope.dart';
import 'hub_theme.dart';

/// Ilustração vetorial desenhada no card — escala com o tamanho, sem PNG.
class GameCardArt extends StatelessWidget {
  const GameCardArt({
    super.key,
    required this.gameId,
    required this.theme,
    this.compact = false,
  });

  final String gameId;
  final HubGameTheme theme;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: switch (gameId) {
        'tap_rush' => _TapRushArt(theme, compact: compact),
        'memory' => _MemoryArt(theme, compact: compact),
        'game_2048' => _Game2048Art(theme, compact: compact),
        'infinite_runner' => _InfiniteRunnerArt(theme, compact: compact),
        'solitaire' => _SolitaireArt(theme, compact: compact),
        'snake' => _SnakeArt(theme, compact: compact),
        'sudoku' => _SudokuArt(theme, compact: compact),
        'color_blocks' => _ColorBlocksArt(theme, compact: compact),
        'cross_sums' => _CrossSumsArt(theme, compact: compact),
        'minesweeper' => _MinesweeperArt(theme, compact: compact),
        _ => _GenericArt(theme, gameId, compact: compact),
      },
      size: Size.infinite,
    );
  }
}

/// Largura típica do card no grid mobile (2 colunas, ~390px).
const _kReferenceCardWidth = 172.0;

/// Miniatura — recorte escalado do mesmo [GameCatalogHero] do catálogo.
class GameCatalogThumbnail extends StatelessWidget {
  const GameCatalogThumbnail({
    super.key,
    required this.gameId,
    required this.theme,
    this.title,
    this.size = 52,
    this.showTitle = false,
    this.showFeaturedBadge = false,
  });

  final String gameId;
  final HubGameTheme theme;
  final String? title;
  final double size;
  final bool showTitle;
  final bool showFeaturedBadge;

  @override
  Widget build(BuildContext context) {
    final cardHeight = _kReferenceCardWidth / HubTheme.cardAspectRatio;
    final radius = size * (HubTheme.cardRadius / _kReferenceCardWidth);

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: showTitle ? Alignment.topCenter : const Alignment(0, 0.12),
          child: SizedBox(
            width: _kReferenceCardWidth,
            height: cardHeight,
            child: GameCatalogHero(
              gameId: gameId,
              title: title ?? '',
              theme: theme,
              height: cardHeight,
              showTitleOverlay: showTitle,
              showFeaturedBadge: showFeaturedBadge,
            ),
          ),
        ),
      ),
    );
  }
}

sealed class _CardArtPainter extends CustomPainter {
  _CardArtPainter(this.theme, {this.compact = false});

  final HubGameTheme theme;
  final bool compact;

  void drawBackgroundBubbles(Canvas canvas, Size size) {
    if (compact) return;
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
  _TapRushArt(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    drawBackgroundBubbles(canvas, size);

    final cx = size.width * 0.5;
    final cy = size.height * (compact ? 0.52 : 0.56);
    final r = math.min(size.width, size.height) * (compact ? 0.40 : 0.36);

    canvas.drawCircle(
      Offset(cx, cy),
      r * 1.15,
      Paint()..color = theme.accentColor.withValues(alpha: 0.22),
    );

    final rings = [
      (r, Colors.white.withValues(alpha: 0.25)),
      (r * 0.82, theme.cardColor),
      (r * 0.60, theme.accentColor),
      (r * 0.38, theme.accentSoft),
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
    if (!compact) {
      canvas.drawRRect(
        fingerRect,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    canvas.restore();

    if (!compact) {
      _sparkle(canvas, Offset(cx - r * 0.85, cy - r * 0.55), 7, theme.accentColor);
      _sparkle(canvas, Offset(cx + r * 0.9, cy - r * 0.2), 6, Colors.white);
      _sparkle(canvas, Offset(cx - r * 0.5, cy + r * 0.65), 5, Colors.white70);
    }
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
  _MemoryArt(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    drawBackgroundBubbles(canvas, size);

    final cards = <_CardSpec>[
      _CardSpec('🎮', -0.28, 0.08, -0.22, theme.cardColor),
      _CardSpec('🎯', 0.02, 0.02, 0.08, theme.accentColor),
      _CardSpec('🎲', -0.12, 0.18, -0.05, theme.blendColor),
      _CardSpec('🎪', 0.22, 0.12, 0.18, theme.accentSoft),
    ];

    final cardW = size.width * (compact ? 0.48 : 0.42);
    final cardH = size.width * (compact ? 0.58 : 0.54);
    final baseX = size.width * (compact ? 0.5 : 0.48);
    final baseY = size.height * (compact ? 0.54 : 0.58);

    final visible = compact ? cards.sublist(0, 2) : cards;

    for (final c in visible) {
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

class _Game2048Art extends _CardArtPainter {
  _Game2048Art(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    drawBackgroundBubbles(canvas, size);

    final tiles = <_TileSpec>[
      _TileSpec(2, -0.32, -0.12, theme.accentSoft),
      _TileSpec(4, -0.08, 0.02, theme.blendColor),
      _TileSpec(8, 0.18, -0.08, theme.accentColor),
      _TileSpec(16, 0.02, 0.22, theme.cardColor),
    ];

    final tileSize = size.width * (compact ? 0.22 : 0.20);
    final baseX = size.width * 0.5;
    final baseY = size.height * (compact ? 0.56 : 0.58);

    final visible = compact ? tiles.sublist(0, 3) : tiles;

    for (final t in visible) {
      final cx = baseX + t.dx * size.width;
      final cy = baseY + t.dy * size.height;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: tileSize,
          height: tileSize,
        ),
        Radius.circular(tileSize * 0.14),
      );
      canvas.drawRRect(
        rect.shift(const Offset(0, 3)),
        Paint()..color = Colors.black.withValues(alpha: 0.14),
      );
      canvas.drawRRect(rect, Paint()..color = t.color);
      canvas.drawRRect(
        rect,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final painter = TextPainter(
        text: TextSpan(
          text: '${t.value}',
          style: TextStyle(
            color: t.value >= 8 ? Colors.white : const Color(0xFF776E65),
            fontSize: tileSize * 0.42,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(cx - painter.width / 2, cy - painter.height / 2),
      );
    }

    if (!compact) {
      _sparkle(canvas, Offset(baseX - tileSize * 1.6, baseY - tileSize * 1.1), 6, theme.accentColor);
      _sparkle(canvas, Offset(baseX + tileSize * 1.7, baseY + tileSize * 0.4), 5, Colors.white);
    }
  }

  void _sparkle(Canvas canvas, Offset p, double s, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(p, s * 0.35, paint);
    canvas.drawRect(
      Rect.fromCenter(center: p, width: s * 1.5, height: s * 0.35),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: p, width: s * 0.35, height: s * 1.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _Game2048Art oldDelegate) => false;
}

class _InfiniteRunnerArt extends _CardArtPainter {
  _InfiniteRunnerArt(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    drawBackgroundBubbles(canvas, size);

    // Céu em gradiente suave.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.78),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.accentSoft.withValues(alpha: 0.28),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.78)),
    );

    if (!compact) {
      _drawCloud(canvas, Offset(size.width * 0.72, size.height * 0.22), size.width * 0.14);
      _drawCloud(canvas, Offset(size.width * 0.38, size.height * 0.30), size.width * 0.10);
      canvas.drawCircle(
        Offset(size.width * 0.88, size.height * 0.16),
        size.width * 0.06,
        Paint()..color = theme.accentSoft.withValues(alpha: 0.55),
      );
    }

    final groundY = size.height * 0.74;
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      Paint()..color = theme.cardColor.withValues(alpha: 0.45),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height * 0.04),
      Paint()..color = const Color(0xFF7BED9F).withValues(alpha: 0.55),
    );
    _drawSpeedStripes(canvas, groundY, size);

    final scale = compact ? 0.88 : 1.0;
    final runnerX = size.width * 0.24;
    _drawRunner(canvas, Offset(runnerX, groundY), size.width * 0.11 * scale);

    final cactusX = size.width * 0.62;
    _drawCactus(canvas, Offset(cactusX, groundY), size.width * 0.09 * scale);

    if (!compact) {
      _drawCoin(canvas, Offset(size.width * 0.48, groundY - size.height * 0.22), size.width * 0.05);
      _drawObstacleBeam(canvas, Offset(size.width * 0.82, groundY), size.width * 0.12);
      _sparkle(canvas, Offset(size.width * 0.12, size.height * 0.32), 6, theme.accentColor);
      _sparkle(canvas, Offset(size.width * 0.90, size.height * 0.38), 5, Colors.white);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double w) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    canvas.drawCircle(center, w * 0.35, paint);
    canvas.drawCircle(center + Offset(w * 0.28, -w * 0.08), w * 0.28, paint);
    canvas.drawCircle(center + Offset(-w * 0.26, -w * 0.04), w * 0.24, paint);
  }

  void _drawSpeedStripes(Canvas canvas, double groundY, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < (compact ? 3 : 5); i++) {
      final y = groundY + size.height * 0.06 + i * size.height * 0.045;
      canvas.drawLine(
        Offset(size.width * 0.05, y),
        Offset(size.width * 0.95, y),
        paint,
      );
    }
  }

  void _drawRunner(Canvas canvas, Offset feet, double bodyW) {
    final bodyH = bodyW * 1.05;
    final headR = bodyW * 0.38;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        feet.dx - bodyW * 0.5,
        feet.dy - bodyH - headR * 1.6,
        bodyW,
        bodyH,
      ),
      Radius.circular(bodyW * 0.22),
    );
    canvas.drawRRect(
      bodyRect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    canvas.drawRRect(bodyRect, Paint()..color = theme.accentColor);
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final headCenter = Offset(feet.dx + bodyW * 0.08, bodyRect.top - headR * 0.75);
    canvas.drawCircle(
      headCenter + const Offset(0, 2),
      headR,
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );
    canvas.drawCircle(headCenter, headR, Paint()..color = theme.accentSoft);
    canvas.drawCircle(
      headCenter + Offset(headR * 0.25, -headR * 0.1),
      headR * 0.14,
      Paint()..color = theme.cardColor,
    );

    // Perna em corrida.
    final legPaint = Paint()
      ..color = theme.cardColor
      ..strokeWidth = bodyW * 0.18
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(feet.dx - bodyW * 0.1, feet.dy - bodyH * 0.15),
      Offset(feet.dx - bodyW * 0.35, feet.dy + bodyW * 0.05),
      legPaint,
    );
    canvas.drawLine(
      Offset(feet.dx + bodyW * 0.15, feet.dy - bodyH * 0.12),
      Offset(feet.dx + bodyW * 0.42, feet.dy - bodyW * 0.18),
      legPaint,
    );

    // Linhas de velocidade.
    final speedPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = headCenter.dy + i * bodyW * 0.22;
      canvas.drawLine(
        Offset(feet.dx - bodyW * 1.1, y),
        Offset(feet.dx - bodyW * 0.65, y),
        speedPaint,
      );
    }
  }

  void _drawCactus(Canvas canvas, Offset base, double w) {
    final h = w * 2.4;
    final green = Color.lerp(const Color(0xFF00B894), theme.cardColor, 0.25)!;
    final armPaint = Paint()..color = green;
    final trunk = RRect.fromRectAndRadius(
      Rect.fromLTWH(base.dx - w * 0.22, base.dy - h, w * 0.44, h),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(
      trunk.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.16),
    );
    canvas.drawRRect(trunk, armPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx - w * 0.62, base.dy - h * 0.62, w * 0.42, w * 0.28),
        Radius.circular(w * 0.1),
      ),
      armPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx - w * 0.62, base.dy - h * 0.78, w * 0.28, h * 0.22),
        Radius.circular(w * 0.1),
      ),
      armPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx + w * 0.22, base.dy - h * 0.48, w * 0.36, w * 0.24),
        Radius.circular(w * 0.1),
      ),
      armPaint,
    );
  }

  void _drawCoin(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(
      center + const Offset(0, 2),
      r,
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );
    canvas.drawCircle(center, r, Paint()..color = theme.accentSoft);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      center + Offset(-r * 0.25, -r * 0.25),
      r * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  void _drawObstacleBeam(Canvas canvas, Offset base, double w) {
    final h = w * 0.55;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(base.dx - w * 0.5, base.dy - h * 2.1, w, h),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(
      rect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.16),
    );
    canvas.drawRRect(rect, Paint()..color = theme.cardColor);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx - w * 0.5, base.dy - h * 2.85, w, h * 0.75),
        Radius.circular(w * 0.08),
      ),
      Paint()..color = theme.blendColor,
    );
  }

  void _sparkle(Canvas canvas, Offset p, double s, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(p, s * 0.35, paint);
    canvas.drawRect(
      Rect.fromCenter(center: p, width: s * 1.5, height: s * 0.35),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: p, width: s * 0.35, height: s * 1.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _InfiniteRunnerArt oldDelegate) => false;
}

class _SolitaireArt extends _CardArtPainter {
  _SolitaireArt(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    drawBackgroundBubbles(canvas, size);

    final cardW = size.width * (compact ? 0.2 : 0.18);
    final cardH = cardW * 1.38;
    final baseX = size.width * 0.5;
    final baseY = size.height * (compact ? 0.56 : 0.58);

    final specs = compact
        ? [
            _CardSpec('A', -0.28, 0.08, -0.12, theme.accentColor),
            _CardSpec('♥', 0.0, -0.06, 0.05, theme.accentSoft),
            _CardSpec('K', 0.26, 0.1, 0.1, theme.blendColor),
          ]
        : [
            _CardSpec('A', -0.32, 0.1, -0.14, theme.accentColor),
            _CardSpec('♠', -0.02, -0.08, 0.04, theme.cardColor),
            _CardSpec('♥', 0.28, 0.06, 0.12, theme.accentSoft),
            _CardSpec('K', 0.08, 0.22, -0.06, theme.blendColor),
          ];

    for (final spec in specs) {
      final cx = baseX + spec.dx * size.width;
      final cy = baseY + spec.dy * size.height;
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(spec.angle);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: cardW,
          height: cardH,
        ),
        Radius.circular(cardW * 0.1),
      );
      canvas.drawRRect(
        rect.shift(const Offset(0, 3)),
        Paint()..color = Colors.black.withValues(alpha: 0.16),
      );
      canvas.drawRRect(rect, Paint()..color = const Color(0xFFF8F9FA));
      canvas.drawRRect(
        rect,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final painter = TextPainter(
        text: TextSpan(
          text: spec.emoji,
          style: TextStyle(
            color: spec.color,
            fontSize: cardW * 0.38,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(-painter.width / 2, -painter.height / 2),
      );
      canvas.restore();
    }

    if (!compact) {
      canvas.drawCircle(
        Offset(size.width * 0.14, size.height * 0.28),
        5,
        Paint()..color = theme.accentColor.withValues(alpha: 0.7),
      );
      canvas.drawCircle(
        Offset(size.width * 0.86, size.height * 0.38),
        4,
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SolitaireArt oldDelegate) => false;
}

class _SnakeArt extends _CardArtPainter {
  _SnakeArt(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    drawBackgroundBubbles(canvas, size);

    final cell = size.width * (compact ? 0.09 : 0.085);
    final startX = size.width * 0.22;
    final startY = size.height * (compact ? 0.54 : 0.56);
    final segments = compact
        ? const [(0, 0), (1, 0), (2, 0), (2, 1), (2, 2)]
        : const [(0, 0), (1, 0), (2, 0), (3, 0), (3, 1), (3, 2), (2, 2)];

    for (var i = segments.length - 1; i >= 0; i--) {
      final (dx, dy) = segments[i];
      final rect = Rect.fromLTWH(
        startX + dx * cell * 0.92,
        startY + dy * cell * 0.92,
        cell,
        cell,
      );
      final isHead = i == 0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.28)),
        Paint()..color = isHead ? theme.accentColor : theme.blendColor,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.28)),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      if (isHead) {
        canvas.drawCircle(
          rect.center + Offset(cell * 0.15, -cell * 0.08),
          cell * 0.1,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          rect.center + Offset(cell * 0.22, -cell * 0.05),
          cell * 0.05,
          Paint()..color = const Color(0xFF2D3436),
        );
      }
    }

    final foodCenter = Offset(
      startX + (compact ? 4.2 : 5.1) * cell * 0.92,
      startY + (compact ? 0.5 : 0.4) * cell * 0.92,
    );
    final foodR = cell * 0.34;
    canvas.drawCircle(
      foodCenter,
      foodR + 3,
      Paint()..color = theme.accentSoft.withValues(alpha: 0.45),
    );
    canvas.drawCircle(foodCenter, foodR, Paint()..color = theme.accentColor);
    canvas.drawOval(
      Rect.fromCenter(
        center: foodCenter + Offset(foodR * 0.1, -foodR * 0.9),
        width: foodR * 0.9,
        height: foodR * 0.5,
      ),
      Paint()..color = theme.accentColor.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _SnakeArt oldDelegate) => false;
}

class _SudokuArt extends _CardArtPainter {
  _SudokuArt(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    drawBackgroundBubbles(canvas, size);

    final gridSize = compact ? size.width * 0.42 : size.width * 0.46;
    final left = (size.width - gridSize) / 2;
    final top = size.height * (compact ? 0.50 : 0.52);
    final cell = gridSize / 3;

    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, gridSize, gridSize),
      Radius.circular(gridSize * 0.06),
    );
    canvas.drawRRect(
      boardRect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );
    canvas.drawRRect(boardRect, Paint()..color = const Color(0xFFF0EDFF));
    canvas.drawRRect(
      boardRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final digits = compact
        ? [
            (0, 0, '5', theme.cardColor),
            (0, 1, '3', theme.accentColor),
            (1, 0, '6', theme.blendColor),
            (2, 2, '9', theme.accentSoft),
          ]
        : [
            (0, 0, '5', theme.cardColor),
            (0, 1, '3', theme.accentColor),
            (0, 2, '7', theme.blendColor),
            (1, 0, '6', theme.accentSoft),
            (1, 1, '1', theme.cardColor),
            (2, 2, '9', theme.accentColor),
          ];

    for (var i = 0; i <= 3; i++) {
      final stroke = i == 0 || i == 3 ? 2.0 : 1.0;
      final color = i == 0 || i == 3
          ? theme.cardColor.withValues(alpha: 0.85)
          : theme.blendColor.withValues(alpha: 0.45);
      final x = left + i * cell;
      canvas.drawLine(
        Offset(x, top),
        Offset(x, top + gridSize),
        Paint()
          ..color = color
          ..strokeWidth = stroke,
      );
      final y = top + i * cell;
      canvas.drawLine(
        Offset(left, y),
        Offset(left + gridSize, y),
        Paint()
          ..color = color
          ..strokeWidth = stroke,
      );
    }

    for (final (r, c, text, color) in digits) {
      final cx = left + (c + 0.5) * cell;
      final cy = top + (r + 0.5) * cell;
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: cell * 0.52,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(cx - painter.width / 2, cy - painter.height / 2),
      );
    }

    if (!compact) {
      canvas.drawCircle(
        Offset(size.width * 0.16, size.height * 0.30),
        5,
        Paint()..color = theme.accentColor.withValues(alpha: 0.75),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SudokuArt oldDelegate) => false;
}

class _CrossSumsArt extends _CardArtPainter {
  _CrossSumsArt(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    drawBackgroundBubbles(canvas, size);

    final gridSize = compact ? size.width * 0.46 : size.width * 0.50;
    final left = (size.width - gridSize) / 2;
    final top = size.height * (compact ? 0.50 : 0.52);
    const extent = 4;
    final cell = gridSize / extent;

    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, gridSize, gridSize),
      Radius.circular(gridSize * 0.06),
    );
    canvas.drawRRect(
      boardRect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    const headers = ['9', '4', '7'];
    const rowTargets = ['14', '2', '5'];
    const cells = [
      ['8', '5', '6'],
      ['7', '1', '4'],
      ['1', '4', '1'],
    ];

    for (var br = 0; br < extent; br++) {
      for (var bc = 0; bc < extent; bc++) {
        final rect = Rect.fromLTWH(
          left + bc * cell,
          top + br * cell,
          cell,
          cell,
        );
        Color bg;
        String? label;

        if (br == 0 && bc == 0) {
          bg = const Color(0xFFE6F2F8);
        } else if (br == 0 && bc > 0) {
          bg = const Color(0xFFB3D9EE);
          label = headers[bc - 1];
        } else if (bc == 0 && br > 0) {
          bg = const Color(0xFFB3D9EE);
          label = rowTargets[br - 1];
        } else {
          bg = Colors.white;
          label = cells[br - 1][bc - 1];
        }

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.deflate(1.2), const Radius.circular(4)),
          Paint()..color = bg,
        );

        if (label != null) {
          final painter = TextPainter(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: br == 0 || bc == 0
                    ? const Color(0xFF2D3436)
                    : theme.cardColor,
                fontSize: cell * 0.42,
                fontWeight: FontWeight.w800,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          painter.paint(
            canvas,
            Offset(
              rect.center.dx - painter.width / 2,
              rect.center.dy - painter.height / 2,
            ),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CrossSumsArt oldDelegate) => false;
}

class _ColorBlocksArt extends _CardArtPainter {
  _ColorBlocksArt(super.theme, {super.compact});

  static const _blockPalette = [
    Color(0xFFFF7675),
    Color(0xFF74B9FF),
    Color(0xFF55EFC4),
    Color(0xFFFDCB6E),
    Color(0xFFE17055),
    Color(0xFFA29BFE),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    drawBackgroundBubbles(canvas, size);

    final gridCells = compact ? 4 : 5;
    final gap = size.width * (compact ? 0.014 : 0.012);
    final cell = size.width * (compact ? 0.105 : 0.092);
    final gridW = gridCells * cell + (gridCells - 1) * gap;
    final gridH = gridW;
    final boardPad = cell * 0.28;
    final boardW = gridW + boardPad * 2;
    final boardH = gridH + boardPad * 2;
    final boardLeft = (size.width - boardW) / 2;
    final boardTop = size.height * (compact ? 0.34 : 0.30);
    final gridLeft = boardLeft + boardPad;
    final gridTop = boardTop + boardPad;

    _drawBoardPanel(canvas, boardLeft, boardTop, boardW, boardH, cell);

    final board = compact
        ? const [
            [0, 1, 2, 3],
            [4, null, 2, null],
            [null, 0, 1, null],
            [3, null, null, null],
          ]
        : const [
            [0, 1, 2, 3, 4],
            [5, null, 2, null, 3],
            [null, 0, 1, 1, null],
            [4, null, null, 5, null],
            [null, null, 3, null, null],
          ];

    final clearedRow = 0;
    final clearedCol = compact ? null : 2;
    _drawLineGlow(
      canvas,
      gridLeft,
      gridTop,
      cell,
      gap,
      gridCells,
      row: clearedRow,
      col: clearedCol,
    );

    for (var row = 0; row < gridCells; row++) {
      for (var col = 0; col < gridCells; col++) {
        final x = gridLeft + col * (cell + gap);
        final y = gridTop + row * (cell + gap);
        final colorIndex = board[row][col];
        if (colorIndex == null) {
          _drawEmptyCell(canvas, x, y, cell);
        } else {
          _drawBlock(
            canvas,
            x,
            y,
            cell,
            _blockPalette[colorIndex % _blockPalette.length],
          );
        }
      }
    }

    if (!compact) {
      _drawGhostPiece(
        canvas,
        gridLeft + cell * 0.15,
        gridTop + clearedRow * (cell + gap) - cell * 0.08,
        cell * 0.88,
        const [(0, 0)],
        _blockPalette[5],
      );
    }

    _drawTray(canvas, size, boardTop + boardH + cell * 0.12);

    if (!compact) {
      _sparkle(
        canvas,
        Offset(boardLeft + boardW * 0.88, boardTop + cell * 0.55),
        6,
        const Color(0xFFFDCB6E),
      );
      _sparkle(
        canvas,
        Offset(boardLeft + boardW * 0.08, boardTop + boardH * 0.72),
        5,
        Colors.white,
      );
    }
  }

  void _drawBoardPanel(
    Canvas canvas,
    double left,
    double top,
    double width,
    double height,
    double cell,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, width, height),
      Radius.circular(cell * 0.18),
    );
    canvas.drawRRect(
      rect.shift(const Offset(0, 4)),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Color.lerp(theme.cardColor, Colors.black, 0.22)!,
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawEmptyCell(Canvas canvas, double x, double y, double cell) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, cell, cell),
      Radius.circular(cell * 0.14),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = theme.blendColor.withValues(alpha: 0.42),
    );
  }

  void _drawBlock(Canvas canvas, double x, double y, double cell, Color color) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, cell, cell),
      Radius.circular(cell * 0.14),
    );
    canvas.drawRRect(
      rect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withValues(alpha: 0.16),
    );
    canvas.drawRRect(rect, Paint()..color = color);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.48)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x + cell * 0.12,
          y + cell * 0.10,
          cell * 0.52,
          cell * 0.22,
        ),
        Radius.circular(cell * 0.08),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
  }

  void _drawLineGlow(
    Canvas canvas,
    double gridLeft,
    double gridTop,
    double cell,
    double gap,
    int gridCells, {
    required int row,
    int? col,
  }) {
    final stride = cell + gap;
    final glow = Paint()..color = const Color(0xFFFDCB6E).withValues(alpha: 0.55);
    final rowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        gridLeft,
        gridTop + row * stride,
        gridCells * cell + (gridCells - 1) * gap,
        cell,
      ),
      Radius.circular(cell * 0.12),
    );
    canvas.drawRRect(rowRect, glow);
    canvas.drawRRect(
      rowRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    if (col != null) {
      final colRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          gridLeft + col * stride,
          gridTop,
          cell,
          gridCells * cell + (gridCells - 1) * gap,
        ),
        Radius.circular(cell * 0.12),
      );
      canvas.drawRRect(
        colRect,
        Paint()..color = const Color(0xFFFDCB6E).withValues(alpha: 0.32),
      );
    }
  }

  void _drawPolyomino(
    Canvas canvas,
    Offset origin,
    double cell,
    List<(int, int)> cells,
    Color color, {
    double alpha = 1,
  }) {
    for (final (row, col) in cells) {
      _drawBlock(
        canvas,
        origin.dx + col * cell * 0.94,
        origin.dy + row * cell * 0.94,
        cell * 0.88,
        color.withValues(alpha: alpha),
      );
    }
  }

  void _drawGhostPiece(
    Canvas canvas,
    double x,
    double y,
    double cell,
    List<(int, int)> cells,
    Color color,
  ) {
    for (final (row, col) in cells) {
      final px = x + col * cell * 0.94;
      final py = y + row * cell * 0.94;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(px, py, cell * 0.88, cell * 0.88),
        Radius.circular(cell * 0.12),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = color.withValues(alpha: 0.38),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = const Color(0xFF55EFC4).withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawTray(
    Canvas canvas,
    Size size,
    double trayTop,
  ) {
    final trayW = size.width * (compact ? 0.78 : 0.82);
    final trayH = size.height * (compact ? 0.16 : 0.18);
    final trayLeft = (size.width - trayW) / 2;
    final trayRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(trayLeft, trayTop, trayW, trayH),
      Radius.circular(trayH * 0.22),
    );
    canvas.drawRRect(
      trayRect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      trayRect,
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      trayRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final slotW = trayW / 3;
    final pieceCell = trayH * (compact ? 0.24 : 0.22);
    final specs = compact
        ? [
            (
              const [(0, 0), (0, 1), (1, 0)],
              _blockPalette[0],
              trayLeft + slotW * 0.5,
            ),
            (
              const [(0, 0), (0, 1), (0, 2)],
              _blockPalette[1],
              trayLeft + slotW * 1.5,
            ),
            (
              const [(0, 0), (0, 1), (1, 0), (1, 1)],
              _blockPalette[2],
              trayLeft + slotW * 2.5,
            ),
          ]
        : [
            (
              const [(0, 0), (0, 1), (1, 0)],
              _blockPalette[0],
              trayLeft + slotW * 0.5,
            ),
            (
              const [(0, 0), (0, 1), (0, 2), (1, 1)],
              _blockPalette[1],
              trayLeft + slotW * 1.5,
            ),
            (
              const [(0, 0), (0, 1), (1, 0), (1, 1)],
              _blockPalette[2],
              trayLeft + slotW * 2.5,
            ),
          ];

    for (var i = 0; i < specs.length; i++) {
      final (cells, color, cx) = specs[i];
      final (minR, maxR, minC, maxC) = _bounds(cells);
      final rows = maxR - minR + 1;
      final cols = maxC - minC + 1;
      final pieceW = cols * pieceCell * 0.94;
      final pieceH = rows * pieceCell * 0.94;
      final lift = i == 0 && !compact ? -pieceCell * 0.35 : 0.0;
      final origin = Offset(
        cx - pieceW / 2 - minC * pieceCell * 0.94,
        trayTop + (trayH - pieceH) / 2 + lift,
      );
      _drawPolyomino(canvas, origin, pieceCell, cells, color);
    }

    if (!compact) {
      canvas.drawLine(
        Offset(trayLeft + slotW, trayTop + trayH * 0.18),
        Offset(trayLeft + slotW, trayTop + trayH * 0.82),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.12)
          ..strokeWidth = 1,
      );
      canvas.drawLine(
        Offset(trayLeft + slotW * 2, trayTop + trayH * 0.18),
        Offset(trayLeft + slotW * 2, trayTop + trayH * 0.82),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.12)
          ..strokeWidth = 1,
      );
    }
  }

  (int minR, int maxR, int minC, int maxC) _bounds(List<(int, int)> cells) {
    var minR = cells.first.$1;
    var maxR = cells.first.$1;
    var minC = cells.first.$2;
    var maxC = cells.first.$2;
    for (final (row, col) in cells) {
      if (row < minR) minR = row;
      if (row > maxR) maxR = row;
      if (col < minC) minC = col;
      if (col > maxC) maxC = col;
    }
    return (minR, maxR, minC, maxC);
  }

  void _sparkle(Canvas canvas, Offset p, double s, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(p, s * 0.35, paint);
    canvas.drawRect(
      Rect.fromCenter(center: p, width: s * 1.5, height: s * 0.35),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: p, width: s * 0.35, height: s * 1.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ColorBlocksArt oldDelegate) => false;
}

class _MinesweeperArt extends _CardArtPainter {
  _MinesweeperArt(super.theme, {super.compact});

  static const _revealedFill = Color(0xFFECF0F1);
  static const _numColors = [
    Color(0xFF0984E3),
    Color(0xFF00B894),
    Color(0xFFE17055),
    Color(0xFF4834D4),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    drawBackgroundBubbles(canvas, size);

    final gridCells = compact ? 4 : 5;
    final gridSize = size.width * (compact ? 0.56 : 0.52);
    final boardPad = gridSize / gridCells * 0.18;
    final boardW = gridSize + boardPad * 2;
    final lcdH = gridSize / gridCells * (compact ? 0.42 : 0.48);
    final boardH = gridSize + boardPad * 2 + lcdH;
    final boardLeft = (size.width - boardW) / 2;
    final boardTop = size.height * (compact ? 0.36 : 0.34);

    canvas.save();
    canvas.translate(size.width * 0.5, boardTop + boardH * 0.55);
    canvas.rotate(compact ? -0.04 : -0.06);
    canvas.translate(-size.width * 0.5, -(boardTop + boardH * 0.55));

    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boardLeft, boardTop, boardW, boardH),
      Radius.circular(boardPad * 0.9),
    );
    canvas.drawRRect(
      boardRect.shift(const Offset(0, 5)),
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );
    canvas.drawRRect(
      boardRect,
      Paint()..color = Color.lerp(theme.cardColor, Colors.black, 0.22)!,
    );
    canvas.drawRRect(
      boardRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final lcdRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        boardLeft + boardPad * 0.55,
        boardTop + boardPad * 0.55,
        boardW - boardPad * 1.1,
        lcdH,
      ),
      Radius.circular(boardPad * 0.35),
    );
    canvas.drawRRect(lcdRect, Paint()..color = const Color(0xFF1A252F));
    canvas.drawRRect(
      lcdRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    _drawLcdCounter(
      canvas,
      Offset(lcdRect.left + lcdRect.width * 0.22, lcdRect.center.dy),
      '010',
      theme.accentColor,
      lcdH * 0.42,
    );
    _drawLcdCounter(
      canvas,
      Offset(lcdRect.right - lcdRect.width * 0.22, lcdRect.center.dy),
      compact ? '042' : '128',
      theme.accentSoft,
      lcdH * 0.42,
    );
    if (!compact) {
      _drawMineIcon(
        canvas,
        Offset(lcdRect.left + lcdRect.width * 0.12, lcdRect.center.dy),
        lcdH * 0.18,
      );
    }

    final gridLeft = boardLeft + boardPad;
    final gridTop = boardTop + boardPad + lcdH + boardPad * 0.35;
    final cell = gridSize / gridCells;
    final gap = cell * 0.08;
    final tile = cell - gap;

    final pattern = compact ? _compactPattern : _fullPattern;
    for (var r = 0; r < gridCells; r++) {
      for (var c = 0; c < gridCells; c++) {
        final rect = Rect.fromLTWH(
          gridLeft + c * cell + gap * 0.5,
          gridTop + r * cell + gap * 0.5,
          tile,
          tile,
        );
        _paintCell(canvas, rect, pattern[r][c], cell);
      }
    }

    canvas.restore();

    if (!compact) {
      _sparkle(
        canvas,
        Offset(size.width * 0.12, size.height * 0.26),
        6,
        theme.accentSoft,
      );
      _sparkle(
        canvas,
        Offset(size.width * 0.90, size.height * 0.22),
        5,
        Colors.white.withValues(alpha: 0.85),
      );
    }
  }

  static const _fullPattern = [
    'Fh...',
    '.122.',
    '.1F23',
    '.222.',
    '...mM',
  ];

  static const _compactPattern = [
    'Fh..',
    '.12f',
    '.1F2',
    '..mM',
  ];

  void _paintCell(Canvas canvas, Rect rect, String code, double cell) {
    switch (code) {
      case 'F':
        _drawHiddenCell(canvas, rect, raised: true);
        _drawFlag(canvas, rect, cell);
      case 'f':
        _drawHiddenCell(canvas, rect, raised: false);
        _drawFlag(canvas, rect, cell, dimmed: true);
      case 'M':
        _drawRevealedCell(
          canvas,
          rect,
          fill: theme.accentColor.withValues(alpha: 0.95),
        );
        _drawMineGlow(canvas, rect.center, rect.width * 0.42);
        _drawMine(canvas, rect.center, rect.width * 0.24);
      case 'm':
        _drawHiddenCell(canvas, rect, raised: true);
        _drawMineGlow(canvas, rect.center, rect.width * 0.38);
        _drawMine(canvas, rect.center, rect.width * 0.18);
      case '.':
        _drawHiddenCell(canvas, rect, raised: true);
      case 'h':
        _drawHiddenCell(canvas, rect, raised: false);
      case '0':
        _drawRevealedCell(canvas, rect);
      default:
        if (code.length == 1 && code.codeUnitAt(0) >= 49 && code.codeUnitAt(0) <= 57) {
          final digit = int.parse(code);
          _drawRevealedCell(canvas, rect);
          _drawDigit(
            canvas,
            rect.center,
            code,
            rect.width * 0.46,
            _numColors[(digit - 1).clamp(0, _numColors.length - 1)],
          );
        }
    }
  }

  void _drawHiddenCell(Canvas canvas, Rect rect, {required bool raised}) {
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.width * 0.16),
    );
    canvas.drawRRect(
      rr.shift(Offset(0, raised ? 2.5 : 1)),
      Paint()..color = Colors.black.withValues(alpha: raised ? 0.16 : 0.10),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: raised
              ? [
                  const Color(0xFFD5DBDB),
                  theme.blendColor.withValues(alpha: 0.95),
                ]
              : [
                  theme.blendColor.withValues(alpha: 0.72),
                  theme.cardColor.withValues(alpha: 0.88),
                ],
        ).createShader(rect),
    );
    if (raised) {
      canvas.drawLine(
        rect.topLeft + const Offset(2, 2),
        rect.topRight + const Offset(-2, 2),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..strokeWidth = 1.2,
      );
      canvas.drawLine(
        rect.bottomLeft + const Offset(2, -2),
        rect.bottomRight + const Offset(-2, -2),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.12)
          ..strokeWidth = 1.2,
      );
    }
  }

  void _drawRevealedCell(Canvas canvas, Rect rect, {Color? fill}) {
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.width * 0.12),
    );
    canvas.drawRRect(rr, Paint()..color = fill ?? _revealedFill);
    if (fill == null) {
      canvas.drawRRect(
        rr,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  void _drawFlag(Canvas canvas, Rect rect, double cell, {bool dimmed = false}) {
    final poleX = rect.center.dx - cell * 0.12;
    final baseY = rect.center.dy + cell * 0.20;
    final topY = rect.center.dy - cell * 0.22;
    final poleColor = dimmed
        ? theme.cardColor.withValues(alpha: 0.65)
        : theme.cardColor;
    canvas.drawLine(
      Offset(poleX, baseY),
      Offset(poleX, topY),
      Paint()
        ..color = poleColor
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(poleX, baseY),
      cell * 0.06,
      Paint()..color = poleColor,
    );
    final flag = Path()
      ..moveTo(poleX, topY)
      ..lineTo(poleX + cell * 0.26, topY + cell * 0.08)
      ..lineTo(poleX, topY + cell * 0.16)
      ..close();
    final flagColor = dimmed
        ? theme.accentColor.withValues(alpha: 0.55)
        : theme.accentColor;
    canvas.drawPath(flag, Paint()..color = flagColor);
    canvas.drawPath(
      flag,
      Paint()
        ..color = Colors.white.withValues(alpha: dimmed ? 0.12 : 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  void _drawMineGlow(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = theme.accentColor.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      center,
      radius * 0.65,
      Paint()..color = theme.accentSoft.withValues(alpha: 0.35),
    );
  }

  void _drawMine(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center + Offset(0, radius * 0.08),
      radius,
      Paint()..color = const Color(0xFF2C3E50),
    );
    canvas.drawCircle(
      center + Offset(-radius * 0.22, -radius * 0.22),
      radius * 0.28,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      center,
      radius * 0.32,
      Paint()..color = const Color(0xFF636E72),
    );
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final dx = math.cos(angle) * radius * 1.5;
      final dy = math.sin(angle) * radius * 1.5;
      canvas.drawLine(
        center,
        Offset(center.dx + dx, center.dy + dy),
        Paint()
          ..color = const Color(0xFF2C3E50)
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawMineIcon(Canvas canvas, Offset center, double radius) {
    _drawMine(canvas, center, radius);
  }

  void _drawLcdCounter(
    Canvas canvas,
    Offset center,
    String text,
    Color color,
    double fontSize,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          fontFeatures: const [FontFeature.tabularFigures()],
          height: 1,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  void _drawDigit(
    Canvas canvas,
    Offset center,
    String text,
    double fontSize,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  void _sparkle(Canvas canvas, Offset p, double s, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(p, s * 0.35, paint);
    canvas.drawRect(
      Rect.fromCenter(center: p, width: s * 1.5, height: s * 0.35),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: p, width: s * 0.35, height: s * 1.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MinesweeperArt oldDelegate) => false;
}

class _TileSpec {
  const _TileSpec(this.value, this.dx, this.dy, this.color);
  final int value;
  final double dx;
  final double dy;
  final Color color;
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
  _GenericArt(super.theme, this.gameId, {super.compact});

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
    this.showTitleOverlay = true,
    this.showFeaturedBadge = false,
  });

  final String gameId;
  final String title;
  final HubGameTheme theme;
  final double height;
  final bool showTitleOverlay;
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
          if (showTitleOverlay) ...[
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
                    width: hubUnderlineWidth(titleLead),
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.accentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (showFeaturedBadge)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: HubTheme.featuredBadge,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  L10nScope.of.featuredBadgeNew,
                  style: const TextStyle(
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
}
