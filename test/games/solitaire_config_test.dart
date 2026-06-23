import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/economy/performance_tier.dart';
import 'package:minigames_hub/games/solitaire/solitaire_config.dart';

void main() {
  group('SolitaireConfig', () {
    test('novo jogo distribui 28 cartas no tableau e 24 no estoque', () {
      final state = solitaireNewGame(Random(123));
      final tableauCount =
          state.tableau.fold<int>(0, (sum, col) => sum + col.length);
      expect(tableauCount, 28);
      expect(state.stock.length, 24);
      expect(state.waste, isEmpty);
      expect(state.foundations.every((f) => f.isEmpty), isTrue);
    });

    test('cada coluna do tableau termina com carta virada', () {
      final state = solitaireNewGame(Random(42));
      for (final col in state.tableau) {
        expect(col.last.faceUp, isTrue);
      }
    });

    test('validação de coluna alternando cores', () {
      final red = SolitaireCard(id: 0, suit: SolitaireSuit.hearts, rank: 8, faceUp: true);
      final black = SolitaireCard(id: 1, suit: SolitaireSuit.spades, rank: 7, faceUp: true);
      expect(solitaireCanPlaceOnTableau(black, red), isTrue);
      expect(solitaireCanPlaceOnTableau(red, black), isFalse);
      expect(
        solitaireCanPlaceOnTableau(
          SolitaireCard(id: 2, suit: SolitaireSuit.hearts, rank: 6, faceUp: true),
          red,
        ),
        isFalse,
      );
    });

    test('rei na coluna vazia e ás na fundação vazia', () {
      final king = SolitaireCard(id: 0, suit: SolitaireSuit.spades, rank: 13, faceUp: true);
      final ace = SolitaireCard(id: 1, suit: SolitaireSuit.hearts, rank: 1, faceUp: true);
      expect(solitaireCanPlaceOnTableau(king, null), isTrue);
      expect(solitaireCanPlaceOnTableau(ace, null), isFalse);
      expect(solitaireCanPlaceOnFoundation(ace, []), isTrue);
      expect(solitaireCanPlaceOnFoundation(king, []), isFalse);
    });

    test('descarte para coluna válida (cor oposta, rank -1)', () {
      final state = SolitaireState(
        stock: const [],
        waste: [
          SolitaireCard(id: 9, suit: SolitaireSuit.spades, rank: 9, faceUp: true),
        ],
        foundations: List.generate(4, (_) => <SolitaireCard>[]),
        tableau: [
          ...List.generate(4, (_) => <SolitaireCard>[]),
          [
            SolitaireCard(
              id: 10,
              suit: SolitaireSuit.diamonds,
              rank: 10,
              faceUp: true,
            ),
          ],
          ...List.generate(2, (_) => <SolitaireCard>[]),
        ],
        drawCount: 1,
      );

      expect(
        solitaireCanMoveSelection(
          state,
          const SolitairePileRef(SolitairePileKind.waste),
          0,
          const SolitairePileRef(SolitairePileKind.tableau, 4),
        ),
        isTrue,
      );

      final result = solitaireTryMove(
        state,
        const SolitairePileRef(SolitairePileKind.waste),
        0,
        const SolitairePileRef(SolitairePileKind.tableau, 4),
      );

      expect(result, isNotNull);
      expect(result!.scoreDelta, SolitaireConfig.pointsWasteToTableau);
      expect(result.state.waste, isEmpty);
      expect(result.state.tableau[4].map((c) => c.rank).toList(), [10, 9]);
    });

    test('mover para fundação soma pontos', () {
      final state = SolitaireState(
        stock: const [],
        waste: [
          SolitaireCard(id: 0, suit: SolitaireSuit.hearts, rank: 1, faceUp: true),
        ],
        foundations: List.generate(4, (_) => <SolitaireCard>[]),
        tableau: List.generate(7, (_) => <SolitaireCard>[]),
        drawCount: 1,
      );

      final result = solitaireTryMove(
        state,
        const SolitairePileRef(SolitairePileKind.waste),
        0,
        const SolitairePileRef(SolitairePileKind.foundation, 0),
      );

      expect(result, isNotNull);
      expect(result!.scoreDelta, SolitaireConfig.pointsToFoundation);
      expect(result.state.foundations[0].length, 1);
      expect(result.state.waste, isEmpty);
    });

    test('virar carta do tableau após mover dá bônus', () {
      final state = SolitaireState(
        stock: const [],
        waste: const [],
        foundations: List.generate(4, (_) => <SolitaireCard>[]),
        tableau: [
          [
            SolitaireCard(id: 0, suit: SolitaireSuit.spades, rank: 11, faceUp: true),
          ],
          [
            SolitaireCard(id: 1, suit: SolitaireSuit.hearts, rank: 10, faceUp: false),
            SolitaireCard(id: 2, suit: SolitaireSuit.diamonds, rank: 10, faceUp: true),
          ],
          ...List.generate(5, (_) => <SolitaireCard>[]),
        ],
        drawCount: 1,
      );

      final result = solitaireTryMove(
        state,
        const SolitairePileRef(SolitairePileKind.tableau, 1),
        1,
        const SolitairePileRef(SolitairePileKind.tableau, 0),
      );

      expect(result, isNotNull);
      expect(result!.flippedTableau, isTrue);
      expect(result.scoreDelta, SolitaireConfig.pointsFlipTableau);
      expect(result.state.tableau[1].single.faceUp, isTrue);
      expect(result.state.tableau[1].single.rank, 10);
    });

    test('vitória detectada com 52 cartas nas fundações', () {
      final foundations = List.generate(
        4,
        (suitIdx) => List.generate(
          13,
          (rank) => SolitaireCard(
            id: suitIdx * 13 + rank,
            suit: SolitaireSuit.values[suitIdx],
            rank: rank + 1,
            faceUp: true,
          ),
        ),
      );
      final state = SolitaireState(
        stock: const [],
        waste: const [],
        foundations: foundations,
        tableau: List.generate(7, (_) => <SolitaireCard>[]),
        drawCount: 1,
      );
      expect(solitaireIsWon(state), isTrue);
    });

    test('placar final inclui bônus de tempo só ao vencer', () {
      expect(
        solitaireFinalScore(
          moveScore: 400,
          duration: const Duration(seconds: 30),
          won: true,
        ),
        400 + solitaireTimeBonusRemaining(const Duration(seconds: 30)),
      );
      expect(
        solitaireFinalScore(
          moveScore: 400,
          duration: const Duration(seconds: 30),
          won: false,
        ),
        400,
      );
    });

    test('bônus de tempo decai com o relógio', () {
      expect(solitaireTimeBonusRemaining(Duration.zero), SolitaireConfig.timeBonusMax);
      expect(
        solitaireTimeBonusRemaining(const Duration(seconds: 50)),
        lessThan(SolitaireConfig.timeBonusMax),
      );
    });

    test('layout mobile 390px alinha estoque e fundações às colunas', () {
      final layout = solitaireBoardLayout(screenW: 390, screenH: 844);
      expect(layout.colX.length, 7);
      expect(layout.stockX, layout.colX[0]);
      expect(layout.wasteX, layout.colX[1]);
      expect(layout.foundationX(0), layout.colX[3]);
      expect(layout.foundationX(3), layout.colX[6]);

      final colGap = layout.colX[1] - layout.colX[0] - layout.cardW;
      expect(colGap, closeTo(SolitaireConfig.layoutColGap, 0.01));

      expect(layout.tableauY, greaterThan(layout.topY + layout.cardH));
      expect(layout.topY, greaterThan(SolitaireConfig.layoutHudHeight));
    });

    test('layout escala para caber em telas baixas', () {
      final tall = solitaireBoardLayout(screenW: 390, screenH: 844);
      final short = solitaireBoardLayout(screenW: 390, screenH: 560);
      expect(short.cardW, lessThanOrEqualTo(tall.cardW));
    });

    test('layout reserva espaço para leque de 3 cartas no descarte', () {
      final layout = solitaireBoardLayout(screenW: 390, screenH: 844);
      final spread = layout.cardW + layout.wasteFanStep * 2;
      final maxSpread = layout.foundationX(0) - layout.wasteX;
      expect(spread, lessThanOrEqualTo(maxSpread + 0.01));
      expect(layout.wasteFanStep, greaterThan(layout.cardW * 0.2));
    });

    test('visível no descarte respeita drawCount', () {
      expect(solitaireWasteVisibleCount(5, 1), 1);
      expect(solitaireWasteVisibleCount(2, 3), 2);
      expect(solitaireWasteVisibleCount(5, 3), 3);
      expect(solitaireWasteVisibleCount(0, 3), 0);
    });

    test('label de tempo formatado', () {
      expect(
        solitaireHudElapsedLabel(const Duration(minutes: 2, seconds: 5)),
        '2:05',
      );
    });
  });

  group('solitairePerformanceTier', () {
    test('vencer é ouro', () {
      expect(
        solitairePerformanceTier(won: true, foundationCards: 52),
        PerformanceTier.gold,
      );
    });

    test('derrota com metade das fundações é prata', () {
      expect(
        solitairePerformanceTier(won: false, foundationCards: 26),
        PerformanceTier.silver,
      );
    });

    test('derrota com poucas fundações é bronze', () {
      expect(
        solitairePerformanceTier(won: false, foundationCards: 10),
        PerformanceTier.bronze,
      );
    });
  });
}
