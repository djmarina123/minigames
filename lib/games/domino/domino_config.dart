import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/economy/performance_tier.dart';

/// Constantes, paleta e regras puras do Dominó (block vs CPU).
abstract final class DominoConfig {
  static const optionKeyDifficulty = 'difficulty';

  static const difficultyEasy = 'easy';
  static const difficultyNormal = 'normal';
  static const difficultyHard = 'hard';

  static const tilesPerPlayer = 7;
  static const maxPip = 6;

  static const pointsPerTilePlayed = 15;
  static const winBonusPerOpponentPip = 3;
  static const drawPenalty = 3;
  static const timeBonusMax = 150;
  static const timeBonusPerSecond = 2;

  /// Paleta alinhada ao card do hub (`HubTheme` id `domino`).
  static const cardColor = Color(0xFF6D4C41);
  static const accentColor = Color(0xFFFFB74D);
  static const blendColor = Color(0xFF9E7B6A);
  static const accentSoft = Color(0xFFFFE0B2);
  static const bgTop = Color(0xFF4E342E);
  static const bgBottom = Color(0xFF2C1810);
  static const feltPattern = Color(0xFF5D4037);
  static const tileFace = Color(0xFFF5F0E8);
  static const tileBack = Color(0xFF3E2723);
  static const pipColor = Color(0xFF2C1810);
  static const hudText = Color(0xFFF5F0E8);
  static const hudMuted = Color(0xFFD7CCC8);
  static const missRed = Color(0xFFFF7675);
  static const successGlow = Color(0xFFFFCA28);

  static const placeAnimSec = 0.38;
  static const lastMoveHighlightSec = 1.6;
  static const shakeSec = 0.28;
  static const cpuThinkSecMin = 0.45;
  static const cpuThinkSecMax = 0.85;
  static const chainTileScale = 0.88;
  static const chainRowGap = 8.0;
  static const chainMinScale = 0.62;

  static const layoutMarginH = 12.0;
  static const layoutHudGap = 8.0;
  static const layoutTileAspect = 0.52;
}

/// Peça de dominó — valores de 0 a 6 em cada lado.
class DominoTile {
  const DominoTile({
    required this.id,
    required this.left,
    required this.right,
  });

  final int id;
  final int left;
  final int right;

  int get pips => left + right;
  bool get isDouble => left == right;

  bool matches(int value) => left == value || right == value;

  @override
  bool operator ==(Object other) =>
      other is DominoTile && other.id == id;

  @override
  int get hashCode => id;
}

enum DominoPlayer { human, cpu }

enum DominoChainEnd { left, right }

/// Peça colocada na mesa — [flipped] inverte visualmente esquerda/direita.
class PlacedDomino {
  const PlacedDomino({
    required this.tile,
    this.flipped = false,
  });

  final DominoTile tile;
  final bool flipped;

  int get outwardLeft => flipped ? tile.right : tile.left;
  int get outwardRight => flipped ? tile.left : tile.right;
}

class DominoPlay {
  const DominoPlay({
    required this.handIndex,
    required this.end,
    required this.flipped,
  });

  final int handIndex;
  final DominoChainEnd end;
  final bool flipped;
}

class DominoMoveResult {
  const DominoMoveResult({
    required this.state,
    required this.scoreDelta,
    this.drawn = false,
    this.passed = false,
    this.finished = false,
  });

  final DominoState state;
  final int scoreDelta;
  final bool drawn;
  final bool passed;
  final bool finished;
}

class DominoState {
  const DominoState({
    required this.humanHand,
    required this.cpuHand,
    required this.boneyard,
    required this.chain,
    required this.turn,
    this.winner,
    this.blocked = false,
    this.humanTilesPlayed = 0,
    this.draws = 0,
    this.passes = 0,
    this.consecutivePasses = 0,
    this.openingRequired = true,
    this.openingTileId,
    this.progressScore = 0,
    this.difficulty = DominoConfig.difficultyNormal,
  });

  final List<DominoTile> humanHand;
  final List<DominoTile> cpuHand;
  final List<DominoTile> boneyard;
  final List<PlacedDomino> chain;
  final DominoPlayer turn;
  final DominoPlayer? winner;
  final bool blocked;
  final int humanTilesPlayed;
  final int draws;
  final int passes;
  final int consecutivePasses;
  final bool openingRequired;
  final int? openingTileId;
  final int progressScore;
  final String difficulty;

