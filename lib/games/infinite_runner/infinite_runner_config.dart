import 'dart:math';
import 'dart:ui';

import '../../core/economy/performance_tier.dart';

/// Constantes, paleta e regras puras da Corrida Infinita.
abstract final class InfiniteRunnerConfig {
  static const countdownSec = 3;

  static const optionKeySpeedMode = 'speedMode';

  /// Multiplicadores por modo (Normal / Rápida / Insana).
  static const speedModeMultipliers = [1.0, 1.35, 1.75];

  static const baseScrollSpeed = 260.0;
  static const maxScrollSpeed = 600.0;
  static const speedRampSec = 50.0;

  static const gravity = 2400.0;
  static const jumpVelocity = -920.0;

  /// Tamanho dos obstáculos baixos em fração do jogador (pulo).
  static const lowObstacleWidthMin = 0.55;
  static const lowObstacleWidthMax = 0.75;
  static const lowObstacleWidthMinLate = 0.62;
  static const lowObstacleWidthMaxLate = 0.82;
  static const lowObstacleHeightMin = 0.45;
  static const lowObstacleHeightMax = 0.65;
  static const lowObstacleHeightMaxLate = 0.78;

  /// Obstáculo alto (agachar) — viga mais baixa e estreita.
  static const highObstacleWidthMin = 1.1;
  static const highObstacleWidthMax = 1.35;
  static const highObstacleHeightFactor = 0.88;
  static const highObstacleHeightFactorLate = 0.94;
  static const highObstacleBeamTopRatio = 0.18;
  static const highObstacleBeamTopRatioLate = 0.28;
  static const highObstacleBeamHeightRatio = 0.30;
  static const highObstacleBeamHeightRatioLate = 0.36;

  static const pointsPerObstacle = 30;

  static const minSpawnGapSec = 1.0;
  static const maxSpawnGapSec = 2.0;
  static const absoluteMinSpawnGapSec = 0.82;

  /// Par jump→duck (ou vice-versa) a partir deste progresso linear.
  static const doubleObstacleProgressThreshold = 0.6;
  static const doubleObstacleBaseChance = 0.12;
  static const doubleObstacleMaxExtraChance = 0.18;
  static const doubleObstacleFollowGapSec = 0.45;

  /// Distância mínima (px) para reconhecer swipe vertical nos controles.
  static const swipeThresholdPx = 22.0;

  static const hudReservedTop = 56.0;
  static const groundRatio = 0.70;
  static const playerXRatio = 0.2;
  static const playerWidthRatio = 0.15;
  static const playerHeightRatio = 0.17;

  /// Paleta alinhada ao card do hub (`HubTheme` id `infinite_runner`).
  static const cardColor = Color(0xFFFF9F43);
  static const accentColor = Color(0xFF54A0FF);
  static const blendColor = Color(0xFFAC7F72);
  static const accentSoft = Color(0xFF8EC5FF);

  static const skyTop = Color(0xFF74B9FF);
  static const skyMid = Color(0xFFFF9F68);
  static const skyBottom = Color(0xFFFF7675);
  static const sunCore = Color(0xFFFFEAA7);
  static const sunGlow = Color(0xFFFDCB6E);
  static const hillFar = Color(0x55FFFFFF);
  static const hillNear = Color(0x88FFFFFF);

  static const groundGrass = Color(0xFF7BED9F);
  static const groundGrassDark = Color(0xFF55C57A);
  static const groundTop = Color(0xFFF5F0E8);
  static const groundBottom = Color(0xFFE2D3BC);

  static const obstacleGreen = Color(0xFF00B894);
  static const obstacleMid = Color(0xFF3DBEA8);
  static const obstacleDark = Color(0xFF008F72);
  static const obstacleHighlight = Color(0xFF55EFC4);
  static const hazardYellow = Color(0xFFFDCB6E);
  static const hazardOrange = Color(0xFFE17055);

  static const playerBody = Color(0xFF54A0FF);
  static const playerHead = Color(0xFF8EC5FF);
  static const playerLeg = Color(0xFF2E86DE);
  static const playerSkin = Color(0xFFFFE0BD);
  static const playerShorts = Color(0xFF2D3436);
  static const playerShoe = Color(0xFF2D3436);
  static const playerAccent = Color(0xFFFF9F43);
  static const outlineWhite = Color(0xFFFFFFFF);

  static const hudText = Color(0xFFF8F9FA);
  static const hudMuted = Color(0xFFE8F4FF);
  static const hudPanel = Color(0x33FFFFFF);
  static const crashRed = Color(0xFFFF7675);
  static const passGreen = Color(0xFF2ED573);
  static const speedBar = Color(0xFF00CEC9);
  static const speedBarLow = Color(0xFFFDCB6E);

  // Legado — usado em FX
  static const bgTop = skyTop;
  static const bgBottom = skyBottom;
  static const obstacleColor = obstacleDark;
}

enum InfiniteRunnerSwipeAction { up, down }

