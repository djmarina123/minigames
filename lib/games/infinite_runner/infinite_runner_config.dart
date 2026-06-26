import 'dart:ui';

import '../../core/economy/performance_tier.dart';

/// Constantes, paleta e regras puras da Corrida Infinita.
abstract final class InfiniteRunnerConfig {
  static const countdownSec = 3;

  static const optionKeySpeedMode = 'speedMode';

  /// Multiplicadores por modo (Normal / Rápida / Insana).
  static const speedModeMultipliers = [1.0, 1.25, 1.5];

  static const baseScrollSpeed = 260.0;
  static const maxScrollSpeed = 500.0;
  static const speedRampSec = 80.0;

  static const gravity = 2400.0;
  static const jumpVelocity = -920.0;

  /// Tamanho dos obstáculos baixos em fração do jogador (pulo).
  static const lowObstacleWidthMin = 0.55;
  static const lowObstacleWidthMax = 0.75;
  static const lowObstacleHeightMin = 0.45;
  static const lowObstacleHeightMax = 0.65;

  /// Obstáculo alto (agachar) — viga mais baixa e estreita.
  static const highObstacleWidthMin = 1.1;
  static const highObstacleWidthMax = 1.35;
  static const highObstacleHeightFactor = 0.88;

  static const pointsPerSecond = 10;
  static const pointsPerObstacle = 30;

  static const minSpawnGapSec = 1.35;
  static const maxSpawnGapSec = 2.5;

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

/// Progresso da partida 0.0 → 1.0 (velocidade e dificuldade).
double infiniteRunnerProgress(double elapsedSec) =>
    (elapsedSec / InfiniteRunnerConfig.speedRampSec).clamp(0.0, 1.0);

/// Velocidade horizontal atual (px/s).
double infiniteRunnerScrollSpeed(double elapsedSec, {double modeMultiplier = 1.0}) {
  final progress = infiniteRunnerProgress(elapsedSec);
  final base = InfiniteRunnerConfig.baseScrollSpeed +
      (InfiniteRunnerConfig.maxScrollSpeed -
              InfiniteRunnerConfig.baseScrollSpeed) *
          progress;
  return base * modeMultiplier;
}

/// Nível exibido no HUD (1–10).
int infiniteRunnerSpeedLevel(double elapsedSec) =>
    (1 + infiniteRunnerProgress(elapsedSec) * 9).floor().clamp(1, 10);

/// Pontos acumulados por tempo e obstáculos ultrapassados.
int infiniteRunnerScore({
  required double elapsedSec,
  required int obstaclesCleared,
}) {
  final timePts =
      (elapsedSec * InfiniteRunnerConfig.pointsPerSecond).floor();
  final obstaclePts =
      obstaclesCleared * InfiniteRunnerConfig.pointsPerObstacle;
  return timePts + obstaclePts;
}

/// Variação visível no placar ao ultrapassar um obstáculo (tempo + obstáculo).
int infiniteRunnerObstaclePassDelta({
  required int previousReportedScore,
  required double elapsedSec,
  required int obstaclesClearedAfter,
}) {
  final newScore = infiniteRunnerScore(
    elapsedSec: elapsedSec,
    obstaclesCleared: obstaclesClearedAfter,
  );
  return newScore - previousReportedScore;
}

/// Intervalo entre spawns (diminui com o progresso).
double infiniteRunnerSpawnGapSec(double progress) {
  final gap = InfiniteRunnerConfig.maxSpawnGapSec -
      (InfiniteRunnerConfig.maxSpawnGapSec -
              InfiniteRunnerConfig.minSpawnGapSec) *
          progress;
  return gap.clamp(
    InfiniteRunnerConfig.minSpawnGapSec,
    InfiniteRunnerConfig.maxSpawnGapSec,
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

/// Largura/altura de obstáculo baixo para um jogador com [playerW] × [playerH].
(double width, double height) infiniteRunnerLowObstacleSize({
  required double playerW,
  required double playerH,
  required double randomUnit,
}) {
  final t = randomUnit.clamp(0.0, 1.0);
  final width = playerW *
      (InfiniteRunnerConfig.lowObstacleWidthMin +
          t *
              (InfiniteRunnerConfig.lowObstacleWidthMax -
                  InfiniteRunnerConfig.lowObstacleWidthMin));
  final height = playerH *
      (InfiniteRunnerConfig.lowObstacleHeightMin +
          t *
              (InfiniteRunnerConfig.lowObstacleHeightMax -
                  InfiniteRunnerConfig.lowObstacleHeightMin));
  return (width, height);
}

/// Largura/altura de obstáculo alto (agachar).
(double width, double height) infiniteRunnerHighObstacleSize({
  required double playerW,
  required double playerH,
  required double randomUnit,
}) {
  final t = randomUnit.clamp(0.0, 1.0);
  final width = playerW *
      (InfiniteRunnerConfig.highObstacleWidthMin +
          t *
              (InfiniteRunnerConfig.highObstacleWidthMax -
                  InfiniteRunnerConfig.highObstacleWidthMin));
  final height = playerH * InfiniteRunnerConfig.highObstacleHeightFactor;
  return (width, height);
}

/// Distância (m) considerada "partida excelente" (desempenho `1.0`).
const infiniteRunnerGoldDistanceM = 235;

/// Obstáculos desviados considerados "partida excelente" (desempenho `1.0`).
const infiniteRunnerGoldObstacles = 17;

/// Desempenho normalizado (`0.0`–`1.0`) — o melhor entre distância e obstáculos.
double infiniteRunnerPerformanceRatio({
  required int distanceM,
  required int obstaclesCleared,
}) {
  final byDistance = distanceM / infiniteRunnerGoldDistanceM;
  final byObstacles = obstaclesCleared / infiniteRunnerGoldObstacles;
  final best = byDistance > byObstacles ? byDistance : byObstacles;
  return best.clamp(0.0, 1.0);
}

PerformanceTier infiniteRunnerPerformanceTier({
  required int distanceM,
  required int obstaclesCleared,
}) =>
    tierFromRatio(infiniteRunnerPerformanceRatio(
      distanceM: distanceM,
      obstaclesCleared: obstaclesCleared,
    ));