  bool get isFinished => winner != null;

  List<DominoTile> handFor(DominoPlayer player) =>
      player == DominoPlayer.human ? humanHand : cpuHand;

  int chainLeftEnd() {
    if (chain.isEmpty) return -1;
    return chain.first.outwardLeft;
  }

  int chainRightEnd() {
    if (chain.isEmpty) return -1;
    return chain.last.outwardRight;
  }
}

List<DominoTile> dominoCreateSet() {
  final tiles = <DominoTile>[];
  var id = 0;
  for (var a = 0; a <= DominoConfig.maxPip; a++) {
    for (var b = a; b <= DominoConfig.maxPip; b++) {
      tiles.add(DominoTile(id: id++, left: a, right: b));
    }
  }
  return tiles;
}

int dominoHandPipSum(List<DominoTile> hand) =>
    hand.fold<int>(0, (sum, tile) => sum + tile.pips);

DominoState dominoNewGame(Random random, {String difficulty = DominoConfig.difficultyNormal}) {
  final deck = dominoCreateSet()..shuffle(random);
  final human = deck.sublist(0, DominoConfig.tilesPerPlayer);
  final cpu = deck.sublist(
    DominoConfig.tilesPerPlayer,
    DominoConfig.tilesPerPlayer * 2,
  );
  final boneyard = deck.sublist(DominoConfig.tilesPerPlayer * 2);

  final starter = dominoFindStarter(human, cpu);
  final openingTile = starter.$2;

  return DominoState(
    humanHand: human,
    cpuHand: cpu,
    boneyard: boneyard,
    chain: const [],
    turn: starter.$1 == 0 ? DominoPlayer.human : DominoPlayer.cpu,
    openingRequired: true,
    openingTileId: openingTile.id,
    difficulty: difficulty,
  );
}

/// Retorna (0 = humano, 1 = CPU) e a peça de abertura.
(int, DominoTile) dominoFindStarter(
  List<DominoTile> human,
  List<DominoTile> cpu,
) {
  DominoTile? best;
  var bestPlayer = 0;

  void consider(List<DominoTile> hand, int player) {
    for (final tile in hand) {
      if (tile.isDouble) {
        if (best == null || !best!.isDouble || tile.left > best!.left) {
          best = tile;
          bestPlayer = player;
        }
      }
    }
  }

  consider(human, 0);
  consider(cpu, 1);

  if (best != null) return (bestPlayer, best!);

  var highestPips = -1;
  DominoTile? highestTile;
  for (final tile in [...human, ...cpu]) {
    if (tile.pips > highestPips) {
      highestPips = tile.pips;
      highestTile = tile;
      bestPlayer = human.any((t) => t.id == tile.id) ? 0 : 1;
    }
  }
  return (bestPlayer, highestTile!);
}

List<DominoPlay> dominoValidPlays(DominoState state, DominoPlayer player) {
  final hand = state.handFor(player);
  if (hand.isEmpty) return const [];

  if (state.openingRequired && state.openingTileId != null) {
    final idx = hand.indexWhere((t) => t.id == state.openingTileId);
    if (idx < 0) return const [];
    return [
      DominoPlay(handIndex: idx, end: DominoChainEnd.left, flipped: false),
    ];
  }

  if (state.chain.isEmpty) {
    return [
      for (var i = 0; i < hand.length; i++)
        DominoPlay(handIndex: i, end: DominoChainEnd.left, flipped: false),
    ];
  }

  final leftEnd = state.chainLeftEnd();
  final rightEnd = state.chainRightEnd();
  final plays = <DominoPlay>[];

  for (var i = 0; i < hand.length; i++) {
    final tile = hand[i];
    if (tile.matches(leftEnd)) {
      plays.add(
        DominoPlay(
          handIndex: i,
          end: DominoChainEnd.left,
          flipped: dominoFlipForChainEnd(tile, leftEnd, DominoChainEnd.left),
        ),
      );
    }
    if (tile.matches(rightEnd)) {
      plays.add(
        DominoPlay(
          handIndex: i,
          end: DominoChainEnd.right,
          flipped: dominoFlipForChainEnd(tile, rightEnd, DominoChainEnd.right),
        ),
      );
    }
  }
  return plays;
}