/// Swipe vertical reconhecido a partir do deslocamento acumulado do arraste.
InfiniteRunnerSwipeAction? infiniteRunnerSwipeActionFromDelta(
  double dx,
  double dy, {
  double minDist = InfiniteRunnerConfig.swipeThresholdPx,
}) {
  if (dx.abs() < minDist && dy.abs() < minDist) return null;
  if (dx.abs() > dy.abs()) return null;
  return dy > 0 ? InfiniteRunnerSwipeAction.down : InfiniteRunnerSwipeAction.up;
}

/// Progresso da partida 0.0 → 1.0 (velocidade e dificuldade).
double infiniteRunnerProgress(double elapsedSec) =>
    (elapsedSec / InfiniteRunnerConfig.speedRampSec).clamp(0.0, 1.0);

/// Curva de dificuldade — acelera suavemente no meio/final da partida.
double infiniteRunnerDifficultyProgress(double progress) =>
    pow(progress.clamp(0.0, 1.0), 1.35).toDouble();

/// Velocidade horizontal atual (px/s).
double infiniteRunnerScrollSpeed(double elapsedSec, {double modeMultiplier = 1.0}) {
  final progress = infiniteRunnerDifficultyProgress(infiniteRunnerProgress(elapsedSec));
  final base = InfiniteRunnerConfig.baseScrollSpeed +
      (InfiniteRunnerConfig.maxScrollSpeed -
              InfiniteRunnerConfig.baseScrollSpeed) *
          progress;
  return base * modeMultiplier;
}

/// Nível exibido no HUD (1–10).
int infiniteRunnerSpeedLevel(double elapsedSec) {
  final progress =
      infiniteRunnerDifficultyProgress(infiniteRunnerProgress(elapsedSec));
  return (1 + progress * 9).floor().clamp(1, 10);
}

/// Progresso 0–1 para barra do HUD (espelha a curva de velocidade).
double infiniteRunnerHudProgress(double elapsedSec) =>
    infiniteRunnerDifficultyProgress(infiniteRunnerProgress(elapsedSec));

/// Pontos acumulados por obstáculos ultrapassados.
int infiniteRunnerScore({required int obstaclesCleared}) =>
    obstaclesCleared * InfiniteRunnerConfig.pointsPerObstacle;

/// Variação visível no placar ao ultrapassar um obstáculo.
int infiniteRunnerObstaclePassDelta({
  required int previousScore,
  required int obstaclesClearedAfter,
}) =>
    infiniteRunnerScore(obstaclesCleared: obstaclesClearedAfter) - previousScore;

/// Escolhe se o próximo obstáculo é alto (agachar) ou baixo (pular).
///
/// Sorteio quase uniforme no início; só aumenta a chance de trocar após
/// sequências longas do mesmo tipo — evita o padrão fixo cacto-barreira.
bool infiniteRunnerPickHighObstacle({
  required bool? lastWasHigh,
  required int consecutiveSameKind,
  required double randomUnit,
}) {
  if (lastWasHigh == null) {
    return randomUnit >= 0.5;
  }

  final pickOther = switch (consecutiveSameKind) {
    1 => randomUnit < 0.45,
    2 => randomUnit < 0.68,
    _ => randomUnit < 0.85,
  };

  return pickOther ? !lastWasHigh : lastWasHigh;
}

/// Intervalo entre spawns (diminui com progresso e velocidade).
double infiniteRunnerSpawnGapSec(
  double progress, {
  double scrollSpeed = InfiniteRunnerConfig.baseScrollSpeed,
}) {
  final difficulty = infiniteRunnerDifficultyProgress(progress.clamp(0.0, 1.0));
  final gap = InfiniteRunnerConfig.maxSpawnGapSec -
      (InfiniteRunnerConfig.maxSpawnGapSec -
              InfiniteRunnerConfig.minSpawnGapSec) *
          difficulty;
  final speedFactor =
      (scrollSpeed / InfiniteRunnerConfig.baseScrollSpeed).clamp(1.0, 2.2);
  return (gap / speedFactor).clamp(
    InfiniteRunnerConfig.absoluteMinSpawnGapSec,
    InfiniteRunnerConfig.maxSpawnGapSec,
  );
}

/// Chance de um segundo obstáculo logo após o primeiro (troca jump/duck).
bool infiniteRunnerRollDoubleObstacle({
  required double progress,
  required double randomUnit,
}) {
  if (progress < InfiniteRunnerConfig.doubleObstacleProgressThreshold) {
    return false;
  }
  final span = 1.0 - InfiniteRunnerConfig.doubleObstacleProgressThreshold;
  final t = ((progress - InfiniteRunnerConfig.doubleObstacleProgressThreshold) /
          span)
      .clamp(0.0, 1.0);
  final chance = InfiniteRunnerConfig.doubleObstacleBaseChance +
      t * InfiniteRunnerConfig.doubleObstacleMaxExtraChance;
  return randomUnit < chance;
}

