import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/economy/performance_tier.dart';

/// Constantes, paleta e regras puras do Color Blocks (puzzle 1010-style).
abstract final class ColorBlocksConfig {
  static const optionKeyGridSize = 'gridSize';
  static const defaultGridSize = 8;

  static const traySize = 3;

  static const pointsPerCell = 10;
  static const pointsPerLine = 80;
  static const comboBonusPerExtraLine = 40;

  static const clearAnimSec = 0.24;
  static const invalidFlashSec = 0.42;
  static const shakeSec = 0.32;
  static const ghostAlpha = 0.42;
  static const linePreviewPulseSec = 0.85;

  static const maxScore = 99999;

  /// Paleta alinhada ao card do hub (`HubTheme` id `color_blocks`).
  static const cardColor = Color(0xFF6C5CE7);
  static const accentColor = Color(0xFFFF7675);
  static const blendColor = Color(0xFF9B89ED);
  static const accentSoft = Color(0xFFFFABAA);
  static const bgTop = Color(0xFF5A4BD1);
  static const bgBottom = Color(0xFF4834B8);
  static const boardBg = Color(0xFF3D2FA8);
  static const cellEmpty = Color(0xFF5646C4);
  static const hudText = Color(0xFFF8F9FA);
  static const hudMuted = Color(0xFFD5D0F5);
  static const missRed = Color(0xFFFF7675);
  static const lineGlow = Color(0xFFFDCB6E);
  static const ghostValid = Color(0xFF55EFC4);
  static const ghostInvalid = Color(0xFFFF7675);
  static const linePreview = Color(0xFFFDCB6E);
  static const conflictRed = Color(0xFFFF4757);

  static const blockColors = <Color>[
    Color(0xFFFF7675),
    Color(0xFF74B9FF),
    Color(0xFF55EFC4),
    Color(0xFFFDCB6E),
    Color(0xFFE17055),
    Color(0xFFA29BFE),
  ];

  /// Formas polimino — offsets (row, col) a partir da âncora superior-esquerda.
  static const shapes = <List<(int, int)>>[
    [(0, 0)],
    [(0, 0), (0, 1)],
    [(0, 0), (1, 0)],
    [(0, 0), (0, 1), (0, 2)],
    [(0, 0), (1, 0), (2, 0)],
    [(0, 0), (1, 0), (1, 1)],
    [(0, 0), (0, 1), (1, 0)],
    [(0, 1), (1, 0), (1, 1)],
    [(0, 0), (0, 1), (1, 1)],
    [(0, 0), (0, 1), (0, 2), (1, 1)],
    [(0, 0), (0, 1), (1, 0), (1, 1)],
    [(0, 0), (0, 1), (0, 2), (0, 3)],
    [(0, 0), (1, 0), (2, 0), (3, 0)],
    [(0, 0), (0, 1), (0, 2), (1, 0)],
    [(0, 0), (0, 1), (0, 2), (1, 2)],
    [(0, 0), (1, 0), (1, 1), (1, 2)],
    [(0, 2), (1, 0), (1, 1), (1, 2)],
  ];
}

typedef ColorBlocksBoard = List<List<int?>>;

enum ColorBlocksInvalidKind { none, overlap, outOfBounds }

/// Peça disponível na bandeja inferior.
class ColorBlockPiece {
  const ColorBlockPiece({
    required this.shapeId,
    required this.colorIndex,
    required this.cells,
  });

  final int shapeId;
  final int colorIndex;
  final List<(int, int)> cells;

  Color get color =>
      ColorBlocksConfig.blockColors[colorIndex % ColorBlocksConfig.blockColors.length];
}

/// Resultado de limpar linhas/colunas completas.
class ColorBlocksClearResult {
  const ColorBlocksClearResult({
    required this.board,
    required this.linesCleared,
    required this.clearedRows,
    required this.clearedCols,
  });

  final ColorBlocksBoard board;
  final int linesCleared;
  final Set<int> clearedRows;
  final Set<int> clearedCols;
}

ColorBlocksBoard colorBlocksEmptyBoard(int size) =>
    List.generate(size, (_) => List<int?>.filled(size, null));

ColorBlockPiece colorBlocksRandomPiece(Random random) {
  final shapeId = random.nextInt(ColorBlocksConfig.shapes.length);
  final colorIndex = random.nextInt(ColorBlocksConfig.blockColors.length);
  return ColorBlockPiece(
    shapeId: shapeId,
    colorIndex: colorIndex,
    cells: ColorBlocksConfig.shapes[shapeId],
  );
}

List<ColorBlockPiece?> colorBlocksNewTray(Random random) => List.generate(
      ColorBlocksConfig.traySize,
      (_) => colorBlocksRandomPiece(random),
    );

bool colorBlocksCanPlace(
  ColorBlocksBoard board,
  ColorBlockPiece piece,
  int anchorRow,
  int anchorCol,
) {
  final size = board.length;
  for (final (dr, dc) in piece.cells) {
    final row = anchorRow + dr;
    final col = anchorCol + dc;
    if (row < 0 || col < 0 || row >= size || col >= size) return false;
    if (board[row][col] != null) return false;
  }
  return true;
}

({ColorBlocksInvalidKind kind, Set<(int row, int col)> conflictCells})
    colorBlocksAnalyzePlacement(
  ColorBlocksBoard board,
  ColorBlockPiece piece,
  int anchorRow,
  int anchorCol,
) {
  final conflicts = <(int, int)>{};
  var outOfBounds = false;
  final size = board.length;
  for (final (dr, dc) in piece.cells) {
    final row = anchorRow + dr;
    final col = anchorCol + dc;
    if (row < 0 || col < 0 || row >= size || col >= size) {
      outOfBounds = true;
      conflicts.add((row, col));
      continue;
    }
    if (board[row][col] != null) {
      conflicts.add((row, col));
    }
  }
  if (conflicts.isEmpty) {
    return (kind: ColorBlocksInvalidKind.none, conflictCells: conflicts);
  }
  return (
    kind: outOfBounds
        ? ColorBlocksInvalidKind.outOfBounds
        : ColorBlocksInvalidKind.overlap,
    conflictCells: conflicts,
  );
}

