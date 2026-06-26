import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/game_sdk/game_metadata.dart';
import '../../core/game_sdk/game_prep.dart';
import '../../core/game_sdk/game_result.dart';
import '../../core/game_sdk/game_session_callbacks.dart';
import '../../core/game_sdk/game_session_config.dart';
import '../../core/game_sdk/hub_game.dart';
import 'components/domino_fx.dart';
import '../../core/l10n/l10n_scope.dart';
import 'domino_config.dart';

class DominoGame implements HubGame {
  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'domino',
        title: 'Dominó',
        description: 'Jogue peças contra a CPU e esvazie sua mão.',
        category: 'Cartas',
        icon: '🁫',
      );

  @override
  GamePrepDefinition get prep => GamePrepDefinition(
        help: const GameHelpContent(
          howToPlay:
              'Combine os números das pontas da fileira com uma peça da sua mão. '
              'Quem tiver o maior duplo começa. Se não puder jogar, compre do monte '
              'ou passe a vez. Vença esvaziando a mão ou ficando com menos pontos '
              'se a partida travar.',
          scoring:
              'Cada peça jogada vale 15 pts. Comprar do monte custa 3 pts. '
              'Ao vencer, ganhe 3 pts por ponto restante na mão da CPU. '
              'Termine rápido para bônus de tempo (até 150 pts).',
        ),
        optionGroups: [
          GamePrepOptionGroup(
            label: L10nScope.of.gameDominoCpuTurn,
            optionKey: DominoConfig.optionKeyDifficulty,
            choices: const [
              GamePrepChoice(
                label: 'Fácil',
                value: DominoConfig.difficultyEasy,
              ),
              GamePrepChoice(
                label: 'Normal',
                value: DominoConfig.difficultyNormal,
              ),
              GamePrepChoice(
                label: 'Difícil',
                value: DominoConfig.difficultyHard,
              ),
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
    final difficulty = config.value(
      DominoConfig.optionKeyDifficulty,
      DominoConfig.difficultyNormal,
    );
    return GameWidget(
      game: DominoFlameGame(
        callbacks: callbacks,
        difficulty: difficulty,
      ),
    );
  }
}

enum _Phase { playing, finished }

class DominoFlameGame extends FlameGame with TapCallbacks, DragCallbacks {
  DominoFlameGame({
    required this.callbacks,
    required this.difficulty,
  }) : _state = dominoNewGame(Random(), difficulty: difficulty);

  final GameSessionCallbacks callbacks;
  final String difficulty;

  final _random = Random();
  late DateTime _startedAt;
  _Phase _phase = _Phase.playing;
  bool _sessionStarted = false;
  bool _sessionActive = true;

  DominoState _state;
  int? _selectedHandIndex;
  double _shakeT = 0;
  double _missFlash = 0;
  double _cpuThinkT = 0;
  bool _cpuBusy = false;
  final List<_FlyingTile> _flyingTiles = [];
  _LastMoveHighlight? _lastMove;
  Rect? _chainLeftHit;
  Rect? _chainRightHit;
  Rect? _chainEmptyHit;
  _DominoDrag? _drag;
  bool _suppressNextTap = false;

  @override
  Color backgroundColor() => DominoConfig.bgBottom;

  @override
  Future<void> onLoad() async {
    _startedAt = DateTime.now();
    callbacks.onScoreUpdate(0);
    if (_state.turn == DominoPlayer.cpu) {
      _cpuBusy = true;
      _cpuThinkT = _randomCpuThink();
    }
  }

  double _randomCpuThink() =>
      DominoConfig.cpuThinkSecMin +
      _random.nextDouble() *
          (DominoConfig.cpuThinkSecMax - DominoConfig.cpuThinkSecMin);

  bool get _inputBlocked =>
      _cpuBusy || _flyingTiles.isNotEmpty || _phase != _Phase.playing;

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
      _shakeT = (_shakeT - dt / DominoConfig.shakeSec).clamp(0.0, 1.0);
    }
    if (_missFlash > 0) {
      _missFlash = (_missFlash - dt * 3).clamp(0.0, 1.0);
    }
    if (_lastMove != null) {
      _lastMove!.remaining -= dt;
      if (_lastMove!.remaining <= 0) _lastMove = null;
    }
    if (_flyingTiles.isNotEmpty) {
      final done = <_FlyingTile>[];
      for (final fly in _flyingTiles) {
        fly.t = (fly.t - dt / DominoConfig.placeAnimSec).clamp(0.0, 1.0);
        if (fly.t <= 0) done.add(fly);
      }
      for (final fly in done) {
        _flyingTiles.remove(fly);
        _onTileLanded(fly);
      }
    }

    if (_cpuBusy && _phase == _Phase.playing && _flyingTiles.isEmpty) {
      _cpuThinkT -= dt;
      if (_cpuThinkT <= 0) {
        _runCpuTurn();
      }
    }
  }

  void _onTileLanded(_FlyingTile fly) {
    _lastMove = _LastMoveHighlight(
      chainIndex: fly.chainIndex,
      player: fly.player,
      remaining: DominoConfig.lastMoveHighlightSec,
    );
    if (_state.turn == DominoPlayer.cpu && !_state.isFinished) {
      _cpuBusy = true;
      _cpuThinkT = _randomCpuThink();
    } else {
      _cpuBusy = false;
    }
  }

  double _easeOutCubic(double t) {
    final inv = 1 - t;
    return 1 - inv * inv * inv;
  }

  void _runCpuTurn() {
    if (_flyingTiles.isNotEmpty) return;
    if (_state.turn != DominoPlayer.cpu || _state.isFinished) {
      _cpuBusy = false;
      return;
    }

    final play = dominoCpuChoosePlay(_state, _random);
    if (play != null) {
      if (_playTile(play, DominoPlayer.cpu)) return;
      _cpuThinkT = _randomCpuThink();
      return;
    }

    if (_state.boneyard.isNotEmpty) {
      final draw = dominoDrawTile(_state, DominoPlayer.cpu);
      _state = draw.state;
      add(
        DominoFloatingLabel(
          position: Vector2(size.x / 2, layoutCpuLabelY()),
          text: L10nScope.of.gameDominoCpuDrew,
          color: DominoConfig.hudMuted,
          fontSize: 13,
        ),
      );
      if (dominoCanPlay(_state, DominoPlayer.cpu)) {
        _cpuThinkT = 0.35;
        return;
      }
      if (_state.boneyard.isNotEmpty) {
        _cpuThinkT = 0.28;
        return;
      }
    }

    final pass = dominoPassTurn(_state, DominoPlayer.cpu);
    _state = pass.state;
    add(
      DominoFloatingLabel(
        position: Vector2(size.x / 2, layoutCpuLabelY()),
        text: L10nScope.of.gameDominoCpuPassed,
        color: DominoConfig.hudMuted,
        fontSize: 13,
      ),
    );
    if (pass.finished) {
      _finishGame();
    }
    _cpuBusy = _state.turn == DominoPlayer.cpu && !_state.isFinished;
    if (_cpuBusy) _cpuThinkT = _randomCpuThink();
  }

  double layoutCpuLabelY() {
    final layout = _layout();
    return layout.cpuY + layout.tileH + 18;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (_inputBlocked || _state.turn != DominoPlayer.human) {
      return;
    }

    final pos = event.localPosition;
    final layout = _layout();
    for (var i = 0; i < _state.humanHand.length; i++) {
      final x = layout.playerTileXs[i];
      final rect = Rect.fromLTWH(x, layout.playerY, layout.tileW, layout.tileH);
      if (!_hitRect(rect, pos)) continue;

      final canPlay = dominoValidPlays(_state, DominoPlayer.human)
          .any((p) => p.handIndex == i);
      if (!canPlay) {
        _shakeT = 1;
        _missFlash = 1;
        return;
      }

      _selectedHandIndex = i;
      _drag = _DominoDrag(
        handIndex: i,
        offset: pos - Vector2(rect.center.dx, rect.center.dy),
        position: pos.clone(),
      );
      return;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    _drag?.position.add(event.localDelta);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    final drag = _drag;
    if (drag == null) return;
    _drag = null;
    _suppressNextTap = true;
    _tryDropTile(drag.handIndex, drag.position);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _drag = null;
  }

  void _tryDropTile(int handIndex, Vector2 pos) {
    _syncChainDropZones(_layout());
    final play = _resolveDropPlay(handIndex, pos);
    if (play == null) {
      _shakeT = 1;
      _missFlash = 1;
      add(
        DominoFloatingLabel(
          position: Vector2(size.x / 2, size.y * 0.55),
          text: L10nScope.of.gameDominoDropOnEnd,
          color: DominoConfig.missRed,
        ),
      );
      _selectedHandIndex = null;
      return;
    }
    _executePlay(play);
  }

  DominoPlay? _resolveDropPlay(int handIndex, Vector2 pos) {
    final plays = dominoValidPlays(_state, DominoPlayer.human)
        .where((p) => p.handIndex == handIndex)
        .toList();
    if (plays.isEmpty) return null;

    if (_state.chain.isEmpty) {
      if (_chainEmptyHit != null && _hitRect(_chainEmptyHit!, pos)) {
        return plays.first;
      }
      return null;
    }

    final onLeft = _chainLeftHit != null && _hitRect(_chainLeftHit!, pos);
    final onRight = _chainRightHit != null && _hitRect(_chainRightHit!, pos);

    if (onLeft && !onRight) {
      return _firstPlayOnEnd(plays, DominoChainEnd.left);
    }
    if (onRight && !onLeft) {
      return _firstPlayOnEnd(plays, DominoChainEnd.right);
    }
    if (onLeft && onRight) {
      final leftDist = (pos.x - _chainLeftHit!.center.dx).abs();
      final rightDist = (pos.x - _chainRightHit!.center.dx).abs();
      final end = leftDist <= rightDist ? DominoChainEnd.left : DominoChainEnd.right;
      return _firstPlayOnEnd(plays, end);
    }
    return null;
  }

  DominoPlay? _firstPlayOnEnd(List<DominoPlay> plays, DominoChainEnd end) {
    for (final play in plays) {
      if (play.end == end) return play;
    }
    return null;
  }

  void _syncChainDropZones(DominoBoardLayout layout) {
    final chainLayout = _chainLayout(layout);
    _chainEmptyHit = chainLayout.emptyDropZone;
    if (_state.chain.isEmpty) {
      _chainLeftHit = null;
      _chainRightHit = null;
      return;
    }
    _chainLeftHit = chainLayout.leftDropZone;
    _chainRightHit = chainLayout.rightDropZone;
  }

  DominoChainLayout _chainLayout(
    DominoBoardLayout layout, {
    int? chainLength,
  }) =>
      dominoChainLayout(
        screenW: size.x,
        tableBounds: layout.chainTableBounds,
        baseTileW: layout.tileW,
        baseTileH: layout.tileH,
        chainLength: chainLength ?? _state.chain.length,
      );

  void _finishGame() {
    if (_phase == _Phase.finished) return;
    _phase = _Phase.finished;
    _cpuBusy = false;

    final elapsed = DateTime.now().difference(_startedAt).inMilliseconds / 1000.0;
    final humanWon = _state.winner == DominoPlayer.human;
    final score = dominoFinalScore(
      progressScore: _state.progressScore,
      humanWon: humanWon,
      opponentHand: _state.cpuHand,
      blocked: _state.blocked,
      elapsedSec: elapsed,
    );

    if (_sessionActive) {
      callbacks.onScoreUpdate(score);
      callbacks.onGameOver(
        GameResult(
          score: score,
          duration: Duration(milliseconds: (elapsed * 1000).round()),
          metadata: {
            'won': humanWon,
            'moves': _state.humanTilesPlayed,
            'timeBonus': dominoTimeBonusRemaining(elapsed),
            'tileBonus': humanWon
                ? dominoWinBonus(
                    humanWon: true,
                    opponentHand: _state.cpuHand,
                    blocked: _state.blocked,
                  )
                : 0,
            'performanceTier': dominoPerformanceTier(
              humanWon: humanWon,
              humanPips: dominoHandPipSum(_state.humanHand),
              opponentPips: dominoHandPipSum(_state.cpuHand),
            ).name,
          },
        ),
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_suppressNextTap) {
      _suppressNextTap = false;
      return;
    }
    if (_inputBlocked || _state.turn != DominoPlayer.human) {
      return;
    }

    final pos = event.localPosition;
    final layout = _layout();
    _syncChainDropZones(layout);

    if (_hitRect(layout.drawRect, pos) &&
        !dominoCanPlay(_state, DominoPlayer.human) &&
        _state.boneyard.isNotEmpty) {
      _drawFromBoneyard();
      return;
    }

    if (_hitRect(layout.passRect, pos) &&
        !dominoCanPlay(_state, DominoPlayer.human) &&
        _state.boneyard.isEmpty) {
      _passTurn();
      return;
    }

    if (_chainLeftHit != null && _hitRect(_chainLeftHit!, pos)) {
      _tryPlaceOnEnd(DominoChainEnd.left);
      return;
    }
    if (_chainRightHit != null && _hitRect(_chainRightHit!, pos)) {
      _tryPlaceOnEnd(DominoChainEnd.right);
      return;
    }

    for (var i = 0; i < _state.humanHand.length; i++) {
      final x = layout.playerTileXs[i];
      final rect = Rect.fromLTWH(x, layout.playerY, layout.tileW, layout.tileH);
      if (_hitRect(rect, pos)) {
        _onHandTileTap(i);
        return;
      }
    }
  }

  void _onHandTileTap(int index) {
    final plays = dominoValidPlays(_state, DominoPlayer.human)
        .where((p) => p.handIndex == index)
        .toList();

    if (plays.isEmpty) {
      _shakeT = 1;
      _missFlash = 1;
      add(
        DominoFloatingLabel(
          position: Vector2(size.x / 2, size.y * 0.72),
          text: L10nScope.of.gameDominoNoFit,
          color: DominoConfig.missRed,
        ),
      );
      return;
    }

    if (plays.length == 1 && _state.chain.isEmpty) {
      _executePlay(plays.first);
      return;
    }

    if (_selectedHandIndex == index) {
      _selectedHandIndex = null;
      return;
    }

    _selectedHandIndex = index;

    if (plays.length == 1) {
      _executePlay(plays.first);
    }
  }

  void _tryPlaceOnEnd(DominoChainEnd end) {
    if (_selectedHandIndex == null) return;
    final plays = dominoValidPlays(_state, DominoPlayer.human)
        .where((p) => p.handIndex == _selectedHandIndex && p.end == end)
        .toList();
    if (plays.isEmpty) {
      _shakeT = 1;
      return;
    }
    _playTile(plays.first, DominoPlayer.human);
  }

  void _executePlay(DominoPlay play) => _playTile(play, DominoPlayer.human);

  bool _playTile(DominoPlay play, DominoPlayer player) {
    final layout = _layout();
    final hand = _state.handFor(player);
    if (play.handIndex < 0 || play.handIndex >= hand.length) return false;

    final tile = hand[play.handIndex];
    final fromRect = player == DominoPlayer.human
        ? Rect.fromLTWH(
            layout.playerTileXs[play.handIndex],
            layout.playerY,
            layout.tileW,
            layout.tileH,
          )
        : Rect.fromLTWH(
            layout.cpuTileXs[play.handIndex],
            layout.cpuY,
            layout.tileW,
            layout.tileH,
          );

    final result = dominoTryPlay(_state, player, play);
    if (identical(result.state, _state)) {
      _shakeT = 1;
      return false;
    }

    final chainIndex = play.end == DominoChainEnd.left
        ? 0
        : result.state.chain.length - 1;
    final chainLayout = _chainLayout(
      layout,
      chainLength: result.state.chain.length,
    );
    final toSlot = chainLayout.slots.firstWhere((s) => s.index == chainIndex);
    final toRect = toSlot.rect;
    final scoreDelta = result.scoreDelta;

    _state = result.state;
    _selectedHandIndex = null;

    _flyingTiles.add(
      _FlyingTile(
        from: fromRect,
        to: toRect,
        tile: tile,
        flipped: play.flipped ^ toSlot.mirrored,
        faceUp: player == DominoPlayer.human,
        player: player,
        chainIndex: chainIndex,
      ),
    );
    _cpuBusy = true;

    final dest = toRect.center;
    if (player == DominoPlayer.human) {
      add(
        DominoFloatingLabel(
          position: Vector2(dest.dx, dest.dy - 28),
          text: scoreDelta > 0 ? '+$scoreDelta' : '+0',
          color: DominoConfig.successGlow,
        ),
      );
      add(DominoPlaceBurst(position: Vector2(dest.dx, dest.dy)));
      callbacks.onScoreUpdate(_state.progressScore);
    } else {
      add(
        DominoFloatingLabel(
          position: Vector2(dest.dx, dest.dy - 32),
          text: L10nScope.of.gameDominoCpuPlayed(dominoTileLabel(tile)),
          color: DominoConfig.accentSoft,
          fontSize: 14,
        ),
      );
      add(
        DominoPlaceBurst(
          position: Vector2(dest.dx, dest.dy),
          color: DominoConfig.accentColor,
        ),
      );
    }

    if (result.finished) {
      Future.delayed(
        Duration(milliseconds: (DominoConfig.placeAnimSec * 1000).round()),
        () {
          if (_sessionActive) _finishGame();
        },
      );
    }
    return true;
  }

  void _drawFromBoneyard() {
    final result = dominoDrawTile(_state, DominoPlayer.human);
    _state = result.state;
    _selectedHandIndex = null;

    if (result.scoreDelta < 0) {
      add(
        DominoFloatingLabel(
          position: Vector2(size.x / 2, size.y * 0.62),
          text: '${result.scoreDelta}',
          color: DominoConfig.missRed,
        ),
      );
      callbacks.onScoreUpdate(_state.progressScore);
    }

    if (dominoCanPlay(_state, DominoPlayer.human)) return;

    if (_state.boneyard.isEmpty) {
      add(
        DominoFloatingLabel(
          position: Vector2(size.x / 2, size.y * 0.5),
          text: L10nScope.of.gameDominoNoPlayPass,
          color: DominoConfig.hudMuted,
        ),
      );
    }
  }

  void _passTurn() {
    final result = dominoPassTurn(_state, DominoPlayer.human);
    _state = result.state;
    _selectedHandIndex = null;

    if (result.finished) {
      _finishGame();
      return;
    }

    if (_state.turn == DominoPlayer.cpu) {
      _cpuBusy = true;
      _cpuThinkT = _randomCpuThink();
    }
  }

  bool _hitRect(Rect rect, Vector2 pos) =>
      rect.contains(Offset(pos.x, pos.y));

  DominoBoardLayout _layout() => dominoBoardLayout(
        screenW: size.x,
        screenH: size.y,
        humanHandCount: _state.humanHand.length,
        cpuHandCount: _state.cpuHand.length,
      );

  @override
  void render(Canvas canvas) {
    final layout = _layout();
    _paintBackground(canvas, layout);
    if (_missFlash > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()
          ..color = DominoConfig.missRed.withValues(alpha: _missFlash * 0.12),
      );
    }
    _paintHud(canvas);
    _syncChainDropZones(layout);
    _paintCpuHand(canvas, layout);
    _paintBoneyard(canvas, layout);
    _paintChain(canvas, layout);
    _paintFlyingTiles(canvas);
    _paintActions(canvas, layout);
    _paintPlayerHand(canvas, layout);
    _paintDraggedTile(canvas, layout);
    super.render(canvas);
  }

  void _paintBackground(Canvas canvas, DominoBoardLayout layout) {
    final w = size.x;
    final h = size.y;
    final topEnd = layout.cpuY + layout.tileH + 18;
    final bottomStart = layout.playerY - 6;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, topEnd),
      Paint()..color = DominoConfig.bgTop,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, topEnd, w, bottomStart - topEnd),
      Paint()..color = DominoConfig.bgMiddle,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, bottomStart, w, h - bottomStart),
      Paint()..color = DominoConfig.bgBottom,
    );

    // Linha divisória entre mesa e mão do jogador.
    canvas.drawLine(
      Offset(16, bottomStart),
      Offset(w - 16, bottomStart),
      Paint()
        ..color = DominoConfig.tileOutline.withValues(alpha: 0.55)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintHud(Canvas canvas) {
    final elapsed = DateTime.now().difference(_startedAt).inMilliseconds / 1000.0;
    final timeBonus = dominoTimeBonusRemaining(elapsed);
    final panelW = min(size.x - 32, 320.0);
    final panelLeft = (size.x - panelW) / 2;
    const panelTop = 6.0;
    const panelH = 72.0;

    final panelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(panelLeft, panelTop, panelW, panelH),
      const Radius.circular(14),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        panelRect.outerRect.shift(const Offset(0, 2)),
        const Radius.circular(14),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );
    canvas.drawRRect(panelRect, Paint()..color = DominoConfig.hudPanel);
    canvas.drawRRect(
      panelRect,
      Paint()
        ..color = DominoConfig.tileOutline.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Dificuldade — pill central no topo.
    final diffLabel = dominoDifficultyLabel(difficulty).toUpperCase();
    _paintCenteredText(
      canvas,
      diffLabel,
      panelTop + 14,
      DominoConfig.hudText,
      11,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.8,
    );

    // Barra de pontuação interna.
    const barH = 32.0;
    final barTop = panelTop + 28;
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(panelLeft + 10, barTop, panelW - 20, barH),
      const Radius.circular(10),
    );
    canvas.drawRRect(barRect, Paint()..color = DominoConfig.hudPanelInner);
    canvas.drawRRect(
      barRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final barCenterY = barTop + barH / 2;
    const circleR = 13.0;

    // Pontuação do jogador (esquerda).
    _paintScoreCircle(
      canvas,
      Offset(panelLeft + 28, barCenterY),
      circleR,
      '${_state.progressScore}',
      DominoConfig.scoreHumanColor,
    );

    // Bônus de tempo restante (direita).
    _paintScoreCircle(
      canvas,
      Offset(panelLeft + panelW - 28, barCenterY),
      circleR,
      '$timeBonus',
      DominoConfig.scoreCpuColor,
    );

    // Objetivo central.
    _paintCenteredText(
      canvas,
      'OBJETIVO ${DominoConfig.timeBonusMax}',
      barCenterY - 5,
      DominoConfig.hudMuted,
      9,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );
    _paintCenteredText(
      canvas,
      dominoTurnLabel(_state.turn).toUpperCase(),
      barCenterY + 9,
      _state.turn == DominoPlayer.human
          ? DominoConfig.successGlow
          : DominoConfig.hudMuted,
      9,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.3,
    );
  }

  void _paintScoreCircle(
    Canvas canvas,
    Offset center,
    double radius,
    String value,
    Color color,
  ) {
    canvas.drawCircle(
      center.translate(0, 1.5),
      radius,
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );
    canvas.drawCircle(center, radius, Paint()..color = color);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _paintCenteredText(
      canvas,
      value,
      center.dy,
      Colors.white,
      value.length >= 3 ? 11 : 13,
      centerX: center.dx,
      fontWeight: FontWeight.w900,
    );
  }

  void _paintCpuHand(Canvas canvas, DominoBoardLayout layout) {
    final thinking = _cpuBusy &&
        _state.turn == DominoPlayer.cpu &&
        _flyingTiles.isEmpty &&
        _phase == _Phase.playing;

    for (var i = 0; i < layout.cpuTileXs.length; i++) {
      final x = layout.cpuTileXs[i];
      _paintTileBack(
        canvas,
        Rect.fromLTWH(x, layout.cpuY, layout.tileW, layout.tileH),
      );
    }

    if (thinking) {
      final dots = '.' * (1 + (DateTime.now().millisecondsSinceEpoch ~/ 400) % 3);
      _paintCenteredText(
        canvas,
        'CPU$dots',
        layout.cpuY - 8,
        DominoConfig.tileOutline.withValues(alpha: 0.7),
        11,
        centerX: size.x / 2,
        fontWeight: FontWeight.w700,
      );
    }
  }

  void _paintPlayerHand(Canvas canvas, DominoBoardLayout layout) {
    for (var i = 0; i < _state.humanHand.length; i++) {
      if (_drag?.handIndex == i) continue;

      final x = layout.playerTileXs[i];
      final rect = Rect.fromLTWH(x, layout.playerY, layout.tileW, layout.tileH);
      final selected = _selectedHandIndex == i;
      final canPlay = dominoValidPlays(_state, DominoPlayer.human)
          .any((p) => p.handIndex == i);
      final dimmed = !canPlay || _state.turn != DominoPlayer.human;

      final shakeOffset = _shakeT > 0 && selected
          ? sin(_shakeT * pi * 8) * 4 * _shakeT
          : 0.0;
      final lift = selected ? -8.0 : 0.0;
      final tileRect = rect.shift(Offset(shakeOffset, lift));

      if (selected) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            tileRect.inflate(5),
            Radius.circular(layout.tileW * 0.12),
          ),
          Paint()
            ..color = DominoConfig.tileOutline.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }

      _paintTileFace(
        canvas,
        tileRect,
        _state.humanHand[i],
        dimmed: dimmed && !selected,
      );
    }
  }

  void _paintChain(Canvas canvas, DominoBoardLayout layout) {
    final chainLayout = _chainLayout(layout);

    if (_state.chain.isEmpty) {
      final hint = switch (_state.turn) {
        DominoPlayer.cpu => L10nScope.of.gameDominoCpuOpening,
        _ when _state.openingRequired => L10nScope.of.gameDominoDragOpening,
        _ => L10nScope.of.gameDominoDragToTable,
      };
      _paintCenteredText(
        canvas,
        hint,
        chainLayout.emptyDropZone.center.dy,
        DominoConfig.tileOutline.withValues(alpha: 0.55),
        13,
        fontWeight: FontWeight.w600,
      );
      if (_drag != null) {
        _paintEndGlow(canvas, chainLayout.emptyDropZone, pulse: true);
      }
      return;
    }

    _paintChainSpine(canvas, chainLayout);

    final hiddenSlots = _flyingTiles.map((f) => f.chainIndex).toSet();
    for (final slot in chainLayout.slots) {
      if (hiddenSlots.contains(slot.index)) continue;

      final placed = _state.chain[slot.index];
      var rect = slot.rect;

      final isLastMove = _lastMove?.chainIndex == slot.index;
      if (isLastMove && _lastMove != null) {
        final pulse = (sin(_lastMove!.remaining * 5) + 1) * 0.5;
        final glowColor = _lastMove!.player == DominoPlayer.cpu
            ? DominoConfig.scoreCpuColor
            : DominoConfig.successGlow;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(5), const Radius.circular(10)),
          Paint()
            ..color = glowColor.withValues(alpha: 0.2 + pulse * 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
        rect = rect.shift(Offset(0, -1.5 * pulse));
      }

      _paintTileFace(
        canvas,
        rect,
        placed.tile,
        flipped: placed.flipped ^ slot.mirrored,
        horizontal: slot.horizontal,
      );
    }

    _paintDropHints(canvas, chainLayout);

    _paintEndBadge(
      canvas,
      chainLayout.leftEndBadge,
      chainLayout.leftEndArrow,
      _state.chainLeftEnd(),
    );
    _paintEndBadge(
      canvas,
      chainLayout.rightEndBadge,
      chainLayout.rightEndArrow,
      _state.chainRightEnd(),
    );
  }

  /// Traço sutil entre peças da fileira — só quando há curva longa.
  void _paintChainSpine(Canvas canvas, DominoChainLayout chainLayout) {
    if (chainLayout.slots.length < 4) return;
    final path = Path();
    for (var i = 0; i < chainLayout.slots.length; i++) {
      final c = chainLayout.slots[i].rect.center;
      if (i == 0) {
        path.moveTo(c.dx, c.dy);
      } else {
        path.lineTo(c.dx, c.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = DominoConfig.tileOutline.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = chainLayout.tileH * 0.45
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintDropHints(Canvas canvas, DominoChainLayout chainLayout) {
    final dragIndex = _drag?.handIndex;
    List<DominoPlay> plays;
    if (dragIndex != null) {
      plays = dominoValidPlays(_state, DominoPlayer.human)
          .where((p) => p.handIndex == dragIndex)
          .toList();
    } else if (_selectedHandIndex != null) {
      plays = dominoValidPlays(_state, DominoPlayer.human)
          .where((p) => p.handIndex == _selectedHandIndex)
          .toList();
    } else {
      return;
    }

    if (plays.any((p) => p.end == DominoChainEnd.left)) {
      _paintEndGlow(canvas, chainLayout.leftDropZone, pulse: true);
    }
    if (plays.any((p) => p.end == DominoChainEnd.right)) {
      _paintEndGlow(canvas, chainLayout.rightDropZone, pulse: true);
    }
  }

  void _paintEndBadge(
    Canvas canvas,
    Offset center,
    Offset arrow,
    int value,
  ) {
    if (value < 0) return;
    const radius = 14.0;

    final pulse = (sin(DateTime.now().millisecondsSinceEpoch / 360) + 1) * 0.5;
    canvas.drawCircle(
      center,
      radius + 4 + pulse * 2,
      Paint()
        ..color = DominoConfig.scoreCpuColor.withValues(alpha: 0.18 + pulse * 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final tip = center + arrow * (radius + 11);
    final base = center + arrow * (radius + 3);
    final perp = Offset(-arrow.dy, arrow.dx);
    final arrowPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base.dx + perp.dx * 5, base.dy + perp.dy * 5)
      ..lineTo(base.dx - perp.dx * 5, base.dy - perp.dy * 5)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = DominoConfig.scoreCpuColor);

    canvas.drawCircle(
      center.translate(0, 1.5),
      radius + 2,
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );
    canvas.drawCircle(center, radius, Paint()..color = DominoConfig.scoreCpuColor);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _paintCenteredText(
      canvas,
      '$value',
      center.dy,
      DominoConfig.pipColor,
      13,
      centerX: center.dx,
      fontWeight: FontWeight.bold,
    );
  }

  void _paintFlyingTiles(Canvas canvas) {
    for (final fly in _flyingTiles) {
      final t = _easeOutCubic(1 - fly.t);
      final rect = Rect.lerp(fly.from, fly.to, t)!;
      final lift = sin(t * pi) * 12;

      if (!fly.faceUp && t < 0.55) {
        _paintTileBack(canvas, rect.shift(Offset(0, -lift)));
      } else if (!fly.faceUp) {
        final flipT = ((t - 0.55) / 0.45).clamp(0.0, 1.0);
        if (flipT < 0.5) {
          final squash = 1 - flipT * 1.8;
          canvas.save();
          canvas.translate(rect.center.dx, rect.center.dy - lift);
          canvas.scale(max(0.12, squash), 1);
          canvas.translate(-rect.center.dx, -(rect.center.dy - lift));
          _paintTileBack(canvas, rect);
          canvas.restore();
        } else {
          final squash = (flipT - 0.5) * 2;
          canvas.save();
          canvas.translate(rect.center.dx, rect.center.dy - lift);
          canvas.scale(max(0.12, squash), 1);
          canvas.translate(-rect.center.dx, -(rect.center.dy - lift));
          _paintTileFace(
            canvas,
            rect,
            fly.tile,
            flipped: fly.flipped,
            horizontal: true,
          );
          canvas.restore();
        }
      } else {
        _paintTileFace(
          canvas,
          rect.shift(Offset(0, -lift)),
          fly.tile,
          flipped: fly.flipped,
          horizontal: rect.width > rect.height,
        );
      }
    }
  }

  void _paintDraggedTile(Canvas canvas, DominoBoardLayout layout) {
    final drag = _drag;
    if (drag == null) return;

    final center = drag.position - drag.offset;
    final rect = Rect.fromCenter(
      center: Offset(center.x, center.y - 10),
      width: layout.tileW,
      height: layout.tileH,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(6), Radius.circular(layout.tileW * 0.12)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    _paintTileFace(canvas, rect, _state.humanHand[drag.handIndex]);
  }

  void _paintEndGlow(Canvas canvas, Rect rect, {bool pulse = false}) {
    final alpha = pulse ? 0.45 + sin(DateTime.now().millisecondsSinceEpoch / 280) * 0.15 : 0.35;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(pulse ? 4 : 2), const Radius.circular(10)),
      Paint()
        ..color = DominoConfig.successGlow.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = pulse ? 3.5 : 2.5,
    );
  }

  void _paintBoneyard(Canvas canvas, DominoBoardLayout layout) {
    final rect = layout.boneyardRect;
    _paintTileBack(canvas, rect);
    _paintCenteredText(
      canvas,
      '${_state.boneyard.length}',
      rect.center.dy,
      DominoConfig.hudPanel,
      12,
      centerX: rect.center.dx,
      fontWeight: FontWeight.w800,
    );
    _paintCenteredText(
      canvas,
      L10nScope.of.gameDominoBoneyard,
      rect.top - 10,
      DominoConfig.tileOutline.withValues(alpha: 0.65),
      9,
      centerX: rect.center.dx,
      fontWeight: FontWeight.w700,
    );
  }

  void _paintActions(Canvas canvas, DominoBoardLayout layout) {
    final canDraw = !dominoCanPlay(_state, DominoPlayer.human) &&
        _state.boneyard.isNotEmpty &&
        _state.turn == DominoPlayer.human;
    final canPass = !dominoCanPlay(_state, DominoPlayer.human) &&
        _state.boneyard.isEmpty &&
        _state.turn == DominoPlayer.human;

    _paintActionButton(canvas, layout.drawRect, L10nScope.of.gameDominoDraw, canDraw);
    _paintActionButton(canvas, layout.passRect, L10nScope.of.gameDominoPass, canPass);
  }

  void _paintActionButton(
    Canvas canvas,
    Rect rect,
    String label,
    bool enabled,
  ) {
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(
      r.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withValues(alpha: enabled ? 0.18 : 0.08),
    );
    canvas.drawRRect(
      r,
      Paint()..color = enabled ? Colors.white : Colors.white.withValues(alpha: 0.45),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..color = DominoConfig.tileOutline.withValues(alpha: enabled ? 0.75 : 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    _paintCenteredText(
      canvas,
      label,
      rect.center.dy,
      enabled ? DominoConfig.tileOutline : DominoConfig.hudMuted,
      13,
      centerX: rect.center.dx,
      fontWeight: FontWeight.w800,
    );
  }

  void _paintTileBack(Canvas canvas, Rect rect) {
    final r = RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.1));
    canvas.drawRRect(
      r.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );
    canvas.drawRRect(r, Paint()..color = DominoConfig.tileBack);
    canvas.drawRRect(
      r,
      Paint()
        ..color = DominoConfig.tileOutline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  void _paintTileFace(
    Canvas canvas,
    Rect rect,
    DominoTile tile, {
    bool flipped = false,
    bool horizontal = false,
    bool dimmed = false,
  }) {
    final left = flipped ? tile.right : tile.left;
    final right = flipped ? tile.left : tile.right;

    final corner = min(rect.width, rect.height) * 0.1;
    final r = RRect.fromRectAndRadius(rect, Radius.circular(corner));
    canvas.drawRRect(
      r.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );
    canvas.drawRRect(
      r,
      Paint()..color = dimmed ? DominoConfig.tileFaceDim : DominoConfig.tileFace,
    );
    canvas.drawRRect(
      r,
      Paint()
        ..color = DominoConfig.tileOutline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    final inset = min(rect.width, rect.height) * 0.14;
    final dividerPaint = Paint()
      ..color = dimmed
          ? DominoConfig.pipColorDim.withValues(alpha: 0.5)
          : DominoConfig.pipColor.withValues(alpha: 0.85)
      ..strokeWidth = 2;

    if (horizontal) {
      final halfW = rect.width / 2;
      final leftHalf = Rect.fromLTWH(rect.left, rect.top, halfW - 1, rect.height);
      final rightHalf =
          Rect.fromLTWH(rect.left + halfW + 1, rect.top, halfW - 1, rect.height);

      canvas.drawLine(
        Offset(rect.center.dx, rect.top + 4),
        Offset(rect.center.dx, rect.bottom - 4),
        dividerPaint,
      );

      _paintPips(canvas, leftHalf.deflate(inset), left, dimmed: dimmed);
      _paintPips(canvas, rightHalf.deflate(inset), right, dimmed: dimmed);
      return;
    }

    final halfH = rect.height / 2;
    final topHalf = Rect.fromLTWH(rect.left, rect.top, rect.width, halfH - 1);
    final bottomHalf = Rect.fromLTWH(rect.left, rect.top + halfH + 1, rect.width, halfH - 1);

    canvas.drawLine(
      Offset(rect.left + 4, rect.center.dy),
      Offset(rect.right - 4, rect.center.dy),
      dividerPaint,
    );

    _paintPips(canvas, topHalf.deflate(inset), left, dimmed: dimmed);
    _paintPips(canvas, bottomHalf.deflate(inset), right, dimmed: dimmed);
  }

  void _paintPips(Canvas canvas, Rect area, int value, {bool dimmed = false}) {
    if (value == 0) return;

    const patterns = <int, List<Offset>>{
      1: [Offset(0.5, 0.5)],
      2: [Offset(0.28, 0.28), Offset(0.72, 0.72)],
      3: [Offset(0.28, 0.28), Offset(0.5, 0.5), Offset(0.72, 0.72)],
      4: [
        Offset(0.28, 0.28),
        Offset(0.72, 0.28),
        Offset(0.28, 0.72),
        Offset(0.72, 0.72),
      ],
      5: [
        Offset(0.28, 0.28),
        Offset(0.72, 0.28),
        Offset(0.5, 0.5),
        Offset(0.28, 0.72),
        Offset(0.72, 0.72),
      ],
      6: [
        Offset(0.28, 0.25),
        Offset(0.72, 0.25),
        Offset(0.28, 0.5),
        Offset(0.72, 0.5),
        Offset(0.28, 0.75),
        Offset(0.72, 0.75),
      ],
    };

    final dots = patterns[value] ?? const [];
    final radius = area.width * 0.09;
    final paint = Paint()
      ..color = dimmed ? DominoConfig.pipColorDim : DominoConfig.pipColor;

    for (final rel in dots) {
      final center = Offset(
        area.left + area.width * rel.dx,
        area.top + area.height * rel.dy,
      );
      canvas.drawCircle(center, radius, paint);
    }
  }

  void _paintCenteredText(
    Canvas canvas,
    String text,
    double centerY,
    Color color,
    double fontSize, {
    double? centerX,
    FontWeight fontWeight = FontWeight.w600,
    double letterSpacing = 0,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: size.x - 32);
    painter.paint(
      canvas,
      Offset((centerX ?? size.x / 2) - painter.width / 2, centerY - painter.height / 2),
    );
  }
}

class _DominoDrag {
  _DominoDrag({
    required this.handIndex,
    required this.offset,
    required this.position,
  });

  final int handIndex;
  final Vector2 offset;
  final Vector2 position;
}

class _FlyingTile {
  _FlyingTile({
    required this.from,
    required this.to,
    required this.tile,
    required this.flipped,
    required this.faceUp,
    required this.player,
    required this.chainIndex,
  });

  final Rect from;
  final Rect to;
  final DominoTile tile;
  final bool flipped;
  final bool faceUp;
  final DominoPlayer player;
  final int chainIndex;
  double t = 1;
}

class _LastMoveHighlight {
  _LastMoveHighlight({
    required this.chainIndex,
    required this.player,
    required this.remaining,
  });

  final int chainIndex;
  final DominoPlayer player;
  double remaining;
}
