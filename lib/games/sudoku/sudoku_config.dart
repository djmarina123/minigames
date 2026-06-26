import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/economy/economy_config.dart';
import '../../core/economy/performance_tier.dart';
import '../../core/game_sdk/game_session_hud_actions.dart';
import '../../core/l10n/l10n_scope.dart';

/// Constantes, paleta e regras puras do Sudoku.
abstract final class SudokuConfig {
  static const gridSize = 9;
  static const boxSize = 3;
  static const optionKeyDifficulty = 'difficulty';

  static const pointsPerCell = 12;
  static const mistakePenalty = 15;
  static const hintPenalty = 30;
  static const winBonus = 500;
  static const perfectBonus = 100;

  static const timeBonusMax = 300;
  static const timeBonusPerSecond = 2;

  static const maxScore = 99999;
  static const maxMistakes = 5;

  static const shakeSec = 0.28;
  static const flashSec = 0.22;
  static const pulseSec = 0.16;

  /// Paleta alinhada ao card do hub (`HubTheme` id `sudoku`).
  static const cardColor = Color(0xFF4834D4);
  static const accentColor = Color(0xFFF9CA24);
  static const blendColor = Color(0xFF7B6FE8);
  static const accentSoft = Color(0xFFFFE58A);
  static const bgTop = Color(0xFF3D2DB8);
  static const bgBottom = Color(0xFF2A1F7A);
  static const boardBg = Color(0xFFF0EDFF);
  static const cellGiven = Color(0xFF2D3436);
  static const cellPlayer = Color(0xFF4834D4);
  static const cellHighlight = Color(0xFFE8E4FF);
  static const cellSelected = Color(0xFFD4CCFF);
  static const cellConflict = Color(0xFFFFE0E0);
  static const gridLine = Color(0xFFB2BEC3);
  static const gridLineBold = Color(0xFF636E72);
  static const hudText = Color(0xFFF8F9FA);
  static const hudMuted = Color(0xFFC8C0F5);
  static const missRed = Color(0xFFFF7675);
  static const successGlow = Color(0xFFF9CA24);

  static const layoutMarginH = 12.0;
  static const layoutBottomMargin = 10.0;
  static const layoutHudGap = 8.0;
  static const layoutPadGap = 8.0;
  static const layoutHudHeight = GameSessionHudActionBar.reservedHeight;
  static const layoutNumPadCols = 3;
  static const layoutNumPadKeyGap = 6.0;
  static const layoutNumPadRowGap = 6.0;
  static const layoutNumPadKeyRowH = 36.0;

  /// Altura total do bloco pinpad (3 linhas de dígitos; apagar fica no HUD).
  static const layoutNumPadHeight =
      layoutNumPadKeyRowH * 3 + layoutNumPadRowGap * 2;
}

/// Índice 0–8 → dígito 1–9 no layout de pinpad (linhas 1–2–3 / 4–5–6 / 7–8–9).
int sudokuNumPadDigitForIndex(int index) => index + 1;

/// Posição (linha, coluna) do dígito no pinpad 3×3.
(int row, int col) sudokuNumPadPositionForDigit(int digit) {
  assert(digit >= 1 && digit <= 9);
  final i = digit - 1;
  return (i ~/ SudokuConfig.layoutNumPadCols, i % SudokuConfig.layoutNumPadCols);
}

enum SudokuDifficulty { easy, medium, hard }

int sudokuClueCount(SudokuDifficulty difficulty) => switch (difficulty) {
      SudokuDifficulty.easy => 42,
      SudokuDifficulty.medium => 32,
      SudokuDifficulty.hard => 26,
    };

SudokuDifficulty sudokuDifficultyFromValue(String value) => switch (value) {
      'medium' => SudokuDifficulty.medium,
      'hard' => SudokuDifficulty.hard,
      _ => SudokuDifficulty.easy,
    };

String sudokuDifficultyLabel(SudokuDifficulty difficulty) => switch (difficulty) {
      SudokuDifficulty.easy => L10nScope.of.difficultyEasy,
      SudokuDifficulty.medium => L10nScope.of.difficultyMedium,
      SudokuDifficulty.hard => L10nScope.of.difficultyHard,
    };

