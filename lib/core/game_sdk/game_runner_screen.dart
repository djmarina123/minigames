import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ads/ads_service.dart';
import '../leaderboard/leaderboard_repository.dart';
import '../storage/player_repository.dart';
import '../theme/game_ui.dart';
import 'game_result.dart';
import 'game_session_callbacks.dart';
import 'game_session_config.dart';
import 'hub_game.dart';
import 'widgets/game_result_dialog.dart';
import 'widgets/game_session_app_bar.dart';

/// Tela sandbox que abre qualquer jogo registrado no hub.
class GameRunnerScreen extends StatefulWidget {
  const GameRunnerScreen({
    super.key,
    required this.game,
    this.config = const GameSessionConfig(),
  });

  final HubGame game;
  final GameSessionConfig config;

  @override
  State<GameRunnerScreen> createState() => _GameRunnerScreenState();
}

class _GameRunnerScreenState extends State<GameRunnerScreen> {
  final _score = ValueNotifier<int>(0);
  bool _finished = false;
  late final GameSessionCallbacks _callbacks;
  Widget? _gameWidget;

  @override
  void initState() {
    super.initState();
    _callbacks = GameSessionCallbacks(
      onScoreUpdate: (score) => _score.value = score,
      onGameOver: _handleGameOver,
      onRewardEarned: (_, amount) {},
      onExit: () => Navigator.of(context).pop(),
    );
  }

  @override
  void dispose() {
    _score.dispose();
    super.dispose();
  }

  Future<void> _handleGameOver(GameResult result) async {
    if (_finished) return;
    _finished = true;

    final playerRepo = context.read<PlayerRepository>();
    final leaderboardRepo = context.read<LeaderboardRepository>();
    await playerRepo.recordGameSession(
      coinsEarned: result.coinsEarned,
      xpEarned: result.xpEarned,
    );
    await leaderboardRepo.submitScore(
      gameId: widget.game.metadata.id,
      gameTitle: widget.game.metadata.title,
      score: result.score,
    );

    if (!mounted) return;

    await showGameResultDialog(
      context: context,
      metadata: widget.game.metadata,
      result: result,
      onExit: () {
        Navigator.of(context).pop();
        if (mounted) Navigator.of(context).pop(result);
      },
      onDoubleCoins: () async {
        final bonus = await AdsService.showRewardedAd();
        await playerRepo.addBonusCoins(bonus);
        if (!mounted) return;
        Navigator.of(context).pop();
        if (mounted) Navigator.of(context).pop(result);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _gameWidget ??= widget.game.buildGame(context, _callbacks, config: widget.config);

    return Scaffold(
      backgroundColor: GameUi.surfaceDark,
      appBar: GameSessionAppBar(
        metadata: widget.game.metadata,
        scoreListenable: _score,
      ),
      body: _gameWidget!,
    );
  }
}
