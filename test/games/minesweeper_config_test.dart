import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/economy/performance_tier.dart';
import 'package:minigames_hub/core/l10n/l10n_scope.dart';
import 'package:minigames_hub/games/minesweeper/minesweeper_config.dart';

void main() {
  setUpAll(() async {
    await L10nScope.installForTest();
  });

  group('MinesweeperConfig', () {
    test('novo jogo respeita dimensões por dificuldade', () {
      final easy = minesweeperNewGame(MinesweeperDifficulty.easy);
      final medium = minesweeperNewGame(MinesweeperDifficulty.medium);
      final hard = minesweeperNewGame(MinesweeperDifficulty.hard);

      expect(easy.rows, 8);
      expect(easy.cols, 8);
      expect(easy.mineCount, 10);
      expect(medium.rows, 12);
      expect(medium.mineCount, 20);
      expect(hard.rows, 14);
      expect(hard.mineCount, 35);
      expect(easy.minesPlaced, isFalse);
    });

    test('primeira revelação nunca acerta mina', () {
      final random = Random(7);
      final state = minesweeperNewGame(MinesweeperDifficulty.easy);
      final result = minesweeperTryReveal(state, 0, 0, random);
      expect(result, isNotNull);
      expect(result!.mineHit, isFalse);
      expect(result.state.minesPlaced, isTrue);
    });

    test('revelação segura soma pontos', () {
      final random = Random(99);
      var state = minesweeperNewGame(MinesweeperDifficulty.easy);
      final first = minesweeperTryReveal(state, 0, 0, random)!;
      state = first.state;
      expect(first.scoreDelta, greaterThan(0));
      expect(first.revealedCells, isNotEmpty);
      expect(first.state.revealedCount, greaterThan(0));
    });

    test('bandeira alterna sem alterar placar', () {
      var state = minesweeperNewGame(MinesweeperDifficulty.easy);
      final flagged = minesweeperTryToggleFlag(state, 1, 1)!;
      expect(flagged.flagged, isTrue);
      expect(flagged.state.flagsPlaced, 1);
      expect(flagged.state.score, 0);

      final unflagged = minesweeperTryToggleFlag(flagged.state, 1, 1)!;
      expect(unflagged.flagged, isFalse);
      expect(unflagged.state.flagsPlaced, 0);
    });

    test('mina encerra partida sem pontos extras', () {
      final random = Random(1);
      var state = minesweeperNewGame(MinesweeperDifficulty.easy);
      state = minesweeperTryReveal(state, 0, 0, random)!.state;

      late MinesweeperActionResult? hit;
      for (var r = 0; r < state.rows; r++) {
        for (var c = 0; c < state.cols; c++) {
          if (state.mines[r][c] &&
              state.visibility[r][c] == CellVisibility.hidden) {
            hit = minesweeperTryReveal(state, r, c, random);
            break;
          }
        }
        if (hit != null) break;
      }

      expect(hit, isNotNull);
      expect(hit!.mineHit, isTrue);
      expect(hit.lost, isTrue);
      expect(hit.scoreDelta, 0);
    });

    test('score final inclui bônus de vitória e tempo', () {
      final state = MinesweeperState(
        rows: 8,
        cols: 8,
        mineCount: 10,
        mines: List.generate(8, (_) => List.filled(8, false)),
        adjacency: List.generate(8, (_) => List.filled(8, 0)),
        visibility: List.generate(
          8,
          (_) => List.filled(8, CellVisibility.revealed),
        ),
        minesPlaced: true,
        revealedCount: 54,
        score: 120,
      );

      final total = minesweeperFinalScore(
        state: state,
        duration: const Duration(seconds: 10),
        won: true,
      );

      expect(
        total,
        120 +
            MinesweeperConfig.winBonus +
            MinesweeperConfig.perfectBonus +
            minesweeperTimeBonusRemaining(const Duration(seconds: 10)),
      );
    });

    test('performance tier exige vitória', () {
      expect(
        minesweeperPerformanceTier(won: false, hintsUsed: 0),
        PerformanceTier.bronze,
      );
      expect(
        minesweeperPerformanceTier(won: true, hintsUsed: 0),
        PerformanceTier.gold,
      );
      expect(
        minesweeperPerformanceTier(won: true, hintsUsed: 1),
        PerformanceTier.silver,
      );
      expect(
        minesweeperPerformanceTier(won: true, hintsUsed: 3),
        PerformanceTier.bronze,
      );
    });

    test('layout difícil em 390px mantém células tocáveis', () {
      final layout = minesweeperBoardLayout(
        screenW: 390,
        screenH: 700,
        rows: 14,
        cols: 14,
      );
      expect(layout.cellSize, greaterThanOrEqualTo(24));
      expect(layout.boardWidth, lessThanOrEqualTo(390));
    });

    test('labels do HUD usam l10n', () {
      final state = minesweeperNewGame(MinesweeperDifficulty.easy);
      expect(minesweeperHudMinesLabel(state), contains('10'));
      expect(
        minesweeperHudTimeBonusLabel(MinesweeperConfig.timeBonusMax),
        isNotEmpty,
      );
    });
  });
}
