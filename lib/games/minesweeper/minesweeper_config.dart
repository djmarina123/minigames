import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/economy/economy_config.dart';
import '../../core/economy/performance_tier.dart';
import '../../core/game_sdk/game_session_hud_actions.dart';
import '../../core/l10n/l10n_scope.dart';

/// Constantes, paleta e regras puras do Campo Minado.
abstract final class MinesweeperConfig {
  static const optionKeyDifficulty = 'difficulty';

  static const pointsPerReveal = 8;
  static const winBonus = 400;
  static const perfectBonus = 80;

  static const timeBonusMax = 250;
  static const timeBonusPerSecond = 2;

  static const maxScore = 99999;

  static const shakeSec = 0.32;
  static const flashSec = 0.24;
  static const pulseSec = 0.14;

  /// Paleta alinhada ao card do hub (`HubTheme` id `minesweeper`).
  static const cardColor = Color(0xFF34495E);
  static const accentColor = Color(0xFFE74C3C);
  static const blendColor = Color(0xFF5D6D7E);
  static const accentSoft = Color(0xFFF1C40F);
  static const bgTop = Color(0xFF2C3E50);
  static const bgBottom = Color(0xFF1A252F);
  static const cellHiddenTop = Color(0xFFBDC3C7);
  static const cellHiddenBottom = Color(0xFF95A5A6);
  static const cellRevealed = Color(0xFFECF0F1);
  static const cellBorder = Color(0xFF7F8C8D);
  static const mineColor = Color(0xFF2C3E50);
  static const mineExploded = Color(0xFFE74C3C);
  static const flagPole = Color(0xFF2C3E50);
  static const flagCloth = Color(0xFFE74C3C);
  static const hudText = Color(0xFFF8F9FA);
  static const hudMuted = Color(0xFFBDC3C7);
  static const successGlow = Color(0xFF2ECC71);
  static const missRed = Color(0xFFFF7675);

  static const layoutMarginH = 12.0;
  static const layoutBottomMargin = 10.0;
  static const layoutHudGap = 16.0;
  static const layoutHudHeight = GameSessionHudActionBar.reservedHeight;

  /// Piso de toque quando o grid couber na tela sem scroll.
  static const layoutMinCellSize = 24.0;
  static const layoutLargeGridThreshold = 13;
}

enum MinesweeperDifficulty { easy, medium, hard }

class MinesweeperBoardSpec {
  const MinesweeperBoardSpec({
    required this.rows,
    required this.cols,
    required this.mineCount,
  });

  final int rows;
  final int cols;
  final int mineCount;

  int get safeCellCount => rows * cols - mineCount;
}

MinesweeperBoardSpec minesweeperBoardSpec(MinesweeperDifficulty difficulty) =>
    switch (difficulty) {
      MinesweeperDifficulty.easy =>
        const MinesweeperBoardSpec(rows: 8, cols: 8, mineCount: 10),
      MinesweeperDifficulty.medium =>
        const MinesweeperBoardSpec(rows: 12, cols: 12, mineCount: 20),
      MinesweeperDifficulty.hard =>
        const MinesweeperBoardSpec(rows: 14, cols: 14, mineCount: 35),
    };

int minesweeperMineCount(MinesweeperDifficulty difficulty) =>
    minesweeperBoardSpec(difficulty).mineCount;

MinesweeperDifficulty minesweeperDifficultyFromValue(String value) =>
    switch (value) {
      'medium' => MinesweeperDifficulty.medium,
      'hard' => MinesweeperDifficulty.hard,
      _ => MinesweeperDifficulty.easy,
    };

enum CellVisibility { hidden, revealed, flagged }

class MinesweeperState {
  MinesweeperState({
    required this.rows,
    required this.cols,
    required this.mineCount,
    required this.mines,
    required this.adjacency,
    required this.visibility,
    required this.minesPlaced,
    this.revealedCount = 0,
    this.flagsPlaced = 0,
    this.score = 0,
    this.moves = 0,
    this.hintsUsed = 0,
    this.lost = false,
    this.won = false,
  });