class SudokuBoardLayout {
  const SudokuBoardLayout({
    required this.boardSize,
    required this.boardLeft,
    required this.boardTop,
    required this.cellSize,
    required this.numPadTop,
    required this.numPadWidth,
    required this.numPadKeyFontSize,
    required this.numPadRects,
  });

  final double boardSize;
  final double boardLeft;
  final double boardTop;
  final double cellSize;
  final double numPadTop;
  final double numPadWidth;
  final double numPadKeyFontSize;
  final List<Rect> numPadRects;
}

SudokuBoardLayout sudokuBoardLayout({
  required double screenW,
  required double screenH,
}) {
  const marginH = SudokuConfig.layoutMarginH;
  const hudHeight = SudokuConfig.layoutHudHeight;
  const hudGap = SudokuConfig.layoutHudGap;
  const padGap = SudokuConfig.layoutPadGap;
  const padBlockH = SudokuConfig.layoutNumPadHeight;
  const keyGap = SudokuConfig.layoutNumPadKeyGap;
  const rowGap = SudokuConfig.layoutNumPadRowGap;
  const keyRowH = SudokuConfig.layoutNumPadKeyRowH;
  const cols = SudokuConfig.layoutNumPadCols;
  const bottomMargin = SudokuConfig.layoutBottomMargin;

  final availW = screenW - marginH * 2;
  final availH =
      screenH - hudHeight - hudGap - padGap - padBlockH - bottomMargin;

  var boardSize = min(availW, availH);
  boardSize = boardSize.clamp(200.0, availW);

  final boardLeft = (screenW - boardSize) / 2;
  final boardTop = hudHeight + hudGap;
  final cellSize = boardSize / SudokuConfig.gridSize;

  final numPadTop = boardTop + boardSize + padGap;
  final numPadWidth = boardSize;
  final numPadLeft = boardLeft;
  final keyW = (numPadWidth - keyGap * (cols - 1)) / cols;

  final numPadRects = <Rect>[];
  for (var digit = 1; digit <= 9; digit++) {
    final (row, col) = sudokuNumPadPositionForDigit(digit);
    numPadRects.add(
      Rect.fromLTWH(
        numPadLeft + col * (keyW + keyGap),
        numPadTop + row * (keyRowH + rowGap),
        keyW,
        keyRowH,
      ),
    );
  }

  return SudokuBoardLayout(
    boardSize: boardSize,
    boardLeft: boardLeft,
    boardTop: boardTop,
    cellSize: cellSize,
    numPadTop: numPadTop,
    numPadWidth: numPadWidth,
    numPadKeyFontSize: keyRowH * 0.48,
    numPadRects: numPadRects,
  );
}

class SudokuPlaceResult {
  const SudokuPlaceResult({
    required this.state,
    required this.scoreDelta,
    required this.correct,
    required this.won,
    required this.mistake,
  });

  final SudokuState state;
  final int scoreDelta;
  final bool correct;
  final bool won;
  final bool mistake;
}

class SudokuHintResult {
  const SudokuHintResult({
    required this.state,
    required this.row,
    required this.col,
    required this.value,
  });

  final SudokuState state;
  final int row;
  final int col;
  final int value;
}

class SudokuState {
  SudokuState({
    required this.solution,
    required this.givens,
    required this.player,
    required this.difficulty,
    this.moves = 0,
    this.mistakes = 0,
    this.hintsUsed = 0,
    this.score = 0,
    Set<String>? scoredCells,
  }) : scoredCells = scoredCells ?? <String>{};

  final List<List<int>> solution;
  final List<List<bool>> givens;
  final List<List<int>> player;
  final SudokuDifficulty difficulty;
  final int moves;
  final int mistakes;
  final int hintsUsed;
  final int score;

  /// Células que já renderam pontos de acerto nesta partida (mesmo após apagar).
  final Set<String> scoredCells;

  int get totalCells => SudokuConfig.gridSize * SudokuConfig.gridSize;

  int filledCount() {
    var count = 0;
    for (var r = 0; r < SudokuConfig.gridSize; r++) {
      for (var c = 0; c < SudokuConfig.gridSize; c++) {
        if (displayValue(r, c) > 0) count++;
      }
    }
    return count;
  }

