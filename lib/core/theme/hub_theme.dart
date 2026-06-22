import 'package:flutter/material.dart';

import '../game_sdk/game_metadata.dart';

/// Tokens visuais do hub — inspirado em apps de minijogos casuais (grid colorido).
abstract final class HubTheme {
  static const background = Color(0xFFF5F0E8);
  static const headerIcon = Color(0xFFE056A0);
  static const coinPillBg = Color(0xFFF0E6D3);
  static const coinGold = Color(0xFFF5B731);
  static const removeAdsPurple = Color(0xFF7B5CF0);
  static const cardBorder = Colors.white;
  static const cardRadius = 22.0;
  static const gridSpacing = 14.0;
  static const gridPadding = 16.0;

  /// Proporção largura/altura dos cards (mais quadrado = menos “faixa vazia”).
  static const cardAspectRatio = 0.92;

  static const _themes = {
    'memory': HubGameTheme(
      cardColor: Color(0xFF5B4BB7),
      accentColor: Color(0xFFFF7675),
    ),
    'tap_rush': HubGameTheme(
      cardColor: Color(0xFFE84393),
      accentColor: Color(0xFFFDCB6E),
    ),
    'demo_tap': HubGameTheme(
      cardColor: Color(0xFF0984E3),
      accentColor: Color(0xFF74B9FF),
    ),
  };

  static HubGameTheme themeFor(GameMetadata meta) =>
      _themes[meta.id] ??
      const HubGameTheme(
        cardColor: Color(0xFF636E72),
        accentColor: Color(0xFFFDCB6E),
      );
}

class HubGameTheme {
  const HubGameTheme({
    required this.cardColor,
    required this.accentColor,
  });

  final Color cardColor;
  final Color accentColor;
}

/// Título do card sempre em caixa alta (padrão do hub).
String hubDisplayTitle(String title) => title.toUpperCase();

/// Primeira palavra do título (para linha decorativa curta).
String hubTitleLead(String title) {
  final parts = title.trim().split(RegExp(r'\s+'));
  return parts.isEmpty ? title : parts.first.toUpperCase();
}
