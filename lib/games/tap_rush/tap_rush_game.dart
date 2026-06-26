import 'dart:math';

import 'package:flame/components.dart';
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
import 'components/tap_rush_components.dart';
import 'tap_rush_config.dart';

/// Ponto de entrada HubGame — copie esta estrutura para novos jogos Flame.
class TapRushGame implements HubGame {
  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'tap_rush',
        title: 'Tap Rush',
        description: 'Acerte alvos em sequência — combo aumenta a pontuação!',
        category: 'Arcade',
        icon: '🎯',
      );

  @override
  GamePrepDefinition get prep => GamePrepDefinition(
        help: const GameHelpContent(
          howToPlay:
              'Toque nos alvos antes que desapareçam. Acertos seguidos formam '
              'combo e valem mais pontos. Errar, tocar fora ou deixar o alvo '
              'sumir zera o combo.',
          scoring:
              'Cada acerto vale 10 pts × combo (até ×5). Quanto mais tempo '
              'passa, os alvos ficam menores e somem mais rápido.',
        ),
        optionGroups: [
          GamePrepOptionGroup(
            label: 'Tempo',
            optionKey: TapRushConfig.optionKeyDurationSec,
            choices: const [
              GamePrepChoice(label: '15 s', value: 15),
              GamePrepChoice(label: '30 s', value: 30),
              GamePrepChoice(label: '60 s', value: 60),
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
    final durationSec = config.value(
      TapRushConfig.optionKeyDurationSec,
      TapRushConfig.gameDurationSec,
    );
    return GameWidget(
      game: TapRushFlameGame(
        callbacks: callbacks,
        durationSec: durationSec,
      ),
    );
  }
}

enum _Phase { countdown, playing, finished }

/// Implementação Flame — referência de qualidade para o hub.
class TapRushFlameGame extends FlameGame with TapCallbacks {
  TapRushFlameGame({
    required this.callbacks,
    required this.durationSec,
  });

  final GameSessionCallbacks callbacks;
  final int durationSec;

  _Phase _phase = _Phase.countdown;
  double _countdownLeft = TapRushConfig.countdownSec.toDouble();
  double _elapsed = 0;
  late DateTime _startedAt;

  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _hits = 0;
  int _misses = 0;
  double _missFlash = 0;

  bool _sessionStarted = false;
  _TapMissLayer? _tapMissLayer;
  RushTarget? _activeTarget;

  double get _progress => tapRushProgress(_elapsed, durationSec);

  @override
  Color backgroundColor() => TapRushConfig.bgTop;

  @override
  Future<void> onLoad() async {
    _startedAt = DateTime.now();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (size.x <= 0) return;
    _tapMissLayer ??= _TapMissLayer(onMiss: _onBackgroundMiss);
    _tapMissLayer!.size = size.clone();
    if (_tapMissLayer!.parent == null) {
      add(_tapMissLayer!);
    }
    if (_sessionStarted) return;
    _sessionStarted = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_sessionStarted || _phase == _Phase.finished) return;

    if (_missFlash > 0) {
      _missFlash = (_missFlash - dt).clamp(0.0, 1.0);
    }

    switch (_phase) {
      case _Phase.countdown:
        _countdownLeft -= dt;
        if (_countdownLeft <= 0) {
          _phase = _Phase.playing;
          _startedAt = DateTime.now();
          _spawnTarget();
        }
      case _Phase.playing:
        _elapsed += dt;
        if (_elapsed >= durationSec) {
          _finish();
        } else if (_activeTarget == null || !_activeTarget!.isMounted) {
          _spawnTarget();
        }
      case _Phase.finished:
        break;
    }
  }

  void _spawnTarget() {
    if (_phase != _Phase.playing || size.x <= 0) return;

    _activeTarget?.removeFromParent();

    final radius = tapRushTargetRadius(_progress);
    final lifetime = tapRushTargetLifetimeMs(_progress) / 1000;
    const padding = 48.0;
    final maxX = size.x - padding * 2;
    final maxY = size.y - 120;

    final x = padding + (maxX - radius * 2) * _random.nextDouble() + radius;
    final y = 80 + (maxY - radius * 2) * _random.nextDouble() + radius;

    _activeTarget = RushTarget(
      radius: radius,
      lifetimeSec: lifetime,
      position: Vector2(x, y),
      onHit: _onTargetHit,
      onMissed: _onTargetMissed,
    );
    add(_activeTarget!);
  }

  void _onTargetHit(RushTarget target, Vector2 worldPos) {
    if (_phase != _Phase.playing) return;

    _combo = (_combo + 1).clamp(1, 999);
    if (_combo > _maxCombo) _maxCombo = _combo;
    _hits++;
    final points = tapRushPointsForHit(_combo);
    _score += points;

    add(HitBurst(position: worldPos.clone()));
    add(
      FloatingLabel(
        position: worldPos.clone()..y -= 20,
        text: _combo > 1 ? '+$points x$_combo' : '+$points',
        color: TapRushConfig.comboGold,
      ),
    );

    callbacks.onScoreUpdate(_score);
    _activeTarget = null;
  }

  void _onTargetMissed() {
    if (_phase != _Phase.playing) return;

    _registerMiss('Errou!');
    _activeTarget = null;
  }

  void _onBackgroundMiss() {
    if (_phase != _Phase.playing) return;
    _registerMiss('Fora!');
  }

  void _registerMiss(String label) {
    _misses++;
    _combo = 0;
    _missFlash = 1;

    add(
      FloatingLabel(
        position: Vector2(size.x / 2, size.y * 0.35),
        text: label,
        color: TapRushConfig.missRed,
      ),
    );
  }

  void _finish() {
    if (_phase == _Phase.finished) return;
    _phase = _Phase.finished;
    _activeTarget?.removeFromParent();

    callbacks.onGameOver(
      GameResult(
        score: _score,
        duration: DateTime.now().difference(_startedAt),
        metadata: {
          'durationSec': durationSec,
          'hits': _hits,
          'misses': _misses,
          'maxCombo': _maxCombo,
          'performanceTier': tapRushPerformanceTier(_score).name,
        },
      ),
    );
  }

  final _random = Random();

  @override
  void render(Canvas canvas) {
    _paintBackground(canvas);
    super.render(canvas);
    if (_missFlash > 0) {
      canvas.drawRect(
        Offset.zero & Size(size.x, size.y),
        Paint()
          ..color = TapRushConfig.missRed.withValues(alpha: _missFlash * 0.15),
      );
    }
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
          colors: [TapRushConfig.bgTop, TapRushConfig.bgBottom],
        ).createShader(rect),
    );
  }

  void _paintHud(Canvas canvas) {
    if (_phase == _Phase.countdown) {
      GameSessionHud.paintText(
        canvas,
        _countdownLeft.ceil().clamp(1, TapRushConfig.countdownSec).toString(),
        Offset(size.x / 2, size.y / 2),
        72,
        TapRushConfig.hudText,
        align: GameSessionHudAlign.center,
      );
      GameSessionHud.paintText(
        canvas,
        'Prepare-se...',
        Offset(size.x / 2, size.y / 2 + 50),
        18,
        TapRushConfig.hudText.withValues(alpha: 0.7),
        align: GameSessionHudAlign.center,
      );
      return;
    }

    if (_phase == _Phase.finished) return;

    const barH = 8.0;
    const margin = GameSessionHud.margin;
    final barW = size.x - margin * 2;
    final timeLeft = (durationSec - _elapsed).clamp(0.0, durationSec.toDouble());
    final ratio = timeLeft / durationSec;

    GameSessionHud.paintProgressBar(
      canvas,
      Rect.fromLTWH(margin, 12, barW, barH),
      GameSessionHudProgress(
        ratio: ratio,
        color: TapRushConfig.timerBar,
        lowColor: TapRushConfig.timerBarLow,
      ),
    );

    if (_combo > 1) {
      GameSessionHud.paintText(
        canvas,
        'COMBO x$_combo',
        Offset(size.x / 2, 36),
        20,
        TapRushConfig.comboGold,
        align: GameSessionHudAlign.center,
      );
    }

    GameSessionHud.paintText(
      canvas,
      '${timeLeft.ceil()}s',
      Offset(size.x - margin, 28),
      16,
      TapRushConfig.hudText,
      align: GameSessionHudAlign.right,
    );
  }
}

/// Captura toques fora do alvo ativo — zera combo.
class _TapMissLayer extends PositionComponent with TapCallbacks {
  _TapMissLayer({required this.onMiss})
      : super(
          position: Vector2.zero(),
          anchor: Anchor.topLeft,
          priority: -10,
        );

  final VoidCallback onMiss;

  @override
  void onTapUp(TapUpEvent event) {
    onMiss();
  }
}