/// Pausa entre os dois obstáculos de um par (segundos).
double infiniteRunnerDoubleObstacleFollowGapSec(double progress) {
  final difficulty = infiniteRunnerDifficultyProgress(progress.clamp(0.0, 1.0));
  return InfiniteRunnerConfig.doubleObstacleFollowGapSec *
      (1.0 - difficulty * 0.25);
}

double _lerpConfig(double from, double to, double t) => from + (to - from) * t;

/// Largura/altura de obstáculo baixo para um jogador com [playerW] × [playerH].
(double width, double height) infiniteRunnerLowObstacleSize({
  required double playerW,
  required double playerH,
  required double randomUnit,
  double progress = 0.0,
}) {
  final t = randomUnit.clamp(0.0, 1.0);
  final p = infiniteRunnerDifficultyProgress(progress.clamp(0.0, 1.0));
  final widthMin = _lerpConfig(
    InfiniteRunnerConfig.lowObstacleWidthMin,
    InfiniteRunnerConfig.lowObstacleWidthMinLate,
    p,
  );
  final widthMax = _lerpConfig(
    InfiniteRunnerConfig.lowObstacleWidthMax,
    InfiniteRunnerConfig.lowObstacleWidthMaxLate,
    p,
  );
  final heightMax = _lerpConfig(
    InfiniteRunnerConfig.lowObstacleHeightMax,
    InfiniteRunnerConfig.lowObstacleHeightMaxLate,
    p,
  );
  final width = playerW * (widthMin + t * (widthMax - widthMin));
  final height = playerH *
      (InfiniteRunnerConfig.lowObstacleHeightMin + t * (heightMax - InfiniteRunnerConfig.lowObstacleHeightMin));
  return (width, height);
}

/// Largura/altura e geometria da viga de obstáculo alto (agachar).
({
  double width,
  double height,
  double beamTopRatio,
  double beamHeightRatio,
}) infiniteRunnerHighObstacleSpec({
  required double playerW,
  required double playerH,
  required double randomUnit,
  double progress = 0.0,
}) {
  final t = randomUnit.clamp(0.0, 1.0);
  final p = infiniteRunnerDifficultyProgress(progress.clamp(0.0, 1.0));
  final width = playerW *
      (InfiniteRunnerConfig.highObstacleWidthMin +
          t *
              (InfiniteRunnerConfig.highObstacleWidthMax -
                  InfiniteRunnerConfig.highObstacleWidthMin));
  final heightFactor = _lerpConfig(
    InfiniteRunnerConfig.highObstacleHeightFactor,
    InfiniteRunnerConfig.highObstacleHeightFactorLate,
    p,
  );
  return (
    width: width,
    height: playerH * heightFactor,
    beamTopRatio: _lerpConfig(
      InfiniteRunnerConfig.highObstacleBeamTopRatio,
      InfiniteRunnerConfig.highObstacleBeamTopRatioLate,
      p,
    ),
    beamHeightRatio: _lerpConfig(
      InfiniteRunnerConfig.highObstacleBeamHeightRatio,
      InfiniteRunnerConfig.highObstacleBeamHeightRatioLate,
      p,
    ),
  );
}

/// Distância percorrida em metros (aprox.) para o HUD.
int infiniteRunnerDistanceMeters(double elapsedSec, {double modeMultiplier = 1.0}) {
  final speed = infiniteRunnerScrollSpeed(elapsedSec, modeMultiplier: modeMultiplier);
  return ((speed * elapsedSec) / 120).floor();
}

/// Multiplicador do modo escolhido na prep.
double infiniteRunnerSpeedModeMultiplier(int modeIndex) {
  final idx = modeIndex.clamp(0, InfiniteRunnerConfig.speedModeMultipliers.length - 1);
  return InfiniteRunnerConfig.speedModeMultipliers[idx];
}

/// Largura/altura de obstáculo alto (agachar) — compatível com testes legados.
(double width, double height) infiniteRunnerHighObstacleSize({
  required double playerW,
  required double playerH,
  required double randomUnit,
  double progress = 0.0,
}) {
  final spec = infiniteRunnerHighObstacleSpec(
    playerW: playerW,
    playerH: playerH,
    randomUnit: randomUnit,
    progress: progress,
  );
  return (spec.width, spec.height);
}

/// Obstáculos desviados considerados "partida excelente" (desempenho `1.0`).
const infiniteRunnerGoldObstacles = 26;

/// Desempenho normalizado (`0.0`–`1.0`) a partir dos obstáculos ultrapassados.
double infiniteRunnerPerformanceRatio({required int obstaclesCleared}) =>
    (obstaclesCleared / infiniteRunnerGoldObstacles).clamp(0.0, 1.0);

PerformanceTier infiniteRunnerPerformanceTier({required int obstaclesCleared}) =>
    tierFromRatio(infiniteRunnerPerformanceRatio(obstaclesCleared: obstaclesCleared));
