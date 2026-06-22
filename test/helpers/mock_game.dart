import 'package:flutter/material.dart';

import 'package:minigames_hub/core/game_sdk/game_metadata.dart';
import 'package:minigames_hub/core/game_sdk/game_prep.dart';
import 'package:minigames_hub/core/game_sdk/game_result.dart';
import 'package:minigames_hub/core/game_sdk/game_session_callbacks.dart';
import 'package:minigames_hub/core/game_sdk/game_session_config.dart';
import 'package:minigames_hub/core/game_sdk/hub_game.dart';

/// Jogo mínimo para testes de integração do runner.
class MockInstantGame implements HubGame {
  MockInstantGame({this.delayBeforeGameOver = Duration.zero});

  final Duration delayBeforeGameOver;

  @override
  GamePrepDefinition? get prep => null;

  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'mock_instant',
        title: 'Mock Instant',
        description: 'Teste',
        category: 'Test',
        icon: '🧪',
        enabled: false,
      );

  @override
  Widget buildGame(
    BuildContext context,
    GameSessionCallbacks callbacks, {
    GameSessionConfig config = const GameSessionConfig(),
  }) {
    return _MockInstantBody(
      callbacks: callbacks,
      delay: delayBeforeGameOver,
    );
  }
}

class _MockInstantBody extends StatefulWidget {
  const _MockInstantBody({
    required this.callbacks,
    required this.delay,
  });

  final GameSessionCallbacks callbacks;
  final Duration delay;

  @override
  State<_MockInstantBody> createState() => _MockInstantBodyState();
}

class _MockInstantBodyState extends State<_MockInstantBody> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (!mounted) return;
      widget.callbacks.onGameOver(
        const GameResult(
          score: 100,
          duration: Duration(seconds: 5),
          coinsEarned: 10,
          xpEarned: 50,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
