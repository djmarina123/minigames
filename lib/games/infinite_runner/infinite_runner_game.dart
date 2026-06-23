import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/game_sdk/game_metadata.dart';
import '../../core/game_sdk/game_session_hud.dart';
import '../../core/game_sdk/game_prep.dart';
import '../../core/game_sdk/game_result.dart';
import '../../core/game_sdk/game_session_callbacks.dart';
import '../../core/game_sdk/game_session_config.dart';
import '../../core/game_sdk/hub_game.dart';
import 'components/infinite_runner_fx.dart';
import 'components/runner_entities.dart';
import 'components/runner_scenery.dart';
import 'infinite_runner_config.dart';

class InfiniteRunnerGame implements HubGame {
  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'infinite_runner',
        title: 'Corrida Infinita',
        description: 'Pule e agache para desviar dos obstáculos!',
        category: 'Arcade',
        icon: '🏃',
        featured: true,
      );

  @override
  GamePrepDefinition get prep => GamePrepDefinition(
        help: const GameHelpContent(
          howToPlay:
              'Toque na metade superior da tela para pular obstáculos baixos. '
              'Toque e segure na parte de baixo — ou deslize para baixo — para '
              'agachar sob as vigas. A velocidade aumenta com o tempo.',
          scoring:
              'Ganhe 10 pts por segundo sobrevivido e +30 pts por cada '
              'obstáculo ultrapassado. Modos mais rápidos aceleram a corrida '
              'desde o início.',
        ),
        optionGroups: [
          GamePrepOptionGroup(
            label: 'Velocidade',
            optionKey: InfiniteRunnerConfig.optionKeySpeedMode,
            choices: const [
              GamePrepChoice(label: 'Normal', value: 0),
              GamePrepChoice(label: 'Rápida', value: 1),
              GamePrepChoice(label: 'Insana', value: 2),
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
    final speedMode = config.value(
      InfiniteRunnerConfig.optionKeySpeedMode,
      0,
    );
    return GameWidget(
      game: InfiniteRunnerFlameGame(
        callbacks: callbacks,
        speedModeIndex: speedMode,
      ),
    );
  }
}

enum _Phase { countdown, playing, crashed, finished }

class InfiniteRunnerFlameGame extends FlameGame with TapCallbacks, DragCallbacks {
  InfiniteRunnerFlameGame({
    required this.callbacks,
    required this.speedModeIndex,
  });

  final GameSessionCallbacks callbacks;
  final int speedModeIndex;

  _Phase _phase = _Phase.countdown;
  double _countdownLeft = InfiniteRunnerConfig.countdownSec.toDouble();
  double _elapsed = 0;
  late DateTime _startedAt;

  bool _sessionStarted = false;
  bool _sessionActive = true;
  bool _duckPointerActive = false;

  double _scrollSpeed = 0;
  double _spawnTimer = 0;
  double _scrollOffset = 0;
  double _groundY = 0;
  double _playerX = 0;
  double _playerW = 0;
  double _playerH = 0;
  double _crashFlash = 0;
  double _dustTimer = 0;

  int _score = 0;
  int _obstaclesCleared = 0;
  int _lastReportedScore = -1;
  RunnerObstacleKind? _lastSpawnKind;

  RunnerPlayer? _player;
  final _obstacles = <RunnerObstacle>[];
  final _random = Random();

  double get _modeMultiplier =>
      infiniteRunnerSpeedModeMultiplier(speedModeIndex);

  double get _progress => infiniteRunnerProgress(_elapsed);

  double get _duckZoneY =>
      size.y * (1 - InfiniteRunnerConfig.duckZoneRatio);

  @override
  Color backgroundColor() => InfiniteRunnerConfig.skyTop;

  @override
  Future<void> onLoad() async {
    _startedAt = DateTime.now();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_sessionStarted || size.x <= 0) return;
    _sessionStarted = true;
    _layoutWorld();
  }

  void _layoutWorld() {
    _groundY = size.y * InfiniteRunnerConfig.groundRatio;
    _playerX = size.x * InfiniteRunnerConfig.playerXRatio;
    _playerW = size.x * InfiniteRunnerConfig.playerWidthRatio;
    _playerH = size.y * InfiniteRunnerConfig.playerHeightRatio;

    _player = RunnerPlayer(
      groundY: _groundY,
      width: _playerW,
      height: _playerH,
      x: _playerX,
    );
    add(_player!);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_sessionStarted || !_sessionActive || _phase == _Phase.finished) {
      return;
    }

    if (_crashFlash > 0) {
      _crashFlash = (_crashFlash - dt).clamp(0.0, 1.0);
    }

    switch (_phase) {
      case _Phase.countdown:
        _countdownLeft -= dt;
        if (_countdownLeft <= 0) {
          _phase = _Phase.playing;
          _startedAt = DateTime.now();
          _spawnTimer = 0.9;
        }
      case _Phase.playing:
        _elapsed += dt;
        _scrollSpeed = infiniteRunnerScrollSpeed(
          _elapsed,
          modeMultiplier: _modeMultiplier,
        );
        _scrollOffset += _scrollSpeed * dt;

        final player = _player;
        if (player != null) {
          final groundedBefore = player.grounded;
          player.updatePhysics(dt);
          _maybeSpawnDust(player, groundedBefore);
        }

        _moveObstacles(dt);
        _spawnObstacles(dt);
        _checkCollisions();
        _updateScore();

      case _Phase.crashed:
      case _Phase.finished:
        break;
    }
  }

  void _maybeSpawnDust(RunnerPlayer player, bool wasGrounded) {
    if (player.grounded && !wasGrounded) {
        add(
          RunnerDustPuff(
            position: Vector2(_playerX + _playerW * 0.45, _groundY),
          ),
        );
    }

    if (player.grounded && !player.ducking) {
      _dustTimer += 1 / 60;
      if (_dustTimer > 0.14) {
        _dustTimer = 0;
        add(
          RunnerDustPuff(
            position: Vector2(_playerX + _playerW * 0.2, _groundY),
            small: true,
          ),
        );
      }
    } else {
      _dustTimer = 0;
    }
  }

  void _moveObstacles(double dt) {
    final toRemove = <RunnerObstacle>[];
    for (final obs in _obstacles) {
      obs.position.x -= _scrollSpeed * dt;
      if (!obs.cleared && obs.position.x + obs.size.x < _playerX) {
        obs.cleared = true;
        _obstaclesCleared++;
        add(
          RunnerPassBurst(
            position: Vector2(
              obs.position.x + obs.size.x * 0.5,
              obs.position.y - obs.size.y * 0.5,
            ),
          ),
        );
        add(
          RunnerFloatingLabel(
            position: Vector2(_playerX + _playerW, _groundY - _playerH * 0.55),
            text: '+${InfiniteRunnerConfig.pointsPerObstacle}',
            color: InfiniteRunnerConfig.passGreen,
          ),
        );
      }
      if (obs.position.x + obs.size.x < -40) {
        toRemove.add(obs);
      }
    }
    for (final obs in toRemove) {
      obs.removeFromParent();
      _obstacles.remove(obs);
    }
  }

  void _spawnObstacles(double dt) {
    _spawnTimer -= dt;
    if (_spawnTimer > 0) return;

    final gap = infiniteRunnerSpawnGapSec(_progress);
    _spawnTimer = gap + _random.nextDouble() * 0.35;

    final kind = _pickObstacleKind();
    _lastSpawnKind = kind;

    final obstacle = _buildObstacle(kind);
    _obstacles.add(obstacle);
    add(obstacle);
  }

  RunnerObstacleKind _pickObstacleKind() {
    // Alterna com leve aleatoriedade para variedade legível.
    if (_lastSpawnKind == null) {
      return _random.nextBool()
          ? RunnerObstacleKind.low
          : RunnerObstacleKind.high;
    }
    if (_random.nextDouble() < 0.72) {
      return _lastSpawnKind == RunnerObstacleKind.low
          ? RunnerObstacleKind.high
          : RunnerObstacleKind.low;
    }
    return _random.nextBool()
        ? RunnerObstacleKind.low
        : RunnerObstacleKind.high;
  }

  RunnerObstacle _buildObstacle(RunnerObstacleKind kind) {
    final roll = _random.nextDouble();
    return switch (kind) {
      RunnerObstacleKind.low => () {
          final (w, h) = infiniteRunnerLowObstacleSize(
            playerW: _playerW,
            playerH: _playerH,
            randomUnit: roll,
          );
          return RunnerObstacle(
            groundPosition: Vector2(size.x + 28, _groundY),
            obstacleSize: Vector2(w, h),
            kind: kind,
          );
        }(),
      RunnerObstacleKind.high => () {
          final (w, h) = infiniteRunnerHighObstacleSize(
            playerW: _playerW,
            playerH: _playerH,
            randomUnit: roll,
          );
          return RunnerObstacle(
            groundPosition: Vector2(size.x + 28, _groundY),
            obstacleSize: Vector2(w, h),
            kind: kind,
          );
        }(),
    };
  }

  void _checkCollisions() {
    final player = _player;
    if (player == null) return;

    final playerRect = player.hitRect;
    for (final obs in _obstacles) {
      if (obs.cleared) continue;
      if (playerRect.overlaps(obs.hitRect)) {
        _onCrash();
        return;
      }
    }
  }

  void _onCrash() {
    if (_phase != _Phase.playing) return;
    _phase = _Phase.crashed;
    _crashFlash = 1;
    _player?.setDuck(false);
    _duckPointerActive = false;

    add(
      RunnerFloatingLabel(
        position: Vector2(_playerX + _playerW / 2, _groundY - _playerH * 1.3),
        text: 'Ops!',
        color: InfiniteRunnerConfig.crashRed,
      ),
    );

    Future<void>.delayed(const Duration(milliseconds: 480), () {
      if (!_sessionActive) return;
      _finish();
    });
  }

  void _updateScore() {
    _score = infiniteRunnerScore(
      elapsedSec: _elapsed,
      obstaclesCleared: _obstaclesCleared,
    );
    if (_score != _lastReportedScore) {
      _lastReportedScore = _score;
      callbacks.onScoreUpdate(_score);
    }
  }

  void _finish() {
    if (_phase == _Phase.finished) return;
    _phase = _Phase.finished;

    callbacks.onGameOver(
      GameResult(
        score: _score,
        duration: DateTime.now().difference(_startedAt),
        coinsEarned: _score ~/ 12,
        xpEarned: _score ~/ 3,
        metadata: {
          'obstaclesCleared': _obstaclesCleared,
          'distanceM': infiniteRunnerDistanceMeters(
            _elapsed,
            modeMultiplier: _modeMultiplier,
          ),
          'speedLevel': infiniteRunnerSpeedLevel(_elapsed),
        },
      ),
    );
  }

  bool _isDuckZone(double y) => y >= _duckZoneY;

  void _handleJumpAttempt(double y) {
    if (_phase != _Phase.playing) return;
    if (_isDuckZone(y)) {
      _player?.setDuck(true);
      _duckPointerActive = true;
    } else {
      _player?.jump();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _handleJumpAttempt(event.localPosition.y);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_duckPointerActive) {
      _player?.setDuck(false);
      _duckPointerActive = false;
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    if (_duckPointerActive) {
      _player?.setDuck(false);
      _duckPointerActive = false;
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (_phase == _Phase.playing && event.localPosition.y >= _duckZoneY * 0.9) {
      _player?.setDuck(true);
      _duckPointerActive = true;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (_phase != _Phase.playing) return;
    if (event.localDelta.y > 6) {
      _player?.setDuck(true);
      _duckPointerActive = true;
    } else if (event.localDelta.y < -10) {
      _player?.jump();
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (_duckPointerActive) {
      _player?.setDuck(false);
      _duckPointerActive = false;
    }
  }

  @override
  void onRemove() {
    _sessionActive = false;
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    final screen = Offset.zero & Size(size.x, size.y);
    RunnerScenery.paintSky(canvas, screen.size);
    RunnerScenery.paintClouds(
      canvas,
      screen.size,
      offset: _scrollOffset * 0.2,
      layer: 1,
    );
    RunnerScenery.paintHills(
      canvas,
      screen.size,
      _groundY,
      scroll: _scrollOffset,
      speedFactor: 1,
    );
    RunnerScenery.paintClouds(
      canvas,
      screen.size,
      offset: _scrollOffset * 0.35,
      layer: 0,
    );
    RunnerScenery.paintGround(
      canvas,
      screen.size,
      _groundY,
      scrollOffset: _scrollOffset,
    );

    super.render(canvas);

    if (_crashFlash > 0) {
      canvas.drawRect(
        screen,
        Paint()
          ..color =
              InfiniteRunnerConfig.crashRed.withValues(alpha: _crashFlash * 0.22),
      );
    }

    _paintControlHints(canvas);
    _paintHud(canvas);
  }

  void _paintControlHints(Canvas canvas) {
    if (_phase != _Phase.countdown && _phase != _Phase.playing) return;

    final duckTop = _duckZoneY;
    final fade = _phase == _Phase.countdown ? 1.0 : 0.35;

    canvas.drawRect(
      Rect.fromLTWH(0, duckTop, size.x, size.y - duckTop),
      Paint()..color = Colors.white.withValues(alpha: 0.02 * fade),
    );
    canvas.drawLine(
      Offset(0, duckTop),
      Offset(size.x, duckTop),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18 * fade)
        ..strokeWidth = 1.5,
    );

    if (_phase == _Phase.countdown) {
      _paintHintChip(canvas, Offset(size.x * 0.5, duckTop - 36), '↑ Pular', fade);
      _paintHintChip(
        canvas,
        Offset(size.x * 0.5, duckTop + (size.y - duckTop) * 0.42),
        '↓ Agachar',
        fade,
      );
    } else if (_player?.ducking == true) {
      _paintHintChip(
        canvas,
        Offset(size.x * 0.5, duckTop + 28),
        'Agachado',
        0.65,
        color: InfiniteRunnerConfig.passGreen,
      );
    }
  }

  void _paintHintChip(
    Canvas canvas,
    Offset center,
    String label,
    double alpha, {
    Color? color,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: (color ?? InfiniteRunnerConfig.hudText).withValues(alpha: alpha),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final padH = 12.0;
    final padV = 6.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: painter.width + padH * 2,
        height: painter.height + padV * 2,
      ),
      const Radius.circular(14),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Colors.black.withValues(alpha: 0.18 * alpha),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = InfiniteRunnerConfig.hudPanel,
    );
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  void _paintHud(Canvas canvas) {
    if (_phase == _Phase.countdown) {
      GameSessionHud.paintText(
        canvas,
        _countdownLeft.ceil().clamp(1, InfiniteRunnerConfig.countdownSec).toString(),
        Offset(size.x / 2, size.y * 0.38),
        76,
        InfiniteRunnerConfig.hudText,
        align: GameSessionHudAlign.center,
        fontWeight: FontWeight.w700,
      );
      return;
    }

    if (_phase == _Phase.finished) return;

    final distance = infiniteRunnerDistanceMeters(
      _elapsed,
      modeMultiplier: _modeMultiplier,
    );
    final speedLevel = infiniteRunnerSpeedLevel(_elapsed);

    GameSessionHud.paintStatsBar(
      canvas,
      Size(size.x, size.y),
      const GameSessionHudPalette(
        text: InfiniteRunnerConfig.hudText,
        muted: InfiniteRunnerConfig.hudMuted,
        accent: InfiniteRunnerConfig.passGreen,
        panel: Color(0x55FFFFFF),
      ),
      columns: [
        GameSessionHudStat(
          caption: 'Distância',
          value: '$distance m',
          footnote: '+${InfiniteRunnerConfig.pointsPerSecond}/s',
          footnoteColor: InfiniteRunnerConfig.hudMuted.withValues(alpha: 0.9),
        ),
        GameSessionHudStat(
          caption: 'Velocidade',
          value: 'Nv. $speedLevel',
        ),
        GameSessionHudStat(
          caption: 'Obstáculos',
          value: '$_obstaclesCleared',
          valueColor: InfiniteRunnerConfig.passGreen,
        ),
      ],
      progress: GameSessionHudProgress(
        ratio: _progress,
        color: InfiniteRunnerConfig.speedBar,
        lowColor: InfiniteRunnerConfig.speedBarLow,
        lowThreshold: 0.75,
        position: GameSessionHudProgressPosition.top,
      ),
    );
  }
}
