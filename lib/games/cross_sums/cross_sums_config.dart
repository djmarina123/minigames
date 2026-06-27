import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/economy/economy_config.dart';
import '../../core/economy/performance_tier.dart';
import '../../core/l10n/l10n_scope.dart';

/// Constantes, paleta e regras puras do Cross Sums.
abstract final class CrossSumsConfig {
  static const optionKeyDifficulty = 'difficulty';

  static const pointsPerCell = 15;
  static const mistakePenalty = 18;
  static const winBonus = 450;
  static const perfectBonus = 120;

  static const timeBonusMax = 280;
  static const timeBonusPerSecond = 2;

  static const maxScore = 99999;
  static const maxMistakes = 5;

  static const shakeSec = 0.28;
  static const flashSec = 0.22;
  static const pulseSec = 0.16;

  /// Paleta inspirada no jogo de referência (azul claro + teal).
  static const cardColor = Color(0xFF1291B5);
  static const accentColor = Color(0xFFF9A825);
  static const blendColor = Color(0xFF7EC8E3);
  static const accentSoft = Color(0xFFB3D9EE);
  static const bgTop = Color(0xFFE6F2F8);
  static const bgBottom = Color(0xFFD4EAF5);
  static const headerCellBg = Color(0xFFB3D9EE);
  static const headerCellMatch = Color(0xFF7FDEC8);
  static const headerCellOver = Color(0xFFFFB4B4);
  static const cornerBg = Color(0xFFE6F2F8);
  static const cellBg = Colors.white;
  static const cellRemovedBg = Color(0xFFF5F9FC);
  static const cellHighlight = Color(0xFFE8F4FA);
  static const cellSelected = Color(0xFFD4EBF7);
  static const cellText = Color(0xFF2D3436);
  static const cellRemovedText = Color(0xFF95A5A6);
  static const gridLine = Color(0xFFD5E8F2);
  static const hudText = Color(0xFF6A3D6A);
  static const hudMuted = Color(0xFF7F8C8D);
  static const badgeBg = Color(0xFF95A5A6);
  static const badgeText = Colors.white;
  static const missRed = Color(0xFFE74C3C);
  static const heartColor = Color(0xFFE74C3C);
  static const successGlow = Color(0xFF1ABC9C);
  static const hintPink = Color(0xFFE91E63);
  static const toolTrack = Color(0xFFB3D9EE);
  static const toolActive = Colors.white;

  static const layoutMarginH = 16.0;
  static const layoutBottomMargin = 12.0;
  static const layoutStatsHeight = 50.0;
  static const layoutTitleHeight = 54.0;
  static const layoutHeaderHeight = layoutStatsHeight + layoutTitleHeight;
  static const layoutHudGap = 10.0;
  static const layoutToolGap = 14.0;
  static const layoutToolHeight = 52.0;
  static const layoutHintSize = 52.0;
}

enum CrossSumsDifficulty { easy, medium, hard }

enum CrossSumsTool { eraser, pencil }

CrossSumsDifficulty crossSumsDifficultyFromValue(String value) =>
    switch (value) {
      'medium' => CrossSumsDifficulty.medium,
      'hard' => CrossSumsDifficulty.hard,
      _ => CrossSumsDifficulty.easy,
    };

int crossSumsGridSize(CrossSumsDifficulty difficulty) => switch (difficulty) {
      CrossSumsDifficulty.easy => 4,
      CrossSumsDifficulty.medium => 5,
      CrossSumsDifficulty.hard => 6,
    };

String crossSumsDifficultyLabel(CrossSumsDifficulty difficulty) =>
    switch (difficulty) {
      CrossSumsDifficulty.easy => L10nScope.of.difficultyEasy,
      CrossSumsDifficulty.medium => L10nScope.of.difficultyMedium,
      CrossSumsDifficulty.hard => L10nScope.of.difficultyHard,
    };

class CrossSumsBoardLayout {
  const CrossSumsBoardLayout({
    required this.gridSize,
    required this.boardLeft,
    required this.boardTop,
    required this.cellSize,
    required this.toolTop,
    required this.toolToggleRect,
    required this.eraserKnobRect,
    required this.pencilKnobRect,
    required this.hintRect,
  });

  final int gridSize;
  final double boardLeft;
  final double boardTop;
  final double cellSize;
  final double toolTop;
  final Rect toolToggleRect;
  final Rect eraserKnobRect;
  final Rect pencilKnobRect;
  final Rect hintRect;

