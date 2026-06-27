import 'package:flutter/material.dart';

/// Paleta do HUD in-game — espelhar `hudText` / `hudMuted` / `accent` do config do jogo.
class GameSessionHudPalette {
  const GameSessionHudPalette({
    required this.text,
    required this.muted,
    required this.accent,
    this.panel = const Color(0x55FFFFFF),
  });

  final Color text;
  final Color muted;
  final Color accent;
  final Color panel;
}

/// Uma coluna: legenda pequena → valor grande → nota opcional.
class GameSessionHudStat {
  const GameSessionHudStat({
    required this.caption,
    required this.value,
    this.footnote,
    this.captionColor,
    this.valueColor,
    this.footnoteColor,
  });

  final String caption;
  final String value;
  final String? footnote;
  final Color? captionColor;
  final Color? valueColor;
  final Color? footnoteColor;
}

enum GameSessionHudProgressPosition { top, bottom }

/// Barra de progresso fina no painel.
class GameSessionHudProgress {
  const GameSessionHudProgress({
    required this.ratio,
    required this.color,
    this.lowColor,
    this.lowThreshold = 0.25,
    this.position = GameSessionHudProgressPosition.bottom,
  });

  final double ratio;
  final Color color;
  final Color? lowColor;
  final double lowThreshold;
  final GameSessionHudProgressPosition position;
}

enum GameSessionHudAlign { left, center, right }

/// Barra de informações in-game compartilhada entre jogos Flame.
///
/// Reserva [reservedHeight] px abaixo da [GameSessionAppBar] antes do tabuleiro.
abstract final class GameSessionHud {
  static const reservedHeight = 56.0;
  static const margin = 16.0;
  static const panelRadius = 14.0;
  static const panelTop = 8.0;
  static const panelHeight = 52.0;
  static const panelHeightWithBar = 64.0;

  static const _captionSize = 9.0;
  static const _valueSize = 18.0;
  static const _valueSizeCompact = 15.0;
  static const _footnoteSize = 10.0;
  static const _captionRowY = 11.0;
  static const _valueRowY = 27.0;
  static const _footnoteRowY = 43.0;

  /// Retângulo do painel arredondado.
  static RRect panelRect(
    Size canvasSize, {
    double top = panelTop,
    bool withProgressBar = false,
  }) {
    final h = withProgressBar ? panelHeightWithBar : panelHeight;
    return RRect.fromRectAndRadius(
      Rect.fromLTWH(margin, top, canvasSize.width - margin * 2, h),
      const Radius.circular(panelRadius),
    );
  }

