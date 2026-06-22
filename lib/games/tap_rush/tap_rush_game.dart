import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/game_sdk/game_metadata.dart';
import '../../core/game_sdk/game_result.dart';
import '../../core/game_sdk/game_session_callbacks.dart';
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
        featured: true,
      );

  @override
  Widget buildGame(BuildContext context, GameSessionCallbacks callbacks) {
    return GameWidget(
      game: TapRushFlameGame(callbacks: callbacks),
    );
  }
}

enum _Phase { countdown, playing, finished }

/// Implementação Flame — referência de qualidade para o hub.
class TapRushFlameGame extends FlameGame with TapCallbacks {
  TapRushFlameGame({required this.callbacks});

  final GameSessionCallbacks callbacks;

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
  RushTarget? _activeTarget;

  double get _progress => tapRushProgress(_elapsed);

  @override
  Color backgroundColor() => TapRushConfig.bgTop;

  @override
  Future<void> onLoad() async {
    _startedAt = DateTime.now();
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
        if (_elapsed >= TapRushConfig.gameDurationSec) {
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

    _misses++;
    _combo = 0;
    _missFlash = 1;

    add(
      FloatingLabel(
        position: Vector2(size.x / 2, size.y * 0.35),
        text: 'Errou!',
        color: TapRushConfig.missRed,
      ),
    );
    _activeTarget = null;
  }

  void _finish() {
    if (_phase == _Phase.finished) return;
    _phase = _Phase.finished;
    _activeTarget?.removeFromParent();

    callbacks.onGameOver(
      GameResult(
        score: _score,
        duration: DateTime.now().difference(_startedAt),
        coinsEarned: _score ~/ 10,
        xpEarned: _score ~/ 2,
        metadata: {
          'hits': _hits,
          'misses': _misses,
          'maxCombo': _maxCombo,
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
      _paintCenterText(
        canvas,
        _countdownLeft.ceil().clamp(1, TapRushConfig.countdownSec).toString(),
        72,
        TapRushConfig.hudText,
      );
      _paintCenterText(canvas, 'Prepare-se...', 18, TapRushConfig.hudText.withValues(alpha: 0.7), yOffset: 50);
      return;
    }

    if (_phase == _Phase.finished) return;

    // Barra de tempo
    const barH = 8.0;
    const margin = 16.0;
    final barW = size.x - margin * 2;
    final timeLeft = (TapRushConfig.gameDurationSec - _elapsed).clamp(0.0, TapRushConfig.gameDurationSec.toDouble());
    final ratio = timeLeft / TapRushConfig.gameDurationSec;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(margin, 12, barW, barH),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.15),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(margin, 12, barW * ratio, barH),
        const Radius.circular(4),
      ),
      Paint()
        ..color = ratio < 0.25 ? TapRushConfig.timerBarLow : TapRushConfig.timerBar,
    );

    // Combo
    if (_combo > 1) {
      _paintText(
        canvas,
        'COMBO x$_combo',
        Offset(size.x / 2, 36),
        20,
        TapRushConfig.comboGold,
        centered: true,
      );
    }

    // Timer numérico
    _paintText(
      canvas,
      '${timeLeft.ceil()}s',
      Offset(size.x - margin, 28),
      16,
      TapRushConfig.hudText,
    );
  }

  void _paintCenterText(Canvas canvas, String text, double fontSize, Color color, {double yOffset = 0}) {
    _paintText(canvas, text, Offset(size.x / 2, size.y / 2 + yOffset), fontSize, color, centered: true);
  }

  void _paintText(Canvas canvas, String text, Offset pos, double fontSize, Color color, {bool centered = false}) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = centered
        ? Offset(pos.dx - painter.width / 2, pos.dy - painter.height / 2)
        : Offset(pos.dx - painter.width, pos.dy - painter.height / 2);
    painter.paint(canvas, offset);
  }
}
