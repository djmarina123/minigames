import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hub_card_widgets.dart';
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

  /// Escala da ilustração (~65–70% da área útil do card).
  double illustrationSize(Size size, {double factor = 0.96}) =>
      math.min(size.width, size.height) *
      (compact ? factor - 0.12 : factor);

  Offset illustrationOrigin(Size size, double extent) =>
      Offset((size.width - extent) / 2, (size.height - extent) / 2);

  void drawCardFace(
    Canvas canvas,
    RRect rect,
    Color fill, {
    String? label,
    Color labelColor = Colors.white,
    double labelSize = 0.38,
  }) {
    canvas.drawRRect(
      rect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawRRect(rect, Paint()..color = fill);
    if (label != null) {
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: labelColor,
            fontSize: rect.width * labelSize,
            fontWeight: FontWeight.w800,
            height: 1,
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

class _TapRushArt extends _CardArtPainter {
  _TapRushArt(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    final extent = illustrationSize(size, factor: 1.0);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = extent * 0.48;

    // Brilho radial de fundo.
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.accentColor.withValues(alpha: 0.35),
          theme.accentColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 1.35));
    canvas.drawCircle(Offset(cx, cy), r * 1.35, glowPaint);

    // Ondas circulares (pulso).
    for (var i = 1; i <= 3; i++) {
      canvas.drawCircle(
        Offset(cx, cy),
        r * (1.0 + i * 0.14),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.06 + i * 0.02)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    final rings = [
      (r * 1.12, Colors.white.withValues(alpha: 0.12)),
      (r * 0.92, theme.cardColor),
      (r * 0.68, theme.accentColor),
      (r * 0.42, theme.accentSoft),
      (r * 0.16, Colors.white),
    ];
    for (final (radius, color) in rings) {
      canvas.drawCircle(Offset(cx, cy), radius, Paint()..color = color);
    }

    // Partículas discretas.
    final particlePaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    for (final (dx, dy, pr) in [
      (-0.72, -0.55, 0.04),
      (0.68, -0.42, 0.035),
      (0.55, 0.62, 0.03),
      (-0.58, 0.48, 0.028),
    ]) {
      canvas.drawCircle(
        Offset(cx + dx * r, cy + dy * r),
        r * pr,
        particlePaint,
      );
    }

    if (!compact) {
      canvas.save();
      canvas.translate(cx + r * 0.08, cy + r * 0.05);
      canvas.rotate(-0.28);
      final fingerW = r * 0.52;
      final fingerH = r * 0.92;
      final fingerRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(fingerW * 0.1, -fingerH * 0.1),
          width: fingerW,
          height: fingerH,
        ),
        Radius.circular(fingerW * 0.45),
      );
      canvas.drawRRect(
        fingerRect.shift(const Offset(0, 2)),
        Paint()..color = Colors.black.withValues(alpha: 0.1),
      );
      canvas.drawRRect(fingerRect, Paint()..color = Colors.white);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _TapRushArt oldDelegate) => false;
}

class _MemoryArt extends _CardArtPainter {
  _MemoryArt(super.theme, {super.compact});

  /// Paleta das cartas viradas — alinhada a [MemoryConfig] / `memory_symbols.dart`.
  static const _backFill = Color(0xFF5B4BB7);
  static const _starFace = Color(0xFFF9A825);
  static const _rocketFace = Color(0xFF1E88E5);
  static const _matchGlow = Color(0xFFFDCB6E);

  @override
  void paint(Canvas canvas, Size size) {
    final gridExtent =
        math.min(size.width, size.height) * (compact ? 0.80 : 0.72);
    final origin = illustrationOrigin(size, gridExtent);

    if (!compact) {
      final glowCenter = Offset(
        origin.dx + gridExtent * 0.5,
        origin.dy + gridExtent * 0.5,
      );
      canvas.drawCircle(
        glowCenter,
        gridExtent * 0.42,
        Paint()
          ..shader = RadialGradient(
            colors: [
              _matchGlow.withValues(alpha: 0.28),
              _matchGlow.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(center: glowCenter, radius: gridExtent * 0.42),
          ),
      );
    }

    if (compact) {
      _paintCompact(canvas, origin, gridExtent);
    } else {
      _paintGrid(canvas, origin, gridExtent);
    }
  }

  void _paintCompact(Canvas canvas, Offset origin, double extent) {
    final tileW = extent * 0.52;
    final tileH = tileW * 1.18;
    final base = Offset(origin.dx + extent * 0.5, origin.dy + extent * 0.54);

    _paintMemoryTile(
      canvas,
      base + Offset(-extent * 0.14, extent * 0.02),
      tileW * 0.92,
      tileH * 0.92,
      angle: -0.14,
      face: _MemoryTileFace.back,
    );
    _paintMemoryTile(
      canvas,
      base + Offset(extent * 0.12, -extent * 0.04),
      tileW,
      tileH,
      angle: 0.1,
      face: _MemoryTileFace.star,
      matched: true,
    );
  }

  void _paintGrid(Canvas canvas, Offset origin, double extent) {
    const cols = 2;
    const rows = 2;
    final gap = extent * 0.07;
    final tileW = (extent - gap * (cols - 1)) / cols;
    final tileH = tileW * 1.12;

    final faces = [
      _MemoryTileFace.back,
      _MemoryTileFace.star,
      _MemoryTileFace.star,
      _MemoryTileFace.rocket,
    ];

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final idx = row * cols + col;
        final cx = origin.dx + col * (tileW + gap) + tileW / 2;
        final cy = origin.dy + row * (tileH + gap) + tileH / 2;
        final face = faces[idx];
        _paintMemoryTile(
          canvas,
          Offset(cx, cy),
          tileW,
          tileH,
          angle: (col - 0.5) * 0.04 + (row - 0.5) * 0.03,
          face: face,
          matched: face == _MemoryTileFace.star,
        );
      }
    }

    // Brilho de par encontrado entre as duas estrelas.
    final sparkle = Paint()..color = Colors.white.withValues(alpha: 0.5);
    for (final (fx, fy, fr) in [
      (0.28, 0.38, 0.016),
      (0.72, 0.62, 0.014),
      (0.5, 0.5, 0.012),
    ]) {
      canvas.drawCircle(
        Offset(origin.dx + extent * fx, origin.dy + extent * fy),
        extent * fr,
        sparkle,
      );
    }
  }

  void _paintMemoryTile(
    Canvas canvas,
    Offset center,
    double width,
    double height, {
    required double angle,
    required _MemoryTileFace face,
    bool matched = false,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );
    final radius = Radius.circular(width * 0.14);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    canvas.drawRRect(
      rrect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    if (matched) {
      canvas.drawRRect(
        rrect.inflate(2),
        Paint()
          ..color = _matchGlow.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    switch (face) {
      case _MemoryTileFace.back:
        canvas.drawRRect(rrect, Paint()..color = _backFill);
        _drawBackDots(canvas, rect);
      case _MemoryTileFace.star:
        canvas.drawRRect(rrect, Paint()..color = _starFace);
        _drawStarIcon(canvas, rect);
      case _MemoryTileFace.rocket:
        canvas.drawRRect(rrect, Paint()..color = _rocketFace);
        _drawRocketIcon(canvas, rect);
    }

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white.withValues(alpha: matched ? 0.85 : 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 0.05,
    );

    canvas.restore();
  }

  void _drawBackDots(Canvas canvas, Rect rect) {
    const cols = 3;
    const rows = 3;
    final dotR = rect.width * 0.045;
    final gapX = rect.width / (cols + 1);
    final gapY = rect.height / (rows + 1);
    final dotPaint = Paint()
      ..color = theme.accentSoft.withValues(alpha: 0.38);
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        canvas.drawCircle(
          Offset(rect.left + gapX * (col + 1), rect.top + gapY * (row + 1)),
          dotR,
          dotPaint,
        );
      }
    }
  }

  void _drawStarIcon(Canvas canvas, Rect rect) {
    final path = _starPath(rect.center, rect.width * 0.22, rect.width * 0.09, 5);
    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFF6F00).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rect.width * 0.025,
    );
  }

  void _drawRocketIcon(Canvas canvas, Rect rect) {
    final cx = rect.center.dx;
    final top = rect.top + rect.height * 0.14;
    final bottom = rect.top + rect.height * 0.72;
    final halfW = rect.width * 0.22;

    final body = Path()
      ..moveTo(cx, top)
      ..lineTo(cx + halfW, bottom)
      ..lineTo(cx - halfW, bottom)
      ..close();
    canvas.drawPath(body, Paint()..color = Colors.white);

    canvas.drawCircle(
      Offset(cx, top + rect.height * 0.28),
      rect.width * 0.07,
      Paint()..color = _rocketFace.withValues(alpha: 0.55),
    );

    for (final wing in [
      Path()
        ..moveTo(cx - halfW, bottom)
        ..lineTo(cx - halfW * 1.35, bottom + rect.height * 0.16)
        ..lineTo(cx - halfW * 0.55, bottom + rect.height * 0.04)
        ..close(),
      Path()
        ..moveTo(cx + halfW, bottom)
        ..lineTo(cx + halfW * 1.35, bottom + rect.height * 0.16)
        ..lineTo(cx + halfW * 0.55, bottom + rect.height * 0.04)
        ..close(),
    ]) {
      canvas.drawPath(wing, Paint()..color = const Color(0xFFFF7043));
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, bottom + rect.height * 0.06),
        width: rect.width * 0.14,
        height: rect.height * 0.1,
      ),
      Paint()..color = const Color(0xFFFF7043),
    );
  }

  Path _starPath(Offset center, double outerR, double innerR, int points) {
    final path = Path();
    final step = math.pi / points;
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = -math.pi / 2 + i * step;
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _MemoryArt oldDelegate) => false;
}