  int playerFilledCount() {
    var count = 0;
    for (var r = 0; r < SudokuConfig.gridSize; r++) {
      for (var c = 0; c < SudokuConfig.gridSize; c++) {
        if (!givens[r][c] && player[r][c] > 0) count++;
      }
    }
    return count;
  }

  int emptyCount() => totalCells - filledCount();

  int displayValue(int row, int col) =>
      givens[row][col] ? solution[row][col] : player[row][col];

  bool isComplete() {
    for (var r = 0; r < SudokuConfig.gridSize; r++) {
      for (var c = 0; c < SudokuConfig.gridSize; c++) {
        if (displayValue(r, c) == 0) return false;
      }
    }
    return true;
  }
}

List<List<int>> sudokuEmptyGrid() => List.generate(
      SudokuConfig.gridSize,
      (_) => List.filled(SudokuConfig.gridSize, 0),
    );

List<List<bool>> sudokuEmptyGivens() => List.generate(
      SudokuConfig.gridSize,
      (_) => List.filled(SudokuConfig.gridSize, false),
    );

List<List<int>> sudokuCopyGrid(List<List<int>> grid) =>
    grid.map((row) => List<int>.from(row)).toList();

List<List<bool>> sudokuCopyGivens(List<List<bool>> givens) =>
    givens.map((row) => List<bool>.from(row)).toList();

String sudokuCellKey(int row, int col) => '${row}_$col';

bool sudokuIsValidInGrid(List<List<int>> grid, int row, int col, int value) {
  for (var c = 0; c < SudokuConfig.gridSize; c++) {
    if (c != col && grid[row][c] == value) return false;
  }
  for (var r = 0; r < SudokuConfig.gridSize; r++) {
    if (r != row && grid[r][col] == value) return false;
  }
  final boxRow = (row ~/ SudokuConfig.boxSize) * SudokuConfig.boxSize;
  final boxCol = (col ~/ SudokuConfig.boxSize) * SudokuConfig.boxSize;
  for (var r = boxRow; r < boxRow + SudokuConfig.boxSize; r++) {
    for (var c = boxCol; c < boxCol + SudokuConfig.boxSize; c++) {
      if ((r != row || c != col) && grid[r][c] == value) return false;
    }
  }
  return true;
}

List<List<bool>> sudokuConflictMask(SudokuState state) {
  final mask = sudokuEmptyGivens();
  for (var r = 0; r < SudokuConfig.gridSize; r++) {
    for (var c = 0; c < SudokuConfig.gridSize; c++) {
      final value = state.displayValue(r, c);
      if (value == 0) continue;
      if (!sudokuIsValidInGrid(_displayGrid(state), r, c, value)) {
        mask[r][c] = true;
      }
    }
  }
  return mask;
}

List<List<int>> _displayGrid(SudokuState state) {
  final grid = sudokuEmptyGrid();
  for (var r = 0; r < SudokuConfig.gridSize; r++) {
    for (var c = 0; c < SudokuConfig.gridSize; c++) {
      grid[r][c] = state.displayValue(r, c);
    }
  }
  return grid;
}

bool _solveGrid(List<List<int>> grid, Random random) {
  for (var r = 0; r < SudokuConfig.gridSize; r++) {
    for (var c = 0; c < SudokuConfig.gridSize; c++) {
      if (grid[r][c] != 0) continue;
      final nums = List.generate(9, (i) => i + 1)..shuffle(random);
      for (final n in nums) {
        if (!sudokuIsValidInGrid(grid, r, c, n)) continue;
        grid[r][c] = n;
        if (_solveGrid(grid, random)) return true;
        grid[r][c] = 0;
      }
      return false;
    }
  }
  return true;
}

void _fillDiagonalBoxes(List<List<int>> grid, Random random) {
  for (var box = 0; box < SudokuConfig.gridSize; box += SudokuConfig.boxSize) {
    final nums = List.generate(9, (i) => i + 1)..shuffle(random);
    var i = 0;
    for (var r = 0; r < SudokuConfig.boxSize; r++) {
      for (var c = 0; c < SudokuConfig.boxSize; c++) {
        grid[box + r][box + c] = nums[i++];
      }
    }
  }
}

