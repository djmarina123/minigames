import 'package:flutter/foundation.dart';

import 'game_result.dart';

/// Callbacks que o hub injeta em cada jogo durante a sessão.
class GameSessionCallbacks {
  const GameSessionCallbacks({
    required this.onScoreUpdate,
    required this.onGameOver,
    required this.onRewardEarned,
    required this.onExit,
  });

  final void Function(int score) onScoreUpdate;
  final void Function(GameResult result) onGameOver;
  final void Function(String rewardType, int amount) onRewardEarned;
  final VoidCallback onExit;
}