enum _MemoryTileFace { back, star, rocket }

class _Game2048Art extends _CardArtPainter {
  _Game2048Art(super.theme, {super.compact});

  static const _tilePalette = <int, (Color bg, Color fg)>{
    2: (Color(0xFFEEE4DA), Color(0xFF776E65)),
    4: (Color(0xFFEDE0C8), Color(0xFF776E65)),
    8: (Color(0xFFF2B179), Colors.white),
    16: (Color(0xFFF59563), Colors.white),
    32: (Color(0xFFF67C5F), Colors.white),
    64: (Color(0xFFF65E3B), Colors.white),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final tiles = const [
      (2, 0, 0),
      (4, 1, 0),
      (8, 0, 1),
      (16, 1, 1),
    ];

    const gridExtent = 2;
    final gridSize = math.min(size.width, size.height) * (compact ? 0.72 : 0.70);
    final gap = gridSize * 0.055;
    final tileSize = (gridSize - gap * (gridExtent - 1)) / gridExtent;
    final originX = (size.width - gridSize) / 2;
    final originY = (size.height - gridSize) / 2;

    if (!compact) {
      // Quadrados transparentes no fundo.
      final ghostPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final ghostStep = gridSize * 0.22;
      for (var gx = 0; gx < 3; gx++) {
        for (var gy = 0; gy < 3; gy++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                originX - ghostStep * 0.6 + gx * ghostStep * 0.55,
                originY - ghostStep * 0.6 + gy * ghostStep * 0.55,
                ghostStep * 0.45,
                ghostStep * 0.45,
              ),
              Radius.circular(ghostStep * 0.08),
            ),
            ghostPaint,
          );
        }
      }

      final boardRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          originX - gap * 0.8,
          originY - gap * 0.8,
          gridSize + gap * 1.6,
          gridSize + gap * 1.6,
        ),
        Radius.circular(tileSize * 0.12),
      );
      canvas.drawRRect(
        boardRect,
        Paint()..color = const Color(0xFFBBADA0).withValues(alpha: 0.55),
      );
    }

    for (final (value, col, row) in tiles) {
      final cx = originX + col * (tileSize + gap) + tileSize / 2;
      final cy = originY + row * (tileSize + gap) + tileSize / 2;
      final palette = _tilePalette[value] ?? (theme.accentColor, Colors.white);
      _drawTile(canvas, Offset(cx, cy), tileSize, value, palette.$1, palette.$2);
    }
  }

  void _drawTile(
    Canvas canvas,
    Offset center,
    double tileSize,
    int value,
    Color bg,
    Color fg,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: tileSize,
        height: tileSize,
      ),
      Radius.circular(tileSize * 0.16),
    );
    canvas.drawRRect(
      rect.shift(const Offset(0, 4)),
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );
    canvas.drawRRect(rect, Paint()..color = bg);
    // Profundidade sutil no topo do bloco.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          rect.left + tileSize * 0.06,
          rect.top + tileSize * 0.06,
          tileSize * 0.88,
          tileSize * 0.22,
        ),
        Radius.circular(tileSize * 0.08),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
    final painter = TextPainter(
      text: TextSpan(
        text: '$value',
        style: TextStyle(
          color: fg,
          fontSize: tileSize * 0.38,
          fontWeight: FontWeight.w800,
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

  @override
  bool shouldRepaint(covariant _Game2048Art oldDelegate) => false;
}

class _InfiniteRunnerArt extends _CardArtPainter {
  _InfiniteRunnerArt(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    final extent = illustrationSize(size, factor: 1.0);
    final origin = illustrationOrigin(size, extent);
    final groundY = origin.dy + extent * 0.78;

    // Chão em duas camadas.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(origin.dx, groundY, extent, extent * 0.07),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF7BED9F).withValues(alpha: 0.7),
    );
    canvas.drawRect(
      Rect.fromLTWH(origin.dx, groundY + extent * 0.07, extent, extent * 0.12),
      Paint()..color = theme.cardColor.withValues(alpha: 0.32),
    );

    final bodyW = extent * 0.34;
    final runnerX = origin.dx + extent * 0.30;
    _drawRunner(canvas, Offset(runnerX, groundY + extent * 0.02), bodyW);

    // Poeira atrás do personagem.
    if (!compact) {
      final dust = Paint()..color = Colors.white.withValues(alpha: 0.35);
      for (var i = 0; i < 4; i++) {
        canvas.drawCircle(
          Offset(runnerX - bodyW * (0.9 + i * 0.22), groundY - bodyW * 0.08),
          bodyW * (0.06 + i * 0.01),
          dust,
        );
      }
    }

    if (!compact) {
      _drawObstacleBeam(
        canvas,
        Offset(origin.dx + extent * 0.62, groundY),
        bodyW * 0.5,
      );
      _drawCactus(
        canvas,
        Offset(origin.dx + extent * 0.82, groundY),
        bodyW * 0.62,
      );
    } else {
      _drawCactus(
        canvas,
        Offset(origin.dx + extent * 0.75, groundY),
        bodyW * 0.7,
      );
    }

    // Linhas de velocidade.
    final speedPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.42)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < (compact ? 2 : 4); i++) {
      final y = origin.dy + extent * (0.28 + i * 0.1);
      canvas.drawLine(
        Offset(origin.dx + extent * 0.02, y),
        Offset(origin.dx + extent * 0.22, y),
        speedPaint,
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
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );
    canvas.drawRRect(bodyRect, Paint()..color = theme.accentColor);

    final headCenter =
        Offset(feet.dx + bodyW * 0.08, bodyRect.top - headR * 0.75);
    canvas.drawCircle(headCenter, headR, Paint()..color = theme.accentSoft);

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

    final speedPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 2; i++) {
      final y = headCenter.dy + bodyW * 0.18 + i * bodyW * 0.2;
      canvas.drawLine(
        Offset(feet.dx - bodyW * 1.1, y),
        Offset(feet.dx - bodyW * 0.55, y),
        speedPaint,
      );
    }
  }

  void _drawCactus(Canvas canvas, Offset base, double w) {
    final h = w * 2.2;
    final green = Color.lerp(const Color(0xFF00B894), theme.cardColor, 0.25)!;
    final paint = Paint()..color = green;
    final trunk = RRect.fromRectAndRadius(
      Rect.fromLTWH(base.dx - w * 0.22, base.dy - h, w * 0.44, h),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(trunk, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx - w * 0.58, base.dy - h * 0.62, w * 0.38, w * 0.26),
        Radius.circular(w * 0.1),
      ),
      paint,
    );
  }

  void _drawObstacleBeam(Canvas canvas, Offset base, double w) {
    final h = w * 0.55;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(base.dx - w * 0.5, base.dy - h * 2.1, w, h),
      Radius.circular(w * 0.08),
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

  @override
  bool shouldRepaint(covariant _InfiniteRunnerArt oldDelegate) => false;
}