/// Orienta a peça para que o lado interno encaixe na ponta da fileira.
bool dominoFlipForChainEnd(
  DominoTile tile,
  int chainEnd,
  DominoChainEnd side,
) {
  if (side == DominoChainEnd.left) {
    // outwardRight conecta à ponta esquerda da fileira.
    return tile.right != chainEnd;
  }
  // outwardLeft conecta à ponta direita da fileira.
  return tile.left != chainEnd;
}

/// Ponto da peça que encaixa na fileira ao jogar em [side].
int dominoConnectingPip(DominoTile tile, DominoPlay play) {
  if (play.end == DominoChainEnd.left) {
    return play.flipped ? tile.left : tile.right;
  }
  return play.flipped ? tile.right : tile.left;
}

bool dominoCanPlay(DominoState state, DominoPlayer player) =>
    dominoValidPlays(state, player).isNotEmpty;

DominoState dominoApplyPlay(DominoState state, DominoPlayer player, DominoPlay play) {
  final hand = List<DominoTile>.from(state.handFor(player));
  final tile = hand.removeAt(play.handIndex);
  final chain = List<PlacedDomino>.from(state.chain);
  final placed = PlacedDomino(tile: tile, flipped: play.flipped);

  if (chain.isEmpty) {
    chain.add(placed);
  } else if (play.end == DominoChainEnd.left) {
    chain.insert(0, placed);
  } else {
    chain.add(placed);
  }

  final humanHand = player == DominoPlayer.human ? hand : state.humanHand;
  final cpuHand = player == DominoPlayer.cpu ? hand : state.cpuHand;

  var humanTilesPlayed = state.humanTilesPlayed;
  var progressScore = state.progressScore;
  var scoreDelta = 0;

  if (player == DominoPlayer.human) {
    humanTilesPlayed++;
    scoreDelta = DominoConfig.pointsPerTilePlayed;
    progressScore += scoreDelta;
  }

  DominoPlayer? winner;
  if (hand.isEmpty) {
    winner = player;
  }

  return DominoState(
    humanHand: humanHand,
    cpuHand: cpuHand,
    boneyard: state.boneyard,
    chain: chain,
    turn: winner == null ? dominoNextPlayer(player) : player,
    winner: winner,
    humanTilesPlayed: humanTilesPlayed,
    draws: state.draws,
    passes: state.passes,
    consecutivePasses: 0,
    openingRequired: false,
    openingTileId: null,
    progressScore: progressScore,
    difficulty: state.difficulty,
  );
}

DominoPlayer dominoNextPlayer(DominoPlayer current) =>
    current == DominoPlayer.human ? DominoPlayer.cpu : DominoPlayer.human;

DominoMoveResult dominoTryPlay(
  DominoState state,
  DominoPlayer player,
  DominoPlay play,
) {
  final valid = dominoValidPlays(state, player);
  final allowed = valid.any(
    (p) =>
        p.handIndex == play.handIndex &&
        p.end == play.end &&
        p.flipped == play.flipped,
  );
  if (!allowed) {
    return DominoMoveResult(state: state, scoreDelta: 0);
  }

  final next = dominoApplyPlay(state, player, play);
  return DominoMoveResult(
    state: next,
    scoreDelta: next.progressScore - state.progressScore,
    finished: next.isFinished,
  );
}

DominoMoveResult dominoDrawTile(DominoState state, DominoPlayer player) {
  if (state.boneyard.isEmpty || dominoCanPlay(state, player)) {
    return DominoMoveResult(state: state, scoreDelta: 0);
  }

  final boneyard = List<DominoTile>.from(state.boneyard);
  final drawn = boneyard.removeAt(0);
  final hand = List<DominoTile>.from(state.handFor(player))..add(drawn);

  var draws = state.draws;
  var progressScore = state.progressScore;
  var scoreDelta = 0;

  if (player == DominoPlayer.human) {
    draws++;
    scoreDelta = -DominoConfig.drawPenalty;
    progressScore = max(0, progressScore + scoreDelta);
  }

  final humanHand =
      player == DominoPlayer.human ? hand : state.humanHand;
  final cpuHand = player == DominoPlayer.cpu ? hand : state.cpuHand;

  return DominoMoveResult(
    state: DominoState(
      humanHand: humanHand,
      cpuHand: cpuHand,
      boneyard: boneyard,
      chain: state.chain,
      turn: player,
      winner: state.winner,
      blocked: state.blocked,
      humanTilesPlayed: state.humanTilesPlayed,
      draws: draws,
      passes: state.passes,
      consecutivePasses: state.consecutivePasses,
      openingRequired: state.openingRequired,
      openingTileId: state.openingTileId,
      progressScore: progressScore,
      difficulty: state.difficulty,
    ),
    scoreDelta: scoreDelta,
    drawn: true,
  );
}

