import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../economy/economy_config.dart';
import '../game_sdk/game_prep.dart';
import '../game_sdk/game_metadata.dart';
import '../progression/mission_models.dart';
import '../progression/progression_models.dart';

extension HubL10n on AppLocalizations {
  String gameTitle(String gameId) => switch (gameId) {
        'memory' => gameMemoryTitle,
        'tap_rush' => gameTapRushTitle,
        'game_2048' => game2048Title,
        'infinite_runner' => gameRunnerTitle,
        'solitaire' => gameSolitaireTitle,
        'snake' => gameSnakeTitle,
        'sudoku' => gameSudokuTitle,
        'demo_tap' => gameDemoTitle,
        _ => gameId,
      };

  String gameDescription(String gameId) => switch (gameId) {
        'memory' => gameMemoryDescription,
        'tap_rush' => gameTapRushDescription,
        'game_2048' => game2048Description,
        'infinite_runner' => gameRunnerDescription,
        'solitaire' => gameSolitaireDescription,
        'snake' => gameSnakeDescription,
        'sudoku' => gameSudokuDescription,
        'demo_tap' => gameDemoDescription,
        _ => '',
      };

  String gameCategory(String category) => switch (category) {
        'Arcade' => categoryArcade,
        'Puzzle' => categoryPuzzle,
        'Cartas' => categoryCards,
        'Cards' => categoryCards,
        _ => category,
      };

  GameMetadata localizedMetadata(GameMetadata meta) => GameMetadata(
        id: meta.id,
        title: gameTitle(meta.id),
        description: gameDescription(meta.id),
        category: gameCategory(meta.category),
        icon: meta.icon,
        enabled: meta.enabled,
      );

  GameHelpContent gameHelp(String gameId) => switch (gameId) {
        'memory' => GameHelpContent(
            howToPlay: gameMemoryHowToPlay,
            scoring: gameMemoryScoring,
          ),
        'tap_rush' => GameHelpContent(
            howToPlay: gameTapRushHowToPlay,
            scoring: gameTapRushScoring,
          ),
        'game_2048' => GameHelpContent(
            howToPlay: game2048HowToPlay,
            scoring: game2048Scoring,
          ),
        'infinite_runner' => GameHelpContent(
            howToPlay: gameRunnerHowToPlay,
            scoring: gameRunnerScoring,
          ),
        'solitaire' => GameHelpContent(
            howToPlay: gameSolitaireHowToPlay,
            scoring: gameSolitaireScoring(EconomyConfig.hintCoinCostSolitaire),
          ),
        'snake' => GameHelpContent(
            howToPlay: gameSnakeHowToPlay,
            scoring: gameSnakeScoring,
          ),
        'sudoku' => GameHelpContent(
            howToPlay: gameSudokuHowToPlay(EconomyConfig.hintCoinCostSudoku),
            scoring: gameSudokuScoring,
          ),
        _ => const GameHelpContent(howToPlay: '', scoring: ''),
      };

  String prepGroupLabel(String gameId, String optionKey) => switch (optionKey) {
        'durationSec' => prepTime,
        'speedMode' => prepSpeed,
        'difficulty' => prepDifficulty,
        'targetTile' => prepObjective,
        'pairCount' => prepCards,
        'drawCount' => prepDraw,
        _ => optionKey,
      };

  String prepChoiceLabel(String gameId, String optionKey, Object value) {
    if (optionKey == 'durationSec' && value is int) {
      return prepSeconds(value);
    }
    if (value is String) {
      return switch (value) {
        'easy' => difficultyEasy,
        'medium' => difficultyMedium,
        'hard' => difficultyHard,
        'normal' => difficultyNormal,
        _ => value,
      };
    }
    if (value is int) {
      return switch ((optionKey, value)) {
        ('speedMode', 0) => difficultyNormal,
        ('speedMode', 1) => speedFast,
        ('speedMode', 2) => speedInsane,
        ('drawCount', 1) => prepDrawOne,
        ('drawCount', 3) => prepDrawThree,
        ('pairCount', _) => '$value',
        ('targetTile', _) => '$value',
        _ => '$value',
      };
    }
    return '$value';
  }

  String? prepChoiceSubtitle(String gameId, String optionKey, Object value) {
    if (optionKey == 'pairCount' && value is int) {
      return prepPairsCount(value);
    }
    if (optionKey == 'targetTile') return prepTargetTile;
    if (optionKey == 'difficulty' && value is String) {
      final count = switch (value) {
        'easy' => 42,
        'medium' => 32,
        'hard' => 26,
        _ => null,
      };
      if (count != null) return prepCluesCount(count);
    }
    return null;
  }

  String achievementTitle(String id) => switch (id) {
        'first_game' => achievementFirstGameTitle,
        'games_10' => achievementGames10Title,
        'games_50' => achievementGames50Title,
        'streak_7' => achievementStreak7Title,
        'level_5' => achievementLevel5Title,
        'level_10' => achievementLevel10Title,
        'gold_once' => achievementGoldOnceTitle,
        'new_record' => achievementNewRecordTitle,
        'variety_5' => achievementVariety5Title,
        _ => id,
      };

  String achievementDescription(String id) => switch (id) {
        'first_game' => achievementFirstGameDesc,
        'games_10' => achievementGames10Desc,
        'games_50' => achievementGames50Desc,
        'streak_7' => achievementStreak7Desc,
        'level_5' => achievementLevel5Desc,
        'level_10' => achievementLevel10Desc,
        'gold_once' => achievementGoldOnceDesc,
        'new_record' => achievementNewRecordDesc,
        'variety_5' => achievementVariety5Desc,
        _ => '',
      };

  AchievementDefinition localizedAchievement(AchievementDefinition def) =>
      AchievementDefinition(
        id: def.id,
        title: achievementTitle(def.id),
        description: achievementDescription(def.id),
        emoji: def.emoji,
        coinReward: def.coinReward,
      );

  String missionTitle(String id) => switch (id) {
        'daily_play_3' => missionPlay3Title,
        'daily_score_500' => missionScore500Title,
        'daily_gold' => missionGoldTitle,
        _ => id,
      };

  String missionDescription(String id) => switch (id) {
        'daily_play_3' => missionPlay3Desc,
        'daily_score_500' => missionScore500Desc,
        'daily_gold' => missionGoldDesc,
        _ => '',
      };

  MissionDefinition localizedMission(MissionDefinition def) => MissionDefinition(
        id: def.id,
        title: missionTitle(def.id),
        description: missionDescription(def.id),
        emoji: def.emoji,
        target: def.target,
        coinReward: def.coinReward,
        kind: def.kind,
      );

  String languageLabel(Locale locale) => switch (locale.languageCode) {
        'pt' => languagePt,
        'en' => languageEn,
        'es' => languageEs,
        _ => locale.languageCode,
      };

  String levelProgressLabel(int level, int xpInLevel, int xpNeeded) =>
      economyLevelProgress(level, xpInLevel, xpNeeded);

  String levelUpMessage(int levels, int bonusCoins) {
    if (levels <= 1) {
      return bonusCoins > 0
          ? economyLevelUpBonus(bonusCoins)
          : economyLevelUp;
    }
    return bonusCoins > 0
        ? economyLevelsUpBonus(levels, bonusCoins)
        : economyLevelsUp(levels);
  }
}
