import 'dart:math';

import 'package:flutter/material.dart';

/// Constantes, paleta e regras puras do 2048.
abstract final class Game2048Config {
  static const gridSize = 4;
  static const optionKeyTargetTile = 'targetTile';
  static const defaultTargetTile = 2048;

  static const countdownSec = 0; // puzzle — inicia direto

  static const slideAnimSec = 0.14;
  static const mergePulseSec = 0.16;
  static const spawnScaleSec = 0.12;
  static const invalidFlashSec = 0.22;

  static const swipeThresholdPx = 28.0;

  static const maxScore = 99999;

  /// Paleta alinhada ao card do hub (`HubTheme` id `game_2048`).
  static const cardColor = Color(0xFF00B894);
  static const accentColor = Color(0xFFFDCB6E);
  static const blendColor = Color(0xFF7EC9B1);
  static const accentSoft = Color(0xFFFFE29A);
  static const bgTop = Color(0xFF008F72);
  static const bgBottom = Color(0xFF006B56);
  static const boardBg = Color(0xFFBBADA0);
  static const cellEmpty = Color(0xFFCDC1B4);
  static const hudText = Color(0xFFF8F9FA);
  static const hudMuted = Color(0xFFD5E8E2);
  static const missRed = Color(0xFFFF7675);
  static const mergeGlow = Color(0xFFFDCB6E);

  /// Bônus por atingir peças altas (placar final).
  static const tileBonusStart = 64;
  static const tileBonusPerStep = 25;
  static const tileBonusMax = 300;
}

enum Game2048Direction { up, down, left, right }

/// Evento de fusão em uma célula (para FX e scoring).
class Game2048MergeEvent {
  const Game2048MergeEvent({
    required this.row,
    required this.col,
    required this.value,
    required this.points,
  });

  final int row;
  final int col;
  final int value;
  final int points;
}

/// Resultado de um movimento no tabuleiro.
class Game2048MoveResult {
  const Game2048MoveResult({
    required this.grid,
    required this.scoreGained,
    required this.changed,
    required this.merges,
  });

  final List<List<int>> grid;
  final int scoreGained;
  final bool changed;
  final List<Game2048MergeEvent> merges;
}

/// Trajetória visual de uma peça entre duas células.
class Game2048TileMotion {
  const Game2048TileMotion({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    required this.slideValue,
    this.mergedValue,
    this.isSurvivor = true,
  });

  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  /// Valor exibido durante o deslize (antes da fusão visual).
  final int slideValue;
  /// Valor após fusão — só na peça que permanece.
  final int? mergedValue;
  /// `false` na peça absorvida numa fusão.
  final bool isSurvivor;
}

class _LineMotion {
  const _LineMotion({
    required this.fromIndex,
    required this.toIndex,
    required this.slideValue,
    this.mergedValue,
    this.isSurvivor = true,
  });

  final int fromIndex;
  final int toIndex;
  final int slideValue;
  final int? mergedValue;
  final bool isSurvivor;
}

List<_LineMotion> _lineMotions(List<int> line) {
  final entries = <({int index, int value})>[];
  for (var i = 0; i < line.length; i++) {
    if (line[i] > 0) entries.add((index: i, value: line[i]));
  }

  final motions = <_LineMotion>[];
  var dest = 0;
  var i = 0;
  while (i < entries.length) {
    final a = entries[i];
    if (i + 1 < entries.length && entries[i + 1].value == a.value) {
      final b = entries[i + 1];
      final merged = a.value * 2;
      motions.add(
        _LineMotion(
          fromIndex: a.index,
          toIndex: dest,
          slideValue: a.value,
          mergedValue: merged,
        ),
      );
      motions.add(
        _LineMotion(
          fromIndex: b.index,
          toIndex: dest,
          slideValue: b.value,
          mergedValue: merged,
          isSurvivor: false,
        ),
      );
      i += 2;
      dest++;
    } else {
      motions.add(
        _LineMotion(
          fromIndex: a.index,
          toIndex: dest,
          slideValue: a.value,
        ),
      );
      i++;
      dest++;
    }
  }
  return motions;
}