DominoMoveResult dominoPassTurn(DominoState state, DominoPlayer player) {
  if (dominoCanPlay(state, player) || state.boneyard.isNotEmpty) {
    return DominoMoveResult(state: state, scoreDelta: 0);
  }

  final passes = state.passes + (player == DominoPlayer.human ? 1 : 0);
  final consecutive = state.consecutivePasses + 1;

  if (consecutive >= 2) {
    final humanPips = dominoHandPipSum(state.humanHand);
    final cpuPips = dominoHandPipSum(state.cpuHand);
    final winner = humanPips <= cpuPips ? DominoPlayer.human : DominoPlayer.cpu;
    return DominoMoveResult(
      state: DominoState(
        humanHand: state.humanHand,
        cpuHand: state.cpuHand,
        boneyard: state.boneyard,
        chain: state.chain,
        turn: player,
        winner: winner,
        blocked: true,
        humanTilesPlayed: state.humanTilesPlayed,
        draws: state.draws,
        passes: passes,
        consecutivePasses: consecutive,
        openingRequired: state.openingRequired,
        openingTileId: state.openingTileId,
        progressScore: state.progressScore,
        difficulty: state.difficulty,
      ),
      scoreDelta: 0,
      passed: true,
      finished: true,
    );
  }

  return DominoMoveResult(
    state: DominoState(
      humanHand: state.humanHand,
      cpuHand: state.cpuHand,
      boneyard: state.boneyard,
      chain: state.chain,
      turn: dominoNextPlayer(player),
      humanTilesPlayed: state.humanTilesPlayed,
      draws: state.draws,
      passes: passes,
      consecutivePasses: consecutive,
      openingRequired: state.openingRequired,
      openingTileId: state.openingTileId,
      progressScore: state.progressScore,
      difficulty: state.difficulty,
    ),
    scoreDelta: 0,
    passed: true,
  );
}

/// Escolhe jogada da CPU conforme dificuldade.
DominoPlay? dominoCpuChoosePlay(DominoState state, Random random) {
  final plays = dominoValidPlays(state, DominoPlayer.cpu);
  if (plays.isEmpty) return null;

  switch (state.difficulty) {
    case DominoConfig.difficultyEasy:
      return plays[random.nextInt(plays.length)];
    case DominoConfig.difficultyHard:
      return _cpuHardPick(state, plays);
    case DominoConfig.difficultyNormal:
    default:
      return _cpuNormalPick(plays, state.cpuHand);
  }
}

DominoPlay _cpuNormalPick(List<DominoPlay> plays, List<DominoTile> hand) {
  final sorted = List<DominoPlay>.from(plays)
    ..sort((a, b) {
      final tileA = hand[a.handIndex];
      final tileB = hand[b.handIndex];
      if (tileA.isDouble != tileB.isDouble) {
        return tileA.isDouble ? -1 : 1;
      }
      return tileB.pips.compareTo(tileA.pips);
    });
  return sorted.first;
}

DominoPlay _cpuHardPick(DominoState state, List<DominoPlay> plays) {
  final hand = state.cpuHand;
  final leftEnd = state.chainLeftEnd();
  final rightEnd = state.chainRightEnd();

  int countForValue(int value) =>
      hand.where((t) => t.left == value || t.right == value).length;

  DominoPlay? best;
  var bestScore = -9999;

  for (final play in plays) {
    final tile = hand[play.handIndex];
    final newLeft = play.end == DominoChainEnd.left
        ? (play.flipped ? tile.left : tile.right)
        : leftEnd;
    final newRight = play.end == DominoChainEnd.right
        ? (play.flipped ? tile.left : tile.right)
        : rightEnd;

    var score = tile.pips;
    if (tile.isDouble) score += 8;
    score += countForValue(newLeft) * 3;
    score += countForValue(newRight) * 3;

    if (score > bestScore) {
      bestScore = score;
      best = play;
    }
  }
  return best ?? plays.first;
}

