import 'dart:ui';

import '../../core/economy/performance_tier.dart';

/// Constantes, paleta e regras puras da Cobra.
abstract final class SnakeConfig {
  static const countdownSec = 3;

  static const optionKeySpeedMode = 'speedMode';

  /// Multiplicadores por modo (Normal / Rápida / Insana).
  static const speedModeMultipliers = [1.0, 1.3, 1.65];

  static const gridCols = 16;
  static const gridRows = 20;

  static const baseTickSec = 0.22;
  static const minTickSec = 0.09;
  static const speedRampSec = 90.0;

  static const pointsPerFood = 20;

  /// Paleta alinhada ao card do hub (`HubTheme` id `snake`).
  static const cardColor = Color(0xFF16A085);
  static const accentColor = Color(0xFFF39C12);
  static const blendColor = Color(0xFF5FAE6E);
  static const accentSoft = Color(0xFFF5C86A);

  static const bgTop = Color(0xFF0E6655);
  static const bgBottom = Color(0xFF0B5345);
  static const gridLine = Color(0x22FFFFFF);
  static const boardFill = Color(0x33145A32);
  static const boardBorder = Color(0x66FFFFFF);

  static const snakeHead = Color(0xFF2ECC71);
  static const snakeBody = Color(0xFF27AE60);
  static const snakeTail = Color(0xFF1E8449);
  static const snakeEye = Color(0xFF2D3436);
  static const foodCore = Color(0xFFF39C12);
  static const foodGlow = Color(0xFFE67E22);
  static const foodLeaf = Color(0xFF2ECC71);

  static const hudText = Color(0xFFF8F9FA);
  static const hudMuted = Color(0xFFD5F5E3);
  static const hudPanel = Color(0x33FFFFFF);
  static const crashRed = Color(0xFFFF7675);
  static const eatGold = Color(0xFFFDCB6E);
  static const speedBar = Color(0xFF00CEC9);
  static const speedBarLow = Color(0xFFFDCB6E);
}

enum SnakeDirection { up, down, left, right }

/// Progresso da partida 0.0 → 1.0 (velocidade).
double snakeProgress(double elapsedSec) =>
    (elapsedSec / SnakeConfig.speedRampSec).clamp(0.0, 1.0);

/// Intervalo entre movimentos (segundos) — diminui com o tempo.
double snakeTickInterval(double elapsedSec, {double modeMultiplier = 1.0}) {
  final progress = snakeProgress(elapsedSec);
  final interval = SnakeConfig.baseTickSec -
      (SnakeConfig.baseTickSec - SnakeConfig.minTickSec) * progress;
  return (interval / modeMultiplier).clamp(
    SnakeConfig.minTickSec / modeMultiplier,
    SnakeConfig.baseTickSec / modeMultiplier,
  );
}

/// Nível exibido no HUD (1–10).
int snakeSpeedLevel(double elapsedSec) =>
    (1 + snakeProgress(elapsedSec) * 9).floor().clamp(1, 10);

/// Multiplicador do modo escolhido na prep.
double snakeSpeedModeMultiplier(int modeIndex) {
  final idx =
      modeIndex.clamp(0, SnakeConfig.speedModeMultipliers.length - 1);
  return SnakeConfig.speedModeMultipliers[idx];
}

/// Pontos por fruta conforme sequência (leve escalonamento).
int snakePointsForFood(int foodEatenBefore) {
  final tier = (foodEatenBefore ~/ 5).clamp(0, 4);
  return SnakeConfig.pointsPerFood + tier * 5;
}

/// Placar ao vivo — soma das frutas comidas (tempo não pontua).
int snakeProgressScore({required int foodEaten}) {
  var total = 0;
  for (var i = 0; i < foodEaten; i++) {
    total += snakePointsForFood(i);
  }
  return total;
}

/// Pontos da próxima fruta (preview no HUD).
int snakeNextFoodPoints(int foodEaten) => snakePointsForFood(foodEaten);

