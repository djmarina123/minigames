// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MiniPlay';

  @override
  String get navGames => 'Games';

  @override
  String get navRanking => 'Ranking';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeNoGames => 'No games available.';

  @override
  String homeAchievementUnlocked(String title) {
    return 'Achievement: $title';
  }

  @override
  String homeAchievementsUnlockedPlural(int count) {
    return '$count achievements unlocked!';
  }

  @override
  String get homeRemoveAdsComingSoon =>
      '\"Remove ads\" purchase — coming soon in Phase 2';

  @override
  String get homeRemoveAdsTooltip => 'Remove ads';

  @override
  String get featuredBadgeNew => 'NEW!';

  @override
  String get favoriteAdd => 'Add to favorites';

  @override
  String get favoriteRemove => 'Remove from favorites';

  @override
  String dailyRewardStreakDay(int day) {
    return 'Day $day of streak';
  }

  @override
  String get dailyRewardStartStreak => 'Start your daily streak';

  @override
  String dailyRewardClaimed(int amount) {
    return '+$amount coins claimed!';
  }

  @override
  String dailyRewardEarnCoins(int amount) {
    return 'Earn +$amount coins';
  }

  @override
  String get dailyRewardClaim => 'Claim';

  @override
  String hubDailyRewardTooltip(int amount) {
    return 'Claim +$amount coins';
  }

  @override
  String get hubMissionsTooltip => 'Today\'s missions';

  @override
  String get hubStatLevel => 'Level';

  @override
  String get hubStatCoins => 'Coins';

  @override
  String get hubActionDaily => 'Daily';

  @override
  String get hubActionGoals => 'Missions';

  @override
  String get hubActionNoAds => 'No Ads';

  @override
  String get missionsTodayTitle => 'Today\'s missions';

  @override
  String missionsProgressSummary(int done, int total) {
    return '$done of $total complete';
  }

  @override
  String missionCompletedReward(int reward) {
    return 'Mission complete! +$reward coins';
  }

  @override
  String get missionClaim => 'Claim';

  @override
  String get profileTitle => 'PROFILE';

  @override
  String get profileEconomyHelpTooltip => 'How coins and XP work';

  @override
  String get profilePlayerLabel => 'Player';

  @override
  String get profileEconomyCardTitle => 'Coins and XP';

  @override
  String get statCoins => 'Coins';

  @override
  String get statTotalXp => 'Total XP';

  @override
  String get statGamesPlayed => 'Games played';

  @override
  String get statDailyStreak => 'Daily streak';

  @override
  String statDailyStreakDays(int count) {
    return '$count days';
  }

  @override
  String profileVersion(String version) {
    return 'MiniPlay · version $version';
  }

  @override
  String profileBuild(String label) {
    return 'Build: $label';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languagePt => 'Português';

  @override
  String get languageEn => 'English';

  @override
  String get languageEs => 'Español';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get achievementsEmpty => 'Play games to unlock achievements.';

  @override
  String get shopTitle => 'Shop';

  @override
  String get shopRemoveAdsTitle => 'Remove ads';

  @override
  String get shopRemoveAdsPurchased => 'Purchased — no interstitials';

  @override
  String get shopRemoveAdsSubtitle => 'No ads between games';

  @override
  String shopCoinPackTitle(int amount) {
    return '$amount coins';
  }

  @override
  String get shopCoinPackSubtitle => 'Coin pack';

  @override
  String get shopPriceTest => 'Test';

  @override
  String get shopRestorePurchases => 'Restore purchases';

  @override
  String get iapProductUnavailable => 'Product unavailable.';

  @override
  String get iapPurchaseError => 'Purchase error.';

  @override
  String get leaderboardTitle => 'RANKING';

  @override
  String get leaderboardSubtitle => 'Your best score in each game';

  @override
  String get leaderboardEmptyTitle => 'No scores yet';

  @override
  String get leaderboardEmptyBody =>
      'Complete a game to appear here with your best result.';

  @override
  String get leaderboardPoints => 'POINTS';

  @override
  String get economyHelpTitle => 'Coins and XP';

  @override
  String get economyProfileSummary =>
      'Play games to earn XP, level up, and receive bonus coins.';

  @override
  String get economyHowCoins =>
      'Coins — earn by finishing games, daily login, and leveling up. Use for hints (Sudoku, Solitaire) and, in the future, cosmetics.';

  @override
  String get economyHowXp =>
      'XP — increases each game based on your performance. Accumulates toward the next level.';

  @override
  String get economyHowLevel =>
      'Level — increases with XP. Each new level gives bonus coins automatically.';

  @override
  String get economyHowRanking =>
      'Ranking — each game\'s score is separate; it doesn\'t spend coins or XP.';

  @override
  String economyLevelShort(int level) {
    return 'Lv. $level';
  }

  @override
  String economyLevelProgress(int level, int xpInLevel, int xpNeeded) {
    return 'Level $level · $xpInLevel / $xpNeeded XP';
  }

  @override
  String economySessionXp(int xp) {
    return '+$xp';
  }

  @override
  String economyLevelUpBonus(int bonusCoins) {
    return 'Level up! +$bonusCoins bonus coins';
  }

  @override
  String get economyLevelUp => 'Level up!';

  @override
  String economyLevelsUpBonus(int levels, int bonusCoins) {
    return '+$levels levels! +$bonusCoins bonus coins';
  }

  @override
  String economyLevelsUp(int levels) {
    return '+$levels levels!';
  }

  @override
  String get dialogGotIt => 'Got it';

  @override
  String get achievementFirstGameTitle => 'First game';

  @override
  String get achievementFirstGameDesc => 'Complete your first game in the hub.';

  @override
  String get achievementGames10Title => 'Addicted';

  @override
  String get achievementGames10Desc => 'Play 10 games in total.';

  @override
  String get achievementGames50Title => 'Marathoner';

  @override
  String get achievementGames50Desc => 'Play 50 games in total.';

  @override
  String get achievementStreak7Title => 'Solid week';

  @override
  String get achievementStreak7Desc => 'Maintain a 7-day daily streak.';

  @override
  String get achievementLevel5Title => 'Leveling up';

  @override
  String get achievementLevel5Desc => 'Reach level 5.';

  @override
  String get achievementLevel10Title => 'Veteran';

  @override
  String get achievementLevel10Desc => 'Reach level 10.';

  @override
  String get achievementGoldOnceTitle => 'Gold performance';

  @override
  String get achievementGoldOnceDesc => 'Complete a game with gold tier.';

  @override
  String get achievementNewRecordTitle => 'Personal record';

  @override
  String get achievementNewRecordDesc => 'Beat your record in any game.';

  @override
  String get achievementVariety5Title => 'Explorer';

  @override
  String get achievementVariety5Desc => 'Play 5 different games.';

  @override
  String get missionPlay3Title => 'Three games';

  @override
  String get missionPlay3Desc => 'Play 3 games today.';

  @override
  String get missionScore500Title => 'Scorer';

  @override
  String get missionScore500Desc => 'Score 500 points today.';

  @override
  String get missionGoldTitle => 'Gold tier';

  @override
  String get missionGoldDesc => 'Complete a game with gold performance.';

  @override
  String get gamePrepPlay => 'PLAY';

  @override
  String get gameHelpHowToPlay => 'How to play';

  @override
  String get gameHelpScoring => 'Scoring';

  @override
  String get resultVictoryTitle => 'VICTORY';

  @override
  String get resultDefeatTitle => 'DEFEAT';

  @override
  String get resultVictorySubtitle => 'You won the game!';

  @override
  String get resultDefeatSubtitle => 'Not this time — try again.';

  @override
  String get resultHeaderNewRecord => 'New record!';

  @override
  String get resultHeaderVictory => 'Victory!';

  @override
  String get resultHeaderDefeat => 'Defeat';

  @override
  String get resultHeaderEnded => 'Game over';

  @override
  String get resultBackToHub => 'Back to hub';

  @override
  String get resultBestBadge => 'BEST';

  @override
  String get resultScoreNewRecord => 'NEW RECORD';

  @override
  String get resultScoreLabel => 'SCORE';

  @override
  String resultGapToRecord(int gap) {
    return '$gap pts short of record';
  }

  @override
  String get resultXpLevel => 'Level XP';

  @override
  String get resultTime => 'Time';

  @override
  String resultBonusCoins(int bonusCoins) {
    return '+$bonusCoins bonus coins';
  }

  @override
  String get resultStatMaxCombo => 'Max combo';

  @override
  String get resultStatHits => 'Hits';

  @override
  String get resultStatMistakes => 'Mistakes';

  @override
  String get resultStatMoves => 'Moves';

  @override
  String get resultStatPerfect => 'Perfect';

  @override
  String get resultStatHighestTile => 'Highest tile';

  @override
  String get resultStatTileBonus => 'Tile bonus';

  @override
  String get resultStatObstacles => 'Obstacles';

  @override
  String get resultStatDistance => 'Distance';

  @override
  String get resultStatSpeed => 'Speed';

  @override
  String resultStatSpeedLevel(int level) {
    return 'Lv. $level';
  }

  @override
  String get resultStatFoundation => 'Foundation';

  @override
  String get resultStatFruits => 'Fruits';

  @override
  String get resultStatSize => 'Size';

  @override
  String get resultStatHints => 'Hints';

  @override
  String get resultStatCells => 'Cells';

  @override
  String get resultPlayAgain => 'PLAY AGAIN';

  @override
  String get resultAdLoading => 'Loading ad…';

  @override
  String get resultDoubleCoins => 'Double coins (ad)';

  @override
  String get categoryArcade => 'Arcade';

  @override
  String get categoryPuzzle => 'Puzzle';

  @override
  String get categoryCards => 'Cards';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyNormal => 'Normal';

  @override
  String get speedFast => 'Fast';

  @override
  String get speedInsane => 'Insane';

  @override
  String get prepTime => 'Time';

  @override
  String get prepSpeed => 'Speed';

  @override
  String get prepDifficulty => 'Difficulty';

  @override
  String get prepCpu => 'CPU';

  @override
  String get prepObjective => 'Goal';

  @override
  String get prepCards => 'Cards';

  @override
  String get prepDraw => 'Draw';

  @override
  String get prepTargetTile => 'target tile';

  @override
  String prepCluesCount(int count) {
    return '$count clues';
  }

  @override
  String prepCellsCount(int count) {
    return '$count cells';
  }

  @override
  String prepGridSize(int size) {
    return '$size×$size';
  }

  @override
  String prepPairsCount(int count) {
    return '$count pairs';
  }

  @override
  String get prepDrawOne => '1 card';

  @override
  String get prepDrawThree => '3 cards';

  @override
  String get prepBoard => 'Board';

  @override
  String get prepDefault => 'default';

  @override
  String get prepChallenge => 'challenge';

  @override
  String prepSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String get hudPairs => 'Pairs';

  @override
  String get hudTime => 'Time';

  @override
  String get hudMoves => 'Moves';

  @override
  String get hudPoints => 'Points';

  @override
  String get hudCombo => 'Combo';

  @override
  String get hudProgress => 'Progress';

  @override
  String get hudObjective => 'Goal';

  @override
  String get hudMax => 'Max';

  @override
  String get hudDistance => 'Distance';

  @override
  String get hudSpeed => 'Speed';

  @override
  String get hudObstacles => 'Obstacles';

  @override
  String get hudFoundation => 'Foundation';

  @override
  String get hudSize => 'Size';

  @override
  String get hudFruits => 'Fruits';

  @override
  String get hudYourTiles => 'Your tiles';

  @override
  String get hudTurn => 'Turn';

  @override
  String hudPenaltyPerMove(int penalty) {
    return '−$penalty/move';
  }

  @override
  String hudBonusPreview(int bonus) {
    return '+$bonus bonus';
  }

  @override
  String hudNextPoints(int pts) {
    return '+$pts next';
  }

  @override
  String hudMovesCount(int moves) {
    return '$moves moves';
  }

  @override
  String hudMistakesCount(int mistakes, int max) {
    return '$mistakes/$max errors';
  }

  @override
  String hudCpuTiles(int count) {
    return 'CPU: $count';
  }

  @override
  String get hudLines => 'Lines';

  @override
  String get hudMines => 'Mines';

  @override
  String hudMinesRemaining(int count) {
    return '$count left';
  }

  @override
  String prepMinesCount(int count) {
    return '$count mines';
  }

  @override
  String hudPointsPerObstacle(int pts) {
    return '+$pts/obs';
  }

  @override
  String get gameCountdownPrepare => 'Get ready...';

  @override
  String get gameSwipeToPlay => 'Swipe to play';

  @override
  String get gameInvalidMove => 'Invalid';

  @override
  String get gameUndone => 'Undone';

  @override
  String get gameNoMoves => 'No moves';

  @override
  String get gameNothingToMove => 'Nothing to move';

  @override
  String get gameHintUsed => 'Hint!';

  @override
  String gameHintCostCoins(int count) {
    return '$count coins';
  }

  @override
  String get gameTapRushTitle => 'Tap Rush';

  @override
  String get gameTapRushDescription =>
      'Hit targets in a row — combo boosts your score!';

  @override
  String get gameTapRushHowToPlay =>
      'Tap targets before they disappear. Consecutive hits build combo for more points. Missing, tapping outside, or letting a target vanish resets combo.';

  @override
  String get gameTapRushScoring =>
      'Each hit is worth 10 pts × combo (up to ×5). Over time targets shrink and disappear faster.';

  @override
  String get gameTapRushMissWrong => 'Miss!';

  @override
  String get gameTapRushMissOff => 'Off!';

  @override
  String gameTapRushCombo(int combo) {
    return 'COMBO x$combo';
  }

  @override
  String get gameMemoryTitle => 'Memory Game';

  @override
  String get gameMemoryDescription => 'Find all matching icon pairs.';

  @override
  String get gameMemoryHowToPlay =>
      'Tap a card to flip it. Tap another to try making a pair. Matching cards stay open; mismatches flip back. Find all pairs to win.';

  @override
  String get gameMemoryScoring =>
      'Each pair is worth 150 pts. Each move (pair attempt) costs 10 pts. Finding all pairs in minimum moves gives +100 pts extra.';

  @override
  String get gameMemoryTryAgain => 'Try again';

  @override
  String get gameSnakeTitle => 'Snake';

  @override
  String get gameSnakeDescription =>
      'Swipe to guide the snake — don\'t hit the walls!';

  @override
  String get gameSnakeHowToPlay =>
      'Swipe in the direction you want to move. Eat fruit to grow and score. Don\'t hit walls or your own body.';

  @override
  String get gameSnakeScoring =>
      'Each fruit scores points based on speed. The longer the snake, the more points per fruit. Survive as long as you can.';

  @override
  String get gameSnakeCrashed => 'Crashed!';

  @override
  String get game2048Title => '2048';

  @override
  String get game2048Description =>
      'Swipe and combine tiles to reach the target!';

  @override
  String get game2048HowToPlay =>
      'Swipe to move all tiles in a direction. Matching adjacent tiles combine. The board fills up — plan ahead.';

  @override
  String get game2048Scoring =>
      'Each merge adds the value of the new tile. Reaching the target tile gives a bonus. Highest tile reached also counts on the scoreboard.';

  @override
  String game2048TileReached(int tile) {
    return 'Tile $tile!';
  }

  @override
  String get gameRunnerTitle => 'Infinite Runner';

  @override
  String get gameRunnerDescription => 'Jump and duck to dodge obstacles!';

  @override
  String get gameRunnerHowToPlay =>
      'Swipe up to jump and hold down to duck. Dodge obstacles as long as you can.';

  @override
  String get gameRunnerScoring =>
      'Each obstacle cleared scores points. Speed increases over time — the farther you go, the more points per obstacle.';

  @override
  String get gameRunnerCrash => 'Oops!';

  @override
  String get gameRunnerHintJump => '↑ Swipe to jump';

  @override
  String get gameRunnerHintDuck => '↓ Hold to duck';

  @override
  String get gameRunnerDucking => 'Ducking';

  @override
  String get gameSolitaireTitle => 'Solitaire';

  @override
  String get gameSolitaireDescription =>
      'Organize cards on foundations from Ace to King.';

  @override
  String get gameSolitaireHowToPlay =>
      'Drag cards between columns (alternating colors, descending values). Move to foundations from Ace to King. Recycling the stock flips cards again.';

  @override
  String gameSolitaireScoring(int hintCost) {
    return 'Moving to foundation scores points. HINT costs $hintCost coins and reveals a playable card.';
  }

  @override
  String get gameSolitaireDropOnColumn => 'Drop on column';

  @override
  String get gameSolitaireRecycle => 'Recycle';

  @override
  String get gameSolitaireFlip => 'Flip';

  @override
  String get gameSudokuTitle => 'Sudoku';

  @override
  String get gameSudokuDescription =>
      'Fill the 9×9 grid without repeating numbers.';

  @override
  String gameSudokuHowToPlay(int hintCost) {
    return 'Tap an empty cell and pick a number from 1 to 9. Each row, column, and 3×3 block must contain all digits without repetition. HINT costs $hintCost coins and reveals a cell. Use ERASE to clear. The game ends when the grid is complete or after 5 errors.';
  }

  @override
  String get gameSudokuScoring =>
      'Each correct entry is +12 pts. Error −15 pts. Complete the puzzle for +500 pts and +100 pts if you finish with no errors or paid hints.';

  @override
  String get gameCrossSumsTitle => 'Cross Sums';

  @override
  String get gameCrossSumsDescription =>
      'Mark the right numbers so row and column sums match.';

  @override
  String gameCrossSumsHowToPlay(int hintCost) {
    return 'Remove or restore numbers so active cells in each row and column add up to the targets on the left and top. Use ERASER to remove and PENCIL to restore. HINT costs $hintCost coins. Finish when every cell is correct or after 5 mistakes.';
  }

  @override
  String get gameCrossSumsScoring =>
      'Each correct toggle is +15 pts. Mistake −18 pts. Complete the puzzle for +450 pts and +120 pts if you finish with no mistakes or paid hints.';

  @override
  String gameCrossSumsLevel(int level) {
    return 'Level $level';
  }

  @override
  String get gameColorBlocksTitle => 'Color Blocks';

  @override
  String get gameColorBlocksDescription =>
      'Fit colored blocks and clear full lines!';

  @override
  String get gameColorBlocksHowToPlay =>
      'Drag pieces from the tray onto the board. Full rows or columns disappear. The game ends when no piece fits on the grid.';

  @override
  String get gameColorBlocksScoring =>
      'Each placed cell is +10 pts. Each cleared row or column is +80 pts; multiple lines at once earn combo bonus.';

  @override
  String get gameColorBlocksNoFit => 'Does not fit';

  @override
  String get gameColorBlocksOverlap => 'Overlaps block!';

  @override
  String get gameColorBlocksOutOfBounds => 'Off the board!';

  @override
  String gameColorBlocksLinesPreview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines!',
      one: '1 line!',
    );
    return '$_temp0';
  }

  @override
  String gameColorBlocksComboPreview(int count) {
    return 'Combo ×$count';
  }

  @override
  String get gameMinesweeperTitle => 'Minesweeper';

  @override
  String get gameMinesweeperDescription =>
      'Reveal safe cells and flag every mine.';

  @override
  String gameMinesweeperHowToPlay(int hintCost) {
    return 'Tap to reveal a cell. The number shows nearby mines. Use FLAG to mark suspects or hold to toggle a flag. HINT costs $hintCost coins and reveals a safe cell. Your first move never hits a mine. Win by revealing every safe cell.';
  }

  @override
  String get gameMinesweeperScoring =>
      'Each revealed cell is +8 pts. Clear the board for +400 pts and +80 pts with no paid hints.';

  @override
  String get gameMinesweeperMineHit => 'Boom!';

  @override
  String get gameDemoTitle => 'Demo Tap';

  @override
  String get gameDemoDescription =>
      'Tap the button as many times as you can in 10 seconds.';
}