  static void paintPanel(
    Canvas canvas,
    Size canvasSize,
    GameSessionHudPalette palette, {
    double top = panelTop,
    bool withProgressBar = false,
  }) {
    final rect = panelRect(
      canvasSize,
      top: top,
      withProgressBar: withProgressBar,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.outerRect.shift(const Offset(0, 1.5)),
        const Radius.circular(panelRadius),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );
    canvas.drawRRect(rect, Paint()..color = palette.panel);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  static void paintColumnSeparators(
    Canvas canvas,
    Size canvasSize, {
    required int columnCount,
    double top = panelTop,
    bool withProgressBar = false,
  }) {
    if (columnCount < 2) return;

    final panel = panelRect(
      canvasSize,
      top: top,
      withProgressBar: withProgressBar,
    );
    final colW = panel.width / columnCount;
    final lineTop = panel.top + 8;
    // Para antes das notas de rodapé — evita linha cortando "+tempo" / "jogadas".
    final lineBottom = panel.top + _valueRowY + 8;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..strokeWidth = 1;

    for (var i = 1; i < columnCount; i++) {
      final x = panel.left + colW * i;
      canvas.drawLine(Offset(x, lineTop), Offset(x, lineBottom), paint);
    }
  }

  /// Layout padrão: painel + até 3 colunas (legenda/valor/nota) + barra opcional.
  static void paintStatsBar(
    Canvas canvas,
    Size canvasSize,
    GameSessionHudPalette palette, {
    required List<GameSessionHudStat> columns,
    GameSessionHudProgress? progress,
    double top = panelTop,
  }) {
    if (columns.isEmpty) return;

    final withBar = progress != null;
    paintPanel(
      canvas,
      canvasSize,
      palette,
      top: top,
      withProgressBar: withBar,
    );

    final colCount = columns.length.clamp(1, 3);
    paintColumnSeparators(
      canvas,
      canvasSize,
      columnCount: colCount,
      top: top,
      withProgressBar: withBar,
    );

    final panel = panelRect(
      canvasSize,
      top: top,
      withProgressBar: withBar,
    );
    final colW = panel.width / colCount;

    final rowShift = progress?.position == GameSessionHudProgressPosition.top
        ? 7.0
        : 0.0;

    if (progress != null) {
      final barH = 3.0;
      final barPad = 6.0;
      final barW = panel.width - barPad * 2;
      final barTop = progress.position == GameSessionHudProgressPosition.top
          ? panel.top + 6
          : panel.bottom - barPad - barH;
      paintProgressBar(
        canvas,
        Rect.fromLTWH(panel.left + barPad, barTop, barW, barH),
        progress,
      );
    }

    for (var i = 0; i < colCount; i++) {
      final stat = columns[i];
      final align = _alignForColumn(i, colCount);
      final anchorX = switch (align) {
        GameSessionHudAlign.left => panel.left + 8,
        GameSessionHudAlign.center => panel.left + colW * i + colW / 2,
        GameSessionHudAlign.right => panel.right - 8,
      };
      final maxWidth = colW - 14;

      paintText(
        canvas,
        stat.caption.toUpperCase(),
        Offset(anchorX, top + _captionRowY + rowShift),
        _captionSize,
        stat.captionColor ?? palette.muted.withValues(alpha: 0.95),
        align: align,
        maxWidth: maxWidth,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );

      final valueSize =
          stat.value.length >= 5 ? _valueSizeCompact : _valueSize;
      paintText(
        canvas,
        stat.value,
        Offset(anchorX, top + _valueRowY + rowShift),
        valueSize,
        stat.valueColor ?? palette.text,
        align: align,
        maxWidth: maxWidth,
        fontWeight: FontWeight.w800,
      );

      if (stat.footnote != null) {
        paintText(
          canvas,
          stat.footnote!,
          Offset(anchorX, top + _footnoteRowY + rowShift),
          _footnoteSize,
          stat.footnoteColor ?? palette.accent,
          align: align,
          maxWidth: maxWidth,
          fontWeight: FontWeight.w600,
        );
      }
    }
  }

  static GameSessionHudAlign _alignForColumn(int index, int count) {
    return switch (index) {
      0 => GameSessionHudAlign.left,
      final idx when idx == count - 1 && count > 1 => GameSessionHudAlign.right,
      _ => GameSessionHudAlign.center,
    };
  }

  /// Barra horizontal fina (tempo, velocidade, bônus decrescente).
  static void paintProgressBar(
    Canvas canvas,
    Rect rect,
    GameSessionHudProgress progress,
  ) {
    final ratio = progress.ratio.clamp(0.0, 1.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
    if (ratio <= 0) return;
    final fillColor = ratio < progress.lowThreshold && progress.lowColor != null
        ? progress.lowColor!
        : progress.color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left, rect.top, rect.width * ratio, rect.height),
        const Radius.circular(3),
      ),
      Paint()..color = fillColor,
    );
  }

  static void paintText(
    Canvas canvas,
    String text,
    Offset anchor,
    double fontSize,
    Color color, {
    GameSessionHudAlign align = GameSessionHudAlign.left,
    double? maxWidth,
    FontWeight fontWeight = FontWeight.w600,
    double letterSpacing = 0,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth ?? double.infinity);

    final dx = switch (align) {
      GameSessionHudAlign.left => anchor.dx,
      GameSessionHudAlign.center => anchor.dx - painter.width / 2,
      GameSessionHudAlign.right => anchor.dx - painter.width,
    };
    painter.paint(canvas, Offset(dx, anchor.dy - painter.height / 2));
  }
}