ColorBlocksClearResult colorBlocksPreviewClears(
  ColorBlocksBoard board,
  ColorBlockPiece piece,
  int anchorRow,
  int anchorCol,
) {
  if (!colorBlocksCanPlace(board, piece, anchorRow, anchorCol)) {
    return const ColorBlocksClearResult(
      board: [],
      linesCleared: 0,
      clearedRows: {},
      clearedCols: {},
    );
  }
  return colorBlocksClearFullLines(
    colorBlocksPlaceBoard(board, piece, anchorRow, anchorCol),
  );
}

ColorBlocksBoard colorBlocksPlaceBoard(
  ColorBlocksBoard board,
  ColorBlockPiece piece,
  int anchorRow,
  int anchorCol,
) {
  final next = board.map((row) => List<int?>.from(row)).toList();
  for (final (dr, dc) in piece.cells) {
    next[anchorRow + dr][anchorCol + dc] = piece.colorIndex;
  }
  return next;
}

ColorBlocksClearResult colorBlocksClearFullLines(ColorBlocksBoard board) {
  final size = board.length;
  final fullRows = <int>{};
  final fullCols = <int>{};

  for (var row = 0; row < size; row++) {
    if (board[row].every((cell) => cell != null)) fullRows.add(row);
  }
  for (var col = 0; col < size; col++) {
    var full = true;
    for (var row = 0; row < size; row++) {
      if (board[row][col] == null) {
        full = false;
        break;
      }
    }
    if (full) fullCols.add(col);
  }

  if (fullRows.isEmpty && fullCols.isEmpty) {
    return ColorBlocksClearResult(
      board: board,
      linesCleared: 0,
      clearedRows: const {},
      clearedCols: const {},
    );
  }

  final next = board.map((row) => List<int?>.from(row)).toList();
  for (final row in fullRows) {
    for (var col = 0; col < size; col++) {
      next[row][col] = null;
    }
  }
  for (final col in fullCols) {
    for (var row = 0; row < size; row++) {
      next[row][col] = null;
    }
  }

  return ColorBlocksClearResult(
    board: next,
    linesCleared: fullRows.length + fullCols.length,
    clearedRows: fullRows,
    clearedCols: fullCols,
  );
}

int colorBlocksPlacePoints(int cellCount) =>
    cellCount * ColorBlocksConfig.pointsPerCell;

int colorBlocksLineClearPoints(int linesCleared) {
  if (linesCleared <= 0) return 0;
  final base = linesCleared * ColorBlocksConfig.pointsPerLine;
  final combo = linesCleared > 1
      ? (linesCleared - 1) *
          ColorBlocksConfig.comboBonusPerExtraLine *
          linesCleared
      : 0;
  return base + combo;
}

int colorBlocksTurnScoreDelta({
  required int cellCount,
  required int linesCleared,
}) =>
    colorBlocksPlacePoints(cellCount) +
    colorBlocksLineClearPoints(linesCleared);

bool colorBlocksPieceHasValidMove(
  ColorBlocksBoard board,
  ColorBlockPiece piece,
) {
  final size = board.length;
  for (var row = 0; row < size; row++) {
    for (var col = 0; col < size; col++) {
      if (colorBlocksCanPlace(board, piece, row, col)) return true;
    }
  }
  return false;
}

bool colorBlocksHasAnyMove(
  ColorBlocksBoard board,
  List<ColorBlockPiece?> tray,
) {
  for (final piece in tray) {
    if (piece == null) continue;
    if (colorBlocksPieceHasValidMove(board, piece)) return true;
  }
  return false;
}

(double, double) colorBlocksPieceCenter(List<(int, int)> cells) {
  var minR = cells.first.$1;
  var maxR = cells.first.$1;
  var minC = cells.first.$2;
  var maxC = cells.first.$2;
  for (final (row, col) in cells) {
    if (row < minR) minR = row;
    if (row > maxR) maxR = row;
    if (col < minC) minC = col;
    if (col > maxC) maxC = col;
  }
  return ((minR + maxR) / 2, (minC + maxC) / 2);
}

(int row, int col) colorBlocksSnapAnchor(
  ColorBlockPiece piece,
  double originX,
  double originY,
  double cell,
  double gap,
  double touchX,
  double touchY,
) {
  final stride = cell + gap;
  final (centerR, centerC) = colorBlocksPieceCenter(piece.cells);
  final gridX = (touchX - originX - gap) / stride;
  final gridY = (touchY - originY - gap) / stride;
  return (
    (gridY - centerR).round(),
    (gridX - centerC).round(),
  );
}

double colorBlocksPerformanceRatio({
  required int score,
  required int linesCleared,
  required int gridSize,
}) {
  final scoreNorm = (score / (gridSize * gridSize * 35)).clamp(0.0, 1.0);
  final linesNorm = (linesCleared / (gridSize * 2.2)).clamp(0.0, 1.0);
  return (scoreNorm * 0.72 + linesNorm * 0.28).clamp(0.0, 1.0);
}

PerformanceTier colorBlocksPerformanceTier({
  required int score,
  required int linesCleared,
  required int gridSize,
}) =>
    tierFromRatio(
      colorBlocksPerformanceRatio(
        score: score,
        linesCleared: linesCleared,
        gridSize: gridSize,
      ),
    );