  final int rows;
  final int cols;
  final int mineCount;
  final List<List<bool>> mines;
  final List<List<int>> adjacency;
  final List<List<CellVisibility>> visibility;
  final bool minesPlaced;
  final int revealedCount;
  final int flagsPlaced;
  final int score;
  final int moves;
  final int hintsUsed;
  final bool lost;
  final bool won;

  int get totalCells => rows * cols;
  int get safeCells => totalCells - mineCount;
  int get flagsRemaining => (mineCount - flagsPlaced).clamp(0, mineCount);
}

class MinesweeperBoardLayout {
  const MinesweeperBoardLayout({
    required this.boardLeft,
    required this.boardTop,
    required this.boardWidth,
    required this.boardHeight,
    required this.cellSize,
  });

  final double boardLeft;
  final double boardTop;
  final double boardWidth;
  final double boardHeight;
  final double cellSize;

  Rect cellRect(int row, int col) => Rect.fromLTWH(
        boardLeft + col * cellSize,
        boardTop + row * cellSize,
        cellSize,
        cellSize,
      );

  (int row, int col)? cellAt(Offset pos) {
    final localX = pos.dx - boardLeft;
    final localY = pos.dy - boardTop;
    if (localX < 0 ||
        localY < 0 ||
        localX >= boardWidth ||
        localY >= boardHeight) {
      return null;
    }
    final col = (localX / cellSize).floor().clamp(0, cols - 1);
    final row = (localY / cellSize).floor().clamp(0, rows - 1);
    return (row, col);
  }

  int get rows => (boardHeight / cellSize).round();
  int get cols => (boardWidth / cellSize).round();
}

MinesweeperBoardLayout minesweeperBoardLayout({
  required double screenW,
  required double screenH,
  required int rows,
  required int cols,
}) {
  final gridMax = max(rows, cols);
  final isLargeGrid = gridMax >= MinesweeperConfig.layoutLargeGridThreshold;
  final marginH =
      isLargeGrid ? 8.0 : MinesweeperConfig.layoutMarginH;
  const hudHeight = MinesweeperConfig.layoutHudHeight;
  const hudGap = MinesweeperConfig.layoutHudGap;
  final bottomMargin =
      isLargeGrid ? 6.0 : MinesweeperConfig.layoutBottomMargin;

  final availW = screenW - marginH * 2;
  final availH = screenH - hudHeight - hudGap - bottomMargin;

  final byWidth = availW / cols;
  final byHeight = availH / rows;
  final cellSize = min(byWidth, byHeight);

  final boardWidth = cellSize * cols;
  final boardHeight = cellSize * rows;
  final boardLeft = (screenW - boardWidth) / 2;
  final boardTop = hudHeight + hudGap;

  return MinesweeperBoardLayout(
    boardLeft: boardLeft,
    boardTop: boardTop,
    boardWidth: boardWidth,
    boardHeight: boardHeight,
    cellSize: cellSize,
  );
}

List<List<bool>> _emptyMines(int rows, int cols) =>
    List.generate(rows, (_) => List.filled(cols, false));

List<List<int>> _emptyAdjacency(int rows, int cols) =>
    List.generate(rows, (_) => List.filled(cols, 0));

List<List<CellVisibility>> _emptyVisibility(int rows, int cols) =>
    List.generate(
      rows,
      (_) => List.filled(cols, CellVisibility.hidden),
    );

MinesweeperState minesweeperNewGame(MinesweeperDifficulty difficulty) {
  final spec = minesweeperBoardSpec(difficulty);
  return MinesweeperState(
    rows: spec.rows,
    cols: spec.cols,
    mineCount: spec.mineCount,
    mines: _emptyMines(spec.rows, spec.cols),
    adjacency: _emptyAdjacency(spec.rows, spec.cols),
    visibility: _emptyVisibility(spec.rows, spec.cols),
    minesPlaced: false,
  );
}