/// Calcula trajetórias visuais para animar um movimento válido.
List<Game2048TileMotion> game2048ComputeMotions(
  List<List<int>> grid,
  Game2048Direction direction,
) {
  final n = Game2048Config.gridSize;
  final motions = <Game2048TileMotion>[];

  switch (direction) {
    case Game2048Direction.left:
      for (var r = 0; r < n; r++) {
        for (final m in _lineMotions(grid[r])) {
          motions.add(
            Game2048TileMotion(
              fromRow: r,
              fromCol: m.fromIndex,
              toRow: r,
              toCol: m.toIndex,
              slideValue: m.slideValue,
              mergedValue: m.mergedValue,
              isSurvivor: m.isSurvivor,
            ),
          );
        }
      }
    case Game2048Direction.right:
      for (var r = 0; r < n; r++) {
        final line = grid[r].reversed.toList();
        for (final m in _lineMotions(line)) {
          motions.add(
            Game2048TileMotion(
              fromRow: r,
              fromCol: n - 1 - m.fromIndex,
              toRow: r,
              toCol: n - 1 - m.toIndex,
              slideValue: m.slideValue,
              mergedValue: m.mergedValue,
              isSurvivor: m.isSurvivor,
            ),
          );
        }
      }
    case Game2048Direction.up:
      for (var c = 0; c < n; c++) {
        final line = [for (var r = 0; r < n; r++) grid[r][c]];
        for (final m in _lineMotions(line)) {
          motions.add(
            Game2048TileMotion(
              fromRow: m.fromIndex,
              fromCol: c,
              toRow: m.toIndex,
              toCol: c,
              slideValue: m.slideValue,
              mergedValue: m.mergedValue,
              isSurvivor: m.isSurvivor,
            ),
          );
        }
      }
    case Game2048Direction.down:
      for (var c = 0; c < n; c++) {
        final line = [for (var r = n - 1; r >= 0; r--) grid[r][c]];
        for (final m in _lineMotions(line)) {
          motions.add(
            Game2048TileMotion(
              fromRow: n - 1 - m.fromIndex,
              fromCol: c,
              toRow: n - 1 - m.toIndex,
              toCol: c,
              slideValue: m.slideValue,
              mergedValue: m.mergedValue,
              isSurvivor: m.isSurvivor,
            ),
          );
        }
      }
  }

  return motions;
}

/// Curva de deslize — desacelera no fim para leitura clara.
double game2048SlideEase(double t) {
  final x = t.clamp(0.0, 1.0);
  return 1 - pow(1 - x, 3).toDouble();
}

List<List<int>> game2048EmptyGrid() => List.generate(
      Game2048Config.gridSize,
      (_) => List.filled(Game2048Config.gridSize, 0),
    );

List<List<int>> game2048CopyGrid(List<List<int>> grid) =>
    grid.map((row) => List<int>.from(row)).toList();

int game2048HighestTile(List<List<int>> grid) {
  var max = 0;
  for (final row in grid) {
    for (final v in row) {
      if (v > max) max = v;
    }
  }
  return max;
}

/// Tabuleiro inicial com duas peças.
List<List<int>> game2048NewGrid(Random random) {
  final grid = game2048EmptyGrid();
  game2048SpawnRandom(grid, random);
  game2048SpawnRandom(grid, random);
  return grid;
}

void game2048SpawnRandom(List<List<int>> grid, Random random) {
  final empties = <(int, int)>[];
  for (var r = 0; r < Game2048Config.gridSize; r++) {
    for (var c = 0; c < Game2048Config.gridSize; c++) {
      if (grid[r][c] == 0) empties.add((r, c));
    }
  }
  if (empties.isEmpty) return;
  final (r, c) = empties[random.nextInt(empties.length)];
  grid[r][c] = random.nextDouble() < 0.9 ? 2 : 4;
}