int dominoTimeBonusRemaining(double elapsedSec) {
  final decay = (elapsedSec * DominoConfig.timeBonusPerSecond).floor();
  return max(0, DominoConfig.timeBonusMax - decay);
}

String dominoHudTimeBonusPreview(double elapsedSec) {
  final bonus = dominoTimeBonusRemaining(elapsedSec);
  return '+$bonus tempo';
}

int dominoWinBonus({
  required bool humanWon,
  required List<DominoTile> opponentHand,
  required bool blocked,
}) {
  if (!humanWon) return 0;
  final pips = dominoHandPipSum(opponentHand);
  return blocked ? pips : pips * DominoConfig.winBonusPerOpponentPip;
}

int dominoFinalScore({
  required int progressScore,
  required bool humanWon,
  required List<DominoTile> opponentHand,
  required bool blocked,
  required double elapsedSec,
}) {
  final winBonus = dominoWinBonus(
    humanWon: humanWon,
    opponentHand: opponentHand,
    blocked: blocked,
  );
  return progressScore + winBonus + dominoTimeBonusRemaining(elapsedSec);
}

/// Posição de uma peça na mesa (fileira em serpentina).
class DominoChainSlot {
  const DominoChainSlot({
    required this.index,
    required this.rect,
    required this.horizontal,
  });

  final int index;
  final Rect rect;
  final bool horizontal;
}

/// Geometria da fileira na mesa — zonas de drop alinhadas ao desenho.
class DominoChainLayout {
  const DominoChainLayout({
    required this.slots,
    required this.tileW,
    required this.tileH,
    required this.leftDropZone,
    required this.rightDropZone,
    required this.emptyDropZone,
    required this.tableBounds,
    required this.leftEndBadge,
    required this.rightEndBadge,
    required this.leftEndArrow,
    required this.rightEndArrow,
  });

  final List<DominoChainSlot> slots;
  final double tileW;
  final double tileH;
  final Rect leftDropZone;
  final Rect rightDropZone;
  final Rect emptyDropZone;
  final Rect tableBounds;
  final Offset leftEndBadge;
  final Offset rightEndBadge;

  /// Direção (unitária) para onde a ponta esquerda/direita está aberta.
  final Offset leftEndArrow;
  final Offset rightEndArrow;

  Rect? slotRect(int index) {
    for (final slot in slots) {
      if (slot.index == index) return slot.rect;
    }
    return null;
  }
}

