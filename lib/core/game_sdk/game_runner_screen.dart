import 'package:flutter/material.dart';

import 'game_result.dart';
import 'game_session_callbacks.dart';
import 'hub_game.dart';

/// Tela sandbox que abre qualquer jogo registrado no hub.
class GameRunnerScreen extends StatefulWidget {
  const GameRunnerScreen({super.key, required this.game});

  final HubGame game;

  @override
  State<GameRunnerScreen> createState() => _GameRunnerScreenState();
}

class _GameRunnerScreenState extends State<GameRunnerScreen> {
  int _score = 0;
  bool _finished = false;

  GameSessionCallbacks get _callbacks => GameSessionCallbacks(
        onScoreUpdate: (score) => setState(() => _score = score),
        onGameOver: _handleGameOver,
        onRewardEarned: (_, amount) {},
        onExit: () => Navigator.of(context).pop(),
      );

  void _handleGameOver(GameResult result) {
    if (_finished) return;
    _finished = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Fim de jogo'),
        content: Text(
          'Pontuação: ${result.score}\n'
          'Moedas: +${result.coinsEarned}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(result);
            },
            child: const Text('Voltar ao hub'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = widget.game.metadata;

    return Scaffold(
      appBar: AppBar(
        title: Text(meta.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('$_score pts')),
          ),
        ],
      ),
      body: widget.game.buildGame(context, _callbacks),
    );
  }
}
