import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/economy/performance_tier.dart';
import 'package:minigames_hub/core/l10n/l10n_scope.dart';
import 'package:minigames_hub/games/sudoku/sudoku_config.dart';

void main() {
  setUpAll(() async {
    await L10nScope.installForTest();
  });

  group('SudokuConfig', () {
    test('gera solução válida 9x9', () {
      final solution = sudokuGenerateSolution(Random(42));
      expect(solution.length, 9);
      for (final row in solution) {
        expect(row.length, 9);
        expect(row.every((v) => v >= 1 && v <= 9), isTrue);
      }
      for (var r = 0; r < 9; r++) {
        for (var c = 0; c < 9; c++) {
          expect(sudokuIsValidInGrid(solution, r, c, solution[r][c]), isTrue);
        }
      }
    });

    test('novo jogo respeita contagem de pistas por dificuldade', () {
      final easy = sudokuNewGame(Random(1), difficulty: SudokuDifficulty.easy);
      final medium =
          sudokuNewGame(Random(1), difficulty: SudokuDifficulty.medium);
      final hard = sudokuNewGame(Random(1), difficulty: SudokuDifficulty.hard);

      expect(easy.filledCount(), sudokuClueCount(SudokuDifficulty.easy));
      expect(medium.filledCount(), sudokuClueCount(SudokuDifficulty.medium));
      expect(hard.filledCount(), sudokuClueCount(SudokuDifficulty.hard));
    });

    test('não permite editar células dadas', () {
      final state = sudokuNewGame(Random(7));
      for (var r = 0; r < 9; r++) {
        for (var c = 0; c < 9; c++) {
          if (state.givens[r][c]) {
            expect(sudokuCanEditCell(state, r, c), isFalse);
            expect(sudokuTryPlace(state, r, c, 1), isNull);
          }
        }
      }
    });

    test('acerto soma pontos e erro incrementa mistakes', () {
      final state = sudokuNewGame(Random(99));
      var targetRow = -1;
      var targetCol = -1;
      for (var r = 0; r < 9 && targetRow < 0; r++) {
        for (var c = 0; c < 9; c++) {
          if (!state.givens[r][c]) {
            targetRow = r;
            targetCol = c;
            break;
          }
        }
      }
      expect(targetRow, greaterThanOrEqualTo(0));

      final correct = sudokuTryPlace(
        state,
        targetRow,
        targetCol,
        state.solution[targetRow][targetCol],
      );
      expect(correct, isNotNull);
      expect(correct!.correct, isTrue);
      expect(correct.scoreDelta, SudokuConfig.pointsPerCell);
      expect(correct.state.mistakes, 0);

      final wrongValue = state.solution[targetRow][targetCol] == 1 ? 2 : 1;
      final wrong = sudokuTryPlace(state, targetRow, targetCol, wrongValue);
      expect(wrong, isNotNull);
      expect(wrong!.mistake, isTrue);
      expect(wrong.state.mistakes, 1);
      expect(wrong.scoreDelta, -SudokuConfig.mistakePenalty);
    });

    test('apagar e recolocar acerto não soma pontos de novo', () {
      final state = sudokuNewGame(Random(99));
      var targetRow = -1;
      var targetCol = -1;
      for (var r = 0; r < 9 && targetRow < 0; r++) {
        for (var c = 0; c < 9; c++) {
          if (!state.givens[r][c]) {
            targetRow = r;
            targetCol = c;
            break;
          }
        }
      }

      final value = state.solution[targetRow][targetCol];
      final first = sudokuTryPlace(state, targetRow, targetCol, value)!;
      expect(first.scoreDelta, SudokuConfig.pointsPerCell);
      expect(first.state.score, SudokuConfig.pointsPerCell);

      final erased = sudokuTryErase(first.state, targetRow, targetCol)!;
      expect(erased.state.score, SudokuConfig.pointsPerCell);
      expect(erased.state.player[targetRow][targetCol], 0);

      final again = sudokuTryPlace(erased.state, targetRow, targetCol, value)!;
      expect(again.correct, isTrue);
      expect(again.scoreDelta, 0);
      expect(again.state.score, SudokuConfig.pointsPerCell);
      expect(again.state.scoredCells, contains(sudokuCellKey(targetRow, targetCol)));
    });

    test('undo restaura pontos e células pontuadas', () {
      final state = sudokuNewGame(Random(12));
      var targetRow = -1;
      var targetCol = -1;
      for (var r = 0; r < 9 && targetRow < 0; r++) {
        for (var c = 0; c < 9; c++) {
          if (!state.givens[r][c]) {
            targetRow = r;
            targetCol = c;
            break;
          }
        }
      }

      final value = state.solution[targetRow][targetCol];
      final placed = sudokuTryPlace(state, targetRow, targetCol, value)!;
      expect(placed.state.score, SudokuConfig.pointsPerCell);

      // Simula pilha de undo com estado anterior à jogada.
      final undone = placed.state;
      final restored = SudokuState(
        solution: state.solution,
        givens: state.givens,
        player: sudokuCopyGrid(state.player),
        difficulty: state.difficulty,
        moves: state.moves,
        mistakes: state.mistakes,
        hintsUsed: state.hintsUsed,
        score: state.score,
        scoredCells: Set<String>.from(state.scoredCells),
      );
      expect(restored.score, 0);
      expect(restored.scoredCells, isEmpty);

      final retry = sudokuTryPlace(restored, targetRow, targetCol, value)!;
      expect(retry.scoreDelta, SudokuConfig.pointsPerCell);
      expect(retry.state.score, SudokuConfig.pointsPerCell);
      expect(undone.scoredCells, isNotEmpty);
    });

    test('erro repetido na mesma célula sem apagar não penaliza de novo', () {
      final state = sudokuNewGame(Random(77));
      var targetRow = -1;
      var targetCol = -1;
      for (var r = 0; r < 9 && targetRow < 0; r++) {
        for (var c = 0; c < 9; c++) {
          if (!state.givens[r][c]) {
            targetRow = r;
            targetCol = c;
            break;
          }
        }
      }

      final wrongValue = state.solution[targetRow][targetCol] == 1 ? 2 : 1;
      final first = sudokuTryPlace(state, targetRow, targetCol, wrongValue)!;
      expect(first.state.mistakes, 1);

      final repeat = sudokuTryPlace(first.state, targetRow, targetCol, wrongValue);
      expect(repeat, isNull);
      expect(first.state.mistakes, 1);
    });

    test('dica preenche célula vazia e penaliza score', () {
      final state = sudokuNewGame(Random(5));
      final hint = sudokuHint(state);
      expect(hint, isNotNull);
      expect(hint!.value, state.solution[hint.row][hint.col]);
      expect(hint.state.hintsUsed, 1);
      expect(hint.state.player[hint.row][hint.col], hint.value);
    });

    test('placar final inclui bônus de vitória', () {
      final state = SudokuState(
        solution: sudokuGenerateSolution(Random(3)),
        givens: sudokuEmptyGivens(),
        player: sudokuEmptyGrid(),
        difficulty: SudokuDifficulty.easy,
        score: 200,
        mistakes: 0,
        hintsUsed: 0,
      );
      final score = sudokuFinalScore(
        state: state,
        won: true,
      );
      expect(
        score,
        200 + SudokuConfig.winBonus + SudokuConfig.perfectBonus,
      );
    });

    test('layout mobile 390px reserva HUD e pinpad 3x3', () {
      final layout = sudokuBoardLayout(screenW: 390, screenH: 844);
      expect(layout.boardLeft, greaterThanOrEqualTo(0));
      expect(layout.boardLeft + layout.boardSize, lessThanOrEqualTo(390));
      expect(layout.boardTop, greaterThanOrEqualTo(SudokuConfig.layoutHudHeight - 1));
      expect(layout.numPadRects, hasLength(9));
      expect(layout.numPadWidth, closeTo(layout.boardSize, 0.01));
      expect(layout.numPadRects.first.left, closeTo(layout.boardLeft, 0.01));

      // Pinpad clássico: 1 acima de 4, 2 acima de 5…
      expect(layout.numPadRects[0].top, lessThan(layout.numPadRects[3].top));
      expect(layout.numPadRects[0].left, lessThan(layout.numPadRects[1].left));
      expect(layout.numPadRects[6].bottom, lessThanOrEqualTo(844));

      expect(sudokuNumPadPositionForDigit(1), (0, 0));
      expect(sudokuNumPadPositionForDigit(5), (1, 1));
      expect(sudokuNumPadPositionForDigit(9), (2, 2));
    });

    test('layout mobile baixo usa quase toda a largura', () {
      const screenW = 390.0;
      const screenH = 640.0;
      final layout = sudokuBoardLayout(screenW: screenW, screenH: screenH);
      final availW = screenW - SudokuConfig.layoutMarginH * 2;
      expect(layout.boardSize, closeTo(availW, 1.0));
    });

    test('helpers do HUD formatam progresso', () {
      final state = sudokuNewGame(Random(0));
      expect(sudokuHudProgressLabel(state), '${state.filledCount()}/81');
    });

    test('dica paga não penaliza score', () {
      final state = sudokuNewGame(Random(5));
      final before = state.score;
      final hint = sudokuHintPaid(state);
      expect(hint, isNotNull);
      expect(hint!.state.score, before);
      expect(hint.state.hintsUsed, 1);
    });

    test('sudokuPerformanceTier — ouro sem erros nem dicas', () {
      expect(
        sudokuPerformanceTier(won: true, mistakes: 0, hintsUsed: 0),
        PerformanceTier.gold,
      );
      expect(
        sudokuPerformanceTier(won: true, mistakes: 1, hintsUsed: 0),
        PerformanceTier.silver,
      );
      expect(
        sudokuPerformanceTier(won: false, mistakes: 0, hintsUsed: 0),
        PerformanceTier.bronze,
      );
    });
  });
}