/// Fileira como um dominó de verdade: fica reta enquanto cabe e, quando o
/// espaço aperta, **vira a quina** — a peça do canto é desenhada na vertical e
/// a fileira continua na linha de baixo no sentido inverso.
///
/// Isso deixa claro que a fileira é contínua (você segue a curva com o olho) e
/// onde estão as pontas jogáveis.
DominoChainLayout dominoChainLayout({
  required double screenW,
  required Rect tableBounds,
  required double baseTileW,
  required double baseTileH,
  required int chainLength,
}) {
  final emptyZone = tableBounds.inflate(-6);
  final baseLong = baseTileH * DominoConfig.chainTileScale;
  final baseShort = baseTileW * DominoConfig.chainTileScale;

  if (chainLength == 0) {
    return DominoChainLayout(
      slots: const [],
      tileW: baseLong,
      tileH: baseShort,
      leftDropZone: Rect.zero,
      rightDropZone: Rect.zero,
      emptyDropZone: emptyZone,
      tableBounds: tableBounds,
      leftEndBadge: emptyZone.center,
      rightEndBadge: emptyZone.center,
      leftEndArrow: const Offset(-1, 0),
      rightEndArrow: const Offset(1, 0),
    );
  }

  const hGap = 2.0;
  var long = baseLong;
  var short = baseShort;
  var vGap = DominoConfig.chainRowGap;

  final availW = tableBounds.width - 20;
  final availH = tableBounds.height - 16;

  int perRow(double l) => max(1, (availW / (l + hGap)).floor());
  // Cada banda tem altura `long` para caber a peça-esquina (vertical).
  double bandsHeight(double l, double g, int r) => r * l + (r - 1) * g;

  var cols = perRow(long);
  var rows = (chainLength / cols).ceil();

  if (bandsHeight(long, vGap, rows) > availH) {
    final scale = max(
      DominoConfig.chainMinScale,
      availH / bandsHeight(long, vGap, rows),
    );
    long *= scale;
    short *= scale;
    vGap *= scale;
    cols = perRow(long);
    rows = (chainLength / cols).ceil();
  }

  final stepX = long + hGap;
  final stepY = long + vGap;
  final fullRowTiles = min(chainLength, cols);
  final gridW = fullRowTiles * stepX - hGap;
  final gridLeft = tableBounds.left + max(8.0, (tableBounds.width - gridW) / 2);
  final usedH = bandsHeight(long, vGap, rows);
  final startY = tableBounds.top + 8 + max(0.0, (availH - usedH) / 2);

  double cellX(int col) => gridLeft + col * stepX;
  double cellY(int row) => startY + row * stepY;

  // Coluna/linha e orientação da peça no índice [i].
  ({int col, int row, bool vertical}) cellFor(int i) {
    final row = i ~/ cols;
    final pos = i % cols;
    if (row == 0) return (col: pos, row: 0, vertical: false);
    if (pos == 0) {
      // Peça-esquina: mesma coluna da última peça da linha de cima, na vertical.
      return (col: row.isOdd ? cols - 1 : 0, row: row, vertical: true);
    }
    final col = row.isOdd ? cols - 1 - pos : pos;
    return (col: col, row: row, vertical: false);
  }

  Rect rectFor(({int col, int row, bool vertical}) cell) {
    final x = cellX(cell.col);
    final y = cellY(cell.row);
    if (cell.vertical) {
      return Rect.fromLTWH(x + (long - short) / 2, y, short, long);
    }
    return Rect.fromLTWH(x, y + (long - short) / 2, long, short);
  }

  final slots = <DominoChainSlot>[];
  for (var i = 0; i < chainLength; i++) {
    final cell = cellFor(i);
    slots.add(
      DominoChainSlot(
        index: i,
        rect: rectFor(cell),
        horizontal: !cell.vertical,
      ),
    );
  }

  const leftArrow = Offset(-1, 0);
  final firstRect = slots.first.rect;
  final lastCell = cellFor(chainLength - 1);
  final lastRect = slots.last.rect;

  // Sentido em que a ponta direita está aberta.
  final Offset rightArrow;
  if (lastCell.vertical) {
    rightArrow = const Offset(0, 1); // acabou de virar a quina → abre p/ baixo
  } else if (lastCell.row.isOdd) {
    rightArrow = const Offset(-1, 0);
  } else {
    rightArrow = const Offset(1, 0);
  }

  const hitPad = 14.0;
  const badgePad = 16.0;

  Rect endZone(Rect tile, Offset dir) {
    if (dir.dy > 0) {
      final half = tile.height * 0.5;
      return Rect.fromLTWH(
        tile.left - hitPad * 0.4,
        tile.top + half,
        tile.width + hitPad * 0.8,
        half + hitPad,
      );
    }
    final half = tile.width * 0.5;
    return Rect.fromLTWH(
      dir.dx < 0 ? tile.left - hitPad : tile.left + half,
      tile.top - hitPad * 0.4,
      half + hitPad,
      tile.height + hitPad * 0.8,
    );
  }

  Offset badgeCenter(Rect tile, Offset dir) {
    if (dir.dy > 0) return Offset(tile.center.dx, tile.bottom + badgePad);
    if (dir.dx < 0) return Offset(tile.left - badgePad, tile.center.dy);
    return Offset(tile.right + badgePad, tile.center.dy);
  }

  return DominoChainLayout(
    slots: slots,
    tileW: long,
    tileH: short,
    leftDropZone: endZone(firstRect, leftArrow),
    rightDropZone: endZone(lastRect, rightArrow),
    emptyDropZone: emptyZone,
    tableBounds: tableBounds,
    leftEndBadge: badgeCenter(firstRect, leftArrow),
    rightEndBadge: badgeCenter(lastRect, rightArrow),
    leftEndArrow: leftArrow,
    rightEndArrow: rightArrow,
  );
}

String dominoTileLabel(DominoTile tile) => '${tile.left}|${tile.right}';

String dominoTurnLabel(DominoPlayer turn) =>
    turn == DominoPlayer.human ? 'Sua vez' : 'CPU';

String dominoDifficultyLabel(String difficulty) => switch (difficulty) {
      DominoConfig.difficultyEasy => 'Fácil',
      DominoConfig.difficultyHard => 'Difícil',
      _ => 'Normal',
    };