class _SolitaireArt extends _CardArtPainter {
  _SolitaireArt(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    final extent = illustrationSize(size, factor: 1.0);
    final cardW = extent * 0.42;
    final cardH = cardW * 1.32;
    final origin = illustrationOrigin(size, extent);
    final baseX = origin.dx + extent * 0.5;
    final baseY = origin.dy + extent * 0.56;

    final specs = compact
        ? [
            ('A', '♥', -0.22, -0.06, -0.14, theme.accentColor, true),
            ('K', '♠', 0.16, 0.08, 0.12, theme.blendColor, true),
          ]
        : [
            ('', '', -0.32, -0.08, -0.18, theme.cardColor, false),
            ('A', '♥', -0.08, 0.02, -0.06, theme.accentColor, true),
            ('K', '♠', 0.18, 0.10, 0.12, theme.blendColor, true),
            ('Q', '♦', 0.34, 0.20, 0.08, theme.accentSoft, true),
            ('', '', 0.42, 0.28, 0.06, theme.cardColor, false),
          ];

    for (final (rank, suit, dx, dy, angle, color, faceUp) in specs) {
      canvas.save();
      canvas.translate(baseX + dx * extent, baseY + dy * extent);
      canvas.rotate(angle);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: cardW, height: cardH),
        Radius.circular(cardW * 0.1),
      );
      if (faceUp) {
        drawCardFace(
          canvas,
          rect,
          const Color(0xFFF8F9FA),
          label: '$rank$suit',
          labelColor: color,
          labelSize: 0.32,
        );
      } else {
        drawCardFace(canvas, rect, theme.cardColor);
        // Padrão de carta virada.
        final dot = Paint()..color = Colors.white.withValues(alpha: 0.25);
        for (var row = 0; row < 3; row++) {
          for (var col = 0; col < 2; col++) {
            canvas.drawCircle(
              Offset(
                rect.left + cardW * (0.28 + col * 0.44),
                rect.top + cardH * (0.22 + row * 0.28),
              ),
              cardW * 0.05,
              dot,
            );
          }
        }
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SolitaireArt oldDelegate) => false;
}

