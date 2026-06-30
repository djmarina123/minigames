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

  /// Escala padrão da ilustração (~88% da área útil).
  double illustrationSize(Size size, {double factor = 0.88}) =>
      math.min(size.width, size.height) *
      (compact ? factor - 0.10 : factor);

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
    final extent = illustrationSize(size);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = extent * 0.42;

    final rings = [
      (r * 1.18, Colors.white.withValues(alpha: 0.08)),
      (r * 1.05, Colors.white.withValues(alpha: 0.18)),
      (r * 0.86, theme.cardColor),
      (r * 0.64, theme.accentColor),
      (r * 0.40, theme.accentSoft),
      (r * 0.18, Colors.white),
    ];
    for (final (radius, color) in rings) {
      canvas.drawCircle(Offset(cx, cy), radius, Paint()..color = color);
    }

    canvas.save();
    canvas.translate(cx + r * 0.1, cy + r * 0.06);
    canvas.rotate(-0.32);
    final fingerW = r * 0.58;
    final fingerH = r * 0.98;
    final fingerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(fingerW * 0.12, -fingerH * 0.12),
        width: fingerW,
        height: fingerH,
      ),
      Radius.circular(fingerW * 0.45),
    );
    canvas.drawRRect(fingerRect, Paint()..color = Colors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TapRushArt oldDelegate) => false;
}