List<List<int>> sudokuGenerateSolution(Random random) {
  final grid = sudokuEmptyGrid();
  _fillDiagonalBoxes(grid, random);
  _solveGrid(grid, random);
  return grid;
}

SudokuState sudokuNewGame(Random random, {SudokuDifficulty difficulty = SudokuDifficulty.easy}) {
  final solution = sudokuGenerateSolution(random);
  final clues = sudokuClueCount(difficulty);
  final givens = sudokuEmptyGivens();
  final player = sudokuEmptyGrid();

  final positions = <(int, int)>[];
  for (var r = 0; r < SudokuConfig.gridSize; r++) {
    for (var c = 0; c < SudokuConfig.gridSize; c++) {
      positions.add((r, c));
    }
  }
  positions.shuffle(random);

  for (var i = 0; i < clues; i++) {
    final (r, c) = positions[i];
    givens[r][c] = true;
  }

  return SudokuState(
    solution: solution,
    givens: givens,
    player: player,
    difficulty: difficulty,
  );
}

SudokuState _cloneState(SudokuState state, {
  List<List<int>>? player,
  int? moves,
  int? mistakes,
  int? hintsUsed,
  int? score,
  Set<String>? scoredCells,
}) {
  return SudokuState(
    solution: state.solution,
    givens: state.givens,
    player: player ?? sudokuCopyGrid(state.player),
    difficulty: state.difficulty,
    moves: moves ?? state.moves,
    mistakes: mistakes ?? state.mistakes,
    hintsUsed: hintsUsed ?? state.hintsUsed,
    score: score ?? state.score,
    scoredCells: scoredCells ?? Set<String>.from(state.scoredCells),
  );
}

bool sudokuCanEditCell(SudokuState state, int row, int col) =>
    !state.givens[row][col];

SudokuPlaceResult? sudokuTryPlace(
  SudokuState state,
  int row,
  int col,
  int value,
) {
  if (!sudokuCanEditCell(state, row, col)) return null;
  if (value < 1 || value > 9) return null;
  if (state.player[row][col] == value) return null;

  final nextPlayer = sudokuCopyGrid(state.player);
  nextPlayer[row][col] = value;

  final correct = value == state.solution[row][col];
  final cellKey = sudokuCellKey(row, col);
  var scoreDelta = 0;
  var mistakes = state.mistakes;
  var mistake = false;
  final scoredCells = Set<String>.from(state.scoredCells);

  if (correct) {
    if (!scoredCells.contains(cellKey)) {
      scoreDelta = SudokuConfig.pointsPerCell;
      scoredCells.add(cellKey);
    }
  } else {
    scoreDelta = -SudokuConfig.mistakePenalty;
    mistakes++;
    mistake = true;
  }

  final next = _cloneState(
    state,
    player: nextPlayer,
    moves: state.moves + 1,
    mistakes: mistakes,
    score: (state.score + scoreDelta).clamp(0, SudokuConfig.maxScore),
    scoredCells: scoredCells,
  );

  final won = correct && sudokuIsSolved(next);

  return SudokuPlaceResult(
    state: next,
    scoreDelta: scoreDelta,
    correct: correct,
    won: won,
    mistake: mistake,
  );
}

SudokuPlaceResult? sudokuTryErase(SudokuState state, int row, int col) {
  if (!sudokuCanEditCell(state, row, col)) return null;
  if (state.player[row][col] == 0) return null;

  final nextPlayer = sudokuCopyGrid(state.player);
  nextPlayer[row][col] = 0;

  return SudokuPlaceResult(
    state: _cloneState(
      state,
      player: nextPlayer,
      moves: state.moves + 1,
    ),
    scoreDelta: 0,
    correct: true,
    won: false,
    mistake: false,
  );
}