  double get boardExtent => cellSize * (gridSize + 1);

  Rect cellRect(int boardRow, int boardCol) => Rect.fromLTWH(
        boardLeft + boardCol * cellSize,
        boardTop + boardRow * cellSize,
        cellSize,
        cellSize,
      );

  /// Converte coordenada do tabuleiro (0..gridSize) em índice da célula jogável.
  (int row, int col)? playableAt(int boardRow, int boardCol) {
    if (boardRow == 0 || boardCol == 0) return null;
    final row = boardRow - 1;
    final col = boardCol - 1;
    if (row < 0 || col < 0 || row >= gridSize || col >= gridSize) return null;
    return (row, col);
  }
}

CrossSumsBoardLayout crossSumsBoardLayout({
  required int gridSize,
  required double screenW,
  required double screenH,
}) {
  const marginH = CrossSumsConfig.layoutMarginH;
  const headerH = CrossSumsConfig.layoutHeaderHeight;
  const hudGap = CrossSumsConfig.layoutHudGap;
  const toolGap = CrossSumsConfig.layoutToolGap;
  const toolH = CrossSumsConfig.layoutToolHeight;
  const hintSize = CrossSumsConfig.layoutHintSize;
  const bottomMargin = CrossSumsConfig.layoutBottomMargin;

  final availW = screenW - marginH * 2;
  final availH = screenH -
      headerH -
      hudGap -
      toolGap -
      toolH -
      bottomMargin;

  final extent = gridSize + 1;
  final cellSize = min(availW / extent, availH / extent).clamp(34.0, 58.0);
  final boardExtent = cellSize * extent;
  final boardLeft = (screenW - boardExtent) / 2;
  final boardTop = headerH + hudGap;
  final toolTop = boardTop + boardExtent + toolGap;

  final toggleW = min(boardExtent * 0.55, 180.0);
  final toggleLeft = boardLeft + (boardExtent - toggleW - hintSize - 12) / 2;
  final toolToggleRect = Rect.fromLTWH(toggleLeft, toolTop, toggleW, toolH);
  final knobSize = toolH - 8;
  final eraserKnobRect = Rect.fromLTWH(
    toolToggleRect.left + 4,
    toolToggleRect.top + 4,
    knobSize,
    knobSize,
  );
  final pencilKnobRect = Rect.fromLTWH(
    toolToggleRect.right - knobSize - 4,
    toolToggleRect.top + 4,
    knobSize,
    knobSize,
  );
  final hintRect = Rect.fromLTWH(
    toolToggleRect.right + 12,
    toolTop,
    hintSize,
    hintSize,
  );

  return CrossSumsBoardLayout(
    gridSize: gridSize,
    boardLeft: boardLeft,
    boardTop: boardTop,
    cellSize: cellSize,
    toolTop: toolTop,
    toolToggleRect: toolToggleRect,
    eraserKnobRect: eraserKnobRect,
    pencilKnobRect: pencilKnobRect,
    hintRect: hintRect,
  );
}

class CrossSumsToggleResult {
  const CrossSumsToggleResult({
    required this.state,
    required this.scoreDelta,
    required this.correct,
    required this.won,
    required this.mistake,
  });

  final CrossSumsState state;
  final int scoreDelta;
  final bool correct;
  final bool won;
  final bool mistake;
}

class CrossSumsHintResult {
  const CrossSumsHintResult({
    required this.state,
    required this.row,
    required this.col,
    required this.kept,
  });

  final CrossSumsState state;
  final int row;
  final int col;
  final bool kept;
}

class CrossSumsState {
  CrossSumsState({
    required this.size,
    required this.rowTargets,
    required this.colTargets,
    required this.values,
    required this.kept,
    required this.solution,
    required this.difficulty,
    required this.puzzleNumber,
    this.moves = 0,
    this.mistakes = 0,
    this.hintsUsed = 0,
    this.score = 0,
    Set<String>? scoredCells,
  }) : scoredCells = scoredCells ?? <String>{};

  final int size;
  final List<int> rowTargets;
  final List<int> colTargets;
  final List<List<int>> values;
  final List<List<bool>> kept;
  final List<List<bool>> solution;
  final CrossSumsDifficulty difficulty;
  final int puzzleNumber;
  final int moves;
  final int mistakes;
  final int hintsUsed;
  final int score;
  final Set<String> scoredCells;

  int get totalCells => size * size;