class _MemoryArt extends _CardArtPainter {
  _MemoryArt(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    final extent = illustrationSize(size, factor: 0.92);
    final cardW = extent * 0.52;
    final cardH = cardW * 1.28;
    final origin = illustrationOrigin(size, extent);
    final baseX = origin.dx + extent * 0.5;
    final baseY = origin.dy + extent * 0.54;

    final cards = compact
        ? [
            (0.0, -0.26, -0.22, theme.cardColor, '?'),
            (0.20, 0.14, 0.16, theme.accentColor, '★'),
          ]
        : [
            (0.0, -0.32, -0.24, theme.cardColor, '?'),
            (0.16, 0.06, 0.12, theme.accentColor, '★'),
            (0.32, 0.24, 0.18, theme.blendColor, '♦'),
            (0.08, 0.28, -0.08, theme.accentSoft, '♣'),
          ];

    for (final (_, dx, dy, color, label) in cards) {
      canvas.save();
      canvas.translate(baseX + dx * extent, baseY + dy * extent);
      canvas.rotate(dy * 0.6);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: cardW, height: cardH),
        Radius.circular(cardW * 0.1),
      );
      drawCardFace(canvas, rect, color, label: label);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _MemoryArt oldDelegate) => false;
}

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
    final gridSize = math.min(size.width, size.height) * (compact ? 0.82 : 0.94);
    final gap = gridSize * 0.055;
    final tileSize = (gridSize - gap * (gridExtent - 1)) / gridExtent;
    final originX = (size.width - gridSize) / 2;
    final originY = (size.height - gridSize) / 2;

    if (!compact) {
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
      Radius.circular(tileSize * 0.12),
    );
    canvas.drawRRect(
      rect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawRRect(rect, Paint()..color = bg);
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
    final extent = illustrationSize(size);
    final origin = illustrationOrigin(size, extent);
    final groundY = origin.dy + extent * 0.82;

    canvas.drawRect(
      Rect.fromLTWH(origin.dx, groundY, extent, extent * 0.06),
      Paint()..color = const Color(0xFF7BED9F).withValues(alpha: 0.65),
    );
    canvas.drawRect(
      Rect.fromLTWH(origin.dx, groundY + extent * 0.06, extent, extent * 0.14),
      Paint()..color = theme.cardColor.withValues(alpha: 0.35),
    );

    final bodyW = extent * 0.22;
    _drawRunner(canvas, Offset(origin.dx + extent * 0.38, groundY), bodyW);

    if (!compact) {
      _drawObstacleBeam(
        canvas,
        Offset(origin.dx + extent * 0.68, groundY),
        bodyW * 0.55,
      );
      _drawCactus(
        canvas,
        Offset(origin.dx + extent * 0.86, groundY),
        bodyW * 0.65,
      );
    } else {
      _drawCactus(
        canvas,
        Offset(origin.dx + extent * 0.78, groundY),
        bodyW * 0.75,
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
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = headCenter.dy + i * bodyW * 0.22;
      canvas.drawLine(
        Offset(feet.dx - bodyW * 1.15, y),
        Offset(feet.dx - bodyW * 0.6, y),
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
    final extent = illustrationSize(size, factor: 0.92);
    final cardW = extent * 0.38;
    final cardH = cardW * 1.35;
    final origin = illustrationOrigin(size, extent);
    final baseX = origin.dx + extent * 0.5;
    final baseY = origin.dy + extent * 0.55;

    final specs = compact
        ? [
            ('A', '♥', -0.24, -0.08, -0.14, theme.accentColor),
            ('K', '♠', 0.18, 0.10, 0.12, theme.blendColor),
          ]
        : [
            ('A', '♥', -0.30, -0.10, -0.16, theme.accentColor),
            ('Q', '♦', 0.0, 0.0, 0.06, theme.accentSoft),
            ('K', '♠', 0.28, 0.14, 0.14, theme.blendColor),
          ];

    for (final (rank, suit, dx, dy, angle, color) in specs) {
      canvas.save();
      canvas.translate(baseX + dx * extent, baseY + dy * extent);
      canvas.rotate(angle);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: cardW, height: cardH),
        Radius.circular(cardW * 0.1),
      );
      drawCardFace(
        canvas,
        rect,
        const Color(0xFFF8F9FA),
        label: '$rank$suit',
        labelColor: color,
        labelSize: 0.34,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SolitaireArt oldDelegate) => false;
}

class _SnakeArt extends _CardArtPainter {
  _SnakeArt(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    final extent = illustrationSize(size, factor: 0.95);
    final cell = extent / (compact ? 3.8 : 4.2);
    final origin = illustrationOrigin(size, extent);
    final startX = origin.dx + cell * 0.35;
    final startY = origin.dy + cell * 0.55;

    final segments = compact
        ? const [(0, 0), (1, 0), (2, 0), (2, 1), (2, 2), (1, 2)]
        : const [(0, 0), (1, 0), (2, 0), (3, 0), (3, 1), (3, 2), (2, 2), (1, 2)];

    for (var i = segments.length - 1; i >= 0; i--) {
      final (dx, dy) = segments[i];
      final rect = Rect.fromLTWH(
        startX + dx * cell * 0.94,
        startY + dy * cell * 0.94,
        cell * 0.9,
        cell * 0.9,
      );
      final isHead = i == 0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.26)),
        Paint()..color = isHead ? theme.accentColor : theme.blendColor,
      );
      if (isHead) {
        canvas.drawCircle(
          rect.center + Offset(cell * 0.14, -cell * 0.08),
          cell * 0.11,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          rect.center + Offset(cell * 0.2, -cell * 0.05),
          cell * 0.05,
          Paint()..color = const Color(0xFF2D3436),
        );
      }
    }

    final foodCenter = Offset(
      startX + (compact ? 3.8 : 4.5) * cell * 0.94,
      startY + (compact ? 0.4 : 0.3) * cell * 0.94,
    );
    final foodR = cell * 0.36;
    canvas.drawCircle(foodCenter, foodR, Paint()..color = theme.accentColor);
    canvas.drawOval(
      Rect.fromCenter(
        center: foodCenter + Offset(foodR * 0.1, -foodR * 0.85),
        width: foodR * 0.85,
        height: foodR * 0.45,
      ),
      Paint()..color = theme.accentSoft,
    );
  }

  @override
  bool shouldRepaint(covariant _SnakeArt oldDelegate) => false;
}

class _SudokuArt extends _CardArtPainter {
  _SudokuArt(super.theme, {super.compact});