MinesweeperState _cloneState(
  MinesweeperState state, {
  List<List<bool>>? mines,
  List<List<int>>? adjacency,
  List<List<CellVisibility>>? visibility,
  bool? minesPlaced,
  int? revealedCount,
  int? flagsPlaced,
  int? score,
  int? moves,
  int? hintsUsed,
  bool? lost,
  bool? won,
}) {
  return MinesweeperState(
    rows: state.rows,
    cols: state.cols,
    mineCount: state.mineCount,
    mines: mines ?? state.mines.map((r) => List<bool>.from(r)).toList(),
    adjacency:
        adjacency ?? state.adjacency.map((r) => List<int>.from(r)).toList(),
    visibility: visibility ??
        state.visibility.map((r) => List<CellVisibility>.from(r)).toList(),
    minesPlaced: minesPlaced ?? state.minesPlaced,
    revealedCount: revealedCount ?? state.revealedCount,
    flagsPlaced: flagsPlaced ?? state.flagsPlaced,
    score: score ?? state.score,
    moves: moves ?? state.moves,
    hintsUsed: hintsUsed ?? state.hintsUsed,
    lost: lost ?? state.lost,
    won: won ?? state.won,
  );
}

bool _inBounds(MinesweeperState state, int row, int col) =>
    row >= 0 && col >= 0 && row < state.rows && col < state.cols;

void _placeMines(
  MinesweeperState state,
  int safeRow,
  int safeCol,
  Random random,
  List<List<bool>> mines,
  List<List<int>> adjacency,
) {
  final positions = <(int, int)>[];
  for (var r = 0; r < state.rows; r++) {
    for (var c = 0; c < state.cols; c++) {
      if (r == safeRow && c == safeCol) continue;
      positions.add((r, c));
    }
  }
  positions.shuffle(random);
  for (var i = 0; i < state.mineCount; i++) {
    final (r, c) = positions[i];
    mines[r][c] = true;
  }

  for (var r = 0; r < state.rows; r++) {
    for (var c = 0; c < state.cols; c++) {
      if (mines[r][c]) {
        adjacency[r][c] = -1;
        continue;
      }
      var count = 0;
      for (var dr = -1; dr <= 1; dr++) {
        for (var dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final nr = r + dr;
          final nc = c + dc;
          if (nr >= 0 &&
              nc >= 0 &&
              nr < state.rows &&
              nc < state.cols &&
              mines[nr][nc]) {
            count++;
          }
        }
      }
      adjacency[r][c] = count;
    }
  }
}

List<(int row, int col)> _collectRevealFlood(
  MinesweeperState state,
  List<List<CellVisibility>> visibility,
  int row,
  int col,
) {
  final queue = <(int, int)>[(row, col)];
  final revealed = <(int, int)>[];
  final seen = <String>{};

  while (queue.isNotEmpty) {
    final (r, c) = queue.removeLast();
    final key = '${r}_$c';
    if (seen.contains(key)) continue;
    seen.add(key);

    if (!_inBounds(state, r, c)) continue;
    if (visibility[r][c] != CellVisibility.hidden) continue;
    if (state.mines[r][c]) continue;

    visibility[r][c] = CellVisibility.revealed;
    revealed.add((r, c));

    if (state.adjacency[r][c] == 0) {
      for (var dr = -1; dr <= 1; dr++) {
        for (var dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          queue.add((r + dr, c + dc));
        }
      }
    }
  }

  return revealed;
}

class MinesweeperActionResult {
  const MinesweeperActionResult({
    required this.state,
    required this.scoreDelta,
    required this.revealedCells,
    required this.won,
    required this.lost,
    required this.mineHit,
  });

  final MinesweeperState state;
  final int scoreDelta;
  final List<(int row, int col)> revealedCells;
  final bool won;
  final bool lost;
  final bool mineHit;
}

