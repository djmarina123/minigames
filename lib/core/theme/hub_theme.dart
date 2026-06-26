import 'package:flutter/material.dart';

import '../game_sdk/game_metadata.dart';

/// Tokens visuais do hub — inspirado em apps de minijogos casuais (grid colorido).
abstract final class HubTheme {
  static const background = Color(0xFFF5F0E8);
  static const textPrimary = Color(0xFF2D3436);
  static const textSecondary = Color(0xFF636E72);
  static const headerIcon = Color(0xFFE056A0);
  static const coinPillBg = Color(0xFFF0E6D3);
  static const coinGold = Color(0xFFF5B731);
  /// Ícone padrão de moeda no hub (pill, perfil, placar, dicas).
  static const coinIcon = Icons.monetization_on_rounded;
  /// Ícone de nível / XP global.
  static const levelIcon = Icons.star_rounded;
  static const levelPillBg = Color(0xFFEDE8FF);
  static const removeAdsPurple = Color(0xFF7B5CF0);
  /// Recompensa diária no header — presente (coral quente).
  static const dailyRewardAccent = Color(0xFFE17055);
  static const dailyRewardPillBg = Color(0xFFFFF0EB);
  static const dailyRewardIcon = Icons.card_giftcard_rounded;
  /// Missões diárias no header — metas (teal).
  static const missionAccent = Color(0xFF00B894);
  static const missionPillBg = Color(0xFFE0F5F0);
  static const missionIcon = Icons.emoji_events_rounded;
  static const featuredBadge = Color(0xFFFF4757);
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
    'game_2048': HubGameTheme(
      cardColor: Color(0xFF00B894),
      accentColor: Color(0xFFFDCB6E),
    ),
    'infinite_runner': HubGameTheme(
      cardColor: Color(0xFFFF9F43),
      accentColor: Color(0xFF54A0FF),
    ),
    'solitaire': HubGameTheme(
      cardColor: Color(0xFF2D6A4F),
      accentColor: Color(0xFFE17055),
    ),
    'sudoku': HubGameTheme(
      cardColor: Color(0xFF4834D4),
      accentColor: Color(0xFFF9CA24),
    ),
    'domino': HubGameTheme(
      cardColor: Color(0xFF5D4037),
      accentColor: Color(0xFFE07A7A),
    ),
    'snake': HubGameTheme(
      cardColor: Color(0xFF16A085),
      accentColor: Color(0xFFF39C12),
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

  /// Tom intermediário entre [cardColor] e [accentColor] — mini-cartas, anéis.
  Color get blendColor => Color.lerp(cardColor, accentColor, 0.45)!;

  /// Variação mais clara de [accentColor] para detalhes secundários.
  Color get accentSoft => Color.lerp(accentColor, Colors.white, 0.22)!;
}

/// Título do card sempre em caixa alta (padrão do hub).
String hubDisplayTitle(String title) => title.toUpperCase();

/// Primeira palavra do título (para linha decorativa curta).
String hubTitleLead(String title) {
  final parts = title.trim().split(RegExp(r'\s+'));
  return parts.isEmpty ? title : parts.first.toUpperCase();
}

/// Largura da barra decorativa abaixo do título (proporcional à 1ª palavra).
double hubUnderlineWidth(String titleLead) {
  final len = titleLead.length.clamp(3, 10);
  return 24.0 + len * 4.5;
}
