import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/games/snake/snake_config.dart';

void main() {
  group('SnakeConfig', () {
    test('velocidade aumenta com o tempo e modo', () {
      expect(snakeTickInterval(0), SnakeConfig.baseTickSec);
      expect(snakeTickInterval(90), SnakeConfig.minTickSec);
      expect(
        snakeTickInterval(40, modeMultiplier: 1.65),
        lessThan(snakeTickInterval(40)),
      );
    });

    test('nível de velocidade vai de 1 a 10', () {
      expect(snakeSpeedLevel(0), 1);
      expect(snakeSpeedLevel(90), 10);
    });

    test('pontos por fruta escalonam a cada 5', () {
      expect(snakePointsForFood(0), 20);
      expect(snakePointsForFood(4), 20);
      expect(snakePointsForFood(5), 25);
      expect(snakePointsForFood(10), 30);
    });

    test('pontuação soma só frutas comidas', () {
      expect(snakeProgressScore(foodEaten: 0), 0);
      expect(snakeProgressScore(foodEaten: 2), 40);
      expect(snakeProgressScore(foodEaten: 6), 20 * 5 + 25);
    });

    test('multiplicadores de modo', () {
      expect(snakeSpeedModeMultiplier(0), 1.0);
      expect(snakeSpeedModeMultiplier(2), 1.65);
      expect(snakeSpeedModeMultiplier(99), 1.65);
    });

    test('direção oposta e deslize', () {
      expect(snakeOpposite(SnakeDirection.up), SnakeDirection.down);
      expect(
        snakeDirectionFromDelta(40, 5),
        SnakeDirection.right,
      );
      expect(
        snakeDirectionFromDelta(5, -40),
        SnakeDirection.up,
      );
      expect(snakeDirectionFromDelta(5, 5), isNull);
    });

    test('colisão com parede', () {
      expect(snakeHitsWall(-1, 0), isTrue);
      expect(snakeHitsWall(0, SnakeConfig.gridRows), isTrue);
      expect(snakeHitsWall(0, 0), isFalse);
    });

    test('spawn de fruta evita células ocupadas', () {
      final food = snakeSpawnFood(
        snakeInitialSegments(),
        (max) => 0,
      );
      expect(food, isNotNull);
      expect(
        snakeInitialSegments().any((s) => s.$1 == food!.$1 && s.$2 == food.$2),
        isFalse,
      );
    });

    test('layout centraliza tabuleiro em 390px', () {
      final layout = snakeBoardLayout(screenW: 390, screenH: 844);
      expect(layout.boardRect.left, greaterThan(0));
      expect(layout.boardRect.right, lessThan(390));
      expect(layout.cellSize, greaterThan(0));
    });

    test('label de tempo no HUD', () {
      expect(
        snakeHudElapsedLabel(const Duration(minutes: 1, seconds: 8)),
        '1:08',
      );
    });
  });
}
