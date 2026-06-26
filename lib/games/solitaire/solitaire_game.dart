import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/economy/economy_config.dart';
import '../../core/game_sdk/game_metadata.dart';
import '../../core/game_sdk/game_session_hud.dart';
import '../../core/game_sdk/game_session_hud_actions.dart';
import '../../core/game_sdk/game_prep.dart';
import '../../core/game_sdk/game_result.dart';
import '../../core/game_sdk/game_session_callbacks.dart';
import '../../core/game_sdk/game_session_config.dart';
import '../../core/game_sdk/hub_game.dart';
import 'components/solitaire_fx.dart';
import 'solitaire_config.dart';

class SolitaireGame implements HubGame {
  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'solitaire',
        title: 'Paciência',
        description: 'Organize as cartas nas fundações do Ás ao Rei.',
        category: 'Cartas',
        icon: '🃏',
      );

  @override
  GamePrepDefinition get prep => GamePrepDefinition(
        help: GameHelpContent(
          howToPlay:
              'Monte sequências alternando cores (vermelho/preto) em ordem '
              'decrescente nas colunas — ex.: 5♥ em cima de 6♠. Mova cartas para '
              'as fundações começando pelo Ás. Toque no monte para virar; arraste '
              'ou toque a carta do descarte para uma coluna. Toque duas vezes '
              'para enviar à fundação quando possível. '
              'DICA custa ${EconomyConfig.hintCoinCostSolitaire} moedas e destaca uma jogada.',
          scoring:
              'Cada carta na fundação vale 10 pts. Virar carta na coluna +5 pts. '
              'Mover do descarte para coluna +5 pts. Complete o jogo para +500 pts '
              'e bônus de tempo (até 300 pts).',
        ),
        optionGroups: [
          GamePrepOptionGroup(
            label: 'Virar',
            optionKey: SolitaireConfig.optionKeyDrawCount,
            choices: const [
              GamePrepChoice(label: '1 carta', value: 1),
              GamePrepChoice(label: '3 cartas', value: 3),
            ],
          ),
        ],
      );

  @override
  Widget buildGame(
    BuildContext context,
    GameSessionCallbacks callbacks, {
    GameSessionConfig config = const GameSessionConfig(),
  }) {
    final drawCount = config.value(
      SolitaireConfig.optionKeyDrawCount,
      1,
    );
    return GameWidget(
      game: SolitaireFlameGame(
        callbacks: callbacks,
        drawCount: drawCount,
      ),
    );
  }
}

enum _Phase { playing, finished }

class _Selection {
  const _Selection({
    required this.pile,
    required this.tableauIndex,
  });

  final SolitairePileRef pile;
  final int tableauIndex;
}

typedef _Layout = SolitaireBoardLayout;

class SolitaireFlameGame extends FlameGame with TapCallbacks, DragCallbacks {
  SolitaireFlameGame({
    required this.callbacks,
    required this.drawCount,
  }) : _state = solitaireNewGame(Random(), drawCount: drawCount);

  final GameSessionCallbacks callbacks;
  final int drawCount;

  late DateTime _startedAt;
  _Phase _phase = _Phase.playing;
  bool _sessionStarted = false;
  bool _sessionActive = true;

  SolitaireState _state;
  _Selection? _selection;
  final List<SolitaireState> _undo = [];
  _DragState? _drag;
  _HintState? _hint;
  final Map<int, double> _flipAnimByCardId = {};
  GameSessionHudActionBar? _actionBar;
  double _shakeT = 0;
  DateTime? _lastTapAt;
  SolitairePileRef? _lastTapPile;
  int _lastTapTableauIndex = 0;

  static const _hudHeight = SolitaireConfig.layoutHudHeight;

  @override
  Color backgroundColor() => SolitaireConfig.bgBottom;

  @override
  Future<void> onLoad() async {
    _startedAt = DateTime.now();
    callbacks.onScoreUpdate(0);
  }

