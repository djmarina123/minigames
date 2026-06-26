// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'MiniPlay';

  @override
  String get navGames => 'Juegos';

  @override
  String get navRanking => 'Ranking';

  @override
  String get navProfile => 'Perfil';

  @override
  String get homeNoGames => 'No hay juegos disponibles.';

  @override
  String homeAchievementUnlocked(String title) {
    return 'Logro: $title';
  }

  @override
  String homeAchievementsUnlockedPlural(int count) {
    return '¡$count logros desbloqueados!';
  }

  @override
  String get homeRemoveAdsComingSoon =>
      'Compra \"Quitar anuncios\" — próximamente en Fase 2';

  @override
  String get homeRemoveAdsTooltip => 'Quitar anuncios';

  @override
  String get featuredBadgeNew => '¡NUEVO!';

  @override
  String get favoriteAdd => 'Añadir a favoritos';

  @override
  String get favoriteRemove => 'Quitar de favoritos';

  @override
  String dailyRewardStreakDay(int day) {
    return 'Día $day de racha';
  }

  @override
  String get dailyRewardStartStreak => 'Empieza tu racha diaria';

  @override
  String dailyRewardClaimed(int amount) {
    return '¡+$amount monedas reclamadas!';
  }

  @override
  String dailyRewardEarnCoins(int amount) {
    return 'Gana +$amount monedas';
  }

  @override
  String get dailyRewardClaim => 'Reclamar';

  @override
  String hubDailyRewardTooltip(int amount) {
    return 'Reclamar +$amount monedas';
  }

  @override
  String get hubMissionsTooltip => 'Misiones de hoy';

  @override
  String get missionsTodayTitle => 'Misiones de hoy';

  @override
  String missionsProgressSummary(int done, int total) {
    return '$done de $total completadas';
  }

  @override
  String missionCompletedReward(int reward) {
    return '¡Misión completada! +$reward monedas';
  }

  @override
  String get missionClaim => 'Reclamar';

  @override
  String get profileTitle => 'PERFIL';

  @override
  String get profileEconomyHelpTooltip => 'Cómo funcionan monedas y XP';

  @override
  String get profilePlayerLabel => 'Jugador';

  @override
  String get profileEconomyCardTitle => 'Monedas y XP';

  @override
  String get statCoins => 'Monedas';

  @override
  String get statTotalXp => 'XP total';

  @override
  String get statGamesPlayed => 'Partidas jugadas';

  @override
  String get statDailyStreak => 'Racha diaria';

  @override
  String statDailyStreakDays(int count) {
    return '$count días';
  }

  @override
  String profileVersion(String version) {
    return 'MiniPlay · versión $version';
  }

  @override
  String profileBuild(String label) {
    return 'Build: $label';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languagePt => 'Português';

  @override
  String get languageEn => 'English';

  @override
  String get languageEs => 'Español';

  @override
  String get achievementsTitle => 'Logros';

  @override
  String get achievementsEmpty => 'Juega partidas para desbloquear logros.';

  @override
  String get shopTitle => 'Tienda';

  @override
  String get shopRemoveAdsTitle => 'Quitar anuncios';

  @override
  String get shopRemoveAdsPurchased => 'Comprado — sin intersticiales';

  @override
  String get shopRemoveAdsSubtitle => 'Sin anuncios entre partidas';

  @override
  String shopCoinPackTitle(int amount) {
    return '$amount monedas';
  }

  @override
  String get shopCoinPackSubtitle => 'Paquete de monedas';

  @override
  String get shopPriceTest => 'Prueba';

  @override
  String get shopRestorePurchases => 'Restaurar compras';

  @override
  String get iapProductUnavailable => 'Producto no disponible.';

  @override
  String get iapPurchaseError => 'Error en la compra.';

  @override
  String get leaderboardTitle => 'RANKING';

  @override
  String get leaderboardSubtitle => 'Tu mejor puntuación en cada juego';

  @override
  String get leaderboardEmptyTitle => 'Aún no hay puntuaciones';

  @override
  String get leaderboardEmptyBody =>
      'Completa una partida para aparecer aquí con tu mejor resultado.';

  @override
  String get leaderboardPoints => 'PUNTOS';

  @override
  String get economyHelpTitle => 'Monedas y XP';

  @override
  String get economyProfileSummary =>
      'Juega partidas para ganar XP, subir de nivel y recibir monedas de bonificación.';

  @override
  String get economyHowCoins =>
      'Monedas — gana al terminar partidas, en el login diario y al subir de nivel. Úsalas en pistas (Sudoku, Solitario) y, en el futuro, en cosméticos.';

  @override
  String get economyHowXp =>
      'XP — sube en cada partida según tu rendimiento. Se acumula hasta el siguiente nivel.';

  @override
  String get economyHowLevel =>
      'Nivel — sube con XP. Cada nivel nuevo da monedas de bonificación automáticamente.';

  @override
  String get economyHowRanking =>
      'Ranking — la puntuación de cada juego es independiente; no gasta monedas ni XP.';

  @override
  String economyLevelShort(int level) {
    return 'Nv. $level';
  }

  @override
  String economyLevelProgress(int level, int xpInLevel, int xpNeeded) {
    return 'Nivel $level · $xpInLevel / $xpNeeded XP';
  }

  @override
  String economySessionXp(int xp) {
    return '+$xp';
  }

  @override
  String economyLevelUpBonus(int bonusCoins) {
    return '¡Subiste de nivel! +$bonusCoins monedas de bonificación';
  }

  @override
  String get economyLevelUp => '¡Subiste de nivel!';

  @override
  String economyLevelsUpBonus(int levels, int bonusCoins) {
    return '¡+$levels niveles! +$bonusCoins monedas de bonificación';
  }

  @override
  String economyLevelsUp(int levels) {
    return '¡+$levels niveles!';
  }

  @override
  String get dialogGotIt => 'Entendido';

  @override
  String get achievementFirstGameTitle => 'Primera partida';

  @override
  String get achievementFirstGameDesc =>
      'Completa tu primera partida en el hub.';

  @override
  String get achievementGames10Title => 'Adicto';

  @override
  String get achievementGames10Desc => 'Juega 10 partidas en total.';

  @override
  String get achievementGames50Title => 'Maratonista';

  @override
  String get achievementGames50Desc => 'Juega 50 partidas en total.';

  @override
  String get achievementStreak7Title => 'Semana firme';

  @override
  String get achievementStreak7Desc => 'Mantén una racha diaria de 7 días.';

  @override
  String get achievementLevel5Title => 'Subiendo de nivel';

  @override
  String get achievementLevel5Desc => 'Alcanza el nivel 5.';

  @override
  String get achievementLevel10Title => 'Veterano';

  @override
  String get achievementLevel10Desc => 'Alcanza el nivel 10.';

  @override
  String get achievementGoldOnceTitle => 'Rendimiento oro';

  @override
  String get achievementGoldOnceDesc => 'Completa una partida con franja oro.';

  @override
  String get achievementNewRecordTitle => 'Récord personal';

  @override
  String get achievementNewRecordDesc => 'Bate tu récord en cualquier juego.';

  @override
  String get achievementVariety5Title => 'Explorador';

  @override
  String get achievementVariety5Desc => 'Juega 5 juegos diferentes.';

  @override
  String get missionPlay3Title => 'Tres partidas';

  @override
  String get missionPlay3Desc => 'Juega 3 partidas hoy.';

  @override
  String get missionScore500Title => 'Anotador';

  @override
  String get missionScore500Desc => 'Suma 500 puntos hoy.';

  @override
  String get missionGoldTitle => 'Franja oro';

  @override
  String get missionGoldDesc => 'Completa una partida con rendimiento oro.';

  @override
  String get gamePrepPlay => 'JUGAR';

  @override
  String get gameHelpHowToPlay => 'Cómo jugar';

  @override
  String get gameHelpScoring => 'Puntuación';

  @override
  String get resultVictoryTitle => 'VICTORIA';

  @override
  String get resultDefeatTitle => 'DERROTA';

  @override
  String get resultVictorySubtitle => '¡Ganaste la partida!';

  @override
  String get resultDefeatSubtitle => 'No fue esta vez — inténtalo de nuevo.';

  @override
  String get resultHeaderNewRecord => '¡Nuevo récord!';

  @override
  String get resultHeaderVictory => '¡Victoria!';

  @override
  String get resultHeaderDefeat => 'Derrota';

  @override
  String get resultHeaderEnded => 'Partida terminada';

  @override
  String get resultBackToHub => 'Volver al hub';

  @override
  String get resultBestBadge => 'MEJOR';

  @override
  String get resultScoreNewRecord => 'NUEVO RÉCORD';

  @override
  String get resultScoreLabel => 'PUNTUACIÓN';

  @override
  String resultGapToRecord(int gap) {
    return 'Faltaron $gap pts para el récord';
  }

  @override
  String get resultXpLevel => 'XP nivel';

  @override
  String get resultTime => 'Tiempo';

  @override
  String resultBonusCoins(int bonusCoins) {
    return '+$bonusCoins monedas de bonificación';
  }

  @override
  String get resultStatMaxCombo => 'Combo máx.';

  @override
  String get resultStatHits => 'Aciertos';

  @override
  String get resultStatMistakes => 'Errores';

  @override
  String get resultStatMoves => 'Jugadas';

  @override
  String get resultStatTimeBonus => 'Bono tiempo';

  @override
  String get resultStatPerfect => 'Perfecto';

  @override
  String get resultStatHighestTile => 'Ficha mayor';

  @override
  String get resultStatTileBonus => 'Bono ficha';

  @override
  String get resultStatObstacles => 'Obstáculos';

  @override
  String get resultStatDistance => 'Distancia';

  @override
  String get resultStatSpeed => 'Velocidad';

  @override
  String resultStatSpeedLevel(int level) {
    return 'Nv. $level';
  }

  @override
  String get resultStatFoundation => 'Fundación';

  @override
  String get resultStatFruits => 'Frutas';

  @override
  String get resultStatSize => 'Tamaño';

  @override
  String get resultStatHints => 'Pistas';

  @override
  String get resultStatCells => 'Celdas';

  @override
  String get resultPlayAgain => 'JUGAR DE NUEVO';

  @override
  String get resultAdLoading => 'Cargando anuncio…';

  @override
  String get resultDoubleCoins => 'Duplicar monedas (anuncio)';

  @override
  String get categoryArcade => 'Arcade';

  @override
  String get categoryPuzzle => 'Puzzle';

  @override
  String get categoryCards => 'Cartas';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Medio';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get difficultyNormal => 'Normal';

  @override
  String get speedFast => 'Rápida';

  @override
  String get speedInsane => 'Insana';

  @override
  String get prepTime => 'Tiempo';

  @override
  String get prepSpeed => 'Velocidad';

  @override
  String get prepDifficulty => 'Dificultad';

  @override
  String get prepCpu => 'CPU';

  @override
  String get prepObjective => 'Objetivo';

  @override
  String get prepCards => 'Cartas';

  @override
  String get prepDraw => 'Voltear';

  @override
  String get prepTargetTile => 'ficha objetivo';

  @override
  String prepCluesCount(int count) {
    return '$count pistas';
  }

  @override
  String prepPairsCount(int count) {
    return '$count pares';
  }

  @override
  String get prepDrawOne => '1 carta';

  @override
  String get prepDrawThree => '3 cartas';

  @override
  String prepSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String get hudPairs => 'Pares';

  @override
  String get hudTime => 'Tiempo';

  @override
  String get hudMoves => 'Jugadas';

  @override
  String get hudPoints => 'Puntos';

  @override
  String get hudProgress => 'Progreso';

  @override
  String get hudObjective => 'Objetivo';

  @override
  String get hudMax => 'Máx.';

  @override
  String get hudDistance => 'Distancia';

  @override
  String get hudSpeed => 'Velocidad';

  @override
  String get hudObstacles => 'Obstáculos';

  @override
  String get hudFoundation => 'Fundación';

  @override
  String get hudSize => 'Tamaño';

  @override
  String get hudFruits => 'Frutas';

  @override
  String get hudYourTiles => 'Tus fichas';

  @override
  String get hudTurn => 'Turno';

  @override
  String hudPenaltyPerMove(int penalty) {
    return '−$penalty/jugada';
  }

  @override
  String hudTimeBonus(int bonus) {
    return '+$bonus tiempo';
  }

  @override
  String get hudNoTimeBonus => 'Sin bono tiempo';

  @override
  String hudBonusPreview(int bonus) {
    return '+$bonus bono';
  }

  @override
  String hudNextPoints(int pts) {
    return '+$pts próx.';
  }

  @override
  String hudMovesCount(int moves) {
    return '$moves jugadas';
  }

  @override
  String hudMistakesCount(int mistakes, int max) {
    return '$mistakes/$max errores';
  }

  @override
  String hudCpuTiles(int count) {
    return 'CPU: $count';
  }

  @override
  String hudPointsPerObstacle(int pts) {
    return '+$pts/obs';
  }

  @override
  String get gameCountdownPrepare => 'Prepárate...';

  @override
  String get gameSwipeToPlay => 'Desliza p/ jugar';

  @override
  String get gameInvalidMove => 'Inválido';

  @override
  String get gameUndone => 'Deshecho';

  @override
  String get gameNoMoves => 'Sin jugadas';

  @override
  String get gameNothingToMove => 'Nada p/ mover';

  @override
  String get gameHintUsed => '¡Pista!';

  @override
  String gameHintCostCoins(int count) {
    return '$count monedas';
  }

  @override
  String get gameTapRushTitle => 'Tap Rush';

  @override
  String get gameTapRushDescription =>
      '¡Acerta objetivos en secuencia — el combo aumenta la puntuación!';

  @override
  String get gameTapRushHowToPlay =>
      'Toca los objetivos antes de que desaparezcan. Los aciertos seguidos forman combo y valen más puntos. Fallar, tocar fuera o dejar que el objetivo desaparezca reinicia el combo.';

  @override
  String get gameTapRushScoring =>
      'Cada acierto vale 10 pts × combo (hasta ×5). Con el tiempo los objetivos se hacen más pequeños y desaparecen más rápido.';

  @override
  String get gameTapRushMissWrong => '¡Fallaste!';

  @override
  String get gameTapRushMissOff => '¡Fuera!';

  @override
  String gameTapRushCombo(int combo) {
    return 'COMBO x$combo';
  }

  @override
  String get gameMemoryTitle => 'Juego de Memoria';

  @override
  String get gameMemoryDescription => 'Encuentra todos los pares de iconos.';

  @override
  String get gameMemoryHowToPlay =>
      'Toca una carta para voltearla. Toca otra para intentar formar un par. Las cartas iguales quedan abiertas; las diferentes se voltean. Encuentra todos los pares para ganar.';

  @override
  String get gameMemoryScoring =>
      'Cada par vale 150 pts. Cada jugada (intento de par) resta 10 pts. Termina rápido para ganar hasta 200 pts de bono de tiempo. Acertar todos los pares en el mínimo de jugadas da +100 pts extra.';

  @override
  String get gameMemoryTryAgain => 'Inténtalo de nuevo';

  @override
  String get gameSnakeTitle => 'Serpiente';

  @override
  String get gameSnakeDescription =>
      '¡Desliza para guiar la serpiente — no choques con las paredes!';

  @override
  String get gameSnakeHowToPlay =>
      'Desliza en la dirección deseada para mover la serpiente. Come frutas para crecer y ganar puntos. No choques con las paredes ni con tu propio cuerpo.';

  @override
  String get gameSnakeScoring =>
      'Cada fruta da puntos según la velocidad. Cuanto más larga la serpiente, más puntos por fruta. Sobrevive el máximo posible.';

  @override
  String get gameSnakeCrashed => '¡Chocaste!';

  @override
  String get game2048Title => '2048';

  @override
  String get game2048Description =>
      '¡Desliza y combina fichas hasta crear la ficha objetivo!';

  @override
  String get game2048HowToPlay =>
      'Desliza para mover todas las fichas en una dirección. Las fichas iguales adyacentes se combinan. El tablero se llena — planifica con antelación.';

  @override
  String get game2048Scoring =>
      'Cada combinación suma el valor de la ficha creada. Alcanzar la ficha objetivo da bono. La ficha más alta alcanzada también cuenta en el marcador.';

  @override
  String game2048TileReached(int tile) {
    return '¡Ficha $tile!';
  }

  @override
  String get gameRunnerTitle => 'Carrera Infinita';

  @override
  String get gameRunnerDescription =>
      '¡Salta y agáchate para esquivar obstáculos!';

  @override
  String get gameRunnerHowToPlay =>
      'Desliza hacia arriba para saltar y mantén hacia abajo para agacharte. Esquiva obstáculos todo lo que puedas.';

  @override
  String get gameRunnerScoring =>
      'Cada obstáculo superado da puntos. La velocidad aumenta con el tiempo — cuanto más lejos, más puntos por obstáculo.';

  @override
  String get gameRunnerCrash => '¡Ups!';

  @override
  String get gameRunnerHintJump => '↑ Desliza p/ saltar';

  @override
  String get gameRunnerHintDuck => '↓ Mantén p/ agacharte';

  @override
  String get gameRunnerDucking => 'Agachado';

  @override
  String get gameSolitaireTitle => 'Solitario';

  @override
  String get gameSolitaireDescription =>
      'Organiza las cartas en las fundaciones del As al Rey.';

  @override
  String get gameSolitaireHowToPlay =>
      'Arrastra cartas entre columnas (color alterno, valor descendente). Mueve a las fundaciones del As al Rey. Reciclar el mazo voltea las cartas de nuevo.';

  @override
  String gameSolitaireScoring(int hintCost) {
    return 'Mover a fundación da puntos. Termina rápido para bono de tiempo. PISTA cuesta $hintCost monedas y revela una carta jugable.';
  }

  @override
  String get gameSolitaireDropOnColumn => 'Suelta en la columna';

  @override
  String get gameSolitaireRecycle => 'Reciclar';

  @override
  String get gameSolitaireFlip => 'Voltear';

  @override
  String get gameSudokuTitle => 'Sudoku';

  @override
  String get gameSudokuDescription =>
      'Rellena la cuadrícula 9×9 sin repetir números.';

  @override
  String gameSudokuHowToPlay(int hintCost) {
    return 'Toca una celda vacía y elige un número del 1 al 9. Cada fila, columna y bloque 3×3 debe contener todos los dígitos sin repetición. PISTA cuesta $hintCost monedas y revela una celda. Usa BORRAR para limpiar. La partida termina al completar la cuadrícula o tras 5 errores.';
  }

  @override
  String get gameSudokuScoring =>
      'Cada acierto vale +12 pts. Error −15 pts. Completa el puzzle para +500 pts, bono de tiempo (hasta 300 pts) y +100 pts si terminas sin errores ni pistas pagadas.';

  @override
  String get gameDominoTitle => 'Dominó';

  @override
  String get gameDominoDescription =>
      'Juega fichas contra la CPU y vacía tu mano.';

  @override
  String get gameDominoHowToPlay =>
      'Combina los números de los extremos de la fila con una ficha de tu mano. Quien tenga el doble mayor empieza. Si no puedes jugar, compra del montón o pasa el turno. Gana vaciando la mano o quedando con menos puntos si la partida se bloquea.';

  @override
  String get gameDominoScoring =>
      'Cada ficha jugada vale 15 pts. Comprar del montón cuesta 3 pts. Al ganar, obtén 3 pts por punto restante en la mano de la CPU. Termina rápido para bono de tiempo (hasta 150 pts).';

  @override
  String get gameDominoCpuDrew => 'CPU compró';

  @override
  String get gameDominoCpuPassed => 'CPU pasó';

  @override
  String get gameDominoDropOnEnd => 'Suelta en el extremo correcto';

  @override
  String get gameDominoNoFit => 'No encaja';

  @override
  String gameDominoCpuPlayed(String tile) {
    return 'CPU: $tile';
  }

  @override
  String get gameDominoNoPlayPass => 'Sin jugada — pasa';

  @override
  String get gameDominoBoneyard => 'Montón';

  @override
  String get gameDominoDraw => 'Comprar';

  @override
  String get gameDominoPass => 'Pasar';

  @override
  String get gameDominoCpuOpening => 'CPU abriendo…';

  @override
  String get gameDominoDragOpening => 'Arrastra la ficha de apertura';

  @override
  String get gameDominoDragToTable => 'Arrastra una ficha a la mesa';

  @override
  String get gameDominoYourTurn => 'Tu turno';

  @override
  String get gameDominoCpuTurn => 'CPU';

  @override
  String get gameDemoTitle => 'Demo Tap';

  @override
  String get gameDemoDescription =>
      'Toca el botón todo lo que puedas en 10 segundos.';
}
