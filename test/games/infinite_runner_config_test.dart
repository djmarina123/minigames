import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/games/infinite_runner/infinite_runner_config.dart';

void main() {
  group('InfiniteRunnerConfig', () {
    test('velocidade aumenta com o tempo e modo', () {
      expect(
        infiniteRunnerScrollSpeed(0),
        InfiniteRunnerConfig.baseScrollSpeed,
      );
      expect(
        infiniteRunnerScrollSpeed(80),
        InfiniteRunnerConfig.maxScrollSpeed,
      );
      expect(
        infiniteRunnerScrollSpeed(40, modeMultiplier: 1.5),
        greaterThan(infiniteRunnerScrollSpeed(40)),
      );
    });

    test('nível de velocidade vai de 1 a 10', () {
      expect(infiniteRunnerSpeedLevel(0), 1);
      expect(infiniteRunnerSpeedLevel(80), 10);
    });

    test('pontuação combina tempo e obstáculos', () {
      expect(
        infiniteRunnerScore(elapsedSec: 10, obstaclesCleared: 0),
        100,
      );
      expect(
        infiniteRunnerScore(elapsedSec: 0, obstaclesCleared: 4),
        120,
      );
      expect(
        infiniteRunnerScore(elapsedSec: 5, obstaclesCleared: 2),
        50 + 60,
      );
    });

    test('intervalo de spawn diminui com progresso', () {
      expect(
        infiniteRunnerSpawnGapSec(0),
        InfiniteRunnerConfig.maxSpawnGapSec,
      );
      expect(
        infiniteRunnerSpawnGapSec(1),
        InfiniteRunnerConfig.minSpawnGapSec,
      );
    });

    test('multiplicadores de modo', () {
      expect(infiniteRunnerSpeedModeMultiplier(0), 1.0);
      expect(infiniteRunnerSpeedModeMultiplier(2), 1.5);
      expect(infiniteRunnerSpeedModeMultiplier(99), 1.5);
    });

    test('obstáculos baixos visíveis mas puláveis', () {
      const pw = 58.0;
      const ph = 143.0;
      final (w, h) = infiniteRunnerLowObstacleSize(
        playerW: pw,
        playerH: ph,
        randomUnit: 0.0,
      );
      final (wMax, hMax) = infiniteRunnerLowObstacleSize(
        playerW: pw,
        playerH: ph,
        randomUnit: 1.0,
      );
      expect(w, greaterThan(pw * 0.5));
      expect(hMax, greaterThan(ph * 0.6));
      expect(h, greaterThan(ph * 0.4));
      expect(wMax, lessThan(pw * 0.85));
    });
  });
}
