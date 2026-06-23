import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/economy/performance_tier.dart';
import '../../core/game_sdk/game_session_hud_actions.dart';

/// Constantes, paleta e regras puras da Paciência (Klondike).
abstract final class SolitaireConfig {
  static const optionKeyDrawCount = 'drawCount';

  static const pointsToFoundation = 10;
  static const pointsWasteToTableau = 5;
  static const pointsFlipTableau = 5;
  static const pointsFoundationToTableau = -15;
  static const winBonus = 500;

  static const timeBonusMax = 300;
  static const timeBonusPerSecond = 2;

  static const maxScore = 99999;

  /// Paleta alinhada ao card do hub (`HubTheme` id `solitaire`).
  static const cardColor = Color(0xFF2D6A4F);
  static const accentColor = Color(0xFFE17055);
  static const blendColor = Color(0xFF5C9E78);
  static const accentSoft = Color(0xFFFFB8A8);
  static const bgTop = Color(0xFF1B4332);
  static const bgBottom = Color(0xFF081C15);
  static const feltPattern = Color(0xFF2D6A4F);
  static const slotEmpty = Color(0xFF40916C);
  static const cardFace = Color(0xFFF8F9FA);
  static const cardBack = Color(0xFF1D3557);
  static const hudText = Color(0xFFF8F9FA);
  static const hudMuted = Color(0xFFB7E4C7);
  static const missRed = Color(0xFFFF7675);
  static const successGlow = Color(0xFFFDCB6E);
  static const suitRed = Color(0xFFE63946);
  static const suitBlack = Color(0xFF1D3557);

  static const flipAnimSec = 0.18;
  static const shakeSec = 0.28;

  /// Layout do tabuleiro (testável sem Flame).
  static const layoutMarginH = 16.0;
  static const layoutColGap = 5.0;
  static const layoutTopRowGap = 14.0;
  static const layoutHudGap = 10.0;
  static const layoutCardAspect = 1.38;
  static const layoutFaceDownOverlap = 0.17;
  static const layoutFaceUpOverlap = 0.27;
  static const layoutHudHeight = GameSessionHudActionBar.reservedHeight;
  /// Fallback se o layout não couber (não deve ocorrer no grid 7 colunas).
  static const layoutWasteFanFallback = 0.22;
}

/// Métricas de layout calculadas a partir do tamanho da tela.
class SolitaireBoardLayout {
  const SolitaireBoardLayout({
    required this.cardW,
    required this.cardH,
    required this.topY,
    required this.tableauY,
    required this.faceDownStep,
    required this.faceUpStep,
    required this.wasteFanStep,
    required this.colX,
  });

  final double cardW;
  final double cardH;
  final double topY;
  final double tableauY;
  final double faceDownStep;
  final double faceUpStep;
  /// Deslocamento horizontal entre cartas visíveis no descarte (modo 3 cartas).
  final double wasteFanStep;
  final List<double> colX;

  double get stockX => colX[0];
  double get wasteX => colX[1];
  double foundationX(int index) => colX[3 + index];
}

SolitaireBoardLayout solitaireBoardLayout({
  required double screenW,
  required double screenH,
}) {
  const marginH = SolitaireConfig.layoutMarginH;
  const colGap = SolitaireConfig.layoutColGap;
  const hudHeight = SolitaireConfig.layoutHudHeight;
  const topRowGap = SolitaireConfig.layoutTopRowGap;
  const bottomMargin = 12.0;

  final availW = screenW - marginH * 2;
  var cardW = (availW - colGap * 6) / 7;
  var cardH = cardW * SolitaireConfig.layoutCardAspect;
  var faceDownStep = cardH * SolitaireConfig.layoutFaceDownOverlap;
  var faceUpStep = cardH * SolitaireConfig.layoutFaceUpOverlap;

  List<double> colX() =>
      List.generate(7, (i) => marginH + i * (cardW + colGap));

  final availH = screenH - hudHeight - bottomMargin;
  var maxTableauH = 6 * faceUpStep + cardH;
  var boardH = cardH + topRowGap + maxTableauH;

  if (boardH > availH && boardH > 0) {
    final scale = availH / boardH;
    cardW *= scale;
    cardH = cardW * SolitaireConfig.layoutCardAspect;
    faceDownStep = cardH * SolitaireConfig.layoutFaceDownOverlap;
    faceUpStep = cardH * SolitaireConfig.layoutFaceUpOverlap;
    maxTableauH = 6 * faceUpStep + cardH;
    boardH = cardH + topRowGap + maxTableauH;
  }

  final verticalPad = max(8.0, (availH - boardH) / 2);
  final topY = hudHeight + SolitaireConfig.layoutHudGap + verticalPad;
  final tableauY = topY + cardH + topRowGap;

  final cols = colX();
  // Coluna 2 fica vazia entre descarte e fundações — usa o vão para o leque.
  final wasteFanAvailable = cols[3] - cols[1] - cardW;
  final wasteFanStep = wasteFanAvailable > 0
      ? wasteFanAvailable / 2
      : cardW * SolitaireConfig.layoutWasteFanFallback;

  return SolitaireBoardLayout(
    cardW: cardW,
    cardH: cardH,
    topY: topY,
    tableauY: tableauY,
    faceDownStep: faceDownStep,
    faceUpStep: faceUpStep,
    wasteFanStep: wasteFanStep,
    colX: cols,
  );
}