  @override
  void onRemove() {
    _sessionActive = false;
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_sessionStarted || size.x <= 0) return;
    _sessionStarted = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_shakeT > 0) {
      _shakeT = (_shakeT - dt / SolitaireConfig.shakeSec).clamp(0.0, 1.0);
    }
    if (_hint != null) {
      _hint!.t = (_hint!.t - dt / 1.1).clamp(0.0, 1.0);
      if (_hint!.t <= 0) _hint = null;
    }
    if (_flipAnimByCardId.isNotEmpty) {
      final done = <int>[];
      _flipAnimByCardId.forEach((id, t) {
        final next = (t - dt / SolitaireConfig.flipAnimSec).clamp(0.0, 1.0);
        if (next <= 0) {
          done.add(id);
        } else {
          _flipAnimByCardId[id] = next;
        }
      });
      for (final id in done) {
        _flipAnimByCardId.remove(id);
      }
    }
  }

  _Layout _layout() => solitaireBoardLayout(
        screenW: size.x,
        screenH: size.y,
      );

  @override
  void onTapDown(TapDownEvent event) {
    if (_phase != _Phase.playing || !_sessionStarted) return;
    final pos = event.localPosition;
    if (_handleHudTap(pos)) return;
    _handleTap(pos);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (_phase != _Phase.playing || !_sessionStarted) return;
    final layout = _layout();
    final pos = event.localPosition;
    if (_handleHudTap(pos)) return;

    final hit = _hitTest(pos, layout);
    if (hit == null) return;
    if (hit.pile.kind == SolitairePileKind.stock) return;
    if (!_canSelect(hit.pile, hit.tableauIndex)) return;

    _selection = _Selection(pile: hit.pile, tableauIndex: hit.tableauIndex);
    _drag = _DragState(
      selection: _selection!,
      start: pos.clone(),
      current: pos.clone(),
    );
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (_drag == null) return;
    _drag!.current.add(event.localDelta);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    final drag = _drag;
    if (drag == null) return;
    _drag = null;

    final layout = _layout();
    final dropPos = drag.current;
    final from = drag.selection;
    final hit = _hitTestDropTarget(dropPos, layout, from);
    if (hit == null) {
      _reject(layout, dropPos, message: 'Solte na coluna');
      _selection = null;
      return;
    }

    final result = solitaireTryMove(
      _state,
      from.pile,
      from.tableauIndex,
      hit.pile,
    );
    if (result == null) {
      _reject(layout, dropPos);
      _selection = null;
      return;
    }
    _applyMove(result, layout, from.pile, before: _state);
    _selection = null;
  }

  bool _handleHudTap(Vector2 pos) {
    final actionId = _actionBar?.hitTest(Offset(pos.x, pos.y));
    if (actionId == null) return false;
    switch (actionId) {
      case 'undo':
        _undoMove();
      case 'hint':
        _showHint();
      case 'auto':
        _autoToFoundations();
    }
    return true;
  }

  List<GameSessionHudAction> _hudActions() {
    final coins = callbacks.currentCoins?.call() ?? 0;
    final canAffordHint = coins >= EconomyConfig.hintCoinCostSolitaire;
    return [
        GameSessionHudAction(
          id: 'undo',
          icon: GameSessionHudActionIcons.undo,
          enabled: _undo.isNotEmpty,
        ),
        GameSessionHudAction(
          id: 'hint',
          icon: GameSessionHudActionIcons.hint,
          enabled: _phase == _Phase.playing && canAffordHint,
          accent: SolitaireConfig.successGlow,
          coinCost: EconomyConfig.hintCoinCostSolitaire,
        ),
        GameSessionHudAction(
          id: 'auto',
          icon: GameSessionHudActionIcons.auto,
          enabled: _phase == _Phase.playing,
          accent: SolitaireConfig.accentSoft,
        ),
      ];
  }

  void _handleTap(Vector2 pos) {
    final layout = _layout();
    final hit = _hitTest(pos, layout);
    if (hit == null) {
      _selection = null;
      return;
    }

    final now = DateTime.now();
    final isDoubleTap = _lastTapAt != null &&
        now.difference(_lastTapAt!) < const Duration(milliseconds: 320) &&
        _lastTapPile == hit.pile &&
        _lastTapTableauIndex == hit.tableauIndex;

    _lastTapAt = now;
    _lastTapPile = hit.pile;
    _lastTapTableauIndex = hit.tableauIndex;

    if (hit.pile.kind == SolitairePileKind.stock) {
      _drawStock(layout);
      return;
    }

    if (isDoubleTap && hit.pile.kind != SolitairePileKind.foundation) {
      final auto = solitaireAutoToFoundation(
        _state,
        hit.pile,
        hit.tableauIndex,
      );
      if (auto != null) {
        _applyMove(auto, layout, hit.pile, before: _state);
        return;
      }
    }

    if (_selection == null) {
      if (!_canSelect(hit.pile, hit.tableauIndex)) {
        _reject(layout, pos);
        return;
      }
      _selection = _Selection(
        pile: hit.pile,
        tableauIndex: hit.tableauIndex,
      );
      return;
    }

    final from = _selection!;
    if (from.pile == hit.pile && from.tableauIndex == hit.tableauIndex) {
      _selection = null;
      return;
    }

    final result = solitaireTryMove(
      _state,
      from.pile,
      from.tableauIndex,
      hit.pile,
    );
    if (result == null) {
      if (_canSelect(hit.pile, hit.tableauIndex)) {
        _selection = _Selection(
          pile: hit.pile,
          tableauIndex: hit.tableauIndex,
        );
      } else {
        _reject(layout, pos);
        _selection = null;
      }
      return;
    }

    _applyMove(result, layout, from.pile, before: _state);
    _selection = null;
  }

  bool _canSelect(SolitairePileRef pile, int tableauIndex) {
    final cards = solitaireSelectedCards(_state, pile, tableauIndex);
    if (cards.isEmpty) return false;
    if (pile.kind == SolitairePileKind.tableau) {
      return solitaireIsValidTableauStack(
        _state.tableau[pile.index],
        tableauIndex,
      );
    }
    return true;
  }

  void _drawStock(_Layout layout) {
    _pushUndo();
    final result = solitaireDrawFromStock(_state);
    if (result == null) return;
    _registerFlipAnimations(before: _state, after: result.state);
    _state = result.state;
    callbacks.onScoreUpdate(solitaireProgressScore(_state));
    add(
      SolitaireFloatingLabel(
        position: Vector2(
          layout.stockX + layout.cardW / 2,
          layout.topY + layout.cardH / 2,
        ),
        text: _state.stock.isEmpty && _state.waste.isNotEmpty
            ? 'Reciclar'
            : 'Virar',
        color: SolitaireConfig.hudMuted,
      ),
    );
  }

  void _applyMove(
    SolitaireMoveResult result,
    _Layout layout,
    SolitairePileRef from, {
    required SolitaireState before,
  }) {
    _pushUndo();
    _registerFlipAnimations(before: before, after: result.state);
    _state = result.state;
    callbacks.onScoreUpdate(solitaireProgressScore(_state));

    if (result.scoreDelta > 0) {
      final origin = _pileCenter(from, 0, layout);
      add(SolitaireMoveBurst(position: origin));
      add(
        SolitaireFloatingLabel(
          position: origin.clone()..y -= 10,
          text: '+${result.scoreDelta}',
          color: SolitaireConfig.successGlow,
        ),
      );
    }

    if (result.won) {
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (_sessionActive) _finish(won: true);
      });
    }
  }

  void _reject(_Layout layout, Vector2 pos, {String message = 'Inválido'}) {
    _shakeT = 1;
    add(
      SolitaireFloatingLabel(
        position: pos.clone(),
        text: message,
        color: SolitaireConfig.missRed,
      ),
    );
  }

  void _undoMove() {
    if (_undo.isEmpty || _phase != _Phase.playing) return;
    _selection = null;
    _drag = null;
    _hint = null;
    _flipAnimByCardId.clear();
    _state = _undo.removeLast();
    callbacks.onScoreUpdate(solitaireProgressScore(_state));
    add(
      SolitaireFloatingLabel(
        position: Vector2(size.x / 2, _hudHeight + 18),
        text: 'Desfeito',
        color: SolitaireConfig.hudMuted,
      ),
    );
  }

  void _showHint() {
    final hint = _findHintMove();
    if (hint == null) {
      add(
        SolitaireFloatingLabel(
          position: Vector2(size.x / 2, _hudHeight + 18),
          text: 'Sem jogadas',
          color: SolitaireConfig.hudMuted,
        ),
      );
      return;
    }

    final spend = callbacks.trySpendCoins;
    if (spend == null || !spend(EconomyConfig.hintCoinCostSolitaire)) {
      add(
        SolitaireFloatingLabel(
          position: Vector2(size.x / 2, _hudHeight + 18),
          text: '${EconomyConfig.hintCoinCostSolitaire} moedas',
          color: SolitaireConfig.missRed,
        ),
      );
      return;
    }

    _hint = hint;
  }

  void _autoToFoundations() {
    if (_phase != _Phase.playing) return;
    var movedAny = false;
    var safety = 0;
    while (safety++ < 64) {
      final move = _findAutoToFoundationMove();
      if (move == null) break;
      if (!movedAny) _pushUndo();
      movedAny = true;
      _registerFlipAnimations(before: _state, after: move.result.state);
      _state = move.result.state;
      callbacks.onScoreUpdate(solitaireProgressScore(_state));
      if (move.result.scoreDelta > 0) {
        final layout = _layout();
        final origin = _pileCenter(move.from, 0, layout);
        add(SolitaireMoveBurst(position: origin));
      }
      if (move.result.won) {
        Future<void>.delayed(const Duration(milliseconds: 400), () {
          if (_sessionActive) _finish(won: true);
        });
        break;
      }
    }
    if (!movedAny) {
      add(
        SolitaireFloatingLabel(
          position: Vector2(size.x / 2, _hudHeight + 18),
          text: 'Nada p/ mover',
          color: SolitaireConfig.hudMuted,
        ),
      );
    }
  }

  void _finish({required bool won}) {
    if (_phase == _Phase.finished || !_sessionActive) return;
    _phase = _Phase.finished;
    final duration = DateTime.now().difference(_startedAt);
    final score = solitaireFinalScore(
      moveScore: _state.moveScore,
      duration: duration,
      won: won,
    );
    callbacks.onGameOver(
      GameResult(
        score: score,
        duration: duration,
        metadata: {
          'moves': _state.moves,
          'foundationCards': solitaireFoundationCount(_state),
          'timeBonus': won ? solitaireTimeBonusRemaining(duration) : 0,
          'won': won,
          'performanceTier': solitairePerformanceTier(
            won: won,
            foundationCards: solitaireFoundationCount(_state),
          ).name,
        },
      ),
    );
  }

  Rect _wasteHitRect(_Layout layout) {
    if (_state.waste.isEmpty) {
      return Rect.fromLTWH(
        layout.wasteX,
        layout.topY,
        layout.cardW,
        layout.cardH,
      );
    }
    final show = solitaireWasteVisibleCount(
      _state.waste.length,
      _state.drawCount,
    );
    final fanStep = layout.wasteFanStep;
    return Rect.fromLTWH(
      layout.wasteX,
      layout.topY,
      layout.cardW + fanStep * (show - 1),
      layout.cardH,
    );
  }

  double _tableauColumnBottomY(int col, _Layout layout) {
    final pile = _state.tableau[col];
    if (pile.isEmpty) return layout.tableauY;
    var cardY = layout.tableauY;
    for (final card in pile) {
      cardY += card.faceUp ? layout.faceUpStep : layout.faceDownStep;
    }
    return cardY;
  }

  bool _isSameSource(
    ({SolitairePileRef pile, int tableauIndex}) hit,
    _Selection from,
  ) =>
      hit.pile == from.pile && hit.tableauIndex == from.tableauIndex;

  ({SolitairePileRef pile, int tableauIndex})? _hitTestDropTarget(
    Vector2 pos,
    _Layout layout,
    _Selection from,
  ) {
    final direct = _hitTest(pos, layout);
    if (direct != null && !_isSameSource(direct, from)) return direct;

    const colPad = 6.0;
    const yPadTop = 14.0;
    const yPadBottom = 28.0;
    for (var col = 0; col < 7; col++) {
      final left = layout.colX[col] - colPad;
      final right = layout.colX[col] + layout.cardW + colPad;
      if (pos.x < left || pos.x > right) continue;
      final bottom = _tableauColumnBottomY(col, layout);
      if (pos.y < layout.tableauY - yPadTop || pos.y > bottom + yPadBottom) {
        continue;
      }
      return (
        pile: SolitairePileRef(SolitairePileKind.tableau, col),
        tableauIndex: 0,
      );
    }

    for (var f = 0; f < 4; f++) {
      final fx = layout.foundationX(f);
      final pad = 8.0;
      final foundationRect = Rect.fromLTWH(
        fx - pad,
        layout.topY - pad,
        layout.cardW + pad * 2,
        layout.cardH + pad * 2,
      );
      if (foundationRect.contains(Offset(pos.x, pos.y))) {
        return (
          pile: SolitairePileRef(SolitairePileKind.foundation, f),
          tableauIndex: 0,
        );
      }
    }

    return null;
  }

  ({SolitairePileRef pile, int tableauIndex})? _hitTest(Vector2 pos, _Layout layout) {
    final x = pos.x;
    final y = pos.y;

    final stockRect = Rect.fromLTWH(
      layout.stockX,
      layout.topY,
      layout.cardW,
      layout.cardH,
    );
    if (stockRect.contains(Offset(x, y))) {
      return (pile: const SolitairePileRef(SolitairePileKind.stock), tableauIndex: 0);
    }

    if (_state.waste.isNotEmpty && _wasteHitRect(layout).contains(Offset(x, y))) {
      return (pile: const SolitairePileRef(SolitairePileKind.waste), tableauIndex: 0);
    }

    for (var f = 0; f < 4; f++) {
      final fx = layout.foundationX(f);
      final foundationRect = Rect.fromLTWH(fx, layout.topY, layout.cardW, layout.cardH);
      if (foundationRect.contains(Offset(x, y))) {
        return (
          pile: SolitairePileRef(SolitairePileKind.foundation, f),
          tableauIndex: 0,
        );
      }
    }

    for (var col = 0; col < 7; col++) {
      final pile = _state.tableau[col];
      if (pile.isEmpty) {
        final emptyRect = Rect.fromLTWH(
          layout.colX[col],
          layout.tableauY,
          layout.cardW,
          layout.cardH,
        );
        if (emptyRect.contains(Offset(x, y))) {
          return (
            pile: SolitairePileRef(SolitairePileKind.tableau, col),
            tableauIndex: 0,
          );
        }
        continue;
      }

      var cardY = layout.tableauY;
      for (var i = 0; i < pile.length; i++) {
        final card = pile[i];
        final step = card.faceUp ? layout.faceUpStep : layout.faceDownStep;
        final nextY = i < pile.length - 1
            ? cardY + (pile[i + 1].faceUp ? layout.faceUpStep : layout.faceDownStep)
            : cardY + layout.cardH;
        final isLast = i == pile.length - 1;
        final hitH = isLast
            ? layout.cardH + 20
            : max(layout.cardH * 0.42, nextY - cardY);
        final rect = Rect.fromLTWH(layout.colX[col], cardY, layout.cardW, hitH);
        if (rect.contains(Offset(x, y)) && card.faceUp) {
          return (
            pile: SolitairePileRef(SolitairePileKind.tableau, col),
            tableauIndex: i,
          );
        }
        cardY += step;
      }

      final topRect = Rect.fromLTWH(
        layout.colX[col],
        layout.tableauY,
        layout.cardW,
        layout.cardH,
      );
      if (pile.isNotEmpty && topRect.contains(Offset(x, y))) {
        final firstFaceUp = pile.indexWhere((c) => c.faceUp);
        if (firstFaceUp >= 0) {
          return (
            pile: SolitairePileRef(SolitairePileKind.tableau, col),
            tableauIndex: firstFaceUp,
          );
        }
      }
    }

    return null;
  }

  Vector2 _pileCenter(SolitairePileRef pile, int tableauIndex, _Layout layout) {
    return switch (pile.kind) {
      SolitairePileKind.stock => Vector2(
          layout.stockX + layout.cardW / 2,
          layout.topY + layout.cardH / 2,
        ),
      SolitairePileKind.waste => () {
          final show = solitaireWasteVisibleCount(
            _state.waste.length,
            _state.drawCount,
          );
          final offset = (show - 1) * layout.wasteFanStep;
          return Vector2(
            layout.wasteX + offset + layout.cardW / 2,
            layout.topY + layout.cardH / 2,
          );
        }(),
      SolitairePileKind.foundation => Vector2(
          layout.foundationX(pile.index) + layout.cardW / 2,
          layout.topY + layout.cardH / 2,
        ),
      SolitairePileKind.tableau => () {
          var y = layout.tableauY;
          final column = _state.tableau[pile.index];
          for (var i = 0; i < tableauIndex && i < column.length; i++) {
            y += column[i].faceUp ? layout.faceUpStep : layout.faceDownStep;
          }
          return Vector2(layout.colX[pile.index] + layout.cardW / 2, y + layout.cardH / 2);
        }(),
    };
  }

  @override
  void render(Canvas canvas) {
    _paintBackground(canvas);
    super.render(canvas);
    if (!_sessionStarted) return;

    final layout = _layout();
    final shakeX = _shakeT > 0 ? sin(_shakeT * pi * 6) * 5 * _shakeT : 0.0;
    canvas.save();
    canvas.translate(shakeX, 0);

    _paintTopRow(canvas, layout);
    _paintTableau(canvas, layout);
    if (_hint != null) {
      _paintHint(canvas, layout, _hint!);
    }
    if (_selection != null) {
      _paintSelection(canvas, layout, _selection!);
    }
    if (_drag != null) {
      _paintDraggedStack(canvas, layout, _drag!);
    }

    canvas.restore();
    _paintHud(canvas);
  }

  void _paintBackground(Canvas canvas) {
    final rect = Offset.zero & Size(size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [SolitaireConfig.bgTop, SolitaireConfig.bgBottom],
        ).createShader(rect),
    );
    if (!_sessionStarted) return;

    final feltPaint = Paint()
      ..color = SolitaireConfig.feltPattern.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    const step = 18.0;
    for (var x = -size.y; x < size.x + size.y; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.y, size.y),
        feltPaint,
      );
    }

    for (final (fx, fy, fr) in [
      (0.12, 0.2, 0.1),
      (0.88, 0.3, 0.08),
    ]) {
      canvas.drawCircle(
        Offset(size.x * fx, size.y * fy),
        size.x * fr,
        Paint()..color = Colors.white.withValues(alpha: 0.04),
      );
    }
  }

  void _paintTopRow(Canvas canvas, _Layout layout) {
    _paintSlot(
      canvas,
      layout.stockX,
      layout.topY,
      layout.cardW,
      layout.cardH,
    );
    if (_state.stock.isNotEmpty) {
      _paintCardBack(
        canvas,
        layout.stockX,
        layout.topY,
        layout.cardW,
        layout.cardH,
        count: _state.stock.length,
      );
    }

    _paintSlot(
      canvas,
      layout.wasteX,
      layout.topY,
      layout.cardW,
      layout.cardH,
    );
    if (_state.waste.isNotEmpty) {
      final waste = _state.waste;
      final show = solitaireWasteVisibleCount(waste.length, _state.drawCount);
      final fanStep = layout.wasteFanStep;
      final hideTopWaste = _drag?.selection.pile.kind == SolitairePileKind.waste;
      for (var i = 0; i < show; i++) {
        final idx = waste.length - show + i;
        if (hideTopWaste && idx == waste.length - 1) continue;
        final offset = i * fanStep;
        _paintCardWithFlipIfNeeded(
          canvas,
          layout.wasteX + offset,
          layout.topY,
          layout.cardW,
          layout.cardH,
          waste[idx],
        );
      }
    }

    for (var f = 0; f < 4; f++) {
      final fx = layout.foundationX(f);
      _paintSlot(canvas, fx, layout.topY, layout.cardW, layout.cardH);
      final pile = _state.foundations[f];
      if (pile.isNotEmpty) {
        _paintCardFace(
          canvas,
          fx,
          layout.topY,
          layout.cardW,
          layout.cardH,
          pile.last,
        );
      } else {
        _paintFoundationHint(canvas, fx, layout.topY, layout.cardW, layout.cardH, f);
      }
    }
  }

  void _paintTableau(Canvas canvas, _Layout layout) {
    for (var col = 0; col < 7; col++) {
      final pile = _state.tableau[col];
      if (pile.isEmpty) {
        _paintSlot(
          canvas,
          layout.colX[col],
          layout.tableauY,
          layout.cardW,
          layout.cardH,
        );
        continue;
      }

      var cardY = layout.tableauY;
      for (var i = 0; i < pile.length; i++) {
        if (_isDraggingFromTableau(col, i)) {
          cardY += pile[i].faceUp ? layout.faceUpStep : layout.faceDownStep;
          continue;
        }
        final card = pile[i];
        _paintCardWithFlipIfNeeded(
          canvas,
          layout.colX[col],
          cardY,
          layout.cardW,
          layout.cardH,
          card,
        );
        cardY += card.faceUp ? layout.faceUpStep : layout.faceDownStep;
      }
    }
  }

  void _paintSelection(Canvas canvas, _Layout layout, _Selection sel) {
    final cards = solitaireSelectedCards(_state, sel.pile, sel.tableauIndex);
    if (cards.isEmpty) return;

    if (sel.pile.kind == SolitairePileKind.tableau) {
      var cardY = layout.tableauY;
      final column = _state.tableau[sel.pile.index];
      for (var i = 0; i < sel.tableauIndex; i++) {
        cardY += column[i].faceUp ? layout.faceUpStep : layout.faceDownStep;
      }
      final stackH = layout.cardH + layout.faceUpStep * (cards.length - 1);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          layout.colX[sel.pile.index] - 2,
          cardY - 2,
          layout.cardW + 4,
          stackH + 4,
        ),
        const Radius.circular(8),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = SolitaireConfig.accentColor.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    } else {
      final center = _pileCenter(sel.pile, sel.tableauIndex, layout);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.x, center.y),
            width: layout.cardW + 6,
            height: layout.cardH + 6,
          ),
          const Radius.circular(8),
        ),
        Paint()
          ..color = SolitaireConfig.accentColor.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  void _paintSlot(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = SolitaireConfig.slotEmpty.withValues(alpha: 0.45),
    );
    _drawDashedRRect(
      canvas,
      rect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.26)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
      dash: max(5.0, w * 0.10),
      gap: max(3.0, w * 0.06),
    );
  }

  void _paintFoundationHint(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    int index,
  ) {
    final suit = SolitaireSuit.values[index];
    final painter = TextPainter(
      text: TextSpan(
        text: solitaireSuitSymbol(suit),
        style: TextStyle(
          color: solitaireSuitColor(suit).withValues(alpha: 0.35),
          fontSize: w * 0.42,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(x + (w - painter.width) / 2, y + (h - painter.height) / 2),
    );
  }

  void _paintCardBack(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h, {
    int? count,
  }) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(
      rect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );
    canvas.drawRRect(rect, Paint()..color = SolitaireConfig.cardBack);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = SolitaireConfig.accentColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final inset = w * 0.12;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + inset, y + inset, w - inset * 2, h - inset * 2),
        Radius.circular(w * 0.06),
      ),
      Paint()
        ..color = SolitaireConfig.blendColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    if (count != null && count > 0) {
      _paintStockCountBadge(canvas, x, y, w, h, count);
    }
  }

  void _paintStockCountBadge(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    int count,
  ) {
    final fontSize = max(9.0, w * 0.19);
    final painter = TextPainter(
      text: TextSpan(
        text: '$count',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const padH = 6.0;
    const padV = 3.0;
    final badgeW = painter.width + padH * 2;
    final badgeH = painter.height + padV * 2;
    final badgeX = x + (w - badgeW) / 2;
    final badgeY = y + h - badgeH - 5;

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeX, badgeY, badgeW, badgeH),
      Radius.circular(badgeH / 2),
    );
    canvas.drawRRect(
      badgeRect,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
    canvas.drawRRect(
      badgeRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    painter.paint(
      canvas,
      Offset(
        badgeX + (badgeW - painter.width) / 2,
        badgeY + (badgeH - painter.height) / 2,
      ),
    );
  }

  void _paintCardFace(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    SolitaireCard card,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(
      rect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    canvas.drawRRect(rect, Paint()..color = SolitaireConfig.cardFace);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final suitColor = solitaireSuitColor(card.suit);
    final rank = solitaireRankLabel(card.rank);
    final suit = solitaireSuitSymbol(card.suit);
    final cornerSize = w * 0.24;

    _paintMiniText(canvas, rank, Offset(x + 6, y + 4), cornerSize, suitColor);
    _paintMiniText(canvas, suit, Offset(x + 6, y + cornerSize + 2), cornerSize * 1.1, suitColor);
    _paintMiniText(
      canvas,
      suit,
      Offset(x + w / 2, y + h / 2),
      w * 0.38,
      suitColor,
      centered: true,
    );
    _paintMiniText(
      canvas,
      rank,
      Offset(x + w - 6, y + h - cornerSize - 8),
      cornerSize,
      suitColor,
      rightAlign: true,
    );
  }

  void _paintMiniText(
    Canvas canvas,
    String text,
    Offset pos,
    double fontSize,
    Color color, {
    bool centered = false,
    bool rightAlign = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = centered
        ? Offset(pos.dx - painter.width / 2, pos.dy - painter.height / 2)
        : rightAlign
            ? Offset(pos.dx - painter.width, pos.dy)
            : pos;
    painter.paint(canvas, offset);
  }

  void _paintHud(Canvas canvas) {
    if (_phase == _Phase.finished) return;

    final elapsed = DateTime.now().difference(_startedAt);
    final timeBonus = solitaireTimeBonusRemaining(elapsed);
    final progress = solitaireProgressScore(_state);
    final foundation = solitaireFoundationCount(_state);

    const palette = GameSessionHudPalette(
      text: SolitaireConfig.hudText,
      muted: SolitaireConfig.hudMuted,
      accent: SolitaireConfig.accentSoft,
    );

    GameSessionHud.paintStatsBar(
      canvas,
      Size(size.x, size.y),
      palette,
      columns: [
        GameSessionHudStat(
          caption: 'Pontos',
          value: '$progress',
          footnote: solitaireHudTimeBonusLabel(timeBonus),
          footnoteColor: SolitaireConfig.accentSoft,
        ),
        GameSessionHudStat(
          caption: 'Tempo',
          value: solitaireHudElapsedLabel(elapsed),
          footnote: '${_state.moves} jogadas',
          captionColor: SolitaireConfig.hudMuted,
        ),
        GameSessionHudStat(
          caption: 'Fundação',
          value: '$foundation/52',
        ),
      ],
      progress: GameSessionHudProgress(
        ratio: timeBonus / SolitaireConfig.timeBonusMax,
        color: SolitaireConfig.successGlow.withValues(alpha: 0.85),
        position: GameSessionHudProgressPosition.top,
      ),
    );

    final canvasSize = Size(size.x, size.y);
    final actions = _hudActions();
    _actionBar = GameSessionHudActionBar.layout(
      canvasSize,
      actions: actions,
      withProgressBar: true,
    );
    GameSessionHudActionBar.paint(canvas, palette, _actionBar!, actions);
  }

  void _pushUndo() {
    if (_undo.length >= 40) _undo.removeAt(0);
    _undo.add(_copyState(_state));
  }

  SolitaireState _copyState(SolitaireState state) {
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

  void _registerFlipAnimations({required SolitaireState before, required SolitaireState after}) {
    for (var i = 0; i < 7; i++) {
      final a = before.tableau[i];
      final b = after.tableau[i];
      final len = min(a.length, b.length);
      for (var j = 0; j < len; j++) {
        if (!a[j].faceUp && b[j].faceUp) {
          _flipAnimByCardId[b[j].id] = 1.0;
        }
      }
    }
    if (after.waste.length > before.waste.length) {
      for (var i = before.waste.length; i < after.waste.length; i++) {
        _flipAnimByCardId[after.waste[i].id] = 1.0;
      }
    }
  }

  bool _isDraggingFromTableau(int col, int index) {
    final drag = _drag;
    if (drag == null) return false;
    if (drag.selection.pile.kind != SolitairePileKind.tableau) return false;
    if (drag.selection.pile.index != col) return false;
    return index >= drag.selection.tableauIndex;
  }

  void _paintDraggedStack(Canvas canvas, _Layout layout, _DragState drag) {
    final cards = solitaireSelectedCards(
      _state,
      drag.selection.pile,
      drag.selection.tableauIndex,
    );
    if (cards.isEmpty) return;

    final dx = drag.current.x - layout.cardW / 2;
    final dy = drag.current.y - layout.cardH / 2;
    var y = dy;
    for (var i = 0; i < cards.length; i++) {
      _paintCardWithFlipIfNeeded(canvas, dx, y, layout.cardW, layout.cardH, cards[i]);
      y += layout.faceUpStep;
    }
  }

  void _paintCardWithFlipIfNeeded(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    SolitaireCard card,
  ) {
    final t = _flipAnimByCardId[card.id];
    if (t == null || t <= 0) {
      if (card.faceUp) {
        _paintCardFace(canvas, x, y, w, h, card);
      } else {
        _paintCardBack(canvas, x, y, w, h);
      }
      return;
    }

    final center = Offset(x + w / 2, y + h / 2);
    final p = 1 - t; // 0..1
    final scaleX = (cos(p * pi) * 0.5 + 0.5) * 0.96 + 0.04;
    final showFront = p >= 0.5;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scaleX, 1);
    canvas.translate(-center.dx, -center.dy);
    if (showFront) {
      _paintCardFace(canvas, x, y, w, h, card);
    } else {
      _paintCardBack(canvas, x, y, w, h);
    }
    canvas.restore();
  }

  void _paintHint(Canvas canvas, _Layout layout, _HintState hint) {
    final alpha = (sin((1 - hint.t) * pi) * 0.6 + 0.2).clamp(0.0, 0.8);
    final paint = Paint()
      ..color = SolitaireConfig.successGlow.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    void drawPile(SolitairePileRef pile, int index) {
      final center = _pileCenter(pile, index, layout);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.x, center.y),
            width: layout.cardW + 10,
            height: layout.cardH + 10,
          ),
          const Radius.circular(10),
        ),
        paint,
      );
    }

    drawPile(hint.from, hint.tableauIndex);
    drawPile(hint.to, 0);
  }

  _HintState? _findHintMove() {
    // 1) Waste -> anywhere
    if (_state.waste.isNotEmpty) {
      final from = const SolitairePileRef(SolitairePileKind.waste);
      for (var i = 0; i < 4; i++) {
        final to = SolitairePileRef(SolitairePileKind.foundation, i);
        if (solitaireTryMove(_state, from, 0, to) != null) {
          return _HintState(from: from, tableauIndex: 0, to: to);
        }
      }
      for (var t = 0; t < 7; t++) {
        final to = SolitairePileRef(SolitairePileKind.tableau, t);
        if (solitaireTryMove(_state, from, 0, to) != null) {
          return _HintState(from: from, tableauIndex: 0, to: to);
        }
      }
    }

    // 2) Tableau (single-card top moves)
    for (var col = 0; col < 7; col++) {
      final pile = _state.tableau[col];
      if (pile.isEmpty) continue;
      final idx = pile.length - 1;
      if (!pile[idx].faceUp) continue;
      final from = SolitairePileRef(SolitairePileKind.tableau, col);
      for (var i = 0; i < 4; i++) {
        final to = SolitairePileRef(SolitairePileKind.foundation, i);
        if (solitaireTryMove(_state, from, idx, to) != null) {
          return _HintState(from: from, tableauIndex: idx, to: to);
        }
      }
      for (var t = 0; t < 7; t++) {
        if (t == col) continue;
        final to = SolitairePileRef(SolitairePileKind.tableau, t);
        if (solitaireTryMove(_state, from, idx, to) != null) {
          return _HintState(from: from, tableauIndex: idx, to: to);
        }
      }
    }

    return null;
  }

  ({SolitaireMoveResult result, SolitairePileRef from})? _findAutoToFoundationMove() {
    if (_state.waste.isNotEmpty) {
      final from = const SolitairePileRef(SolitairePileKind.waste);
      final res = solitaireAutoToFoundation(_state, from, 0);
      if (res != null) return (result: res, from: from);
    }
    for (var col = 0; col < 7; col++) {
      final pile = _state.tableau[col];
      if (pile.isEmpty) continue;
      final idx = pile.length - 1;
      if (!pile[idx].faceUp) continue;
      final from = SolitairePileRef(SolitairePileKind.tableau, col);
      final res = solitaireAutoToFoundation(_state, from, idx);
      if (res != null) return (result: res, from: from);
    }
    return null;
  }

  void _drawDashedRRect(
    Canvas canvas,
    RRect rrect,
    Paint paint, {
    required double dash,
    required double gap,
  }) {
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final len = min(dash, metric.length - distance);
        final seg = metric.extractPath(distance, distance + len);
        canvas.drawPath(seg, paint);
        distance += dash + gap;
      }
    }
  }
}

class _DragState {
  _DragState({
    required this.selection,
    required this.start,
    required this.current,
  });

  final _Selection selection;
  final Vector2 start;
  final Vector2 current;
}

class _HintState {
  _HintState({
    required this.from,
    required this.tableauIndex,
    required this.to,
  });

  final SolitairePileRef from;
  final int tableauIndex;
  final SolitairePileRef to;
  double t = 1.0;
}
