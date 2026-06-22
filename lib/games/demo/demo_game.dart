import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/game_sdk/game_metadata.dart';
import '../../core/game_sdk/game_result.dart';
import '../../core/game_sdk/game_session_callbacks.dart';
import '../../core/game_sdk/game_prep.dart';
import '../../core/game_sdk/game_session_config.dart';
import '../../core/game_sdk/hub_game.dart';

/// Jogo de demonstração da Fase 0 — toque para pontuar.
class DemoGame implements HubGame {
  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'demo_tap',
        title: 'Demo Tap',
        description: 'Toque o botão o máximo que puder em 10 segundos.',
        category: 'Arcade',
        icon: '👆',
        featured: true,
      );

  @override
  GamePrepDefinition? get prep => null;

  @override
  Widget buildGame(
    BuildContext context,
    GameSessionCallbacks callbacks, {
    GameSessionConfig config = const GameSessionConfig(),
  }) {
    return _DemoGameView(callbacks: callbacks);
  }
}

class _DemoGameView extends StatefulWidget {
  const _DemoGameView({required this.callbacks});

  final GameSessionCallbacks callbacks;

  @override
  State<_DemoGameView> createState() => _DemoGameViewState();
}

class _DemoGameViewState extends State<_DemoGameView> {
  static const _duration = Duration(seconds: 10);

  int _score = 0;
  int _secondsLeft = _duration.inSeconds;
  Timer? _timer;
  bool _running = false;
  late final DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _start();
  }

  void _start() {
    _running = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        _finish();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _tap() {
    if (!_running) return;
    setState(() => _score++);
    widget.callbacks.onScoreUpdate(_score);
  }

  void _finish() {
    if (!_running) return;
    _running = false;

    final duration = DateTime.now().difference(_startedAt);
    widget.callbacks.onGameOver(
      GameResult(
        score: _score,
        duration: duration,
        coinsEarned: _score ~/ 5,
        xpEarned: _score,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$_secondsLeft s',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _running ? _tap : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size(200, 200),
              shape: const CircleBorder(),
            ),
            child: Text('$_score', style: const TextStyle(fontSize: 32)),
          ),
        ],
      ),
    );
  }
}