  @override
  void paint(Canvas canvas, Size size) {
    final gridSize = illustrationSize(size);
    final origin = illustrationOrigin(size, gridSize);
    final left = origin.dx;
    final top = origin.dy;
    final cell = gridSize / 3;

    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, gridSize, gridSize),
      Radius.circular(gridSize * 0.05),
    );
    canvas.drawRRect(
      boardRect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawRRect(boardRect, Paint()..color = const Color(0xFFF0EDFF));

    final digits = const [
      (0, 0, '5', 0),
      (0, 1, '3', 1),
      (0, 2, '7', 2),
      (1, 0, '6', 3),
      (1, 1, '1', 0),
      (2, 2, '9', 1),
    ];
    final digitColors = [
      theme.cardColor,
      theme.accentColor,
      theme.blendColor,
      theme.accentSoft,
    ];

    for (var i = 0; i <= 3; i++) {
      final stroke = i == 0 || i == 3 ? 2.5 : 1.2;
      final color = theme.cardColor.withValues(alpha: i == 1 || i == 2 ? 0.35 : 0.85);
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
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: digitColors[colorIdx % digitColors.length],
            fontSize: cell * 0.55,
            fontWeight: FontWeight.w800,
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
    final gridSize = illustrationSize(size);
    final origin = illustrationOrigin(size, gridSize);
    final left = origin.dx;
    final top = origin.dy;
    const extent = 4;
    final cell = gridSize / extent;

    const headers = ['9', '4', '7'];
    const rowTargets = ['14', '2', '5'];
    const cells = [
      ['8', '5', '6'],
      ['7', '1', '4'],
      ['1', '4', '1'],
    ];

    for (var br = 0; br < extent; br++) {
      for (var bc = 0; bc < extent; bc++) {
        final rect = Rect.fromLTWH(left + bc * cell, top + br * cell, cell, cell);
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
          RRect.fromRectAndRadius(rect.deflate(1), Radius.circular(cell * 0.08)),
          Paint()..color = bg,
        );

        if (label != null) {
          final isHeader = br == 0 || bc == 0;
          final painter = TextPainter(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: isHeader ? const Color(0xFF2D3436) : theme.cardColor,
                fontSize: cell * (isHeader ? 0.44 : 0.54),
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
        _drawRoundedRects(canvas, size, paint, 0.07);
      case 'tap_rush':
        _drawCircles(canvas, size, paint, 0.06);
      case 'game_2048':
        _drawSquareGrid(canvas, size, paint, 0.06);
      case 'snake':
        _drawWaves(canvas, size, paint, 0.07);
      case 'infinite_runner':
        _drawSpeedLines(canvas, size, paint, 0.08);
      case 'sudoku':
      case 'cross_sums':
      case 'minesweeper':
        _drawFineGrid(canvas, size, paint, 0.06);
      case 'color_blocks':
        _drawSquareGrid(canvas, size, paint, 0.05);
      case 'solitaire':
        _drawDiamonds(canvas, size, paint, 0.06);
      default:
        _drawCircles(canvas, size, paint, 0.04);
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

/// Banner do jogo — layout minimalista com foco na ilustração.
class GameCatalogHero extends StatelessWidget {
  const GameCatalogHero({
    super.key,
    required this.gameId,
    required this.title,
    required this.theme,
    this.height = 200,
    this.showTitleOverlay = true,
    this.showFeaturedBadge = false,
    this.progress,
  });

  final String gameId;
  final String title;
  final HubGameTheme theme;
  final double height;
  final bool showTitleOverlay;
  final bool showFeaturedBadge;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final displayTitle = hubDisplayTitle(title);
    final gradientEnd = Color.lerp(theme.cardColor, theme.accentColor, 0.18)!;
    final gradientMid = Color.lerp(theme.cardColor, Colors.white, 0.08)!;

    return SizedBox(
      height: height,
      child: DecoratedBox(
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
                        HubTheme.cardPadding + 30,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: 0.3,
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
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        6,
                        showTitleOverlay ? 4 : 8,
                        6,
                        HubTheme.cardPadding * 0.35,
                      ),
                      child: GameCardArt(gameId: gameId, theme: theme),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