class _SnakeArt extends _CardArtPainter {
  _SnakeArt(super.theme, {super.compact});

  static const _headGreen = Color(0xFF2ECC71);
  static const _bodyGreen = Color(0xFF27AE60);
  static const _tailGreen = Color(0xFF1E8449);
  static const _eyeColor = Color(0xFF2D3436);
  static const _leafGreen = Color(0xFF2ECC71);

  @override
  void paint(Canvas canvas, Size size) {
    final extent = illustrationSize(size, factor: 1.0);
    final origin = illustrationOrigin(size, extent);
    final left = origin.dx;
    final top = origin.dy;
    final w = extent;
    final h = extent;

    final foodCenter = Offset(left + w * 0.82, top + h * (compact ? 0.28 : 0.24));
    final foodR = w * (compact ? 0.075 : 0.082);

    if (!compact) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            theme.accentColor.withValues(alpha: 0.32),
            theme.accentColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: foodCenter, radius: foodR * 2.4));
      canvas.drawCircle(foodCenter, foodR * 2.4, glowPaint);
    }

    final segmentCount = compact ? 9 : 13;
    final points = List<Offset>.generate(segmentCount, (i) {
      final t = i / (segmentCount - 1);
      final px = left + w * (0.06 + t * 0.68);
      final wave = math.sin(t * math.pi * 1.75) * h * 0.17;
      final py = top + h * (0.62 + wave - t * 0.12);
      return Offset(px, py);
    });

    // Corpo — cauda → cabeça, segmentos sobrepostos.
    for (var i = points.length - 1; i >= 0; i--) {
      final t = i / (points.length - 1);
      final center = points[i];
      final radius = w * (0.048 + (1 - t) * 0.038);
      final color = Color.lerp(_tailGreen, _bodyGreen, t * 0.85)!;
      canvas.drawCircle(
        center + const Offset(0, 2),
        radius,
        Paint()..color = Colors.black.withValues(alpha: 0.1),
      );
      canvas.drawCircle(center, radius, Paint()..color = color);
    }

    // Cabeça em destaque.
    final head = points.first;
    final headR = w * 0.105;
    canvas.drawCircle(
      head + const Offset(0, 3),
      headR,
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );
    canvas.drawCircle(head, headR, Paint()..color = _headGreen);
    canvas.drawCircle(
      head + Offset(-headR * 0.08, -headR * 0.12),
      headR * 0.52,
      Paint()..color = _headGreen.withValues(alpha: 0.85),
    );

    // Olhos voltados para a fruta.
    final eyeOffset = Offset(headR * 0.22, -headR * 0.18);
    for (final dx in [-1.0, 1.0]) {
      final eyeCenter = head + Offset(eyeOffset.dx * dx, eyeOffset.dy);
      canvas.drawCircle(eyeCenter, headR * 0.22, Paint()..color = Colors.white);
      canvas.drawCircle(
        eyeCenter + Offset(headR * 0.06 * dx, headR * 0.02),
        headR * 0.11,
        Paint()..color = _eyeColor,
      );
      canvas.drawCircle(
        eyeCenter + Offset(headR * 0.1 * dx, -headR * 0.04),
        headR * 0.04,
        Paint()..color = Colors.white.withValues(alpha: 0.75),
      );
    }

    if (!compact) {
      final tongue = Path()
        ..moveTo(head.dx + headR * 0.82, head.dy + headR * 0.05)
        ..lineTo(head.dx + headR * 1.18, head.dy - headR * 0.08)
        ..lineTo(head.dx + headR * 1.05, head.dy + headR * 0.02)
        ..moveTo(head.dx + headR * 1.18, head.dy - headR * 0.08)
        ..lineTo(head.dx + headR * 1.05, head.dy + headR * 0.12);
      canvas.drawPath(
        tongue,
        Paint()
          ..color = const Color(0xFFFF7675)
          ..style = PaintingStyle.stroke
          ..strokeWidth = headR * 0.12
          ..strokeCap = StrokeCap.round,
      );
    }

    // Fruta alvo.
    canvas.drawCircle(
      foodCenter + const Offset(0, 2),
      foodR,
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawCircle(foodCenter, foodR, Paint()..color = theme.accentColor);
    canvas.drawOval(
      Rect.fromCenter(
        center: foodCenter + Offset(foodR * 0.12, -foodR * 0.92),
        width: foodR * 0.9,
        height: foodR * 0.48,
      ),
      Paint()..color = _leafGreen,
    );
    canvas.drawCircle(
      foodCenter + Offset(-foodR * 0.22, -foodR * 0.08),
      foodR * 0.14,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant _SnakeArt oldDelegate) => false;
}