/// Quantas cartas do descarte ficam visíveis (1 no modo 1 carta, até 3 no modo 3).
int solitaireWasteVisibleCount(int wasteLength, int drawCount) {
  if (wasteLength == 0) return 0;
  if (drawCount <= 1) return 1;
  return wasteLength.clamp(1, 3);
}

enum SolitaireSuit { hearts, diamonds, clubs, spades }

enum SolitairePileKind { stock, waste, foundation, tableau }

/// Carta de baralho — [rank] 1 = Ás, 13 = Rei.
class SolitaireCard {
  SolitaireCard({
    required this.id,
    required this.suit,
    required this.rank,
    this.faceUp = false,
  });

  final int id;
  final SolitaireSuit suit;
  final int rank;
  bool faceUp;

  bool get isRed =>
      suit == SolitaireSuit.hearts || suit == SolitaireSuit.diamonds;

  SolitaireCard copyWith({bool? faceUp}) => SolitaireCard(
        id: id,
        suit: suit,
        rank: rank,
        faceUp: faceUp ?? this.faceUp,
      );
}

class SolitairePileRef {
  const SolitairePileRef(this.kind, [this.index = 0]);

  final SolitairePileKind kind;
  final int index;

  @override
  bool operator ==(Object other) =>
      other is SolitairePileRef &&
      other.kind == kind &&
      other.index == index;

  @override
  int get hashCode => Object.hash(kind, index);
}

class SolitaireMoveResult {
  const SolitaireMoveResult({
    required this.state,
    required this.scoreDelta,
    required this.moves,
    this.flippedTableau = false,
    this.toFoundation = false,
    this.won = false,
  });

  final SolitaireState state;
  final int scoreDelta;
  final int moves;
  final bool flippedTableau;
  final bool toFoundation;
  final bool won;
}

class SolitaireState {
  SolitaireState({
    required this.stock,
    required this.waste,
    required this.foundations,
    required this.tableau,
    required this.drawCount,
    this.moveScore = 0,
    this.moves = 0,
    this.foundationCards = 0,
  });

  final List<SolitaireCard> stock;
  final List<SolitaireCard> waste;
  final List<List<SolitaireCard>> foundations;
  final List<List<SolitaireCard>> tableau;
  final int drawCount;
  final int moveScore;
  final int moves;
  final int foundationCards;
}

List<SolitaireCard> solitaireCreateDeck() {
  final cards = <SolitaireCard>[];
  var id = 0;
  for (final suit in SolitaireSuit.values) {
    for (var rank = 1; rank <= 13; rank++) {
      cards.add(SolitaireCard(id: id++, suit: suit, rank: rank));
    }
  }
  return cards;
}

SolitaireState solitaireNewGame(Random random, {int drawCount = 1}) {
  final deck = solitaireCreateDeck()..shuffle(random);
  final tableau = List.generate(7, (_) => <SolitaireCard>[]);
  var idx = 0;
  for (var col = 0; col < 7; col++) {
    for (var row = 0; row <= col; row++) {
      final card = deck[idx++];
      card.faceUp = row == col;
      tableau[col].add(card);
    }
  }
  final stock = deck.sublist(idx);
  for (final card in stock) {
    card.faceUp = false;
  }
  return SolitaireState(
    stock: stock,
    waste: [],
    foundations: List.generate(4, (_) => <SolitaireCard>[]),
    tableau: tableau,
    drawCount: drawCount,
  );
}

bool solitaireCanPlaceOnTableau(SolitaireCard card, SolitaireCard? below) {
  if (below == null) return card.rank == 13;
  return card.isRed != below.isRed && card.rank == below.rank - 1;
}

bool solitaireCanPlaceOnFoundation(
  SolitaireCard card,
  List<SolitaireCard> foundation,
) {
  if (foundation.isEmpty) return card.rank == 1;
  final top = foundation.last;
  return card.suit == top.suit && card.rank == top.rank + 1;
}

