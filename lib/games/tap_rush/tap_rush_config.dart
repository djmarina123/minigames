import 'dart:math';
import 'dart:ui';

import '../../core/economy/performance_tier.dart';

/// Constantes e paleta do Tap Rush — referência para novos jogos Flame.
abstract final class TapRushConfig {
  static const gameDurationSec = 15;
  static const countdownSec = 3;

  static const optionKeyDurationSec = 'durationSec';

  static const durationChoicesSec = [15, 30, 60];

  static const baseTargetRadius = 40.0;
  static const minTargetRadius = 26.0;

  /// Tempo máximo (ms) antes do alvo sumir — diminui com a partida.
  static const maxTargetLifetimeMs = 1200.0;
  static const minTargetLifetimeMs = 525.0;

  /// Raio mínimo da área de toque — independente do tamanho visual.
  static const minHitRadius = 32.0;

  /// Tolerância extra (px) além do raio de toque para registrar acerto.
  static const hitGracePx = 10.0;

  static const maxComboMultiplier = 5;
  static const basePointsPerHit = 10;

  static const bgTop = Color(0xFF0F0C29);
  static const bgBottom = Color(0xFF302B63);
  static const targetOuter = Color(0xFF6C5CE7);
  static const targetInner = Color(0xFFa29bfe);
  static const targetCore = Color(0xFFFD79A8);
  static const comboGold = Color(0xFFFDCB6E);
  static const missRed = Color(0xFFFF7675);
  static const hudText = Color(0xFFF8F9FA);
  static const timerBar = Color(0xFF00CEC9);
  static const timerBarLow = Color(0xFFFF7675);
}

/// Pontos por acerto conforme combo atual (1..maxComboMultiplier).
int tapRushPointsForHit(int combo) {
  final mult = combo.clamp(1, TapRushConfig.maxComboMultiplier);
  return TapRushConfig.basePointsPerHit * mult;
}

/// Progresso da partida 0.0 → 1.0.
double tapRushProgress(double elapsedSec, int durationSec) =>
    (elapsedSec / durationSec).clamp(0.0, 1.0);

/// Curva de dificuldade — acelera suavemente no meio/final da partida.
double tapRushDifficultyProgress(double progress) =>
    pow(progress.clamp(0.0, 1.0), 1.2).toDouble();

double tapRushTargetRadius(double progress) {
  final t = tapRushDifficultyProgress(progress);
  return TapRushConfig.baseTargetRadius -
      (TapRushConfig.baseTargetRadius - TapRushConfig.minTargetRadius) * t;
}

double tapRushTargetLifetimeMs(double progress) {
  final t = tapRushDifficultyProgress(progress);
  return TapRushConfig.maxTargetLifetimeMs -
      (TapRushConfig.maxTargetLifetimeMs - TapRushConfig.minTargetLifetimeMs) *
          t;
}

/// Raio efetivo de toque — não encolhe abaixo do mínimo confortável no mobile.
double tapRushHitRadius(double visualRadius) =>
    max(visualRadius, TapRushConfig.minHitRadius) + TapRushConfig.hitGracePx;

/// Score considerado "partida excelente" (desempenho `1.0`).
const tapRushGoldScore = 450;

/// Desempenho normalizado (`0.0`–`1.0`) pela pontuação obtida.
double tapRushPerformanceRatio(int score) =>
    (score / tapRushGoldScore).clamp(0.0, 1.0);

PerformanceTier tapRushPerformanceTier(int score) =>
    tierFromRatio(tapRushPerformanceRatio(score));