class _SudokuArt extends _CardArtPainter {
  _SudokuArt(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    const gridCells = 4;
    final gridSize =
        math.min(size.width, size.height) * (compact ? 0.70 : 0.74);
    final origin = illustrationOrigin(size, gridSize);
    final left = origin.dx;
    final top = origin.dy;
    final cell = gridSize / gridCells;

    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, gridSize, gridSize),
      Radius.circular(gridSize * 0.06),
    );
    canvas.drawRRect(
      boardRect.shift(const Offset(0, 4)),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawRRect(boardRect, Paint()..color = const Color(0xFFF0EDFF));

    final digits = compact
        ? const [
            (0, 0, '5', 0),
            (0, 2, '7', 1),
            (1, 1, '1', 2),
            (2, 3, '9', 3),
          ]
        : const [
            (0, 0, '5', 0),
            (0, 1, '3', 1),
            (0, 3, '7', 2),
            (1, 0, '6', 3),
            (1, 2, '1', 0),
            (2, 1, '8', 1),
            (3, 2, '9', 2),
            (3, 3, '4', 3),
          ];
    final digitColors = [
      theme.cardColor,
      theme.accentColor,
      theme.blendColor,
      theme.accentSoft,
    ];

    for (var i = 0; i <= gridCells; i++) {
      final stroke = i == 0 || i == gridCells ? 2.5 : 1.2;
      final color =
          theme.cardColor.withValues(alpha: i == 0 || i == gridCells ? 0.85 : 0.3);
      final x = left + i * cell;
      canvas.drawLine(
        Offset(x, top),
        Offset(x, top + gridSize),
        Paint()..color = color..strokeWidth = stroke,
      );
      final y = top + i * cell;
      canvas.drawLine(
        Offset(left, y),
        Offset(left + gridSize, y),
        Paint()..color = color..strokeWidth = stroke,
      );
    }

    for (final (r, c, text, colorIdx) in digits) {
      final cx = left + (c + 0.5) * cell;
      final cy = top + (r + 0.5) * cell;
      final isHighlight = text == '9' || text == '5';
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: digitColors[colorIdx % digitColors.length],
            fontSize: cell * (isHighlight ? 0.62 : 0.52),
            fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w800,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(cx - painter.width / 2, cy - painter.height / 2),
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
    final gridSize =
        math.min(size.width, size.height) * (compact ? 0.68 : 0.70);
    final origin = illustrationOrigin(size, gridSize);
    final left = origin.dx;
    final top = origin.dy;
    const cols = 3;
    const rows = 2;
    final cellW = gridSize / (cols + 0.6);
    final cellH = gridSize / (rows + 0.4);
    final gap = cellW * 0.12;

    void drawBlock(Rect rect, String label, {bool highlight = false}) {
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(cellW * 0.14));
      canvas.drawRRect(
        rr.shift(const Offset(0, 3)),
        Paint()..color = Colors.black.withValues(alpha: 0.1),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..color = highlight
              ? theme.accentColor
              : Colors.white.withValues(alpha: 0.92),
      );
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: highlight ? Colors.white : theme.cardColor,
            fontSize: rect.height * 0.42,
            fontWeight: FontWeight.w900,
            height: 1,
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

    void drawOperator(Offset center, String op) {
      final painter = TextPainter(
        text: TextSpan(
          text: op,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: cellH * 0.38,
            fontWeight: FontWeight.w800,
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

    final blocks = compact
        ? ['8', '5', '13']
        : ['9', '4', '7', '3', '2', '5'];
    final positions = compact
        ? [
            Rect.fromLTWH(left, top + cellH * 0.2, cellW, cellH),
            Rect.fromLTWH(left + cellW + gap, top + cellH * 0.2, cellW, cellH),
            Rect.fromLTWH(
              left + (cellW + gap) * 2,
              top + cellH * 0.2,
              cellW * 1.1,
              cellH,
            ),
          ]
        : [
            Rect.fromLTWH(left, top, cellW, cellH),
            Rect.fromLTWH(left + cellW + gap, top, cellW, cellH),
            Rect.fromLTWH(left + (cellW + gap) * 2, top, cellW, cellH),
            Rect.fromLTWH(left, top + cellH + gap, cellW, cellH),
            Rect.fromLTWH(left + cellW + gap, top + cellH + gap, cellW, cellH),
            Rect.fromLTWH(
              left + (cellW + gap) * 2,
              top + cellH + gap,
              cellW * 1.1,
              cellH,
            ),
          ];

    for (var i = 0; i < blocks.length; i++) {
      drawBlock(
        positions[i],
        blocks[i],
        highlight: i == blocks.length - 1,
      );
    }

    if (!compact) {
      drawOperator(
        Offset(left + cellW + gap * 0.5, top + cellH * 0.5),
        '+',
      );
      drawOperator(
        Offset(left + (cellW + gap) * 1.5 + gap * 0.5, top + cellH * 0.5),
        '−',
      );
      drawOperator(
        Offset(left + cellW * 0.5, top + cellH + gap * 0.5),
        '=',
      );
      // Conexões discretas entre blocos.
      final linkPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(left + cellW + gap * 0.15, top + cellH * 0.5),
        Offset(left + cellW + gap * 0.85, top + cellH * 0.5),
        linkPaint,
      );
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
    final extent = illustrationSize(size);
    final origin = illustrationOrigin(size, extent);
    const gridCells = 4;
    final gap = extent * 0.018;
    final cell = (extent - gap * (gridCells - 1)) / gridCells;
    final gridLeft = origin.dx;
    final gridTop = origin.dy;

    final board = const [
      [0, 1, 2, 3],
      [4, null, 2, null],
      [null, 0, 1, null],
      [3, null, null, 5],
    ];

    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        gridLeft - gap,
        gridTop - gap,
        extent + gap * 2,
        extent + gap * 2,
      ),
      Radius.circular(cell * 0.14),
    );
    canvas.drawRRect(
      boardRect,
      Paint()..color = Color.lerp(theme.cardColor, Colors.black, 0.18)!,
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
  }

  void _drawEmptyCell(Canvas canvas, double x, double y, double cell) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, cell, cell),
      Radius.circular(cell * 0.12),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = theme.blendColor.withValues(alpha: 0.38),
    );
  }

  void _drawBlock(Canvas canvas, double x, double y, double cell, Color color) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, cell, cell),
      Radius.circular(cell * 0.12),
    );
    canvas.drawRRect(
      rect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawRRect(rect, Paint()..color = color);
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
    final extent = illustrationSize(size);
    final origin = illustrationOrigin(size, extent);
    final gridCells = compact ? 4 : 5;
    final cell = extent / gridCells;
    final gap = cell * 0.06;
    final tile = cell - gap;
    final gridLeft = origin.dx;
    final gridTop = origin.dy;

    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(gridLeft, gridTop, extent, extent),
      Radius.circular(cell * 0.12),
    );
    canvas.drawRRect(
      boardRect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );
    canvas.drawRRect(
      boardRect,
      Paint()..color = Color.lerp(theme.cardColor, Colors.black, 0.15)!,
    );

    final pattern = compact ? _compactPattern : _fullPattern;
    for (var r = 0; r < gridCells; r++) {
      for (var c = 0; c < gridCells; c++) {
        final rect = Rect.fromLTWH(
          gridLeft + c * cell + gap * 0.5,
          gridTop + r * cell + gap * 0.5,
          tile,
          tile,
        );
        _paintCell(canvas, rect, pattern[r][c], tile);
      }
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
        _drawMine(canvas, rect.center, rect.width * 0.28);
      case 'm':
        _drawHiddenCell(canvas, rect, raised: true);
        _drawMine(canvas, rect.center, rect.width * 0.2);
      case '.':
        _drawHiddenCell(canvas, rect, raised: true);
      case 'h':
        _drawHiddenCell(canvas, rect, raised: false);
      case '0':
        _drawRevealedCell(canvas, rect);
      default:
        if (code.length == 1 &&
            code.codeUnitAt(0) >= 49 &&
            code.codeUnitAt(0) <= 57) {
          final digit = int.parse(code);
          _drawRevealedCell(canvas, rect);
          _drawDigit(
            canvas,
            rect.center,
            code,
            rect.width * 0.48,
            _numColors[(digit - 1).clamp(0, _numColors.length - 1)],
          );
        }
    }
  }

  void _drawHiddenCell(Canvas canvas, Rect rect, {required bool raised}) {
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.width * 0.14),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..color = raised
            ? const Color(0xFFD5DBDB)
            : theme.blendColor.withValues(alpha: 0.75),
    );
  }

  void _drawRevealedCell(Canvas canvas, Rect rect, {Color? fill}) {
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.width * 0.1),
    );
    canvas.drawRRect(rr, Paint()..color = fill ?? _revealedFill);
  }

  void _drawFlag(Canvas canvas, Rect rect, double cell, {bool dimmed = false}) {
    final poleX = rect.center.dx - cell * 0.1;
    final baseY = rect.center.dy + cell * 0.18;
    final topY = rect.center.dy - cell * 0.2;
    final poleColor = dimmed
        ? theme.cardColor.withValues(alpha: 0.6)
        : theme.cardColor;
    canvas.drawLine(
      Offset(poleX, baseY),
      Offset(poleX, topY),
      Paint()
        ..color = poleColor
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    final flag = Path()
      ..moveTo(poleX, topY)
      ..lineTo(poleX + cell * 0.24, topY + cell * 0.07)
      ..lineTo(poleX, topY + cell * 0.14)
      ..close();
    canvas.drawPath(
      flag,
      Paint()..color = dimmed ? theme.accentColor.withValues(alpha: 0.5) : theme.accentColor,
    );
  }

  void _drawMine(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF2C3E50));
    canvas.drawCircle(
      center,
      radius * 0.3,
      Paint()..color = const Color(0xFF636E72),
    );
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        center,
        Offset(
          center.dx + math.cos(angle) * radius * 1.4,
          center.dy + math.sin(angle) * radius * 1.4,
        ),
        Paint()
          ..color = const Color(0xFF2C3E50)
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }
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

  @override
  bool shouldRepaint(covariant _MinesweeperArt oldDelegate) => false;
}