SudokuHintResult? sudokuHint(SudokuState state) {
  final empties = <(int, int)>[];
  for (var r = 0; r < SudokuConfig.gridSize; r++) {
    for (var c = 0; c < SudokuConfig.gridSize; c++) {
      if (!state.givens[r][c] && state.player[r][c] == 0) {
        empties.add((r, c));
      }
    }
  }
  if (empties.isEmpty) return null;

  final (row, col) = empties.first;
  final value = state.solution[row][col];
  final nextPlayer = sudokuCopyGrid(state.player);
  nextPlayer[row][col] = value;

  final next = _cloneState(
    state,
    player: nextPlayer,
    hintsUsed: state.hintsUsed + 1,
    moves: state.moves + 1,
    score: (state.score - SudokuConfig.hintPenalty)
        .clamp(0, SudokuConfig.maxScore),
  );

  return SudokuHintResult(
    state: next,
    row: row,
    col: col,
    value: value,
  );
}

/// Dica paga com moedas — sem penalidade de pontuação.
SudokuHintResult? sudokuHintPaid(SudokuState state) {
  final empties = <(int, int)>[];
  for (var r = 0; r < SudokuConfig.gridSize; r++) {
    for (var c = 0; c < SudokuConfig.gridSize; c++) {
      if (!state.givens[r][c] && state.player[r][c] == 0) {
        empties.add((r, c));
      }
    }
  }
  if (empties.isEmpty) return null;

  final (row, col) = empties.first;
  final value = state.solution[row][col];
  final nextPlayer = sudokuCopyGrid(state.player);
  nextPlayer[row][col] = value;

  final next = _cloneState(
    state,
    player: nextPlayer,
    hintsUsed: state.hintsUsed + 1,
    moves: state.moves + 1,
  );

  return SudokuHintResult(
    state: next,
    row: row,
    col: col,
    value: value,
  );
}

int get sudokuHintCoinCost => EconomyConfig.hintCoinCostSudoku;

bool sudokuIsSolved(SudokuState state) {
  if (!state.isComplete()) return false;
  for (var r = 0; r < SudokuConfig.gridSize; r++) {
    for (var c = 0; c < SudokuConfig.gridSize; c++) {
      if (state.displayValue(r, c) != state.solution[r][c]) return false;
    }
  }
  return true;
}

bool sudokuIsGameOver(SudokuState state) =>
    state.mistakes >= SudokuConfig.maxMistakes;

int sudokuProgressScore(SudokuState state) =>
    state.score.clamp(0, SudokuConfig.maxScore);

int sudokuTimeBonusRemaining(Duration elapsed) {
  final sec = elapsed.inSeconds;
  return (SudokuConfig.timeBonusMax - sec * SudokuConfig.timeBonusPerSecond)
      .clamp(0, SudokuConfig.timeBonusMax);
}

int sudokuFinalScore({
  required SudokuState state,
  required Duration duration,
  required bool won,
}) {
  var total = state.score;
  if (won) {
    total += SudokuConfig.winBonus;
    if (state.mistakes == 0 && state.hintsUsed == 0) {
      total += SudokuConfig.perfectBonus;
    }
    total += sudokuTimeBonusRemaining(duration);
  }
  return total.clamp(0, SudokuConfig.maxScore);
}

String sudokuHudTimeBonusLabel(int bonus) =>
    bonus > 0
        ? L10nScope.of.hudTimeBonus(bonus)
        : L10nScope.of.hudNoTimeBonus;

String sudokuHudElapsedLabel(Duration elapsed) {
  final m = elapsed.inMinutes;
  final s = elapsed.inSeconds.remainder(60);
  return '$m:${s.toString().padLeft(2, '0')}';
}

String sudokuHudProgressLabel(SudokuState state) =>
    '${state.filledCount()}/${state.totalCells}';

double sudokuCellFontSize(double cellSize) => cellSize * 0.46;

/// Desempenho normalizado (`0.0`–`1.0`).
///
/// Derrota = desempenho mínimo (bronze). Vencer parte de `0.65` (prata) e chega
/// a `0.85` (ouro) só com partida impecável (sem erros nem dicas); cada erro/dica
/// derruba o desempenho.
double sudokuPerformanceRatio({
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

PerformanceTier sudokuPerformanceTier({
  required bool won,
  required int mistakes,
  required int hintsUsed,
}) =>
    tierFromRatio(sudokuPerformanceRatio(
      won: won,
      mistakes: mistakes,
      hintsUsed: hintsUsed,
    ));