/// Comprime e funde uma linha para a esquerda; retorna pontos e posições fundidas.
(int score, List<int> line, List<int> mergeCols) _mergeLineLeft(List<int> input) {
  final tiles = <int>[];
  for (final v in input) {
    if (v > 0) tiles.add(v);
  }

  var score = 0;
  final mergedCols = <int>[];
  final out = <int>[];
  var i = 0;
  var outCol = 0;
  while (i < tiles.length) {
    if (i + 1 < tiles.length && tiles[i] == tiles[i + 1]) {
      final merged = tiles[i] * 2;
      out.add(merged);
      score += merged;
      mergedCols.add(outCol);
      i += 2;
    } else {
      out.add(tiles[i]);
      i += 1;
    }
    outCol++;
  }
  while (out.length < Game2048Config.gridSize) {
    out.add(0);
  }
  return (score, out, mergedCols);
}

bool _gridsEqual(List<List<int>> a, List<List<int>> b) {
  for (var r = 0; r < Game2048Config.gridSize; r++) {
    for (var c = 0; c < Game2048Config.gridSize; c++) {
      if (a[r][c] != b[r][c]) return false;
    }
  }
  return true;
}

/// Aplica movimento e devolve novo grid (cópia).
Game2048MoveResult game2048Move(
  List<List<int>> grid,
  Game2048Direction direction,
) {
  final next = game2048CopyGrid(grid);
  var totalScore = 0;
  final merges = <Game2048MergeEvent>[];

  void processRow(int rowIndex, bool reverse) {
    var line = List<int>.from(next[rowIndex]);
    if (reverse) line = line.reversed.toList();
    final (score, mergedLine, mergeCols) = _mergeLineLeft(line);
    totalScore += score;
    if (reverse) {
      final reversed = mergedLine.reversed.toList();
      next[rowIndex] = reversed;
      for (final col in mergeCols) {
        merges.add(
          Game2048MergeEvent(
            row: rowIndex,
            col: Game2048Config.gridSize - 1 - col,
            value: reversed[Game2048Config.gridSize - 1 - col],
            points: reversed[Game2048Config.gridSize - 1 - col],
          ),
        );
      }
    } else {
      next[rowIndex] = mergedLine;
      for (final col in mergeCols) {
        merges.add(
          Game2048MergeEvent(
            row: rowIndex,
            col: col,
            value: mergedLine[col],
            points: mergedLine[col],
          ),
        );
      }
    }
  }

  void processCol(int colIndex, bool reverse) {
    var line = <int>[
      for (var r = 0; r < Game2048Config.gridSize; r++) next[r][colIndex],
    ];
    if (reverse) line = line.reversed.toList();
    final (score, mergedLine, mergeRows) = _mergeLineLeft(line);
    totalScore += score;
    if (reverse) {
      final reversed = mergedLine.reversed.toList();
      for (var r = 0; r < Game2048Config.gridSize; r++) {
        next[r][colIndex] = reversed[r];
      }
      for (final row in mergeRows) {
        final actualRow = Game2048Config.gridSize - 1 - row;
        merges.add(
          Game2048MergeEvent(
            row: actualRow,
            col: colIndex,
            value: next[actualRow][colIndex],
            points: next[actualRow][colIndex],
          ),
        );
      }
    } else {
      for (var r = 0; r < Game2048Config.gridSize; r++) {
        next[r][colIndex] = mergedLine[r];
      }
      for (final row in mergeRows) {
        merges.add(
          Game2048MergeEvent(
            row: row,
            col: colIndex,
            value: mergedLine[row],
            points: mergedLine[row],
          ),
        );
      }
    }
  }

  switch (direction) {
    case Game2048Direction.left:
      for (var r = 0; r < Game2048Config.gridSize; r++) {
        processRow(r, false);
      }
    case Game2048Direction.right:
      for (var r = 0; r < Game2048Config.gridSize; r++) {
        processRow(r, true);
      }
    case Game2048Direction.up:
      for (var c = 0; c < Game2048Config.gridSize; c++) {
        processCol(c, false);
      }
    case Game2048Direction.down:
      for (var c = 0; c < Game2048Config.gridSize; c++) {
        processCol(c, true);
      }
  }

  final changed = !_gridsEqual(grid, next);
  return Game2048MoveResult(
    grid: next,
    scoreGained: changed ? totalScore : 0,
    changed: changed,
    merges: changed ? merges : const [],
  );
}

