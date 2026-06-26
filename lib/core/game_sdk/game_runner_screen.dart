import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ads/ads_service.dart';
import '../economy/session_rewards.dart';
import '../leaderboard/leaderboard_repository.dart';
import '../progression/achievements_repository.dart';
import '../progression/missions_repository.dart';
import '../progression/progression_models.dart';
import '../storage/player_repository.dart';
import '../theme/game_ui.dart';
import '../l10n/l10n_extensions.dart';
import '../../l10n/app_localizations.dart';
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
  late GameSessionCallbacks _callbacks;
  Widget? _gameWidget;

  @override
  void initState() {
    super.initState();
    _callbacks = _buildCallbacks();
  }

  GameSessionCallbacks _buildCallbacks() {
    return GameSessionCallbacks(
      onScoreUpdate: (score) => _score.value = score,
      onGameOver: _handleGameOver,
      onRewardEarned: (_, _) {},
      onExit: () => Navigator.of(context).pop(),
      trySpendCoins: (amount) =>
          context.read<PlayerRepository>().trySpendCoins(amount),
      currentCoins: () => context.read<PlayerRepository>().profile.coins,
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
    final gameId = widget.game.metadata.id;
    final previousBest = _bestScoreFor(leaderboardRepo, gameId);
    final isNewRecord =
        previousBest == null || result.score > previousBest;
    final isFirstGameToday = playerRepo.isFirstGameToday;

    final reward = resolveSessionReward(
      result: result,
      isNewRecord: isNewRecord,
      isFirstGameToday: isFirstGameToday,
    );
    final enriched = applySessionReward(result, reward);

    final l10n = AppLocalizations.of(context);
    final meta = l10n.localizedMetadata(widget.game.metadata);

    final sessionRecord = await playerRepo.recordGameSession(
      coinsEarned: enriched.coinsEarned,
      xpEarned: enriched.xpEarned,
    );
    await leaderboardRepo.submitScore(
      gameId: gameId,
      gameTitle: meta.title,
      score: result.score,
    );

    final profile = playerRepo.profile;
    final sessionEvent = SessionEvent(
      gameId: gameId,
      score: result.score,
      tierName: result.metadata['performanceTier'] as String?,
      isNewRecord: isNewRecord,
      gamesPlayed: profile.gamesPlayed,
      level: sessionRecord.newLevel,
      dailyStreak: profile.dailyStreak,
      uniqueGamesPlayed: 0,
      won: gameResultOutcomeWon(result.metadata),
    );

    if (!mounted) return;

    final achievementsRepo = context.read<AchievementsRepository>();
    final missionsRepo = context.read<MissionsRepository>();
    await achievementsRepo.onSession(sessionEvent);
    await missionsRepo.onSession(sessionEvent);

    if (!mounted) return;

    final bestScore =
        _bestScoreFor(leaderboardRepo, gameId) ?? result.score;

    if (!mounted) return;

    await showGameResultDialog(
      context: context,
      metadata: meta,
      result: enriched,
      bestScore: bestScore,
      isNewRecord: isNewRecord,
      levelUpLevels: sessionRecord.levelsGained,
      levelUpCoins: sessionRecord.levelUpCoins,
      onPlayAgain: () {
        Navigator.of(context).pop();
        if (!mounted) return;
        setState(() {
          _finished = false;
          _score.value = 0;
          _gameWidget = null;
          _callbacks = _buildCallbacks();
        });
      },
      onExit: () {
        Navigator.of(context).pop();
        if (mounted) Navigator.of(context).pop(enriched);
      },
      onDoubleCoins: () async {
        final watched = await AdsService.showRewardedAd();
        if (watched <= 0) return;
        await playerRepo.addBonusCoins(enriched.coinsEarned);
        if (!mounted) return;
        Navigator.of(context).pop();
        if (mounted) Navigator.of(context).pop(enriched);
      },
    );
  }

  int? _bestScoreFor(LeaderboardRepository repo, String gameId) {
    for (final entry in repo.allBest) {
      if (entry.gameId == gameId) return entry.score;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final meta =
        AppLocalizations.of(context).localizedMetadata(widget.game.metadata);
    _gameWidget ??=
        widget.game.buildGame(context, _callbacks, config: widget.config);

    return Scaffold(
      backgroundColor: GameUi.surfaceDark,
      appBar: GameSessionAppBar(
        metadata: meta,
        scoreListenable: _score,
      ),
      body: _gameWidget!,
    );
  }
}