class MinesweeperFlagResult {
  const MinesweeperFlagResult({
    required this.state,
    required this.flagged,
  });

  final MinesweeperState state;
  final bool flagged;
}

MinesweeperActionResult? minesweeperTryReveal(
  MinesweeperState state,
  int row,
  int col,
  Random random,
) {
  if (state.lost || state.won) return null;
  if (!_inBounds(state, row, col)) return null;
  if (state.visibility[row][col] == CellVisibility.flagged) return null;
  if (state.visibility[row][col] == CellVisibility.revealed) return null;

  var mines = state.mines.map((r) => List<bool>.from(r)).toList();
  var adjacency = state.adjacency.map((r) => List<int>.from(r)).toList();
  var minesPlaced = state.minesPlaced;

  if (!minesPlaced) {
    _placeMines(state, row, col, random, mines, adjacency);
    minesPlaced = true;
  }

  final visibility =
      state.visibility.map((r) => List<CellVisibility>.from(r)).toList();

  if (mines[row][col]) {
    visibility[row][col] = CellVisibility.revealed;
    return MinesweeperActionResult(
      state: _cloneState(
        state,
        mines: mines,
        adjacency: adjacency,
        visibility: visibility,
        minesPlaced: minesPlaced,
        revealedCount: state.revealedCount + 1,
        moves: state.moves + 1,
        lost: true,
      ),
      scoreDelta: 0,
      revealedCells: [(row, col)],
      won: false,
      lost: true,
      mineHit: true,
    );
  }

  final revealed = _collectRevealFlood(
    MinesweeperState(
      rows: state.rows,
      cols: state.cols,
      mineCount: state.mineCount,
      mines: mines,
      adjacency: adjacency,
      visibility: visibility,
      minesPlaced: minesPlaced,
    ),
    visibility,
    row,
    col,
  );

  final scoreDelta = revealed.length * MinesweeperConfig.pointsPerReveal;
  final nextRevealed = state.revealedCount + revealed.length;
  final won = nextRevealed >= state.safeCells;

  return MinesweeperActionResult(
    state: _cloneState(
      state,
      mines: mines,
      adjacency: adjacency,
      visibility: visibility,
      minesPlaced: minesPlaced,
      revealedCount: nextRevealed,
      score: (state.score + scoreDelta).clamp(0, MinesweeperConfig.maxScore),
      moves: state.moves + 1,
      won: won,
    ),
    scoreDelta: scoreDelta,
    revealedCells: revealed,
    won: won,
    lost: false,
    mineHit: false,
  );
}

MinesweeperFlagResult? minesweeperTryToggleFlag(
  MinesweeperState state,
  int row,
  int col,
) {
  if (state.lost || state.won) return null;
  if (!_inBounds(state, row, col)) return null;
  if (state.visibility[row][col] == CellVisibility.revealed) return null;

  final visibility =
      state.visibility.map((r) => List<CellVisibility>.from(r)).toList();
  final current = visibility[row][col];
  var flags = state.flagsPlaced;

  if (current == CellVisibility.flagged) {
    visibility[row][col] = CellVisibility.hidden;
    flags--;
  } else {
    visibility[row][col] = CellVisibility.flagged;
    flags++;
  }

  return MinesweeperFlagResult(
    state: _cloneState(
      state,
      visibility: visibility,
      flagsPlaced: flags,
      moves: state.moves + 1,
    ),
    flagged: visibility[row][col] == CellVisibility.flagged,
  );
}