bool game2048CanMove(List<List<int>> grid) {
  for (final dir in Game2048Direction.values) {
    if (game2048Move(grid, dir).changed) return true;
  }
  return false;
}

bool game2048ReachedTarget(List<List<int>> grid, int targetTile) =>
    game2048HighestTile(grid) >= targetTile;

/// Placar ao vivo = soma das fusões.
int game2048ProgressScore(int mergeScore) =>
    mergeScore.clamp(0, Game2048Config.maxScore);

int game2048TileBonus(int highestTile) {
  if (highestTile < Game2048Config.tileBonusStart) return 0;
  final steps = (log(highestTile) / log(2)).round() -
      (log(Game2048Config.tileBonusStart) / log(2)).round();
  return (steps * Game2048Config.tileBonusPerStep)
      .clamp(0, Game2048Config.tileBonusMax);
}

int game2048FinalScore({
  required int mergeScore,
  required int highestTile,
}) {
  final bonus = game2048TileBonus(highestTile);
  return (mergeScore + bonus).clamp(0, Game2048Config.maxScore);
}

String game2048FormatTile(int value) => value >= 1024 ? '$value' : '$value';

/// Nota do HUD à direita — dica inicial ou preview de bônus.
String? game2048HudRightFootnote({
  required int moves,
  required int bonusPreview,
}) {
  if (bonusPreview > 0) return '+$bonusPreview bônus';
  if (moves == 0) return 'Deslize p/ jogar';
  return null;
}

/// Cores das peças (estilo 2048 clássico, adaptadas ao hub).
(Color bg, Color fg) game2048TileColors(int value) {
  return switch (value) {
    0 => (Game2048Config.cellEmpty, Game2048Config.hudMuted),
    2 => (const Color(0xFFEEE4DA), const Color(0xFF776E65)),
    4 => (const Color(0xFFEDE0C8), const Color(0xFF776E65)),
    8 => (const Color(0xFFF2B179), Colors.white),
    16 => (const Color(0xFFF59563), Colors.white),
    32 => (const Color(0xFFF67C5F), Colors.white),
    64 => (const Color(0xFFF65E3B), Colors.white),
    128 => (const Color(0xFFEDCF72), const Color(0xFFF9F6F2)),
    256 => (const Color(0xFFEDCC61), const Color(0xFFF9F6F2)),
    512 => (const Color(0xFFEDC850), const Color(0xFFF9F6F2)),
    1024 => (const Color(0xFFEDC53F), const Color(0xFFF9F6F2)),
    2048 => (Game2048Config.accentColor, const Color(0xFF776E65)),
    _ => (Game2048Config.cardColor, Colors.white),
  };
}

double game2048TileFontSize(int value, double cellSize) {
  if (value >= 1024) return cellSize * 0.28;
  if (value >= 128) return cellSize * 0.34;
  return cellSize * 0.40;
}

Game2048Direction? game2048DirectionFromDelta(double dx, double dy) {
  if (dx.abs() < Game2048Config.swipeThresholdPx &&
      dy.abs() < Game2048Config.swipeThresholdPx) {
    return null;
  }
  if (dx.abs() > dy.abs()) {
    return dx > 0 ? Game2048Direction.right : Game2048Direction.left;
  }
  return dy > 0 ? Game2048Direction.down : Game2048Direction.up;
}