  int correctCount() {
    var count = 0;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (kept[r][c] == solution[r][c]) count++;
      }
    }
    return count;
  }
}

String crossSumsCellKey(int row, int col) => '${row}_$col';

List<List<bool>> crossSumsCopyBoolGrid(List<List<bool>> grid) =>
    grid.map((row) => List<bool>.from(row)).toList();

int crossSumsRowSum(CrossSumsState state, int row) {
  var sum = 0;
  for (var c = 0; c < state.size; c++) {
    if (state.kept[row][c]) sum += state.values[row][c];
  }
  return sum;
}

int crossSumsColSum(CrossSumsState state, int col) {
  var sum = 0;
  for (var r = 0; r < state.size; r++) {
    if (state.kept[r][col]) sum += state.values[r][col];
  }
  return sum;
}

CrossSumsState _cloneState(
  CrossSumsState state, {
  List<List<bool>>? kept,
  int? moves,
  int? mistakes,
  int? hintsUsed,
  int? score,
  Set<String>? scoredCells,
}) {
  return CrossSumsState(
    size: state.size,
    rowTargets: state.rowTargets,
    colTargets: state.colTargets,
    values: state.values,
    kept: kept ?? crossSumsCopyBoolGrid(state.kept),
    solution: state.solution,
    difficulty: state.difficulty,
    puzzleNumber: state.puzzleNumber,
    moves: moves ?? state.moves,
    mistakes: mistakes ?? state.mistakes,
    hintsUsed: hintsUsed ?? state.hintsUsed,
    score: score ?? state.score,
    scoredCells: scoredCells ?? Set<String>.from(state.scoredCells),
  );
}

List<List<bool>> _generateSolutionMask(int size, Random random) {
  for (var attempt = 0; attempt < 64; attempt++) {
    final mask = List.generate(size, (_) => List.filled(size, false));

    for (var r = 0; r < size; r++) {
      mask[r][random.nextInt(size)] = true;
    }
    for (var c = 0; c < size; c++) {
      var has = false;
      for (var r = 0; r < size; r++) {
        if (mask[r][c]) has = true;
      }
      if (!has) mask[random.nextInt(size)][c] = true;
    }

    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (!mask[r][c] && random.nextDouble() < 0.22) {
          mask[r][c] = true;
        }
      }
    }

    var keptCount = 0;
    for (final row in mask) {
      keptCount += row.where((v) => v).length;
    }
    if (keptCount >= size + 2 && keptCount <= size * 2) {
      return mask;
    }
  }

  final fallback = List.generate(size, (_) => List.filled(size, false));
  for (var i = 0; i < size; i++) {
    fallback[i][i] = true;
  }
  return fallback;
}

CrossSumsState crossSumsNewGame(
  Random random, {
  CrossSumsDifficulty difficulty = CrossSumsDifficulty.easy,
}) {
  final size = crossSumsGridSize(difficulty);
  final solution = _generateSolutionMask(size, random);
  final values = List.generate(size, (_) => List.filled(size, 0));

  for (var r = 0; r < size; r++) {
    for (var c = 0; c < size; c++) {
      values[r][c] = solution[r][c]
          ? 1 + random.nextInt(9)
          : 1 + random.nextInt(9);
    }
  }

  final rowTargets = List.generate(size, (r) {
    var sum = 0;
    for (var c = 0; c < size; c++) {
      if (solution[r][c]) sum += values[r][c];
    }
    return sum;
  });

  final colTargets = List.generate(size, (c) {
    var sum = 0;
    for (var r = 0; r < size; r++) {
      if (solution[r][c]) sum += values[r][c];
    }
    return sum;
  });

  final kept = List.generate(size, (_) => List.filled(size, true));

  return CrossSumsState(
    size: size,
    rowTargets: rowTargets,
    colTargets: colTargets,
    values: values,
    kept: kept,
    solution: solution,
    difficulty: difficulty,
    puzzleNumber: 1 + random.nextInt(99),
  );
}

