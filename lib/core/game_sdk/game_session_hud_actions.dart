import 'package:flutter/material.dart';

import '../theme/hub_theme.dart';
import 'game_session_hud.dart';

/// Um botão de ação abaixo do painel de stats (ícone quadrado, padrão Paciência).
class GameSessionHudAction {
  const GameSessionHudAction({
    required this.id,
    required this.icon,
    required this.enabled,
    this.accent,
    this.coinCost,
  });

  final String id;
  final IconData icon;
  final bool enabled;

  /// Borda/fundo levemente coloridos quando habilitado (ex.: dourado na dica).
  final Color? accent;

  /// Quando definido, exibe o custo em moedas no botão (ex.: dica paga).
  final int? coinCost;
}

/// Layout dos botões — calcular no `render` e reutilizar no hit-test do toque.
class GameSessionHudActionBar {
  GameSessionHudActionBar._(this.rects);

  final Map<String, Rect> rects;

  static const buttonSize = 34.0;
  static const coinButtonWidth = 44.0;
  static const gap = 8.0;
  static const edgePad = 8.0;
  static const belowPanelGap = 10.0;

  /// Altura total a reservar no topo do canvas (painel + faixa de botões).
  static const reservedHeight = GameSessionHud.panelTop +
      GameSessionHud.panelHeightWithBar +
      belowPanelGap +
      buttonSize;

  static double buttonWidth(GameSessionHudAction action) =>
      action.coinCost != null ? coinButtonWidth : buttonSize;

  /// Faixa vertical dos botões — útil para filtrar toques antes do tabuleiro.
  static Rect bandRect(
    Size canvasSize, {
    bool withProgressBar = true,
  }) {
    final panel = GameSessionHud.panelRect(
      canvasSize,
      withProgressBar: withProgressBar,
    );
    return Rect.fromLTWH(
      0,
      panel.bottom,
      canvasSize.width,
      belowPanelGap + buttonSize,
    );
  }

  /// Posiciona botões alinhados à direita, da esquerda para a direita na lista.
  static GameSessionHudActionBar layout(
    Size canvasSize, {
    required List<GameSessionHudAction> actions,
    bool withProgressBar = true,
  }) {
    final panel = GameSessionHud.panelRect(
      canvasSize,
      withProgressBar: withProgressBar,
    );
    final y = panel.bottom + belowPanelGap;
    final right = panel.right - edgePad;
    final rects = <String, Rect>{};

    var cursorRight = right;
    for (var i = actions.length - 1; i >= 0; i--) {
      final action = actions[i];
      final w = buttonWidth(action);
      cursorRight -= w;
      rects[action.id] = Rect.fromLTWH(cursorRight, y, w, buttonSize);
      if (i > 0) cursorRight -= gap;
    }

    return GameSessionHudActionBar._(rects);
  }

  String? hitTest(Offset pos) {
    for (final entry in rects.entries) {
      if (entry.value.contains(pos)) return entry.key;
    }
    return null;
  }

  static void paint(
    Canvas canvas,
    GameSessionHudPalette palette,
    GameSessionHudActionBar layout,
    List<GameSessionHudAction> actions,
  ) {
    for (final action in actions) {
      final rect = layout.rects[action.id];
      if (rect == null) continue;
      _paintIconButton(canvas, rect, action, palette);
    }
  }

  static void _paintIconButton(
    Canvas canvas,
    Rect rect,
    GameSessionHudAction action,
    GameSessionHudPalette palette,
  ) {
    final enabled = action.enabled;
    final accent = action.accent;
    final radius = Radius.circular(rect.height * 0.32);
    final rr = RRect.fromRectAndRadius(rect, radius);

    canvas.drawRRect(
      rr,
      Paint()
        ..color = enabled
            ? (accent?.withValues(alpha: 0.14) ??
                Colors.white.withValues(alpha: 0.12))
            : Colors.white.withValues(alpha: 0.06),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..color = enabled
            ? (accent?.withValues(alpha: 0.45) ??
                Colors.white.withValues(alpha: 0.22))
            : Colors.white.withValues(alpha: 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    if (action.coinCost != null) {
      _paintCoinCostButton(canvas, rect, action, palette, enabled, accent);
      return;
    }

    _paintIcon(
      canvas,
      rect,
      action.icon,
      enabled ? (accent ?? palette.text) : palette.muted.withValues(alpha: 0.65),
      rect.height * 0.52,
    );
  }

  static void _paintCoinCostButton(
    Canvas canvas,
    Rect rect,
    GameSessionHudAction action,
    GameSessionHudPalette palette,
    bool enabled,
    Color? accent,
  ) {
    final cost = action.coinCost!;
    final iconColor = enabled
        ? (accent ?? palette.text)
        : palette.muted.withValues(alpha: 0.65);
    final costColor = enabled ? HubTheme.coinGold : palette.muted.withValues(alpha: 0.55);

    final iconRect = Rect.fromLTWH(
      rect.left,
      rect.top + rect.height * 0.06,
      rect.width,
      rect.height * 0.48,
    );
    _paintIcon(canvas, iconRect, action.icon, iconColor, iconRect.height * 0.72);

    final costPainter = TextPainter(
      text: TextSpan(
        text: '$cost',
        style: TextStyle(
          fontSize: (rect.height * 0.28).clamp(9.0, 11.0),
          fontWeight: FontWeight.w900,
          color: costColor,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width);

    costPainter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - costPainter.width) / 2,
        rect.bottom - costPainter.height - rect.height * 0.08,
      ),
    );
  }

  static void _paintIcon(
    Canvas canvas,
    Rect rect,
    IconData icon,
    Color color,
    double iconSize,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: iconSize,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - painter.width) / 2,
        rect.top + (rect.height - painter.height) / 2,
      ),
    );
  }
}

/// Ícones padrão para ações comuns entre jogos Flame.
abstract final class GameSessionHudActionIcons {
  static const undo = Icons.undo_rounded;
  static const hint = Icons.lightbulb_outline_rounded;
  static const auto = Icons.auto_awesome_rounded;
  static const erase = Icons.backspace_outlined;
}
