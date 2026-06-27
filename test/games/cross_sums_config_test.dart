import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/economy/performance_tier.dart';
import 'package:minigames_hub/core/l10n/l10n_scope.dart';
import 'package:minigames_hub/games/cross_sums/cross_sums_config.dart';

void main() {
  setUpAll(() async {
    await L10nScope.installForTest();
  });

  group('CrossSumsConfig', () {
    test('gera puzzle com alvos coerentes por dificuldade', () {
      for (final difficulty in CrossSumsDifficulty.values) {
        final state = crossSumsNewGame(Random(7), difficulty: difficulty);
        expect(state.size, crossSumsGridSize(difficulty));
        expect(state.rowTargets.length, state.size);
        expect(state.colTargets.length, state.size);

        for (var r = 0; r < state.size; r++) {
          var rowSum = 0;
          for (var c = 0; c < state.size; c++) {
            if (state.solution[r][c]) rowSum += state.values[r][c];
          }
          expect(rowSum, state.rowTargets[r]);
        }

        for (var c = 0; c < state.size; c++) {
          var colSum = 0;
          for (var r = 0; r < state.size; r++) {
            if (state.solution[r][c]) colSum += state.values[r][c];
          }
          expect(colSum, state.colTargets[c]);
        }
      }
    });

    test('partida começa com todas as células ativas', () {
      final state = crossSumsNewGame(Random(42));
      for (var r = 0; r < state.size; r++) {
        for (var c = 0; c < state.size; c++) {
          expect(state.kept[r][c], isTrue);
        }
      }
    });

    test('borracha correta soma pontos e erro incrementa mistakes', () {
      final state = crossSumsNewGame(Random(99));
      var targetRow = -1;
      var targetCol = -1;
      for (var r = 0; r < state.size && targetRow < 0; r++) {
        for (var c = 0; c < state.size; c++) {
          if (!state.solution[r][c]) {
            targetRow = r;
            targetCol = c;
            break;
          }
        }
      }
      expect(targetRow, greaterThanOrEqualTo(0));

      final correct = crossSumsTryToggle(
        state,
        targetRow,
        targetCol,
        CrossSumsTool.eraser,
      );
      expect(correct, isNotNull);
      expect(correct!.correct, isTrue);
      expect(correct.scoreDelta, CrossSumsConfig.pointsPerCell);
      expect(correct.state.kept[targetRow][targetCol], isFalse);

      var keepRow = -1;
      var keepCol = -1;
      for (var r = 0; r < state.size && keepRow < 0; r++) {
        for (var c = 0; c < state.size; c++) {
          if (state.solution[r][c]) {
            keepRow = r;
            keepCol = c;
            break;
          }
        }
      }

      final wrong = crossSumsTryToggle(
        state,
        keepRow,
        keepCol,
        CrossSumsTool.eraser,
      );
      expect(wrong, isNotNull);
      expect(wrong!.mistake, isTrue);
      expect(wrong.scoreDelta, -CrossSumsConfig.mistakePenalty);
    });

    test('lápis restaura célula removida corretamente', () {
      final state = crossSumsNewGame(Random(5));
      var row = -1;
      var col = -1;
      for (var r = 0; r < state.size && row < 0; r++) {
        for (var c = 0; c < state.size; c++) {
          if (state.solution[r][c]) {
            row = r;
            col = c;
            break;
          }
        }
      }

      final removed = crossSumsTryToggle(
        state,
        row,
        col,
        CrossSumsTool.eraser,
      );
      expect(removed, isNotNull);
      expect(removed!.mistake, isTrue);

      final restored = crossSumsTryToggle(
        removed.state,
        row,
        col,
        CrossSumsTool.pencil,
      );
      expect(restored, isNotNull);
      expect(restored!.correct, isTrue);
      expect(restored.state.kept[row][col], isTrue);
    });

    test('score final inclui bônus de vitória e tempo', () {
      final state = crossSumsNewGame(Random(3));
      const duration = Duration(seconds: 30);
      final score = crossSumsFinalScore(
        state: state,
        duration: duration,
        won: true,
      );
      expect(
        score,
        greaterThanOrEqualTo(
          state.score +
              CrossSumsConfig.winBonus +
              CrossSumsConfig.perfectBonus,
        ),
      );
    });

    test('derrota zera desempenho', () {
      expect(
        crossSumsPerformanceTier(
          won: false,
          mistakes: 0,
          hintsUsed: 0,
        ),
        PerformanceTier.bronze,
      );
    });

    test('vitória perfeita alcança ouro', () {
      expect(
        crossSumsPerformanceTier(
          won: true,
          mistakes: 0,
          hintsUsed: 0,
        ),
        PerformanceTier.gold,
      );
    });

    test('helpers de HUD retornam texto localizado', () {
      expect(crossSumsHudTimeBonusLabel(120), isNotEmpty);
      expect(crossSumsHudElapsedLabel(const Duration(minutes: 1, seconds: 5)),
          '1:05');
      final state = crossSumsNewGame(Random(1));
      expect(
        crossSumsHudProgressLabel(state),
        '${state.correctCount()}/${state.totalCells}',
      );
    });

    test('layout reserva espaço para cabeçalho e ferramentas', () {
      final layout = crossSumsBoardLayout(
        gridSize: 5,
        screenW: 390,
        screenH: 700,
      );
      expect(
        layout.boardTop,
        greaterThanOrEqualTo(CrossSumsConfig.layoutHeaderHeight),
      );
      expect(layout.toolTop, greaterThan(layout.boardTop + layout.boardExtent));
      expect(layout.hintRect.width, CrossSumsConfig.layoutHintSize);
    });
  });
}