class _GenericArt extends _CardArtPainter {
  _GenericArt(super.theme, this.gameId, {super.compact});

  final String gameId;

  @override
  void paint(Canvas canvas, Size size) {
    final extent = illustrationSize(size);
    final origin = illustrationOrigin(size, extent);
    final cx = origin.dx + extent / 2;
    final cy = origin.dy + extent / 2;
    final r = extent * 0.36;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = theme.accentColor.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.55,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _GenericArt oldDelegate) => false;
}

/// Padrão de fundo exclusivo por jogo — baixa opacidade, não compete com a arte.
class _GameCardBackdropPainter extends CustomPainter {
  _GameCardBackdropPainter(this.gameId, this.theme);

  final String gameId;
  final HubGameTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    switch (gameId) {
      case 'memory':
        _drawRoundedRects(canvas, size, paint, 0.08);
        _drawSparkles(canvas, size, 0.07);
      case 'tap_rush':
        _drawCircles(canvas, size, paint, 0.07);
        _drawRippleRings(canvas, size, 0.06);
      case 'game_2048':
        _drawSquareGrid(canvas, size, paint, 0.08);
      case 'snake':
        _drawWaves(canvas, size, paint, 0.08);
        _drawLeaves(canvas, size, 0.07);
      case 'infinite_runner':
        _drawSpeedLines(canvas, size, paint, 0.09);
      case 'sudoku':
        _drawFineGrid(canvas, size, paint, 0.07);
      case 'cross_sums':
        _drawFineGrid(canvas, size, paint, 0.06);
        _drawOperators(canvas, size, 0.08);
      case 'minesweeper':
        _drawFineGrid(canvas, size, paint, 0.07);
      case 'color_blocks':
        _drawSquareGrid(canvas, size, paint, 0.07);
      case 'solitaire':
        _drawDiamonds(canvas, size, paint, 0.08);
      default:
        _drawCircles(canvas, size, paint, 0.05);
    }
  }

  void _drawSparkles(Canvas canvas, Size size, double alpha) {
    final paint = Paint()..color = Colors.white.withValues(alpha: alpha);
    for (final (fx, fy) in [(0.15, 0.35), (0.85, 0.28), (0.72, 0.72)]) {
      final c = Offset(size.width * fx, size.height * fy);
      canvas.drawCircle(c, size.width * 0.012, paint);
      canvas.drawCircle(
        c + Offset(size.width * 0.02, -size.width * 0.015),
        size.width * 0.008,
        paint,
      );
    }
  }

  void _drawRippleRings(Canvas canvas, Size size, double alpha) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final cx = size.width * 0.5;
    final cy = size.height * 0.62;
    for (var i = 1; i <= 2; i++) {
      canvas.drawCircle(
        Offset(cx, cy),
        size.width * (0.12 + i * 0.08),
        paint,
      );
    }
  }

  void _drawLeaves(Canvas canvas, Size size, double alpha) {
    final paint = Paint()..color = Colors.white.withValues(alpha: alpha);
    for (final (fx, fy, angle) in [
      (0.12, 0.42, -0.5),
      (0.88, 0.55, 0.4),
      (0.22, 0.78, 0.2),
    ]) {
      canvas.save();
      canvas.translate(size.width * fx, size.height * fy);
      canvas.rotate(angle);
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(6, -4, 12, 0)
        ..quadraticBezierTo(6, 4, 0, 0);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  void _drawOperators(Canvas canvas, Size size, double alpha) {
    final specs = ['+', '−', '+'];
    for (var i = 0; i < specs.length; i++) {
      final painter = TextPainter(
        text: TextSpan(
          text: specs[i],
          style: TextStyle(
            color: Colors.white.withValues(alpha: alpha),
            fontSize: size.width * 0.07,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(
          size.width * (0.2 + i * 0.28) - painter.width / 2,
          size.height * 0.82 - painter.height / 2,
        ),
      );
    }
  }

  void _drawRoundedRects(Canvas canvas, Size size, Paint paint, double alpha) {
    paint.color = Colors.white.withValues(alpha: alpha);
    final specs = [
      (0.12, 0.62, 0.38, 0.22, 0.15),
      (0.72, 0.68, 0.28, 0.18, -0.2),
      (0.48, 0.78, 0.32, 0.2, 0.1),
    ];
    for (final (fx, fy, fw, fh, angle) in specs) {
      canvas.save();
      canvas.translate(size.width * fx, size.height * fy);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: size.width * fw,
            height: size.height * fh,
          ),
          Radius.circular(12),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  void _drawCircles(Canvas canvas, Size size, Paint paint, double alpha) {
    paint.color = Colors.white.withValues(alpha: alpha);
    final specs = [
      (0.82, 0.72, 0.34),
      (0.18, 0.78, 0.22),
      (0.55, 0.55, 0.16),
    ];
    for (final (fx, fy, fr) in specs) {
      canvas.drawCircle(
        Offset(size.width * fx, size.height * fy),
        size.width * fr,
        paint,
      );
    }
  }

  void _drawSquareGrid(Canvas canvas, Size size, Paint paint, double alpha) {
    paint.color = Colors.white.withValues(alpha: alpha);
    final step = size.width * 0.14;
    for (var x = step * 0.5; x < size.width; x += step) {
      for (var y = step * 0.5; y < size.height; y += step) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(x, y),
              width: step * 0.55,
              height: step * 0.55,
            ),
            const Radius.circular(3),
          ),
          paint,
        );
      }
    }
  }

  void _drawFineGrid(Canvas canvas, Size size, Paint paint, double alpha) {
    paint
      ..color = Colors.white.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final step = size.width / 8;
    for (var i = 0; i <= 8; i++) {
      final p = i * step;
      canvas.drawLine(Offset(p, 0), Offset(p, size.height), paint);
      canvas.drawLine(Offset(0, p), Offset(size.width, p), paint);
    }
  }

  void _drawWaves(Canvas canvas, Size size, Paint paint, double alpha) {
    paint
      ..color = Colors.white.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final path = Path();
      final baseY = size.height * (0.55 + i * 0.12);
      path.moveTo(0, baseY);
      for (var x = 0.0; x <= size.width; x += size.width / 6) {
        path.quadraticBezierTo(
          x + size.width / 12,
          baseY + (i.isEven ? 10 : -10),
          x + size.width / 6,
          baseY,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawSpeedLines(Canvas canvas, Size size, Paint paint, double alpha) {
    paint
      ..color = Colors.white.withValues(alpha: alpha)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.35 + i * 0.1);
      canvas.drawLine(
        Offset(size.width * 0.05, y),
        Offset(size.width * 0.95, y),
        paint,
      );
    }
  }

  void _drawDiamonds(Canvas canvas, Size size, Paint paint, double alpha) {
    paint.color = Colors.white.withValues(alpha: alpha);
    for (final (fx, fy) in [(0.2, 0.7), (0.75, 0.65), (0.5, 0.82)]) {
      final c = Offset(size.width * fx, size.height * fy);
      final r = size.width * 0.08;
      final path = Path()
        ..moveTo(c.dx, c.dy - r)
        ..lineTo(c.dx + r, c.dy)
        ..lineTo(c.dx, c.dy + r)
        ..lineTo(c.dx - r, c.dy)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GameCardBackdropPainter oldDelegate) =>
      oldDelegate.gameId != gameId;
}

/// Plano 4 — brilhos discretos sobre a ilustração (luz superior esquerda).
class _CardHighlightPainter extends CustomPainter {
  _CardHighlightPainter(this.gameId, this.theme);

  final String gameId;
  final HubGameTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Brilho diagonal suave — canto superior esquerdo.
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: const Alignment(0.4, 0.5),
      colors: [
        Colors.white.withValues(alpha: 0.10),
        Colors.white.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.55));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.55), paint);

    // Pontos de luz por jogo — opacidade máx. 10%.
    switch (gameId) {
      case 'memory':
        _drawSpark(canvas, size, 0.72, 0.38, 0.018, 0.08);
        _drawSpark(canvas, size, 0.28, 0.62, 0.014, 0.07);
      case 'tap_rush':
        _drawSpark(canvas, size, 0.5, 0.55, 0.022, 0.09);
      case 'infinite_runner':
        _drawSpark(canvas, size, 0.35, 0.48, 0.016, 0.08);
      case 'snake':
        _drawSpark(canvas, size, 0.62, 0.42, 0.015, 0.07);
      case 'game_2048':
        _drawSpark(canvas, size, 0.55, 0.35, 0.012, 0.06);
      default:
        _drawSpark(canvas, size, 0.65, 0.4, 0.012, 0.06);
    }
  }

  void _drawSpark(
    Canvas canvas,
    Size size,
    double fx,
    double fy,
    double radiusFactor,
    double alpha,
  ) {
    canvas.drawCircle(
      Offset(size.width * fx, size.height * fy),
      size.width * radiusFactor,
      Paint()..color = Colors.white.withValues(alpha: alpha),
    );
  }

  @override
  bool shouldRepaint(covariant _CardHighlightPainter oldDelegate) =>
      oldDelegate.gameId != gameId;
}

