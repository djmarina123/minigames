import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/economy/performance_tier.dart';
import 'package:minigames_hub/core/l10n/l10n_scope.dart';
import 'package:minigames_hub/games/color_blocks/color_blocks_config.dart';

void main() {
  setUpAll(() async {
    await L10nScope.installForTest();
  });

  group('ColorBlocksConfig', () {
    test('coloca peça em células vazias', () {
      final board = colorBlocksEmptyBoard(8);
      const piece = ColorBlockPiece(
        shapeId: 1,
        colorIndex: 0,
        cells: [(0, 0), (0, 1)],
      );
      expect(colorBlocksCanPlace(board, piece, 0, 0), isTrue);
      final placed = colorBlocksPlaceBoard(board, piece, 0, 0);
      expect(placed[0][0], 0);
      expect(placed[0][1], 0);
      expect(placed[0][2], isNull);
    });

    test('não coloca sobre células ocupadas', () {
      final board = colorBlocksEmptyBoard(8);
      const piece = ColorBlockPiece(
        shapeId: 0,
        colorIndex: 1,
        cells: [(0, 0)],
      );
      final placed = colorBlocksPlaceBoard(board, piece, 0, 0);
      expect(colorBlocksCanPlace(placed, piece, 0, 0), isFalse);
    });

    test('limpa linha e coluna completas', () {
      const board = <List<int?>>[
        [0, 0, 0],
        [1, null, 1],
        [2, 2, 2],
      ];
      final result = colorBlocksClearFullLines(board);
      expect(result.linesCleared, 4);
      expect(result.clearedRows, {0, 2});
      expect(result.clearedCols, {0, 2});
      expect(result.board[1][1], isNull);
    });

    test('preview de linhas após colocação válida', () {
      const board = <List<int?>>[
        [0, 0, null],
        [1, null, null],
        [null, null, null],
      ];
      const piece = ColorBlockPiece(
        shapeId: 0,
        colorIndex: 2,
        cells: [(0, 0)],
      );
      final preview = colorBlocksPreviewClears(board, piece, 0, 2);
      expect(preview.linesCleared, 1);
      expect(preview.clearedRows, {0});
    });

    test('analisa conflito por sobreposição e fora do tabuleiro', () {
      final board = colorBlocksEmptyBoard(4);
      board[1][1] = 0;
      const piece = ColorBlockPiece(
        shapeId: 0,
        colorIndex: 1,
        cells: [(0, 0)],
      );
      expect(
        colorBlocksAnalyzePlacement(board, piece, 1, 1).kind,
        ColorBlocksInvalidKind.overlap,
      );
      expect(
        colorBlocksAnalyzePlacement(board, piece, -1, 0).kind,
        ColorBlocksInvalidKind.outOfBounds,
      );
    });

    test('pontuação por célula e combo de linhas', () {
      expect(colorBlocksPlacePoints(4), 40);
      expect(colorBlocksLineClearPoints(1), 80);
      expect(colorBlocksLineClearPoints(2), greaterThan(160));
      expect(
        colorBlocksTurnScoreDelta(cellCount: 3, linesCleared: 2),
        colorBlocksPlacePoints(3) + colorBlocksLineClearPoints(2),
      );
    });

    test('detecta movimentos válidos e game over', () {
      final board = colorBlocksEmptyBoard(4);
      const piece = ColorBlockPiece(
        shapeId: 10,
        colorIndex: 0,
        cells: [(0, 0), (0, 1), (1, 0), (1, 1)],
      );
      expect(colorBlocksPieceHasValidMove(board, piece), isTrue);

      final full = List.generate(
        4,
        (_) => List<int?>.filled(4, 0),
      );
      expect(colorBlocksPieceHasValidMove(full, piece), isFalse);
      expect(
        colorBlocksHasAnyMove(full, [piece]),
        isFalse,
      );
    });

    test('desempenho normalizado aumenta com score e linhas', () {
      final low = colorBlocksPerformanceRatio(
        score: 200,
        linesCleared: 2,
        gridSize: 8,
      );
      final high = colorBlocksPerformanceRatio(
        score: 2500,
        linesCleared: 18,
        gridSize: 8,
      );
      expect(high, greaterThan(low));
      expect(
        colorBlocksPerformanceTier(
          score: 2500,
          linesCleared: 18,
          gridSize: 8,
        ),
        isNot(PerformanceTier.bronze),
      );
    });
  });
}
