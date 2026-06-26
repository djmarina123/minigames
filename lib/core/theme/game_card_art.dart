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
        'domino' => _DominoArt(theme, compact: compact),
        'sudoku' => _SudokuArt(theme, compact: compact),
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

    final groundY = size.height * 0.76;
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      Paint()..color = const Color(0xFF7BED9F).withValues(alpha: 0.35),
    );
    canvas.drawLine(
      Offset(0, groundY),
      Offset(size.width, groundY),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..strokeWidth = 2,
    );

    final pw = size.width * (compact ? 0.1 : 0.11);
    final ph = size.height * (compact ? 0.11 : 0.13);
    final px = size.width * 0.2;
    final py = groundY;

    // Corredor
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(px, py - ph * 0.82, pw, ph * 0.55),
        Radius.circular(pw * 0.18),
      ),
      Paint()..color = theme.accentColor,
    );
    canvas.drawCircle(
      Offset(px + pw * 0.62, py - ph * 0.86),
      pw * 0.2,
      Paint()..color = theme.accentSoft,
    );

    // Cacto baixo
    final cactusX = size.width * 0.58;
    final ch = ph * 0.72;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cactusX, py - ch, pw * 0.28, ch),
        Radius.circular(pw * 0.08),
      ),
      Paint()..color = const Color(0xFF00B894),
    );

    // Viga alta
    if (!compact) {
      final beamW = pw * 1.5;
      final beamX = size.width * 0.78;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(beamX, py - ph * 1.15, beamW, ph * 0.28),
          Radius.circular(4),
        ),
        Paint()..color = theme.cardColor,
      );
    }
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

class _DominoArt extends _CardArtPainter {
  _DominoArt(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    drawBackgroundBubbles(canvas, size);

    final tileW = size.width * (compact ? 0.22 : 0.2);
    final tileH = tileW / 0.52;
    final baseX = size.width * 0.5;
    final baseY = size.height * (compact ? 0.56 : 0.58);

    final specs = compact
        ? [
            _DominoTileSpec(3, 5, -0.3, 0.0, -0.1),
            _DominoTileSpec(6, 6, 0.05, -0.08, 0.04),
            _DominoTileSpec(2, 4, 0.32, 0.1, 0.12),
          ]
        : [
            _DominoTileSpec(4, 2, -0.34, 0.06, -0.12),
            _DominoTileSpec(6, 6, -0.02, -0.1, 0.05),
            _DominoTileSpec(1, 5, 0.3, 0.08, 0.1),
            _DominoTileSpec(3, 3, 0.08, 0.2, -0.05),
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
          width: tileW,
          height: tileH,
        ),
        Radius.circular(tileW * 0.1),
      );
      canvas.drawRRect(
        rect.shift(const Offset(0, 3)),
        Paint()..color = Colors.black.withValues(alpha: 0.16),
      );
      canvas.drawRRect(rect, Paint()..color = const Color(0xFFF5F0E8));
      canvas.drawRRect(
        rect,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final half = tileH / 2;
      canvas.drawLine(
        Offset(-tileW / 2 + 4, 0),
        Offset(tileW / 2 - 4, 0),
        Paint()
          ..color = theme.cardColor.withValues(alpha: 0.35)
          ..strokeWidth = 1.5,
      );
      _paintDominoPips(canvas, Rect.fromLTWH(-tileW / 2, -tileH / 2, tileW, half - 1), spec.top);
      _paintDominoPips(canvas, Rect.fromLTWH(-tileW / 2, 1, tileW, half - 1), spec.bottom);
      canvas.restore();
    }
  }

  void _paintDominoPips(Canvas canvas, Rect area, int value) {
    if (value == 0) return;
    const patterns = <int, List<Offset>>{
      1: [Offset(0.5, 0.5)],
      2: [Offset(0.28, 0.28), Offset(0.72, 0.72)],
      3: [Offset(0.28, 0.28), Offset(0.5, 0.5), Offset(0.72, 0.72)],
      4: [Offset(0.28, 0.28), Offset(0.72, 0.28), Offset(0.28, 0.72), Offset(0.72, 0.72)],
      5: [Offset(0.28, 0.28), Offset(0.72, 0.28), Offset(0.5, 0.5), Offset(0.28, 0.72), Offset(0.72, 0.72)],
      6: [Offset(0.28, 0.25), Offset(0.72, 0.25), Offset(0.28, 0.5), Offset(0.72, 0.5), Offset(0.28, 0.75), Offset(0.72, 0.75)],
    };
    final dots = patterns[value] ?? const [];
    final radius = area.width * 0.08;
    final paint = Paint()..color = theme.cardColor;
    for (final rel in dots) {
      canvas.drawCircle(
        Offset(area.left + area.width * rel.dx, area.top + area.height * rel.dy),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DominoArt oldDelegate) => false;
}

class _DominoTileSpec {
  const _DominoTileSpec(this.top, this.bottom, this.dx, this.dy, this.angle);
  final int top;
  final int bottom;
  final double dx;
  final double dy;
  final double angle;
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