/// Banner do jogo — layout minimalista com foco na ilustração.
class GameCatalogHero extends StatelessWidget {
  const GameCatalogHero({
    super.key,
    required this.gameId,
    required this.title,
    required this.theme,
    this.height,
    this.showTitleOverlay = true,
    this.showFeaturedBadge = false,
    this.progress,
    this.bottomOverlay,
  });

  final String gameId;
  final String title;
  final HubGameTheme theme;
  /// Altura fixa; `null` preenche o pai (ex.: grid do catálogo).
  final double? height;
  final bool showTitleOverlay;
  final bool showFeaturedBadge;
  final double? progress;
  /// Widget sobreposto no canto inferior direito (ex.: favorito).
  final Widget? bottomOverlay;

  @override
  Widget build(BuildContext context) {
    final displayTitle = hubDisplayTitle(title);
    final gradientEnd = Color.lerp(theme.cardColor, theme.accentColor, 0.18)!;
    final gradientMid = Color.lerp(theme.cardColor, Colors.white, 0.08)!;

    final card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(HubTheme.cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            gradientMid,
            gradientEnd,
          ],
          stops: const [0, 0.45, 1],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(HubTheme.cardRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Plano 1–2: fundo + decoração por jogo.
            CustomPaint(
              painter: _GameCardBackdropPainter(gameId, theme),
              size: Size.infinite,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showTitleOverlay)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      HubTheme.cardPadding,
                      HubTheme.cardPadding,
                      HubTheme.cardPadding,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: 0.3,
                              shadows: HubTheme.cardTitleShadow(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GameCardProgressBar(
                          progress: progress,
                          trackColor: Colors.white.withValues(alpha: 0.22),
                          fillColor: theme.accentColor.withValues(alpha: 0.95),
                        ),
                        if (showFeaturedBadge) ...[
                          const SizedBox(height: 8),
                          GameBadge.featured(
                            label: L10nScope.of.featuredBadgeNew,
                            backgroundColor: HubTheme.featuredBadge,
                          ),
                        ],
                      ],
                    ),
                  ),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Plano 3: ilustração protagonista.
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          4,
                          showTitleOverlay ? 2 : 6,
                          4,
                          HubTheme.cardPadding * 0.3,
                        ),
                        child: GameCardArt(gameId: gameId, theme: theme),
                      ),
                      // Plano 4: brilhos discretos sobre a arte.
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _CardHighlightPainter(gameId, theme),
                          size: Size.infinite,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (bottomOverlay != null)
              Positioned(
                bottom: HubTheme.cardPadding - 4,
                right: HubTheme.cardPadding - 4,
                child: bottomOverlay!,
              ),
          ],
        ),
      ),
    );

    if (height != null) {
      return SizedBox(height: height, child: card);
    }
    return card;
  }
}
