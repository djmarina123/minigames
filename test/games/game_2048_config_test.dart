import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/l10n/l10n_scope.dart';
import 'package:minigames_hub/games/game_2048/game_2048_config.dart';

void main() {
  setUpAll(() async {
    await L10nScope.installForTest();
  });

  group('Game2048Config', () {
    test('fusão à esquerda soma pontos e move peças', () {
      final grid = [
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      final result = game2048Move(grid, Game2048Direction.left);
      expect(result.changed, isTrue);
      expect(result.grid[0], [4, 0, 0, 0]);
      expect(result.scoreGained, 4);
      expect(result.merges, hasLength(1));
      expect(result.merges.first.value, 4);
    });

    test('cada peça funde no máximo uma vez por jogada', () {
      final grid = [
        [2, 2, 2, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      final result = game2048Move(grid, Game2048Direction.left);
      expect(result.grid[0], [4, 4, 0, 0]);
      expect(result.scoreGained, 8);
    });

    test('movimento inválido não altera o tabuleiro', () {
      final grid = [
        [2, 4, 8, 16],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      final result = game2048Move(grid, Game2048Direction.left);
      expect(result.changed, isFalse);
      expect(result.scoreGained, 0);
    });

    test('direções verticais funcionam', () {
      final grid = [
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      final up = game2048Move(grid, Game2048Direction.up);
      expect(up.grid[0][0], 4);
      expect(up.scoreGained, 4);

      final down = game2048Move(grid, Game2048Direction.down);
      expect(down.grid[3][0], 4);
    });

    test('bônus por peça alta e placar final', () {
      expect(game2048TileBonus(32), 0);
      expect(game2048TileBonus(64), 0);
      expect(game2048TileBonus(128), 25);
      expect(game2048TileBonus(2048), greaterThan(100));

      final finalScore = game2048FinalScore(
        mergeScore: 500,
        highestTile: 256,
      );
      expect(finalScore, 500 + game2048TileBonus(256));
    });

    test('detecção de swipe por delta', () {
      expect(game2048DirectionFromDelta(40, 5), Game2048Direction.right);
      expect(game2048DirectionFromDelta(-40, 5), Game2048Direction.left);
      expect(game2048DirectionFromDelta(5, -40), Game2048Direction.up);
      expect(game2048DirectionFromDelta(5, 40), Game2048Direction.down);
      expect(game2048DirectionFromDelta(5, 5), isNull);
    });

    test('trajetórias de deslize acompanham fusões', () {
      final grid = [
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      final motions = game2048ComputeMotions(grid, Game2048Direction.left);
      expect(motions, hasLength(2));
      expect(motions.where((m) => m.isSurvivor), hasLength(1));
      expect(motions.first.toCol, 0);
      expect(motions.first.mergedValue, 4);
    });

    test('nota do HUD à direita — dica ou bônus', () {
      expect(
        game2048HudRightFootnote(moves: 0, bonusPreview: 0),
        'Deslize p/ jogar',
      );
      expect(
        game2048HudRightFootnote(moves: 3, bonusPreview: 0),
        isNull,
      );
      expect(
        game2048HudRightFootnote(moves: 1, bonusPreview: 50),
        '+50 bônus',
      );
    });

    test('game2048CanMove detecta tabuleiro travado e móvel', () {
      final stuck = [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ];
      for (final d in Game2048Direction.values) {
        expect(game2048Move(stuck, d).changed, isFalse, reason: '$d');
      }
      expect(game2048CanMove(stuck), isFalse);

      final movable = [
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      expect(game2048CanMove(movable), isTrue);
    });
  });
}
