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

    test('delta ao passar obstáculo inclui tempo acumulado desde último placar', () {
      expect(
        infiniteRunnerObstaclePassDelta(
          previousReportedScore: 100,
          elapsedSec: 11,
          obstaclesClearedAfter: 1,
        ),
        40,
      );
      expect(
        infiniteRunnerObstaclePassDelta(
          previousReportedScore: 50,
          elapsedSec: 5,
          obstaclesClearedAfter: 1,
        ),
        30,
      );
    });

    test('tipo de obstáculo não alterna de forma fixa', () {
      expect(
        infiniteRunnerPickHighObstacle(
          lastWasHigh: false,
          consecutiveSameKind: 1,
          randomUnit: 0.3,
        ),
        isTrue,
      );
      expect(
        infiniteRunnerPickHighObstacle(
          lastWasHigh: false,
          consecutiveSameKind: 1,
          randomUnit: 0.6,
        ),
        isFalse,
      );
      expect(
        infiniteRunnerPickHighObstacle(
          lastWasHigh: false,
          consecutiveSameKind: 2,
          randomUnit: 0.5,
        ),
        isTrue,
      );
      expect(
        infiniteRunnerPickHighObstacle(
          lastWasHigh: true,
          consecutiveSameKind: 3,
          randomUnit: 0.1,
        ),
        isFalse,
      );
    });

    test('sequência simulada evita alternância rígida', () {
      var lastWasHigh = infiniteRunnerPickHighObstacle(
        lastWasHigh: null,
        consecutiveSameKind: 0,
        randomUnit: 0.2,
      );
      var streak = 1;
      var alternations = 0;
      var doubles = 0;

      for (var i = 1; i < 200; i++) {
        final unit = (i * 0.137) % 1.0;
        final next = infiniteRunnerPickHighObstacle(
          lastWasHigh: lastWasHigh,
          consecutiveSameKind: streak,
          randomUnit: unit,
        );
        if (next == lastWasHigh) {
          doubles++;
          streak++;
        } else {
          alternations++;
          streak = 1;
        }
        lastWasHigh = next;
      }

      expect(alternations, greaterThan(40));
      expect(doubles, greaterThan(20));
      expect(alternations, lessThan(170));
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

    test('swipe vertical reconhece cima e baixo', () {
      expect(
        infiniteRunnerSwipeActionFromDelta(0, -30),
        InfiniteRunnerSwipeAction.up,
      );
      expect(
        infiniteRunnerSwipeActionFromDelta(0, 30),
        InfiniteRunnerSwipeAction.down,
      );
      expect(infiniteRunnerSwipeActionFromDelta(40, 5), isNull);
      expect(infiniteRunnerSwipeActionFromDelta(5, 5), isNull);
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