/// Posição inicial da cobra (cabeça + corpo) no centro do grid.
List<(int col, int row)> snakeInitialSegments() {
  final midCol = SnakeConfig.gridCols ~/ 2;
  final midRow = SnakeConfig.gridRows ~/ 2;
  return [
    (midCol, midRow),
    (midCol - 1, midRow),
    (midCol - 2, midRow),
  ];
}

/// Direção oposta — impede inverter 180° num único tick.
SnakeDirection? snakeOpposite(SnakeDirection dir) => switch (dir) {
      SnakeDirection.up => SnakeDirection.down,
      SnakeDirection.down => SnakeDirection.up,
      SnakeDirection.left => SnakeDirection.right,
      SnakeDirection.right => SnakeDirection.left,
    };

/// Direção a partir de um deslize na tela.
SnakeDirection? snakeDirectionFromDelta(double dx, double dy,
    {double minDist = 28}) {
  if (dx.abs() < minDist && dy.abs() < minDist) return null;
  if (dx.abs() > dy.abs()) {
    return dx > 0 ? SnakeDirection.right : SnakeDirection.left;
  }
  return dy > 0 ? SnakeDirection.down : SnakeDirection.up;
}

/// Próxima célula da cabeça.
(int col, int row) snakeNextHead(
  int col,
  int row,
  SnakeDirection direction,
) {
  return switch (direction) {
    SnakeDirection.up => (col, row - 1),
    SnakeDirection.down => (col, row + 1),
    SnakeDirection.left => (col - 1, row),
    SnakeDirection.right => (col + 1, row),
  };
}

/// Verifica colisão com paredes.
bool snakeHitsWall(int col, int row) =>
    col < 0 ||
    row < 0 ||
    col >= SnakeConfig.gridCols ||
    row >= SnakeConfig.gridRows;

/// Gera posição livre para a fruta.
(int col, int row)? snakeSpawnFood(
  List<(int col, int row)> occupied,
  int Function(int max) randomInt,
) {
  final blocked = occupied.map((s) => '${s.$1},${s.$2}').toSet();
  final free = <(int, int)>[];
  for (var r = 0; r < SnakeConfig.gridRows; r++) {
    for (var c = 0; c < SnakeConfig.gridCols; c++) {
      if (!blocked.contains('$c,$r')) free.add((c, r));
    }
  }
  if (free.isEmpty) return null;
  return free[randomInt(free.length)];
}

/// Layout do tabuleiro abaixo do HUD.
class SnakeBoardLayout {
  const SnakeBoardLayout({
    required this.origin,
    required this.cellSize,
    required this.boardRect,
  });

  final Offset origin;
  final double cellSize;
  final Rect boardRect;

  Rect cellRect(int col, int row) => Rect.fromLTWH(
        origin.dx + col * cellSize,
        origin.dy + row * cellSize,
        cellSize,
        cellSize,
      );
}

/// Calcula tamanho da célula e origem centralizada.
SnakeBoardLayout snakeBoardLayout({
  required double screenW,
  required double screenH,
  double hudTop = 56,
  double margin = 12,
}) {
  final top = hudTop + margin;
  final availW = screenW - margin * 2;
  final availH = screenH - top - margin;
  final cellSize = (availW / SnakeConfig.gridCols)
      .clamp(0.0, availH / SnakeConfig.gridRows);
  final boardW = cellSize * SnakeConfig.gridCols;
  final boardH = cellSize * SnakeConfig.gridRows;
  final origin = Offset(
    (screenW - boardW) / 2,
    top + (availH - boardH) / 2,
  );
  return SnakeBoardLayout(
    origin: origin,
    cellSize: cellSize,
    boardRect: Rect.fromLTWH(origin.dx, origin.dy, boardW, boardH),
  );
}

/// Label de tempo para o HUD.
String snakeHudElapsedLabel(Duration elapsed) {
  final s = elapsed.inSeconds;
  final m = s ~/ 60;
  final r = s % 60;
  return '$m:${r.toString().padLeft(2, '0')}';
}

PerformanceTier snakePerformanceTier({
  required bool won,
  required int snakeLength,
}) {
  if (won || snakeLength >= 20) return PerformanceTier.gold;
  if (snakeLength >= 12) return PerformanceTier.silver;
  return PerformanceTier.bronze;
}
