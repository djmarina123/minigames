import 'package:flutter/foundation.dart';

import 'game_result.dart';

/// Callbacks que o hub injeta em cada jogo durante a sessão.
class GameSessionCallbacks {
  const GameSessionCallbacks({
    required this.onScoreUpdate,
    required this.onGameOver,
    required this.onRewardEarned,
    required this.onExit,
    this.trySpendCoins,
    this.currentCoins,
  });

  final void Function(int score) onScoreUpdate;
  final void Function(GameResult result) onGameOver;
  final void Function(String rewardType, int amount) onRewardEarned;
  final VoidCallback onExit;

  /// Gasta moedas do perfil (ex.: dica paga). Retorna `false` se saldo insuficiente.
  final bool Function(int amount)? trySpendCoins;

  /// Saldo atual — útil para habilitar ações pagas no jogo.
  final int Function()? currentCoins;
}
