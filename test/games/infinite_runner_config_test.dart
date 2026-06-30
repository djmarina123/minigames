import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/economy/performance_tier.dart';
import 'package:minigames_hub/games/infinite_runner/infinite_runner_config.dart';

void main() {
  group('InfiniteRunnerConfig', () {
    test('velocidade aumenta com o tempo e modo', () {
      expect(
        infiniteRunnerScrollSpeed(0),
        InfiniteRunnerConfig.baseScrollSpeed,
      );
      expect(
        infiniteRunnerScrollSpeed(InfiniteRunnerConfig.speedRampSec),
        InfiniteRunnerConfig.maxScrollSpeed,
      );
      expect(
        infiniteRunnerScrollSpeed(25, modeMultiplier: 1.75),
        greaterThan(infiniteRunnerScrollSpeed(25)),
      );
    });

    test('curva de dificuldade acelera no final da partida', () {
      expect(infiniteRunnerDifficultyProgress(0.5), lessThan(0.5));
      expect(infiniteRunnerDifficultyProgress(1.0), 1.0);
      final ramp = InfiniteRunnerConfig.speedRampSec;
      final earlyDelta = infiniteRunnerScrollSpeed(ramp * 0.2) -
          infiniteRunnerScrollSpeed(ramp * 0.1);
      final lateDelta = infiniteRunnerScrollSpeed(ramp * 0.9) -
          infiniteRunnerScrollSpeed(ramp * 0.8);
      expect(lateDelta, greaterThan(earlyDelta));
    });

    test('nível de velocidade vai de 1 a 10', () {
      expect(infiniteRunnerSpeedLevel(0), 1);
      expect(infiniteRunnerSpeedLevel(InfiniteRunnerConfig.speedRampSec), 10);
    });

    test('pontuação vem só de obstáculos ultrapassados', () {
      expect(infiniteRunnerScore(obstaclesCleared: 0), 0);
      expect(infiniteRunnerScore(obstaclesCleared: 4), 120);
      expect(infiniteRunnerScore(obstaclesCleared: 26), 780);
    });

    test('delta ao passar obstáculo é fixo por obstáculo', () {
      expect(
        infiniteRunnerObstaclePassDelta(
          previousScore: 0,
          obstaclesClearedAfter: 1,
        ),
        InfiniteRunnerConfig.pointsPerObstacle,
      );
      expect(
        infiniteRunnerObstaclePassDelta(
          previousScore: 90,
          obstaclesClearedAfter: 4,
        ),
        30,
      );
    });

    test('desempenho normalizado usa obstáculos', () {
      expect(infiniteRunnerPerformanceRatio(obstaclesCleared: 0), 0);
      expect(
        infiniteRunnerPerformanceRatio(obstaclesCleared: 26),
        closeTo(1.0, 0.001),
      );
      expect(
        infiniteRunnerPerformanceTier(obstaclesCleared: 26),
        PerformanceTier.gold,
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

    test('intervalo de spawn diminui com progresso e velocidade', () {
      expect(
        infiniteRunnerSpawnGapSec(0),
        InfiniteRunnerConfig.maxSpawnGapSec,
      );
      expect(
        infiniteRunnerSpawnGapSec(1),
        InfiniteRunnerConfig.minSpawnGapSec,
      );
      expect(
        infiniteRunnerSpawnGapSec(1, scrollSpeed: 600),
        lessThan(InfiniteRunnerConfig.minSpawnGapSec),
      );
    });

    test('par de obstáculos só após limiar de progresso', () {
      expect(
        infiniteRunnerRollDoubleObstacle(progress: 0.5, randomUnit: 0.0),
        isFalse,
      );
      expect(
        infiniteRunnerRollDoubleObstacle(progress: 0.6, randomUnit: 0.0),
        isTrue,
      );
      expect(
        infiniteRunnerRollDoubleObstacle(progress: 1.0, randomUnit: 0.99),
        isFalse,
      );
    });

    test('multiplicadores de modo', () {
      expect(infiniteRunnerSpeedModeMultiplier(0), 1.0);
      expect(infiniteRunnerSpeedModeMultiplier(2), 1.75);
      expect(infiniteRunnerSpeedModeMultiplier(99), 1.75);
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

    test('obstáculos baixos crescem com o progresso', () {
      const pw = 58.0;
      const ph = 143.0;
      final (_, hEarly) = infiniteRunnerLowObstacleSize(
        playerW: pw,
        playerH: ph,
        randomUnit: 1.0,
        progress: 0.0,
      );
      final (_, hLate) = infiniteRunnerLowObstacleSize(
        playerW: pw,
        playerH: ph,
        randomUnit: 1.0,
        progress: 1.0,
      );
      final (wEarly, _) = infiniteRunnerLowObstacleSize(
        playerW: pw,
        playerH: ph,
        randomUnit: 0.0,
        progress: 0.0,
      );
      final (wLate, _) = infiniteRunnerLowObstacleSize(
        playerW: pw,
        playerH: ph,
        randomUnit: 0.0,
        progress: 1.0,
      );
      expect(hLate, greaterThan(hEarly));
      expect(wLate, greaterThan(wEarly));
      expect(hEarly, greaterThan(ph * 0.4));
    });

    test('viga alta desce com o progresso', () {
      const pw = 58.0;
      const ph = 143.0;
      final early = infiniteRunnerHighObstacleSpec(
        playerW: pw,
        playerH: ph,
        randomUnit: 0.5,
        progress: 0.0,
      );
      final late = infiniteRunnerHighObstacleSpec(
        playerW: pw,
        playerH: ph,
        randomUnit: 0.5,
        progress: 1.0,
      );
      expect(late.height, greaterThan(early.height));
      expect(late.beamTopRatio, greaterThan(early.beamTopRatio));
      expect(late.beamHeightRatio, greaterThan(early.beamHeightRatio));
    });

    test('viga alta sempre deixa folga para agachar', () {
      const ph = 143.0;
      for (final progress in [0.0, 0.5, 1.0]) {
        final spec = infiniteRunnerHighObstacleSpec(
          playerW: 58.0,
          playerH: ph,
          randomUnit: 0.5,
          progress: progress,
        );
        final heightFactor = spec.height / ph;
        final clearance = infiniteRunnerBeamClearanceRatio(
          heightFactor: heightFactor,
          beamTopRatio: spec.beamTopRatio,
          beamHeightRatio: spec.beamHeightRatio,
        );
        expect(
          clearance,
          greaterThanOrEqualTo(InfiniteRunnerConfig.highObstacleMinClearanceRatio),
          reason: 'progress=$progress clearance=$clearance',
        );
        expect(
          clearance,
          greaterThan(InfiniteRunnerConfig.duckHitHeightRatio),
          reason: 'progress=$progress',
        );
      }
    });
  });
}