CrossSumsToggleResult? crossSumsTryToggle(
  CrossSumsState state,
  int row,
  int col,
  CrossSumsTool tool,
) {
  if (row < 0 || col < 0 || row >= state.size || col >= state.size) {
    return null;
  }

  final nextKept = tool == CrossSumsTool.pencil;
  if (state.kept[row][col] == nextKept) return null;

  final nextGrid = crossSumsCopyBoolGrid(state.kept);
  nextGrid[row][col] = nextKept;

  final correct = nextKept == state.solution[row][col];
  final cellKey = crossSumsCellKey(row, col);
  var scoreDelta = 0;
  var mistakes = state.mistakes;
  var mistake = false;
  final scoredCells = Set<String>.from(state.scoredCells);

  if (correct) {
    if (!scoredCells.contains(cellKey)) {
      scoreDelta = CrossSumsConfig.pointsPerCell;
      scoredCells.add(cellKey);
    }
  } else {
    scoreDelta = -CrossSumsConfig.mistakePenalty;
    mistakes++;
    mistake = true;
  }

  final next = _cloneState(
    state,
    kept: nextGrid,
    moves: state.moves + 1,
    mistakes: mistakes,
    score: (state.score + scoreDelta).clamp(0, CrossSumsConfig.maxScore),
    scoredCells: scoredCells,
  );

  return CrossSumsToggleResult(
    state: next,
    scoreDelta: scoreDelta,
    correct: correct,
    won: correct && crossSumsIsSolved(next),
    mistake: mistake,
  );
}

CrossSumsHintResult? crossSumsHintPaid(CrossSumsState state) {
  for (var r = 0; r < state.size; r++) {
    for (var c = 0; c < state.size; c++) {
      if (state.kept[r][c] != state.solution[r][c]) {
        final nextGrid = crossSumsCopyBoolGrid(state.kept);
        nextGrid[r][c] = state.solution[r][c];
        return CrossSumsHintResult(
          state: _cloneState(
            state,
            kept: nextGrid,
            hintsUsed: state.hintsUsed + 1,
            moves: state.moves + 1,
          ),
          row: r,
          col: c,
          kept: state.solution[r][c],
        );
      }
    }
  }
  return null;
}

int get crossSumsHintCoinCost => EconomyConfig.hintCoinCostCrossSums;

bool crossSumsIsSolved(CrossSumsState state) {
  for (var r = 0; r < state.size; r++) {
    for (var c = 0; c < state.size; c++) {
      if (state.kept[r][c] != state.solution[r][c]) return false;
    }
  }
  return true;
}

bool crossSumsIsGameOver(CrossSumsState state) =>
    state.mistakes >= CrossSumsConfig.maxMistakes;

int crossSumsProgressScore(CrossSumsState state) =>
    state.score.clamp(0, CrossSumsConfig.maxScore);

int crossSumsTimeBonusRemaining(Duration elapsed) {
  final sec = elapsed.inSeconds;
  return (CrossSumsConfig.timeBonusMax -
          sec * CrossSumsConfig.timeBonusPerSecond)
      .clamp(0, CrossSumsConfig.timeBonusMax);
}

int crossSumsFinalScore({
  required CrossSumsState state,
  required Duration duration,
  required bool won,
}) {
  var total = state.score;
  if (won) {
    total += CrossSumsConfig.winBonus;
    if (state.mistakes == 0 && state.hintsUsed == 0) {
      total += CrossSumsConfig.perfectBonus;
    }
    total += crossSumsTimeBonusRemaining(duration);
  }
  return total.clamp(0, CrossSumsConfig.maxScore);
}

String crossSumsHudTimeBonusLabel(int bonus) =>
    bonus > 0
        ? L10nScope.of.hudTimeBonus(bonus)
        : L10nScope.of.hudNoTimeBonus;

String crossSumsHudElapsedLabel(Duration elapsed) {
  final m = elapsed.inMinutes;
  final s = elapsed.inSeconds.remainder(60);
  return '$m:${s.toString().padLeft(2, '0')}';
}

String crossSumsHudProgressLabel(CrossSumsState state) =>
    '${state.correctCount()}/${state.totalCells}';

double crossSumsCellFontSize(double cellSize) => cellSize * 0.42;

double crossSumsHeaderFontSize(double cellSize) => cellSize * 0.38;

double crossSumsPerformanceRatio({
  required bool won,
  required int mistakes,
  required int hintsUsed,
}) {
  if (!won) return 0;
  var ratio = 0.65;
  if (mistakes == 0 && hintsUsed == 0) ratio += 0.20;
  ratio -= mistakes * 0.05;
  ratio -= hintsUsed * 0.07;
  return ratio.clamp(0.0, 1.0);
}

PerformanceTier crossSumsPerformanceTier({
  required bool won,
  required int mistakes,
  required int hintsUsed,
}) =>
    tierFromRatio(crossSumsPerformanceRatio(
      won: won,
      mistakes: mistakes,
      hintsUsed: hintsUsed,
    ));
