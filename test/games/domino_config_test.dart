import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/economy/performance_tier.dart';
import 'package:minigames_hub/core/l10n/l10n_scope.dart';
import 'package:minigames_hub/games/domino/domino_config.dart';

void main() {
  setUpAll(() async {
    await L10nScope.installForTest();
  });

  group('DominoConfig', () {
    test('conjunto completo tem 28 peças double-six', () {
      final set = dominoCreateSet();
      expect(set.length, 28);
      expect(set.where((t) => t.isDouble).length, 7);
    });

    test('novo jogo distribui 7 peças por jogador e 14 no monte', () {
      final state = dominoNewGame(Random(42));
      expect(state.humanHand.length, 7);
      expect(state.cpuHand.length, 7);
      expect(state.boneyard.length, 14);
      expect(state.chain, isEmpty);
    });

    test('abertura exige a peça definida pelo starter', () {
      final state = dominoNewGame(Random(7));
      final openingId = state.openingTileId!;
      final plays = dominoValidPlays(state, state.turn);
      expect(plays, hasLength(1));
      final hand = state.handFor(state.turn);
      expect(hand[plays.first.handIndex].id, openingId);
    });

    test('jogada válida conecta pontas da fileira', () {
      var state = dominoNewGame(Random(1));
      final starter = state.turn;
      final opening = dominoValidPlays(state, starter).first;
      state = dominoApplyPlay(state, starter, opening).copyWithOpeningDone();

      final next = dominoNextPlayer(starter);
      final plays = dominoValidPlays(state, next);
      for (final play in plays) {
        final tile = state.handFor(next)[play.handIndex];
        final end = play.end == DominoChainEnd.left
            ? state.chainLeftEnd()
            : state.chainRightEnd();
        expect(tile.matches(end), isTrue);
      }
    });

    test('comprar do monte reduz pontuação do humano', () {
      var state = DominoState(
        humanHand: const [DominoTile(id: 99, left: 0, right: 1)],
        cpuHand: const [DominoTile(id: 98, left: 2, right: 3)],
        boneyard: const [DominoTile(id: 0, left: 4, right: 5)],
        chain: const [
          PlacedDomino(tile: DominoTile(id: 1, left: 4, right: 6)),
        ],
        turn: DominoPlayer.human,
        openingRequired: false,
        progressScore: 30,
      );

      final result = dominoDrawTile(state, DominoPlayer.human);
      expect(result.drawn, isTrue);
      expect(result.state.humanHand.length, 2);
      expect(result.state.boneyard.length, 0);
      expect(result.scoreDelta, -DominoConfig.drawPenalty);
      expect(result.state.progressScore, 27);
    });

    test('jogada da CPU altera o estado sem pontuar o humano', () {
      var state = DominoState(
        humanHand: const [DominoTile(id: 98, left: 0, right: 0)],
        cpuHand: const [
          DominoTile(id: 10, left: 2, right: 5),
          DominoTile(id: 11, left: 3, right: 4),
        ],
        boneyard: const [],
        chain: const [
          PlacedDomino(tile: DominoTile(id: 1, left: 5, right: 1)),
        ],
        turn: DominoPlayer.cpu,
        openingRequired: false,
        progressScore: 45,
      );

      final play = dominoValidPlays(state, DominoPlayer.cpu).first;
      final result = dominoTryPlay(state, DominoPlayer.cpu, play);

      expect(result.finished, isFalse);
      expect(result.scoreDelta, 0);
      expect(result.state.progressScore, 45);
      expect(result.state.cpuHand.length, 1);
      expect(result.state.turn, DominoPlayer.human);
      expect(identical(result.state, state), isFalse);
    });

    test('vitória ao esvaziar a mão', () {
      var state = DominoState(
        humanHand: const [DominoTile(id: 0, left: 3, right: 5)],
        cpuHand: const [DominoTile(id: 1, left: 2, right: 2)],
        boneyard: const [],
        chain: const [
          PlacedDomino(tile: DominoTile(id: 2, left: 5, right: 1)),
        ],
        turn: DominoPlayer.human,
        openingRequired: false,
      );

      final play = dominoValidPlays(state, DominoPlayer.human).first;
      final result = dominoTryPlay(state, DominoPlayer.human, play);
      expect(result.finished, isTrue);
      expect(result.state.winner, DominoPlayer.human);
      expect(result.state.humanHand, isEmpty);
    });

    test('pontuação final inclui bônus de vitória e tempo', () {
      final score = dominoFinalScore(
        progressScore: 60,
        humanWon: true,
        opponentHand: const [DominoTile(id: 0, left: 5, right: 5)],
        blocked: false,
        elapsedSec: 10,
      );
      // 60 + (10 pips * 3) + (150 - 20) tempo
      expect(score, 60 + 30 + 130);
    });

    test('layout reserva área para mão e mesa da fileira', () {
      final layout = dominoBoardLayout(
        screenW: 390,
        screenH: 844,
        humanHandCount: 7,
        cpuHandCount: 7,
      );
      expect(layout.playerTileXs.length, 7);
      expect(layout.tileW, greaterThan(0));
      expect(layout.playerY, greaterThan(layout.cpuY));
      expect(layout.chainTableBounds.height, greaterThan(80));
    });

    test('orientação da peça conecta na ponta correta', () {
      const tileRight = DominoTile(id: 10, left: 2, right: 5);
      const tileLeft = DominoTile(id: 11, left: 5, right: 2);

      expect(
        dominoFlipForChainEnd(tileRight, 5, DominoChainEnd.left),
        isFalse,
      );
      expect(
        dominoFlipForChainEnd(tileLeft, 5, DominoChainEnd.left),
        isTrue,
      );
      expect(
        dominoFlipForChainEnd(tileRight, 5, DominoChainEnd.right),
        isTrue,
      );
      expect(
        dominoFlipForChainEnd(tileLeft, 5, DominoChainEnd.right),
        isFalse,
      );
    });

    test('jogada aplicada mantém encaixe entre peças', () {
      var state = DominoState(
        humanHand: const [DominoTile(id: 10, left: 2, right: 5)],
        cpuHand: const [DominoTile(id: 98, left: 0, right: 0)],
        boneyard: const [],
        chain: const [
          PlacedDomino(tile: DominoTile(id: 1, left: 5, right: 1)),
        ],
        turn: DominoPlayer.human,
        openingRequired: false,
      );

      final play = dominoValidPlays(state, DominoPlayer.human).single;
      expect(dominoConnectingPip(state.humanHand[play.handIndex], play), 5);

      state = dominoApplyPlay(state, DominoPlayer.human, play);
      expect(state.chain.first.outwardRight, state.chain[1].outwardLeft);
    });

    test('layout da fileira em serpentina expõe zonas de drop', () {
      final table = const Rect.fromLTWH(12, 200, 366, 280);
      final filled = dominoChainLayout(
        screenW: 390,
        tableBounds: table,
        baseTileW: 48,
        baseTileH: 92,
        chainLength: 3,
      );
      expect(filled.slots.length, 3);
      expect(filled.tileW, greaterThan(filled.tileH));
      expect(filled.leftDropZone.width, greaterThan(0));
      expect(filled.rightDropZone.width, greaterThan(0));

      final long = dominoChainLayout(
        screenW: 390,
        tableBounds: table,
        baseTileW: 48,
        baseTileH: 92,
        chainLength: 14,
      );
      expect(long.slots.length, 14);
      expect(long.slots.first.rect.top, lessThan(long.slots.last.rect.top + 1));

      final empty = dominoChainLayout(
        screenW: 390,
        tableBounds: table,
        baseTileW: 48,
        baseTileH: 92,
        chainLength: 0,
      );
      expect(empty.emptyDropZone.width, greaterThan(0));
      expect(empty.leftDropZone, Rect.zero);
    });

    test('fileira vira a quina com peça vertical ao quebrar de linha', () {
      final table = const Rect.fromLTWH(12, 200, 366, 280);
      final layout = dominoChainLayout(
        screenW: 390,
        tableBounds: table,
        baseTileW: 48,
        baseTileH: 92,
        chainLength: 14,
      );

      // Peças da 1ª linha são horizontais (mesmo topo).
      final firstRowTop = layout.slots.first.rect.top;
      final firstRow = layout.slots
          .where((s) => (s.rect.top - firstRowTop).abs() < 0.5)
          .toList();
      expect(firstRow.length, greaterThan(1));
      expect(firstRow.every((s) => s.horizontal), isTrue);

      // A 1ª peça da 2ª linha é a esquina: vertical, encostada na última da 1ª.
      final lastOfFirstRow = firstRow.last.rect;
      final corner = layout.slots[firstRow.length];
      expect(corner.horizontal, isFalse);
      expect(corner.rect.height, greaterThan(corner.rect.width));
      expect(corner.rect.left, closeTo(lastOfFirstRow.right, 0.5));
    });

    test('peças da fileira encostam sem folga horizontal', () {
      final table = const Rect.fromLTWH(12, 200, 366, 280);
      final layout = dominoChainLayout(
        screenW: 390,
        tableBounds: table,
        baseTileW: 48,
        baseTileH: 92,
        chainLength: 5,
      );

      for (var i = 1; i < 5; i++) {
        final prev = layout.slots[i - 1];
        final curr = layout.slots[i];
        if (prev.horizontal && curr.horizontal) {
          expect(curr.rect.left, closeTo(prev.rect.right, 0.5));
        }
      }
    });

    test('dupla na fileira fica perpendicular à linha', () {
      final table = const Rect.fromLTWH(12, 200, 366, 280);
      final chain = [
        const PlacedDomino(tile: DominoTile(id: 0, left: 3, right: 3)),
        const PlacedDomino(tile: DominoTile(id: 1, left: 3, right: 6)),
        const PlacedDomino(tile: DominoTile(id: 2, left: 6, right: 4)),
      ];
      final layout = dominoChainLayout(
        screenW: 390,
        tableBounds: table,
        baseTileW: 48,
        baseTileH: 92,
        chainLength: 3,
        chain: chain,
      );

      expect(layout.slots.first.horizontal, isFalse);
      expect(layout.slots.first.rect.height, greaterThan(layout.slots.first.rect.width));
      expect(layout.slots[1].horizontal, isTrue);
      expect(layout.slots[1].rect.left, closeTo(layout.slots.first.rect.right, 0.5));
    });

    test('peças de linhas invertidas são espelhadas no encaixe', () {
      final table = const Rect.fromLTWH(12, 200, 366, 280);
      final layout = dominoChainLayout(
        screenW: 390,
        tableBounds: table,
        baseTileW: 48,
        baseTileH: 92,
        chainLength: 14,
      );

      // 1ª linha (esquerda→direita) não espelha.
      final firstRowTop = layout.slots.first.rect.top;
      final firstRow = layout.slots
          .where((s) => (s.rect.top - firstRowTop).abs() < 0.5)
          .toList();
      expect(firstRow.every((s) => !s.mirrored), isTrue);

      // Esquinas (verticais) nunca espelham.
      final corners = layout.slots.where((s) => !s.horizontal);
      expect(corners.every((s) => !s.mirrored), isTrue);

      // Há ao menos uma peça horizontal espelhada (linha que corre p/ esquerda).
      expect(
        layout.slots.any((s) => s.horizontal && s.mirrored),
        isTrue,
      );
    });

    test('setas das pontas seguem o sentido da fileira', () {
      final table = const Rect.fromLTWH(12, 200, 366, 280);
      final wrapped = dominoChainLayout(
        screenW: 390,
        tableBounds: table,
        baseTileW: 48,
        baseTileH: 92,
        chainLength: 14,
      );
      // Ponta esquerda (peça de abertura) sempre abre p/ a esquerda.
      expect(wrapped.leftEndArrow, const Offset(-1, 0));
      // Em linha única a ponta direita abre p/ direita.
      final single = dominoChainLayout(
        screenW: 390,
        tableBounds: table,
        baseTileW: 48,
        baseTileH: 92,
        chainLength: 3,
      );
      expect(single.rightEndArrow, const Offset(1, 0));
    });

    test('layout da fileira com uma peça expõe slot 0', () {
      final table = const Rect.fromLTWH(12, 200, 366, 280);
      final opening = dominoChainLayout(
        screenW: 390,
        tableBounds: table,
        baseTileW: 48,
        baseTileH: 92,
        chainLength: 1,
      );
      expect(opening.slots.length, 1);
      expect(opening.slotRect(0), isNotNull);
    });

    test('preview do HUD de bônus tempo', () {
      expect(dominoHudTimeBonusPreview(0), '+150 tempo');
      expect(dominoTimeBonusRemaining(75), 0);
    });
  });

  group('dominoPerformanceTier', () {
    test('vitória é sempre ouro', () {
      expect(
        dominoPerformanceTier(humanWon: true),
        PerformanceTier.gold,
      );
      expect(
        dominoPerformanceTier(humanWon: true, opponentPips: 40),
        PerformanceTier.gold,
      );
    });

    test('derrota apertada (poucos pips na mão) é prata', () {
      expect(
        dominoPerformanceTier(humanWon: false, humanPips: 4),
        PerformanceTier.silver,
      );
    });

    test('derrota feia (mão cheia) é bronze', () {
      expect(
        dominoPerformanceTier(humanWon: false, humanPips: 40),
        PerformanceTier.bronze,
      );
    });
  });
}

extension on DominoState {
  DominoState copyWithOpeningDone() => DominoState(
        humanHand: humanHand,
        cpuHand: cpuHand,
        boneyard: boneyard,
        chain: chain,
        turn: turn,
        winner: winner,
        blocked: blocked,
        humanTilesPlayed: humanTilesPlayed,
        draws: draws,
        passes: passes,
        consecutivePasses: consecutivePasses,
        openingRequired: false,
        openingTileId: null,
        progressScore: progressScore,
        difficulty: difficulty,
      );
}