/// Layout do tabuleiro (testável sem Flame).
class DominoBoardLayout {
  const DominoBoardLayout({
    required this.tileW,
    required this.tileH,
    required this.chainTableBounds,
    required this.playerY,
    required this.cpuY,
    required this.boneyardRect,
    required this.passRect,
    required this.drawRect,
    required this.playerTileXs,
    required this.cpuTileXs,
  });

  final double tileW;
  final double tileH;
  final Rect chainTableBounds;
  final double playerY;
  final double cpuY;
  final Rect boneyardRect;
  final Rect passRect;
  final Rect drawRect;
  final List<double> playerTileXs;
  final List<double> cpuTileXs;
}

DominoBoardLayout dominoBoardLayout({
  required double screenW,
  required double screenH,
  required int humanHandCount,
  required int cpuHandCount,
}) {
  const marginH = DominoConfig.layoutMarginH;
  const hudHeight = 56.0;
  const bottomMargin = 10.0;
  const actionH = 40.0;
  const actionGap = 8.0;

  final availW = screenW - marginH * 2;
  var tileW = min(availW / 7.5, 52.0);
  var tileH = tileW / DominoConfig.layoutTileAspect;

  final playerHandW = humanHandCount * (tileW + 4) - 4;
  if (playerHandW > availW && humanHandCount > 0) {
    tileW = (availW + 4) / humanHandCount - 4;
    tileH = tileW / DominoConfig.layoutTileAspect;
  }

  final playerY = screenH - bottomMargin - tileH;
  final cpuY = hudHeight + DominoConfig.layoutHudGap + 6;

  final actionY = playerY - actionH - actionGap;
  final tableTop = cpuY + tileH + 10;
  final tableBottom = actionY - 10;
  final chainTableBounds = Rect.fromLTWH(
    marginH,
    tableTop,
    availW,
    max(80.0, tableBottom - tableTop),
  );
  final drawRect = Rect.fromLTWH(marginH, actionY, availW * 0.42, actionH);
  final passRect = Rect.fromLTWH(
    marginH + availW * 0.46,
    actionY,
    availW * 0.54,
    actionH,
  );
  final boneyardRect = Rect.fromLTWH(
    screenW - marginH - tileW * 0.9,
    cpuY + tileH * 0.15,
    tileW * 0.85,
    tileH * 0.7,
  );

  List<double> handXs(int count) {
    if (count == 0) return const [];
    final gap = min(4.0, (availW - tileW * count) / max(1, count - 1));
    final totalW = count * tileW + (count - 1) * gap;
    final startX = marginH + (availW - totalW) / 2;
    return List.generate(count, (i) => startX + i * (tileW + gap));
  }

  return DominoBoardLayout(
    tileW: tileW,
    tileH: tileH,
    chainTableBounds: chainTableBounds,
    playerY: playerY,
    cpuY: cpuY,
    boneyardRect: boneyardRect,
    passRect: passRect,
    drawRect: drawRect,
    playerTileXs: handXs(humanHandCount),
    cpuTileXs: handXs(cpuHandCount),
  );
}

/// Pips do oponente que caracterizam uma vitória "no grito" (margem cheia).
const dominoWinMarginPips = 40;

/// Pips na própria mão que caracterizam uma derrota "feia" (sem mérito).
const dominoLossPips = 40;

/// Desempenho normalizado (`0.0`–`1.0`).
///
/// Vitória = ouro garantido (a margem sobre o oponente só reforça). Derrota
/// gradua pela quantidade de pips que sobraram na mão: quase bater pode render
/// prata; perder com a mão cheia é bronze. Derrota nunca alcança ouro.
double dominoPerformanceRatio({
  required bool humanWon,
  int humanPips = 0,
  int opponentPips = 0,
}) {
  if (humanWon) {
    final margin = (opponentPips / dominoWinMarginPips).clamp(0.0, 1.0);
    return 0.85 + 0.15 * margin;
  }
  final closeness = (1 - humanPips / dominoLossPips).clamp(0.0, 1.0);
  return (closeness * 0.75).clamp(0.0, 0.84);
}

PerformanceTier dominoPerformanceTier({
  required bool humanWon,
  int humanPips = 0,
  int opponentPips = 0,
}) =>
    tierFromRatio(dominoPerformanceRatio(
      humanWon: humanWon,
      humanPips: humanPips,
      opponentPips: opponentPips,
    ));
