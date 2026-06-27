// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'MiniPlay';

  @override
  String get navGames => 'Jogos';

  @override
  String get navRanking => 'Ranking';

  @override
  String get navProfile => 'Perfil';

  @override
  String get homeNoGames => 'Nenhum jogo disponível.';

  @override
  String homeAchievementUnlocked(String title) {
    return 'Conquista: $title';
  }

  @override
  String homeAchievementsUnlockedPlural(int count) {
    return '$count conquistas desbloqueadas!';
  }

  @override
  String get homeRemoveAdsComingSoon =>
      'Compra \"Remover ads\" — em breve na Fase 2';

  @override
  String get homeRemoveAdsTooltip => 'Remover anúncios';

  @override
  String get featuredBadgeNew => 'NOVO!';

  @override
  String get favoriteAdd => 'Adicionar aos favoritos';

  @override
  String get favoriteRemove => 'Remover dos favoritos';

  @override
  String dailyRewardStreakDay(int day) {
    return 'Dia $day da sequência';
  }

  @override
  String get dailyRewardStartStreak => 'Comece sua sequência diária';

  @override
  String dailyRewardClaimed(int amount) {
    return '+$amount moedas resgatadas!';
  }

  @override
  String dailyRewardEarnCoins(int amount) {
    return 'Ganhe +$amount moedas';
  }

  @override
  String get dailyRewardClaim => 'Resgatar';

  @override
  String hubDailyRewardTooltip(int amount) {
    return 'Resgatar +$amount moedas';
  }

  @override
  String get hubMissionsTooltip => 'Missões de hoje';

  @override
  String get missionsTodayTitle => 'Missões de hoje';

  @override
  String missionsProgressSummary(int done, int total) {
    return '$done de $total concluídas';
  }

  @override
  String missionCompletedReward(int reward) {
    return 'Missão concluída! +$reward moedas';
  }

  @override
  String get missionClaim => 'Resgatar';

  @override
  String get profileTitle => 'PERFIL';

  @override
  String get profileEconomyHelpTooltip => 'Como funcionam moedas e XP';

  @override
  String get profilePlayerLabel => 'Jogador';

  @override
  String get profileEconomyCardTitle => 'Moedas e XP';

  @override
  String get statCoins => 'Moedas';

  @override
  String get statTotalXp => 'XP total';

  @override
  String get statGamesPlayed => 'Partidas jogadas';

  @override
  String get statDailyStreak => 'Sequência diária';

  @override
  String statDailyStreakDays(int count) {
    return '$count dias';
  }

  @override
  String profileVersion(String version) {
    return 'MiniPlay · versão $version';
  }

  @override
  String profileBuild(String label) {
    return 'Build: $label';
  }

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languagePt => 'Português';

  @override
  String get languageEn => 'English';

  @override
  String get languageEs => 'Español';

  @override
  String get achievementsTitle => 'Conquistas';

  @override
  String get achievementsEmpty => 'Jogue partidas para desbloquear conquistas.';

  @override
  String get shopTitle => 'Loja';

  @override
  String get shopRemoveAdsTitle => 'Remover anúncios';

  @override
  String get shopRemoveAdsPurchased => 'Comprado — sem interstitials';

  @override
  String get shopRemoveAdsSubtitle => 'Sem anúncios entre partidas';

  @override
  String shopCoinPackTitle(int amount) {
    return '$amount moedas';
  }

  @override
  String get shopCoinPackSubtitle => 'Pacote de moedas';

  @override
  String get shopPriceTest => 'Teste';

  @override
  String get shopRestorePurchases => 'Restaurar compras';

  @override
  String get iapProductUnavailable => 'Produto indisponível.';

  @override
  String get iapPurchaseError => 'Erro na compra.';

  @override
  String get leaderboardTitle => 'RANKING';

  @override
  String get leaderboardSubtitle => 'Seu melhor score em cada jogo';

  @override
  String get leaderboardEmptyTitle => 'Nenhum score ainda';

  @override
  String get leaderboardEmptyBody =>
      'Complete uma partida para aparecer aqui com seu melhor resultado.';

  @override
  String get leaderboardPoints => 'PONTOS';

  @override
  String get economyHelpTitle => 'Moedas e XP';

  @override
  String get economyProfileSummary =>
      'Jogue partidas para ganhar XP, subir de nível e receber moedas bônus.';

  @override
  String get economyHowCoins =>
      'Moedas — ganhe ao terminar partidas, no login diário e ao subir de nível. Use em dicas (Sudoku, Paciência) e, no futuro, em cosméticos.';

  @override
  String get economyHowXp =>
      'XP — sobe a cada partida conforme seu desempenho. Acumula até o próximo nível.';

  @override
  String get economyHowLevel =>
      'Nível — sobe com XP. Cada nível novo dá moedas bônus automaticamente.';

  @override
  String get economyHowRanking =>
      'Ranking — a pontuação de cada jogo é separada; não gasta moedas nem XP.';

  @override
  String economyLevelShort(int level) {
    return 'Nv. $level';
  }

  @override
  String economyLevelProgress(int level, int xpInLevel, int xpNeeded) {
    return 'Nível $level · $xpInLevel / $xpNeeded XP';
  }

  @override
  String economySessionXp(int xp) {
    return '+$xp';
  }

  @override
  String economyLevelUpBonus(int bonusCoins) {
    return 'Nível up! +$bonusCoins moedas de bônus';
  }

  @override
  String get economyLevelUp => 'Nível up!';

  @override
  String economyLevelsUpBonus(int levels, int bonusCoins) {
    return '+$levels níveis! +$bonusCoins moedas de bônus';
  }

  @override
  String economyLevelsUp(int levels) {
    return '+$levels níveis!';
  }

  @override
  String get dialogGotIt => 'Entendi';

  @override
  String get achievementFirstGameTitle => 'Primeira partida';

  @override
  String get achievementFirstGameDesc =>
      'Complete sua primeira partida no hub.';

  @override
  String get achievementGames10Title => 'Viciado';

  @override
  String get achievementGames10Desc => 'Jogue 10 partidas no total.';

  @override
  String get achievementGames50Title => 'Maratonista';

  @override
  String get achievementGames50Desc => 'Jogue 50 partidas no total.';

  @override
  String get achievementStreak7Title => 'Semana firme';

  @override
  String get achievementStreak7Desc => 'Mantenha sequência diária de 7 dias.';

  @override
  String get achievementLevel5Title => 'Subindo de nível';

  @override
  String get achievementLevel5Desc => 'Alcance o nível 5.';

  @override
  String get achievementLevel10Title => 'Veterano';

  @override
  String get achievementLevel10Desc => 'Alcance o nível 10.';

  @override
  String get achievementGoldOnceTitle => 'Desempenho ouro';

  @override
  String get achievementGoldOnceDesc => 'Conclua uma partida com faixa ouro.';

  @override
  String get achievementNewRecordTitle => 'Recorde pessoal';

  @override
  String get achievementNewRecordDesc => 'Bata seu recorde em qualquer jogo.';

  @override
  String get achievementVariety5Title => 'Explorador';

  @override
  String get achievementVariety5Desc => 'Jogue 5 jogos diferentes.';

  @override
  String get missionPlay3Title => 'Três partidas';

  @override
  String get missionPlay3Desc => 'Jogue 3 partidas hoje.';

  @override
  String get missionScore500Title => 'Pontuador';

  @override
  String get missionScore500Desc => 'Some 500 pontos hoje.';

  @override
  String get missionGoldTitle => 'Faixa ouro';

  @override
  String get missionGoldDesc => 'Conclua uma partida com desempenho ouro.';

  @override
  String get gamePrepPlay => 'JOGAR';

  @override
  String get gameHelpHowToPlay => 'Como jogar';

  @override
  String get gameHelpScoring => 'Pontuação';

  @override
  String get resultVictoryTitle => 'VITÓRIA';

  @override
  String get resultDefeatTitle => 'DERROTA';

  @override
  String get resultVictorySubtitle => 'Você venceu a partida!';

  @override
  String get resultDefeatSubtitle => 'Não foi desta vez — tente de novo.';

  @override
  String get resultHeaderNewRecord => 'Novo recorde!';

  @override
  String get resultHeaderVictory => 'Vitória!';

  @override
  String get resultHeaderDefeat => 'Derrota';

  @override
  String get resultHeaderEnded => 'Partida encerrada';

  @override
  String get resultBackToHub => 'Voltar ao hub';

  @override
  String get resultBestBadge => 'MELHOR';

  @override
  String get resultScoreNewRecord => 'NOVO RECORDE';

  @override
  String get resultScoreLabel => 'PONTUAÇÃO';

  @override
  String resultGapToRecord(int gap) {
    return 'Faltaram $gap pts para o recorde';
  }

  @override
  String get resultXpLevel => 'XP nível';

  @override
  String get resultTime => 'Tempo';

  @override
  String resultBonusCoins(int bonusCoins) {
    return '+$bonusCoins moedas de bônus';
  }

  @override
  String get resultStatMaxCombo => 'Combo máx.';

  @override
  String get resultStatHits => 'Acertos';

  @override
  String get resultStatMistakes => 'Erros';

  @override
  String get resultStatMoves => 'Jogadas';

  @override
  String get resultStatTimeBonus => 'Bônus tempo';

  @override
  String get resultStatPerfect => 'Perfeito';

  @override
  String get resultStatHighestTile => 'Maior peça';

  @override
  String get resultStatTileBonus => 'Bônus peça';

  @override
  String get resultStatObstacles => 'Obstáculos';

  @override
  String get resultStatDistance => 'Distância';

  @override
  String get resultStatSpeed => 'Velocidade';

  @override
  String resultStatSpeedLevel(int level) {
    return 'Nv. $level';
  }

  @override
  String get resultStatFoundation => 'Fundação';

  @override
  String get resultStatFruits => 'Frutas';

  @override
  String get resultStatSize => 'Tamanho';

  @override
  String get resultStatHints => 'Dicas';

  @override
  String get resultStatCells => 'Células';

  @override
  String get resultPlayAgain => 'JOGAR NOVAMENTE';

  @override
  String get resultAdLoading => 'Carregando anúncio…';

  @override
  String get resultDoubleCoins => 'Dobrar moedas (anúncio)';

  @override
  String get categoryArcade => 'Arcade';

  @override
  String get categoryPuzzle => 'Puzzle';

  @override
  String get categoryCards => 'Cartas';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Médio';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get difficultyNormal => 'Normal';

  @override
  String get speedFast => 'Rápida';

  @override
  String get speedInsane => 'Insana';

  @override
  String get prepTime => 'Tempo';

  @override
  String get prepSpeed => 'Velocidade';

  @override
  String get prepDifficulty => 'Dificuldade';

  @override
  String get prepCpu => 'CPU';

  @override
  String get prepObjective => 'Objetivo';

  @override
  String get prepCards => 'Cartas';

  @override
  String get prepDraw => 'Virar';

  @override
  String get prepTargetTile => 'peça-alvo';

  @override
  String prepCluesCount(int count) {
    return '$count pistas';
  }

  @override
  String prepCellsCount(int count) {
    return '$count células';
  }

  @override
  String prepGridSize(int size) {
    return '$size×$size';
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
  String get prepBoard => 'Tabuleiro';

  @override
  String get prepDefault => 'padrão';

  @override
  String get prepChallenge => 'desafio';

  @override
  String prepSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String get hudPairs => 'Pares';

  @override
  String get hudTime => 'Tempo';

  @override
  String get hudMoves => 'Jogadas';

  @override
  String get hudPoints => 'Pontos';

  @override
  String get hudProgress => 'Progresso';

  @override
  String get hudObjective => 'Objetivo';

  @override
  String get hudMax => 'Máx.';

  @override
  String get hudDistance => 'Distância';

  @override
  String get hudSpeed => 'Velocidade';

  @override
  String get hudObstacles => 'Obstáculos';

  @override
  String get hudFoundation => 'Fundação';

  @override
  String get hudSize => 'Tamanho';

  @override
  String get hudFruits => 'Frutas';

  @override
  String get hudYourTiles => 'Suas peças';

  @override
  String get hudTurn => 'Turno';

  @override
  String hudPenaltyPerMove(int penalty) {
    return '−$penalty/jogada';
  }

  @override
  String hudTimeBonus(int bonus) {
    return '+$bonus tempo';
  }

  @override
  String get hudNoTimeBonus => 'Sem bônus tempo';

  @override
  String hudBonusPreview(int bonus) {
    return '+$bonus bônus';
  }

  @override
  String hudNextPoints(int pts) {
    return '+$pts próx.';
  }

  @override
  String hudMovesCount(int moves) {
    return '$moves jogadas';
  }

  @override
  String hudMistakesCount(int mistakes, int max) {
    return '$mistakes/$max erros';
  }

  @override
  String hudCpuTiles(int count) {
    return 'CPU: $count';
  }

  @override
  String get hudLines => 'Linhas';

  @override
  String get hudMines => 'Minas';

  @override
  String hudMinesRemaining(int count) {
    return '$count restantes';
  }

  @override
  String prepMinesCount(int count) {
    return '$count minas';
  }

  @override
  String hudPointsPerObstacle(int pts) {
    return '+$pts/obs';
  }

  @override
  String get gameCountdownPrepare => 'Prepare-se...';

  @override
  String get gameSwipeToPlay => 'Deslize p/ jogar';

  @override
  String get gameInvalidMove => 'Inválido';

  @override
  String get gameUndone => 'Desfeito';

  @override
  String get gameNoMoves => 'Sem jogadas';

  @override
  String get gameNothingToMove => 'Nada p/ mover';

  @override
  String get gameHintUsed => 'Dica!';

  @override
  String gameHintCostCoins(int count) {
    return '$count moedas';
  }

  @override
  String get gameTapRushTitle => 'Tap Rush';

  @override
  String get gameTapRushDescription =>
      'Acerte alvos em sequência — combo aumenta a pontuação!';

  @override
  String get gameTapRushHowToPlay =>
      'Toque nos alvos antes que desapareçam. Acertos seguidos formam combo e valem mais pontos. Errar, tocar fora ou deixar o alvo sumir zera o combo.';

  @override
  String get gameTapRushScoring =>
      'Cada acerto vale 10 pts × combo (até ×5). Quanto mais tempo passa, os alvos ficam menores e somem mais rápido.';

  @override
  String get gameTapRushMissWrong => 'Errou!';

  @override
  String get gameTapRushMissOff => 'Fora!';

  @override
  String gameTapRushCombo(int combo) {
    return 'COMBO x$combo';
  }

  @override
  String get gameMemoryTitle => 'Jogo da Memória';

  @override
  String get gameMemoryDescription => 'Encontre todos os pares de ícones.';

  @override
  String get gameMemoryHowToPlay =>
      'Toque em uma carta para virá-la. Toque em outra para tentar formar um par. Cartas iguais ficam abertas; diferentes voltam a fechar. Encontre todos os pares para vencer.';

  @override
  String get gameMemoryScoring =>
      'Cada par vale 150 pts. Cada jogada (tentativa de par) tira 10 pts. Termine rápido para ganhar até 200 pts de bônus de tempo. Acertar todos os pares no mínimo de jogadas dá +100 pts extra.';

  @override
  String get gameMemoryTryAgain => 'Tente de novo';

  @override
  String get gameSnakeTitle => 'Cobra';

  @override
  String get gameSnakeDescription =>
      'Deslize para guiar a cobra — não bata nas paredes!';

  @override
  String get gameSnakeHowToPlay =>
      'Deslize na direção desejada para mover a cobra. Coma frutas para crescer e ganhar pontos. Não bata nas paredes nem no próprio corpo.';

  @override
  String get gameSnakeScoring =>
      'Cada fruta vale pontos conforme a velocidade. Quanto mais longa a cobra, mais pontos por fruta. Sobreviva o máximo possível.';

  @override
  String get gameSnakeCrashed => 'Bateu!';

  @override
  String get game2048Title => '2048';

  @override
  String get game2048Description =>
      'Deslize e combine peças até criar a peça-alvo!';

  @override
  String get game2048HowToPlay =>
      'Deslize para mover todas as peças numa direção. Peças iguais adjacentes se combinam. O tabuleiro enche — planeje com antecedência.';

  @override
  String get game2048Scoring =>
      'Cada combinação soma o valor da peça criada. Atingir a peça-alvo dá bônus. Maior peça alcançada também conta no placar.';

  @override
  String game2048TileReached(int tile) {
    return 'Peça $tile!';
  }

  @override
  String get gameRunnerTitle => 'Corrida Infinita';

  @override
  String get gameRunnerDescription =>
      'Pule e agache para desviar dos obstáculos!';

  @override
  String get gameRunnerHowToPlay =>
      'Deslize para cima para pular e segure para baixo para agachar. Desvie dos obstáculos o máximo que puder.';

  @override
  String get gameRunnerScoring =>
      'Cada obstáculo ultrapassado vale pontos. A velocidade aumenta com o tempo — quanto mais longe, mais pontos por obstáculo.';

  @override
  String get gameRunnerCrash => 'Ops!';

  @override
  String get gameRunnerHintJump => '↑ Deslize p/ pular';

  @override
  String get gameRunnerHintDuck => '↓ Segure p/ agachar';

  @override
  String get gameRunnerDucking => 'Agachado';

  @override
  String get gameSolitaireTitle => 'Paciência';

  @override
  String get gameSolitaireDescription =>
      'Organize as cartas nas fundações do Ás ao Rei.';

  @override
  String get gameSolitaireHowToPlay =>
      'Arraste cartas entre colunas (cor alternada, valor decrescente). Mova para as fundações do Ás ao Rei. Virar do monte recicla as cartas.';

  @override
  String gameSolitaireScoring(int hintCost) {
    return 'Mover para fundação vale pontos. Termine rápido para bônus de tempo. DICA custa $hintCost moedas e revela uma carta jogável.';
  }

  @override
  String get gameSolitaireDropOnColumn => 'Solte na coluna';

  @override
  String get gameSolitaireRecycle => 'Reciclar';

  @override
  String get gameSolitaireFlip => 'Virar';

  @override
  String get gameSudokuTitle => 'Sudoku';

  @override
  String get gameSudokuDescription =>
      'Preencha o grid 9×9 sem repetir números.';

  @override
  String gameSudokuHowToPlay(int hintCost) {
    return 'Toque uma célula vazia e escolha um número de 1 a 9. Cada linha, coluna e bloco 3×3 deve conter todos os dígitos sem repetição. DICA custa $hintCost moedas e revela uma célula. Use APAGAR para limpar. A partida termina ao completar o grid ou após 5 erros.';
  }

  @override
  String get gameSudokuScoring =>
      'Cada acerto vale +12 pts. Erro −15 pts. Complete o puzzle para +500 pts, bônus de tempo (até 300 pts) e +100 pts se terminar sem erros nem dicas pagas.';

  @override
  String get gameCrossSumsTitle => 'Cross Sums';

  @override
  String get gameCrossSumsDescription =>
      'Marque os números certos para bater as soma das linhas e colunas.';

  @override
  String gameCrossSumsHowToPlay(int hintCost) {
    return 'Remova ou marque números na grade para que a soma dos ativos em cada linha e coluna bata com os alvos à esquerda e acima. Use a BORRACHA para remover e o LÁPIS para restaurar. DICA custa $hintCost moedas. Termine ao acertar todas as células ou após 5 erros.';
  }

  @override
  String get gameCrossSumsScoring =>
      'Cada acerto vale +15 pts. Erro −18 pts. Complete o puzzle para +450 pts, bônus de tempo (até 280 pts) e +120 pts se terminar sem erros nem dicas pagas.';

  @override
  String gameCrossSumsLevel(int level) {
    return 'Nível $level';
  }

  @override
  String get gameColorBlocksTitle => 'Color Blocks';

  @override
  String get gameColorBlocksDescription =>
      'Encaixe blocos coloridos e limpe linhas completas!';

  @override
  String get gameColorBlocksHowToPlay =>
      'Arraste as peças da bandeja para o tabuleiro. Linhas ou colunas completas desaparecem. A partida termina quando nenhuma peça cabe no grid.';

  @override
  String get gameColorBlocksScoring =>
      'Cada célula colocada vale +10 pts. Cada linha ou coluna limpa vale +80 pts; várias de uma vez dão bônus de combo.';

  @override
  String get gameColorBlocksNoFit => 'Não encaixa';

  @override
  String get gameColorBlocksOverlap => 'Sobrepõe bloco!';

  @override
  String get gameColorBlocksOutOfBounds => 'Fora do tabuleiro!';

  @override
  String gameColorBlocksLinesPreview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linhas!',
      one: '1 linha!',
    );
    return '$_temp0';
  }

  @override
  String gameColorBlocksComboPreview(int count) {
    return 'Combo ×$count';
  }

  @override
  String get gameMinesweeperTitle => 'Campo Minado';

  @override
  String get gameMinesweeperDescription =>
      'Revele células seguras e marque todas as minas.';

  @override
  String gameMinesweeperHowToPlay(int hintCost) {
    return 'Toque para revelar uma célula. O número indica minas vizinhas. Use BANDEIRA para marcar suspeitas ou segure para alternar bandeira. DICA custa $hintCost moedas e revela uma célula segura. A primeira jogada nunca acerta mina. Vença revelando todas as células seguras.';
  }

  @override
  String get gameMinesweeperScoring =>
      'Cada célula revelada vale +8 pts. Complete o tabuleiro para +400 pts, bônus de tempo (até 250 pts) e +80 pts sem dicas pagas.';

  @override
  String get gameMinesweeperMineHit => 'Boom!';

  @override
  String get gameDemoTitle => 'Demo Tap';

  @override
  String get gameDemoDescription =>
      'Toque o botão o máximo que puder em 10 segundos.';
}