bool solitaireIsValidTableauStack(List<SolitaireCard> column, int startIndex) {
  if (startIndex < 0 || startIndex >= column.length) return false;
  final stack = column.sublist(startIndex);
  if (!stack.first.faceUp) return false;
  for (var i = 0; i < stack.length - 1; i++) {
    final lower = stack[i];
    final upper = stack[i + 1];
    if (!upper.faceUp) return false;
    if (!solitaireCanPlaceOnTableau(upper, lower)) return false;
  }
  return true;
}

bool solitaireIsWon(SolitaireState state) =>
    state.foundations.every((pile) => pile.length == 13);

int solitaireFoundationCount(SolitaireState state) =>
    state.foundations.fold<int>(0, (sum, pile) => sum + pile.length);

List<SolitaireCard> solitaireSelectedCards(
  SolitaireState state,
  SolitairePileRef from,
  int tableauStartIndex,
) {
  return switch (from.kind) {
    SolitairePileKind.waste =>
      state.waste.isEmpty ? [] : [state.waste.last],
    SolitairePileKind.foundation =>
      state.foundations[from.index].isEmpty
          ? []
          : [state.foundations[from.index].last],
    SolitairePileKind.tableau =>
      state.tableau[from.index].sublist(tableauStartIndex),
    SolitairePileKind.stock => const [],
  };
}

bool solitaireCanMoveSelection(
  SolitaireState state,
  SolitairePileRef from,
  int tableauStartIndex,
  SolitairePileRef to,
) {
  if (from == to) return false;
  final cards = solitaireSelectedCards(state, from, tableauStartIndex);
  if (cards.isEmpty) return false;
  final moving = cards.first;

  return switch (to.kind) {
    SolitairePileKind.foundation => cards.length == 1 &&
        solitaireCanPlaceOnFoundation(
          moving,
          state.foundations[to.index],
        ),
    SolitairePileKind.tableau => () {
        if (from.kind == SolitairePileKind.tableau &&
            from.index == to.index) {
          return false;
        }
        if (from.kind == SolitairePileKind.tableau &&
            !solitaireIsValidTableauStack(
              state.tableau[from.index],
              tableauStartIndex,
            )) {
          return false;
        }
        final target = state.tableau[to.index];
        final below = target.isEmpty ? null : target.last;
        return solitaireCanPlaceOnTableau(moving, below);
      }(),
    _ => false,
  };
}

SolitaireMoveResult? solitaireTryMove(
  SolitaireState state,
  SolitairePileRef from,
  int tableauStartIndex,
  SolitairePileRef to,
) {
  if (!solitaireCanMoveSelection(state, from, tableauStartIndex, to)) {
    return null;
  }

  final cards = solitaireSelectedCards(state, from, tableauStartIndex);
  final next = _cloneState(state);
  _removeFromSource(next, from, tableauStartIndex, cards.length);

  var scoreDelta = 0;
  var flipped = false;
  var toFoundation = false;

  switch (to.kind) {
    case SolitairePileKind.foundation:
      next.foundations[to.index].add(cards.first);
      scoreDelta = SolitaireConfig.pointsToFoundation;
      toFoundation = true;
    case SolitairePileKind.tableau:
      next.tableau[to.index].addAll(cards);
      if (from.kind == SolitairePileKind.waste) {
        scoreDelta = SolitaireConfig.pointsWasteToTableau;
      } else if (from.kind == SolitairePileKind.foundation) {
        scoreDelta = SolitaireConfig.pointsFoundationToTableau;
      }
    case _:
      return null;
  }

  if (from.kind == SolitairePileKind.tableau) {
    final col = next.tableau[from.index];
    if (col.isNotEmpty && !col.last.faceUp) {
      col.last.faceUp = true;
      scoreDelta += SolitaireConfig.pointsFlipTableau;
      flipped = true;
    }
  }

  final foundationCards = solitaireFoundationCount(next);
  final won = solitaireIsWon(next);
  if (won) scoreDelta += SolitaireConfig.winBonus;

  return SolitaireMoveResult(
    state: SolitaireState(
      stock: next.stock,
      waste: next.waste,
      foundations: next.foundations,
      tableau: next.tableau,
      drawCount: next.drawCount,
      moveScore: state.moveScore + scoreDelta,
      moves: state.moves + 1,
      foundationCards: foundationCards,
    ),
    scoreDelta: scoreDelta,
    moves: state.moves + 1,
    flippedTableau: flipped,
    toFoundation: toFoundation,
    won: won,
  );
}