MinesweeperActionResult? minesweeperHintSafe(
  MinesweeperState state,
  Random random,
) {
  if (state.lost || state.won || !state.minesPlaced) return null;

  final safeHidden = <(int, int)>[];
  for (var r = 0; r < state.rows; r++) {
    for (var c = 0; c < state.cols; c++) {
      if (state.visibility[r][c] == CellVisibility.hidden &&
          !state.mines[r][c]) {
        safeHidden.add((r, c));
      }
    }
  }
  if (safeHidden.isEmpty) return null;

  final (row, col) = safeHidden[random.nextInt(safeHidden.length)];
  final visibility =
      state.visibility.map((r) => List<CellVisibility>.from(r)).toList();

  final revealed = _collectRevealFlood(
    state,
    visibility,
    row,
    col,
  );

  final scoreDelta = revealed.length * MinesweeperConfig.pointsPerReveal;
  final nextRevealed = state.revealedCount + revealed.length;
  final won = nextRevealed >= state.safeCells;

  return MinesweeperActionResult(
    state: _cloneState(
      state,
      visibility: visibility,
      revealedCount: nextRevealed,
      score: (state.score + scoreDelta).clamp(0, MinesweeperConfig.maxScore),
      hintsUsed: state.hintsUsed + 1,
      moves: state.moves + 1,
      won: won,
    ),
    scoreDelta: scoreDelta,
    revealedCells: revealed,
    won: won,
    lost: false,
    mineHit: false,
  );
}

int minesweeperProgressScore(MinesweeperState state) =>
    state.score.clamp(0, MinesweeperConfig.maxScore);

int minesweeperTimeBonusRemaining(Duration elapsed) {
  final sec = elapsed.inSeconds;
  return (MinesweeperConfig.timeBonusMax -
          sec * MinesweeperConfig.timeBonusPerSecond)
      .clamp(0, MinesweeperConfig.timeBonusMax);
}

int minesweeperFinalScore({
  required MinesweeperState state,
  required Duration duration,
  required bool won,
}) {
  var total = state.score;
  if (won) {
    total += MinesweeperConfig.winBonus;
    if (state.hintsUsed == 0) {
      total += MinesweeperConfig.perfectBonus;
    }
    total += minesweeperTimeBonusRemaining(duration);
  }
  return total.clamp(0, MinesweeperConfig.maxScore);
}

String minesweeperHudElapsedLabel(Duration elapsed) {
  final m = elapsed.inMinutes;
  final s = elapsed.inSeconds.remainder(60);
  return '$m:${s.toString().padLeft(2, '0')}';
}

String minesweeperHudProgressLabel(MinesweeperState state) =>
    '${state.revealedCount}/${state.safeCells}';

String minesweeperHudMinesLabel(MinesweeperState state) =>
    L10nScope.of.hudMinesRemaining(state.flagsRemaining);

String minesweeperHudTimeBonusLabel(int bonus) => bonus > 0
    ? L10nScope.of.hudTimeBonus(bonus)
    : L10nScope.of.hudNoTimeBonus;

double minesweeperCellFontSize(double cellSize) =>
    (cellSize * 0.52).clamp(10.0, 22.0);

Color minesweeperNumberColor(int count) => switch (count) {
      1 => const Color(0xFF0984E3),
      2 => const Color(0xFF00B894),
      3 => const Color(0xFFE17055),
      4 => const Color(0xFF4834D4),
      5 => const Color(0xFF6C0505),
      6 => const Color(0xFF16A085),
      7 => const Color(0xFF2D3436),
      8 => const Color(0xFF636E72),
      _ => MinesweeperConfig.cellBorder,
    };

double minesweeperPerformanceRatio({
  required bool won,
  required int hintsUsed,
}) {
  if (!won) return 0;
  var ratio = 0.65;
  if (hintsUsed == 0) ratio += 0.20;
  ratio -= hintsUsed * 0.08;
  return ratio.clamp(0.0, 1.0);
}

PerformanceTier minesweeperPerformanceTier({
  required bool won,
  required int hintsUsed,
}) =>
    tierFromRatio(minesweeperPerformanceRatio(
      won: won,
      hintsUsed: hintsUsed,
    ));

int get minesweeperHintCoinCost => EconomyConfig.hintCoinCostMinesweeper;