SolitaireMoveResult? solitaireDrawFromStock(SolitaireState state) {
  final next = _cloneState(state);

  if (next.stock.isNotEmpty) {
    final count = min(next.drawCount, next.stock.length);
    for (var i = 0; i < count; i++) {
      final card = next.stock.removeLast();
      card.faceUp = true;
      next.waste.add(card);
    }
    return SolitaireMoveResult(
      state: SolitaireState(
        stock: next.stock,
        waste: next.waste,
        foundations: next.foundations,
        tableau: next.tableau,
        drawCount: next.drawCount,
        moveScore: state.moveScore,
        moves: state.moves + 1,
        foundationCards: state.foundationCards,
      ),
      scoreDelta: 0,
      moves: state.moves + 1,
    );
  }

  if (next.waste.isEmpty) return null;

  final recycled = next.waste.reversed.toList();
  for (final card in recycled) {
    card.faceUp = false;
  }
  next.waste.clear();
  next.stock.addAll(recycled);

  return SolitaireMoveResult(
    state: SolitaireState(
      stock: next.stock,
      waste: next.waste,
      foundations: next.foundations,
      tableau: next.tableau,
      drawCount: next.drawCount,
      moveScore: state.moveScore,
      moves: state.moves + 1,
      foundationCards: state.foundationCards,
    ),
    scoreDelta: 0,
    moves: state.moves + 1,
  );
}

/// Auto-move para fundação quando possível (topo da seleção).
SolitaireMoveResult? solitaireAutoToFoundation(
  SolitaireState state,
  SolitairePileRef from,
  int tableauStartIndex,
) {
  final cards = solitaireSelectedCards(state, from, tableauStartIndex);
  if (cards.length != 1) return null;
  for (var i = 0; i < 4; i++) {
    final to = SolitairePileRef(SolitairePileKind.foundation, i);
    final result = solitaireTryMove(state, from, tableauStartIndex, to);
    if (result != null) return result;
  }
  return null;
}

SolitaireState _cloneState(SolitaireState state) {
  return SolitaireState(
    stock: state.stock.map((c) => c.copyWith(faceUp: c.faceUp)).toList(),
    waste: state.waste.map((c) => c.copyWith(faceUp: c.faceUp)).toList(),
    foundations: state.foundations
        .map((pile) => pile.map((c) => c.copyWith(faceUp: c.faceUp)).toList())
        .toList(),
    tableau: state.tableau
        .map((pile) => pile.map((c) => c.copyWith(faceUp: c.faceUp)).toList())
        .toList(),
    drawCount: state.drawCount,
    moveScore: state.moveScore,
    moves: state.moves,
    foundationCards: state.foundationCards,
  );
}

void _removeFromSource(
  SolitaireState state,
  SolitairePileRef from,
  int tableauStartIndex,
  int count,
) {
  switch (from.kind) {
    case SolitairePileKind.waste:
      state.waste.removeLast();
    case SolitairePileKind.foundation:
      state.foundations[from.index].removeLast();
    case SolitairePileKind.tableau:
      state.tableau[from.index].removeRange(
        tableauStartIndex,
        tableauStartIndex + count,
      );
    case SolitairePileKind.stock:
      break;
  }
}

int solitaireProgressScore(SolitaireState state) =>
    state.moveScore.clamp(0, SolitaireConfig.maxScore);

int solitaireTimeBonusRemaining(Duration elapsed) {
  final sec = elapsed.inSeconds;
  return (SolitaireConfig.timeBonusMax - sec * SolitaireConfig.timeBonusPerSecond)
      .clamp(0, SolitaireConfig.timeBonusMax);
}

int solitaireFinalScore({
  required int moveScore,
  required Duration duration,
  required bool won,
}) {
  final timeBonus = won ? solitaireTimeBonusRemaining(duration) : 0;
  return (moveScore + timeBonus).clamp(0, SolitaireConfig.maxScore);
}

String solitaireRankLabel(int rank) => switch (rank) {
      1 => 'A',
      11 => 'J',
      12 => 'Q',
      13 => 'K',
      _ => '$rank',
    };

String solitaireSuitSymbol(SolitaireSuit suit) => switch (suit) {
      SolitaireSuit.hearts => '♥',
      SolitaireSuit.diamonds => '♦',
      SolitaireSuit.clubs => '♣',
      SolitaireSuit.spades => '♠',
    };

Color solitaireSuitColor(SolitaireSuit suit) =>
    suit == SolitaireSuit.hearts || suit == SolitaireSuit.diamonds
        ? SolitaireConfig.suitRed
        : SolitaireConfig.suitBlack;

String solitaireHudTimeBonusLabel(int bonus) =>
    bonus > 0 ? '+$bonus tempo' : 'Sem bônus tempo';

String solitaireHudElapsedLabel(Duration elapsed) {
  final m = elapsed.inMinutes;
  final s = elapsed.inSeconds.remainder(60);
  return '$m:${s.toString().padLeft(2, '0')}';
}

PerformanceTier solitairePerformanceTier({
  required bool won,
  required int foundationCards,
}) {
  if (won) return PerformanceTier.gold;
  if (foundationCards >= 26) return PerformanceTier.silver;
  return PerformanceTier.bronze;
}
