import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'MiniPlay'**
  String get appName;

  /// No description provided for @navGames.
  ///
  /// In pt, this message translates to:
  /// **'Jogos'**
  String get navGames;

  /// No description provided for @navRanking.
  ///
  /// In pt, this message translates to:
  /// **'Ranking'**
  String get navRanking;

  /// No description provided for @navProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @homeNoGames.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum jogo disponível.'**
  String get homeNoGames;

  /// No description provided for @homeAchievementUnlocked.
  ///
  /// In pt, this message translates to:
  /// **'Conquista: {title}'**
  String homeAchievementUnlocked(String title);

  /// No description provided for @homeAchievementsUnlockedPlural.
  ///
  /// In pt, this message translates to:
  /// **'{count} conquistas desbloqueadas!'**
  String homeAchievementsUnlockedPlural(int count);

  /// No description provided for @homeRemoveAdsComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Compra \"Remover ads\" — em breve na Fase 2'**
  String get homeRemoveAdsComingSoon;

  /// No description provided for @homeRemoveAdsTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Remover anúncios'**
  String get homeRemoveAdsTooltip;

  /// No description provided for @featuredBadgeNew.
  ///
  /// In pt, this message translates to:
  /// **'NOVO!'**
  String get featuredBadgeNew;

  /// No description provided for @favoriteAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar aos favoritos'**
  String get favoriteAdd;

  /// No description provided for @favoriteRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover dos favoritos'**
  String get favoriteRemove;

  /// No description provided for @dailyRewardStreakDay.
  ///
  /// In pt, this message translates to:
  /// **'Dia {day} da sequência'**
  String dailyRewardStreakDay(int day);

  /// No description provided for @dailyRewardStartStreak.
  ///
  /// In pt, this message translates to:
  /// **'Comece sua sequência diária'**
  String get dailyRewardStartStreak;

  /// No description provided for @dailyRewardClaimed.
  ///
  /// In pt, this message translates to:
  /// **'+{amount} moedas resgatadas!'**
  String dailyRewardClaimed(int amount);

  /// No description provided for @dailyRewardEarnCoins.
  ///
  /// In pt, this message translates to:
  /// **'Ganhe +{amount} moedas'**
  String dailyRewardEarnCoins(int amount);

  /// No description provided for @dailyRewardClaim.
  ///
  /// In pt, this message translates to:
  /// **'Resgatar'**
  String get dailyRewardClaim;

  /// No description provided for @hubDailyRewardTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Resgatar +{amount} moedas'**
  String hubDailyRewardTooltip(int amount);

  /// No description provided for @hubMissionsTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Missões de hoje'**
  String get hubMissionsTooltip;

  /// No description provided for @missionsTodayTitle.
  ///
  /// In pt, this message translates to:
  /// **'Missões de hoje'**
  String get missionsTodayTitle;

  /// No description provided for @missionsProgressSummary.
  ///
  /// In pt, this message translates to:
  /// **'{done} de {total} concluídas'**
  String missionsProgressSummary(int done, int total);

  /// No description provided for @missionCompletedReward.
  ///
  /// In pt, this message translates to:
  /// **'Missão concluída! +{reward} moedas'**
  String missionCompletedReward(int reward);

  /// No description provided for @missionClaim.
  ///
  /// In pt, this message translates to:
  /// **'Resgatar'**
  String get missionClaim;

  /// No description provided for @profileTitle.
  ///
  /// In pt, this message translates to:
  /// **'PERFIL'**
  String get profileTitle;

  /// No description provided for @profileEconomyHelpTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Como funcionam moedas e XP'**
  String get profileEconomyHelpTooltip;

  /// No description provided for @profilePlayerLabel.
  ///
  /// In pt, this message translates to:
  /// **'Jogador'**
  String get profilePlayerLabel;

  /// No description provided for @profileEconomyCardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Moedas e XP'**
  String get profileEconomyCardTitle;

  /// No description provided for @statCoins.
  ///
  /// In pt, this message translates to:
  /// **'Moedas'**
  String get statCoins;

  /// No description provided for @statTotalXp.
  ///
  /// In pt, this message translates to:
  /// **'XP total'**
  String get statTotalXp;

  /// No description provided for @statGamesPlayed.
  ///
  /// In pt, this message translates to:
  /// **'Partidas jogadas'**
  String get statGamesPlayed;

  /// No description provided for @statDailyStreak.
  ///
  /// In pt, this message translates to:
  /// **'Sequência diária'**
  String get statDailyStreak;

  /// No description provided for @statDailyStreakDays.
  ///
  /// In pt, this message translates to:
  /// **'{count} dias'**
  String statDailyStreakDays(int count);

  /// No description provided for @profileVersion.
  ///
  /// In pt, this message translates to:
  /// **'MiniPlay · versão {version}'**
  String profileVersion(String version);

  /// No description provided for @profileBuild.
  ///
  /// In pt, this message translates to:
  /// **'Build: {label}'**
  String profileBuild(String label);

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @languagePt.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get languagePt;

  /// No description provided for @languageEn.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageEs.
  ///
  /// In pt, this message translates to:
  /// **'Español'**
  String get languageEs;

  /// No description provided for @achievementsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conquistas'**
  String get achievementsTitle;

  /// No description provided for @achievementsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Jogue partidas para desbloquear conquistas.'**
  String get achievementsEmpty;

  /// No description provided for @shopTitle.
  ///
  /// In pt, this message translates to:
  /// **'Loja'**
  String get shopTitle;

  /// No description provided for @shopRemoveAdsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Remover anúncios'**
  String get shopRemoveAdsTitle;

  /// No description provided for @shopRemoveAdsPurchased.
  ///
  /// In pt, this message translates to:
  /// **'Comprado — sem interstitials'**
  String get shopRemoveAdsPurchased;

  /// No description provided for @shopRemoveAdsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Sem anúncios entre partidas'**
  String get shopRemoveAdsSubtitle;

  /// No description provided for @shopCoinPackTitle.
  ///
  /// In pt, this message translates to:
  /// **'{amount} moedas'**
  String shopCoinPackTitle(int amount);

  /// No description provided for @shopCoinPackSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Pacote de moedas'**
  String get shopCoinPackSubtitle;

  /// No description provided for @shopPriceTest.
  ///
  /// In pt, this message translates to:
  /// **'Teste'**
  String get shopPriceTest;

  /// No description provided for @shopRestorePurchases.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar compras'**
  String get shopRestorePurchases;

  /// No description provided for @iapProductUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Produto indisponível.'**
  String get iapProductUnavailable;

  /// No description provided for @iapPurchaseError.
  ///
  /// In pt, this message translates to:
  /// **'Erro na compra.'**
  String get iapPurchaseError;

  /// No description provided for @leaderboardTitle.
  ///
  /// In pt, this message translates to:
  /// **'RANKING'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu melhor score em cada jogo'**
  String get leaderboardSubtitle;

  /// No description provided for @leaderboardEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum score ainda'**
  String get leaderboardEmptyTitle;

  /// No description provided for @leaderboardEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Complete uma partida para aparecer aqui com seu melhor resultado.'**
  String get leaderboardEmptyBody;

  /// No description provided for @leaderboardPoints.
  ///
  /// In pt, this message translates to:
  /// **'PONTOS'**
  String get leaderboardPoints;

  /// No description provided for @economyHelpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Moedas e XP'**
  String get economyHelpTitle;

  /// No description provided for @economyProfileSummary.
  ///
  /// In pt, this message translates to:
  /// **'Jogue partidas para ganhar XP, subir de nível e receber moedas bônus.'**
  String get economyProfileSummary;

  /// No description provided for @economyHowCoins.
  ///
  /// In pt, this message translates to:
  /// **'Moedas — ganhe ao terminar partidas, no login diário e ao subir de nível. Use em dicas (Sudoku, Paciência) e, no futuro, em cosméticos.'**
  String get economyHowCoins;

  /// No description provided for @economyHowXp.
  ///
  /// In pt, this message translates to:
  /// **'XP — sobe a cada partida conforme seu desempenho. Acumula até o próximo nível.'**
  String get economyHowXp;

  /// No description provided for @economyHowLevel.
  ///
  /// In pt, this message translates to:
  /// **'Nível — sobe com XP. Cada nível novo dá moedas bônus automaticamente.'**
  String get economyHowLevel;

  /// No description provided for @economyHowRanking.
  ///
  /// In pt, this message translates to:
  /// **'Ranking — a pontuação de cada jogo é separada; não gasta moedas nem XP.'**
  String get economyHowRanking;

  /// No description provided for @economyLevelShort.
  ///
  /// In pt, this message translates to:
  /// **'Nv. {level}'**
  String economyLevelShort(int level);

  /// No description provided for @economyLevelProgress.
  ///
  /// In pt, this message translates to:
  /// **'Nível {level} · {xpInLevel} / {xpNeeded} XP'**
  String economyLevelProgress(int level, int xpInLevel, int xpNeeded);

  /// No description provided for @economySessionXp.
  ///
  /// In pt, this message translates to:
  /// **'+{xp}'**
  String economySessionXp(int xp);

  /// No description provided for @economyLevelUpBonus.
  ///
  /// In pt, this message translates to:
  /// **'Nível up! +{bonusCoins} moedas de bônus'**
  String economyLevelUpBonus(int bonusCoins);

  /// No description provided for @economyLevelUp.
  ///
  /// In pt, this message translates to:
  /// **'Nível up!'**
  String get economyLevelUp;

  /// No description provided for @economyLevelsUpBonus.
  ///
  /// In pt, this message translates to:
  /// **'+{levels} níveis! +{bonusCoins} moedas de bônus'**
  String economyLevelsUpBonus(int levels, int bonusCoins);

  /// No description provided for @economyLevelsUp.
  ///
  /// In pt, this message translates to:
  /// **'+{levels} níveis!'**
  String economyLevelsUp(int levels);

  /// No description provided for @dialogGotIt.
  ///
  /// In pt, this message translates to:
  /// **'Entendi'**
  String get dialogGotIt;

  /// No description provided for @achievementFirstGameTitle.
  ///
  /// In pt, this message translates to:
  /// **'Primeira partida'**
  String get achievementFirstGameTitle;

  /// No description provided for @achievementFirstGameDesc.
  ///
  /// In pt, this message translates to:
  /// **'Complete sua primeira partida no hub.'**
  String get achievementFirstGameDesc;

  /// No description provided for @achievementGames10Title.
  ///
  /// In pt, this message translates to:
  /// **'Viciado'**
  String get achievementGames10Title;

  /// No description provided for @achievementGames10Desc.
  ///
  /// In pt, this message translates to:
  /// **'Jogue 10 partidas no total.'**
  String get achievementGames10Desc;

  /// No description provided for @achievementGames50Title.
  ///
  /// In pt, this message translates to:
  /// **'Maratonista'**
  String get achievementGames50Title;

  /// No description provided for @achievementGames50Desc.
  ///
  /// In pt, this message translates to:
  /// **'Jogue 50 partidas no total.'**
  String get achievementGames50Desc;

  /// No description provided for @achievementStreak7Title.
  ///
  /// In pt, this message translates to:
  /// **'Semana firme'**
  String get achievementStreak7Title;

  /// No description provided for @achievementStreak7Desc.
  ///
  /// In pt, this message translates to:
  /// **'Mantenha sequência diária de 7 dias.'**
  String get achievementStreak7Desc;

  /// No description provided for @achievementLevel5Title.
  ///
  /// In pt, this message translates to:
  /// **'Subindo de nível'**
  String get achievementLevel5Title;

  /// No description provided for @achievementLevel5Desc.
  ///
  /// In pt, this message translates to:
  /// **'Alcance o nível 5.'**
  String get achievementLevel5Desc;

  /// No description provided for @achievementLevel10Title.
  ///
  /// In pt, this message translates to:
  /// **'Veterano'**
  String get achievementLevel10Title;

  /// No description provided for @achievementLevel10Desc.
  ///
  /// In pt, this message translates to:
  /// **'Alcance o nível 10.'**
  String get achievementLevel10Desc;

  /// No description provided for @achievementGoldOnceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Desempenho ouro'**
  String get achievementGoldOnceTitle;

  /// No description provided for @achievementGoldOnceDesc.
  ///
  /// In pt, this message translates to:
  /// **'Conclua uma partida com faixa ouro.'**
  String get achievementGoldOnceDesc;

  /// No description provided for @achievementNewRecordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Recorde pessoal'**
  String get achievementNewRecordTitle;

  /// No description provided for @achievementNewRecordDesc.
  ///
  /// In pt, this message translates to:
  /// **'Bata seu recorde em qualquer jogo.'**
  String get achievementNewRecordDesc;

  /// No description provided for @achievementVariety5Title.
  ///
  /// In pt, this message translates to:
  /// **'Explorador'**
  String get achievementVariety5Title;

  /// No description provided for @achievementVariety5Desc.
  ///
  /// In pt, this message translates to:
  /// **'Jogue 5 jogos diferentes.'**
  String get achievementVariety5Desc;

  /// No description provided for @missionPlay3Title.
  ///
  /// In pt, this message translates to:
  /// **'Três partidas'**
  String get missionPlay3Title;

  /// No description provided for @missionPlay3Desc.
  ///
  /// In pt, this message translates to:
  /// **'Jogue 3 partidas hoje.'**
  String get missionPlay3Desc;

  /// No description provided for @missionScore500Title.
  ///
  /// In pt, this message translates to:
  /// **'Pontuador'**
  String get missionScore500Title;

  /// No description provided for @missionScore500Desc.
  ///
  /// In pt, this message translates to:
  /// **'Some 500 pontos hoje.'**
  String get missionScore500Desc;

  /// No description provided for @missionGoldTitle.
  ///
  /// In pt, this message translates to:
  /// **'Faixa ouro'**
  String get missionGoldTitle;

  /// No description provided for @missionGoldDesc.
  ///
  /// In pt, this message translates to:
  /// **'Conclua uma partida com desempenho ouro.'**
  String get missionGoldDesc;

  /// No description provided for @gamePrepPlay.
  ///
  /// In pt, this message translates to:
  /// **'JOGAR'**
  String get gamePrepPlay;

  /// No description provided for @gameHelpHowToPlay.
  ///
  /// In pt, this message translates to:
  /// **'Como jogar'**
  String get gameHelpHowToPlay;

  /// No description provided for @gameHelpScoring.
  ///
  /// In pt, this message translates to:
  /// **'Pontuação'**
  String get gameHelpScoring;

  /// No description provided for @resultVictoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'VITÓRIA'**
  String get resultVictoryTitle;

  /// No description provided for @resultDefeatTitle.
  ///
  /// In pt, this message translates to:
  /// **'DERROTA'**
  String get resultDefeatTitle;

  /// No description provided for @resultVictorySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Você venceu a partida!'**
  String get resultVictorySubtitle;

  /// No description provided for @resultDefeatSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Não foi desta vez — tente de novo.'**
  String get resultDefeatSubtitle;

  /// No description provided for @resultHeaderNewRecord.
  ///
  /// In pt, this message translates to:
  /// **'Novo recorde!'**
  String get resultHeaderNewRecord;

  /// No description provided for @resultHeaderVictory.
  ///
  /// In pt, this message translates to:
  /// **'Vitória!'**
  String get resultHeaderVictory;

  /// No description provided for @resultHeaderDefeat.
  ///
  /// In pt, this message translates to:
  /// **'Derrota'**
  String get resultHeaderDefeat;

  /// No description provided for @resultHeaderEnded.
  ///
  /// In pt, this message translates to:
  /// **'Partida encerrada'**
  String get resultHeaderEnded;

  /// No description provided for @resultBackToHub.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao hub'**
  String get resultBackToHub;

  /// No description provided for @resultBestBadge.
  ///
  /// In pt, this message translates to:
  /// **'MELHOR'**
  String get resultBestBadge;

  /// No description provided for @resultScoreNewRecord.
  ///
  /// In pt, this message translates to:
  /// **'NOVO RECORDE'**
  String get resultScoreNewRecord;

  /// No description provided for @resultScoreLabel.
  ///
  /// In pt, this message translates to:
  /// **'PONTUAÇÃO'**
  String get resultScoreLabel;

  /// No description provided for @resultGapToRecord.
  ///
  /// In pt, this message translates to:
  /// **'Faltaram {gap} pts para o recorde'**
  String resultGapToRecord(int gap);

  /// No description provided for @resultXpLevel.
  ///
  /// In pt, this message translates to:
  /// **'XP nível'**
  String get resultXpLevel;

  /// No description provided for @resultTime.
  ///
  /// In pt, this message translates to:
  /// **'Tempo'**
  String get resultTime;

  /// No description provided for @resultBonusCoins.
  ///
  /// In pt, this message translates to:
  /// **'+{bonusCoins} moedas de bônus'**
  String resultBonusCoins(int bonusCoins);

  /// No description provided for @resultStatMaxCombo.
  ///
  /// In pt, this message translates to:
  /// **'Combo máx.'**
  String get resultStatMaxCombo;

  /// No description provided for @resultStatHits.
  ///
  /// In pt, this message translates to:
  /// **'Acertos'**
  String get resultStatHits;

  /// No description provided for @resultStatMistakes.
  ///
  /// In pt, this message translates to:
  /// **'Erros'**
  String get resultStatMistakes;

  /// No description provided for @resultStatMoves.
  ///
  /// In pt, this message translates to:
  /// **'Jogadas'**
  String get resultStatMoves;

  /// No description provided for @resultStatTimeBonus.
  ///
  /// In pt, this message translates to:
  /// **'Bônus tempo'**
  String get resultStatTimeBonus;

  /// No description provided for @resultStatPerfect.
  ///
  /// In pt, this message translates to:
  /// **'Perfeito'**
  String get resultStatPerfect;

  /// No description provided for @resultStatHighestTile.
  ///
  /// In pt, this message translates to:
  /// **'Maior peça'**
  String get resultStatHighestTile;

  /// No description provided for @resultStatTileBonus.
  ///
  /// In pt, this message translates to:
  /// **'Bônus peça'**
  String get resultStatTileBonus;

  /// No description provided for @resultStatObstacles.
  ///
  /// In pt, this message translates to:
  /// **'Obstáculos'**
  String get resultStatObstacles;

  /// No description provided for @resultStatDistance.
  ///
  /// In pt, this message translates to:
  /// **'Distância'**
  String get resultStatDistance;

  /// No description provided for @resultStatSpeed.
  ///
  /// In pt, this message translates to:
  /// **'Velocidade'**
  String get resultStatSpeed;

  /// No description provided for @resultStatSpeedLevel.
  ///
  /// In pt, this message translates to:
  /// **'Nv. {level}'**
  String resultStatSpeedLevel(int level);

  /// No description provided for @resultStatFoundation.
  ///
  /// In pt, this message translates to:
  /// **'Fundação'**
  String get resultStatFoundation;

  /// No description provided for @resultStatFruits.
  ///
  /// In pt, this message translates to:
  /// **'Frutas'**
  String get resultStatFruits;

  /// No description provided for @resultStatSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho'**
  String get resultStatSize;

  /// No description provided for @resultStatHints.
  ///
  /// In pt, this message translates to:
  /// **'Dicas'**
  String get resultStatHints;

  /// No description provided for @resultStatCells.
  ///
  /// In pt, this message translates to:
  /// **'Células'**
  String get resultStatCells;

  /// No description provided for @resultPlayAgain.
  ///
  /// In pt, this message translates to:
  /// **'JOGAR NOVAMENTE'**
  String get resultPlayAgain;

  /// No description provided for @resultAdLoading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando anúncio…'**
  String get resultAdLoading;

  /// No description provided for @resultDoubleCoins.
  ///
  /// In pt, this message translates to:
  /// **'Dobrar moedas (anúncio)'**
  String get resultDoubleCoins;

  /// No description provided for @categoryArcade.
  ///
  /// In pt, this message translates to:
  /// **'Arcade'**
  String get categoryArcade;

  /// No description provided for @categoryPuzzle.
  ///
  /// In pt, this message translates to:
  /// **'Puzzle'**
  String get categoryPuzzle;

  /// No description provided for @categoryCards.
  ///
  /// In pt, this message translates to:
  /// **'Cartas'**
  String get categoryCards;

  /// No description provided for @difficultyEasy.
  ///
  /// In pt, this message translates to:
  /// **'Fácil'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In pt, this message translates to:
  /// **'Médio'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In pt, this message translates to:
  /// **'Difícil'**
  String get difficultyHard;

  /// No description provided for @difficultyNormal.
  ///
  /// In pt, this message translates to:
  /// **'Normal'**
  String get difficultyNormal;

  /// No description provided for @speedFast.
  ///
  /// In pt, this message translates to:
  /// **'Rápida'**
  String get speedFast;

  /// No description provided for @speedInsane.
  ///
  /// In pt, this message translates to:
  /// **'Insana'**
  String get speedInsane;

  /// No description provided for @prepTime.
  ///
  /// In pt, this message translates to:
  /// **'Tempo'**
  String get prepTime;

  /// No description provided for @prepSpeed.
  ///
  /// In pt, this message translates to:
  /// **'Velocidade'**
  String get prepSpeed;

  /// No description provided for @prepDifficulty.
  ///
  /// In pt, this message translates to:
  /// **'Dificuldade'**
  String get prepDifficulty;

  /// No description provided for @prepCpu.
  ///
  /// In pt, this message translates to:
  /// **'CPU'**
  String get prepCpu;

  /// No description provided for @prepObjective.
  ///
  /// In pt, this message translates to:
  /// **'Objetivo'**
  String get prepObjective;

  /// No description provided for @prepCards.
  ///
  /// In pt, this message translates to:
  /// **'Cartas'**
  String get prepCards;

  /// No description provided for @prepDraw.
  ///
  /// In pt, this message translates to:
  /// **'Virar'**
  String get prepDraw;

  /// No description provided for @prepTargetTile.
  ///
  /// In pt, this message translates to:
  /// **'peça-alvo'**
  String get prepTargetTile;

  /// No description provided for @prepCluesCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} pistas'**
  String prepCluesCount(int count);

  /// No description provided for @prepCellsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} células'**
  String prepCellsCount(int count);

  /// No description provided for @prepGridSize.
  ///
  /// In pt, this message translates to:
  /// **'{size}×{size}'**
  String prepGridSize(int size);

  /// No description provided for @prepPairsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} pares'**
  String prepPairsCount(int count);

  /// No description provided for @prepDrawOne.
  ///
  /// In pt, this message translates to:
  /// **'1 carta'**
  String get prepDrawOne;

  /// No description provided for @prepDrawThree.
  ///
  /// In pt, this message translates to:
  /// **'3 cartas'**
  String get prepDrawThree;

  /// No description provided for @prepBoard.
  ///
  /// In pt, this message translates to:
  /// **'Tabuleiro'**
  String get prepBoard;

  /// No description provided for @prepDefault.
  ///
  /// In pt, this message translates to:
  /// **'padrão'**
  String get prepDefault;

  /// No description provided for @prepChallenge.
  ///
  /// In pt, this message translates to:
  /// **'desafio'**
  String get prepChallenge;

  /// No description provided for @prepSeconds.
  ///
  /// In pt, this message translates to:
  /// **'{seconds} s'**
  String prepSeconds(int seconds);

  /// No description provided for @hudPairs.
  ///
  /// In pt, this message translates to:
  /// **'Pares'**
  String get hudPairs;

  /// No description provided for @hudTime.
  ///
  /// In pt, this message translates to:
  /// **'Tempo'**
  String get hudTime;

  /// No description provided for @hudMoves.
  ///
  /// In pt, this message translates to:
  /// **'Jogadas'**
  String get hudMoves;

  /// No description provided for @hudPoints.
  ///
  /// In pt, this message translates to:
  /// **'Pontos'**
  String get hudPoints;

  /// No description provided for @hudProgress.
  ///
  /// In pt, this message translates to:
  /// **'Progresso'**
  String get hudProgress;

  /// No description provided for @hudObjective.
  ///
  /// In pt, this message translates to:
  /// **'Objetivo'**
  String get hudObjective;

  /// No description provided for @hudMax.
  ///
  /// In pt, this message translates to:
  /// **'Máx.'**
  String get hudMax;

  /// No description provided for @hudDistance.
  ///
  /// In pt, this message translates to:
  /// **'Distância'**
  String get hudDistance;

  /// No description provided for @hudSpeed.
  ///
  /// In pt, this message translates to:
  /// **'Velocidade'**
  String get hudSpeed;

  /// No description provided for @hudObstacles.
  ///
  /// In pt, this message translates to:
  /// **'Obstáculos'**
  String get hudObstacles;

  /// No description provided for @hudFoundation.
  ///
  /// In pt, this message translates to:
  /// **'Fundação'**
  String get hudFoundation;

  /// No description provided for @hudSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho'**
  String get hudSize;

  /// No description provided for @hudFruits.
  ///
  /// In pt, this message translates to:
  /// **'Frutas'**
  String get hudFruits;

  /// No description provided for @hudYourTiles.
  ///
  /// In pt, this message translates to:
  /// **'Suas peças'**
  String get hudYourTiles;

  /// No description provided for @hudTurn.
  ///
  /// In pt, this message translates to:
  /// **'Turno'**
  String get hudTurn;

  /// No description provided for @hudPenaltyPerMove.
  ///
  /// In pt, this message translates to:
  /// **'−{penalty}/jogada'**
  String hudPenaltyPerMove(int penalty);

  /// No description provided for @hudTimeBonus.
  ///
  /// In pt, this message translates to:
  /// **'+{bonus} tempo'**
  String hudTimeBonus(int bonus);

  /// No description provided for @hudNoTimeBonus.
  ///
  /// In pt, this message translates to:
  /// **'Sem bônus tempo'**
  String get hudNoTimeBonus;

  /// No description provided for @hudBonusPreview.
  ///
  /// In pt, this message translates to:
  /// **'+{bonus} bônus'**
  String hudBonusPreview(int bonus);

  /// No description provided for @hudNextPoints.
  ///
  /// In pt, this message translates to:
  /// **'+{pts} próx.'**
  String hudNextPoints(int pts);

  /// No description provided for @hudMovesCount.
  ///
  /// In pt, this message translates to:
  /// **'{moves} jogadas'**
  String hudMovesCount(int moves);

  /// No description provided for @hudMistakesCount.
  ///
  /// In pt, this message translates to:
  /// **'{mistakes}/{max} erros'**
  String hudMistakesCount(int mistakes, int max);

  /// No description provided for @hudCpuTiles.
  ///
  /// In pt, this message translates to:
  /// **'CPU: {count}'**
  String hudCpuTiles(int count);

  /// No description provided for @hudLines.
  ///
  /// In pt, this message translates to:
  /// **'Linhas'**
  String get hudLines;

  /// No description provided for @hudMines.
  ///
  /// In pt, this message translates to:
  /// **'Minas'**
  String get hudMines;

  /// No description provided for @hudMinesRemaining.
  ///
  /// In pt, this message translates to:
  /// **'{count} restantes'**
  String hudMinesRemaining(int count);

  /// No description provided for @prepMinesCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} minas'**
  String prepMinesCount(int count);

  /// No description provided for @hudPointsPerObstacle.
  ///
  /// In pt, this message translates to:
  /// **'+{pts}/obs'**
  String hudPointsPerObstacle(int pts);

  /// No description provided for @gameCountdownPrepare.
  ///
  /// In pt, this message translates to:
  /// **'Prepare-se...'**
  String get gameCountdownPrepare;

  /// No description provided for @gameSwipeToPlay.
  ///
  /// In pt, this message translates to:
  /// **'Deslize p/ jogar'**
  String get gameSwipeToPlay;

  /// No description provided for @gameInvalidMove.
  ///
  /// In pt, this message translates to:
  /// **'Inválido'**
  String get gameInvalidMove;

  /// No description provided for @gameUndone.
  ///
  /// In pt, this message translates to:
  /// **'Desfeito'**
  String get gameUndone;

  /// No description provided for @gameNoMoves.
  ///
  /// In pt, this message translates to:
  /// **'Sem jogadas'**
  String get gameNoMoves;

  /// No description provided for @gameNothingToMove.
  ///
  /// In pt, this message translates to:
  /// **'Nada p/ mover'**
  String get gameNothingToMove;

  /// No description provided for @gameHintUsed.
  ///
  /// In pt, this message translates to:
  /// **'Dica!'**
  String get gameHintUsed;

  /// No description provided for @gameHintCostCoins.
  ///
  /// In pt, this message translates to:
  /// **'{count} moedas'**
  String gameHintCostCoins(int count);

  /// No description provided for @gameTapRushTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tap Rush'**
  String get gameTapRushTitle;

  /// No description provided for @gameTapRushDescription.
  ///
  /// In pt, this message translates to:
  /// **'Acerte alvos em sequência — combo aumenta a pontuação!'**
  String get gameTapRushDescription;

  /// No description provided for @gameTapRushHowToPlay.
  ///
  /// In pt, this message translates to:
  /// **'Toque nos alvos antes que desapareçam. Acertos seguidos formam combo e valem mais pontos. Errar, tocar fora ou deixar o alvo sumir zera o combo.'**
  String get gameTapRushHowToPlay;

  /// No description provided for @gameTapRushScoring.
  ///
  /// In pt, this message translates to:
  /// **'Cada acerto vale 10 pts × combo (até ×5). Quanto mais tempo passa, os alvos ficam menores e somem mais rápido.'**
  String get gameTapRushScoring;

  /// No description provided for @gameTapRushMissWrong.
  ///
  /// In pt, this message translates to:
  /// **'Errou!'**
  String get gameTapRushMissWrong;

  /// No description provided for @gameTapRushMissOff.
  ///
  /// In pt, this message translates to:
  /// **'Fora!'**
  String get gameTapRushMissOff;

  /// No description provided for @gameTapRushCombo.
  ///
  /// In pt, this message translates to:
  /// **'COMBO x{combo}'**
  String gameTapRushCombo(int combo);

  /// No description provided for @gameMemoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Jogo da Memória'**
  String get gameMemoryTitle;

  /// No description provided for @gameMemoryDescription.
  ///
  /// In pt, this message translates to:
  /// **'Encontre todos os pares de ícones.'**
  String get gameMemoryDescription;

  /// No description provided for @gameMemoryHowToPlay.
  ///
  /// In pt, this message translates to:
  /// **'Toque em uma carta para virá-la. Toque em outra para tentar formar um par. Cartas iguais ficam abertas; diferentes voltam a fechar. Encontre todos os pares para vencer.'**
  String get gameMemoryHowToPlay;

  /// No description provided for @gameMemoryScoring.
  ///
  /// In pt, this message translates to:
  /// **'Cada par vale 150 pts. Cada jogada (tentativa de par) tira 10 pts. Termine rápido para ganhar até 200 pts de bônus de tempo. Acertar todos os pares no mínimo de jogadas dá +100 pts extra.'**
  String get gameMemoryScoring;

  /// No description provided for @gameMemoryTryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tente de novo'**
  String get gameMemoryTryAgain;

  /// No description provided for @gameSnakeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cobra'**
  String get gameSnakeTitle;

  /// No description provided for @gameSnakeDescription.
  ///
  /// In pt, this message translates to:
  /// **'Deslize para guiar a cobra — não bata nas paredes!'**
  String get gameSnakeDescription;

  /// No description provided for @gameSnakeHowToPlay.
  ///
  /// In pt, this message translates to:
  /// **'Deslize na direção desejada para mover a cobra. Coma frutas para crescer e ganhar pontos. Não bata nas paredes nem no próprio corpo.'**
  String get gameSnakeHowToPlay;

  /// No description provided for @gameSnakeScoring.
  ///
  /// In pt, this message translates to:
  /// **'Cada fruta vale pontos conforme a velocidade. Quanto mais longa a cobra, mais pontos por fruta. Sobreviva o máximo possível.'**
  String get gameSnakeScoring;

  /// No description provided for @gameSnakeCrashed.
  ///
  /// In pt, this message translates to:
  /// **'Bateu!'**
  String get gameSnakeCrashed;

  /// No description provided for @game2048Title.
  ///
  /// In pt, this message translates to:
  /// **'2048'**
  String get game2048Title;

  /// No description provided for @game2048Description.
  ///
  /// In pt, this message translates to:
  /// **'Deslize e combine peças até criar a peça-alvo!'**
  String get game2048Description;

  /// No description provided for @game2048HowToPlay.
  ///
  /// In pt, this message translates to:
  /// **'Deslize para mover todas as peças numa direção. Peças iguais adjacentes se combinam. O tabuleiro enche — planeje com antecedência.'**
  String get game2048HowToPlay;

  /// No description provided for @game2048Scoring.
  ///
  /// In pt, this message translates to:
  /// **'Cada combinação soma o valor da peça criada. Atingir a peça-alvo dá bônus. Maior peça alcançada também conta no placar.'**
  String get game2048Scoring;

  /// No description provided for @game2048TileReached.
  ///
  /// In pt, this message translates to:
  /// **'Peça {tile}!'**
  String game2048TileReached(int tile);

  /// No description provided for @gameRunnerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Corrida Infinita'**
  String get gameRunnerTitle;

  /// No description provided for @gameRunnerDescription.
  ///
  /// In pt, this message translates to:
  /// **'Pule e agache para desviar dos obstáculos!'**
  String get gameRunnerDescription;

  /// No description provided for @gameRunnerHowToPlay.
  ///
  /// In pt, this message translates to:
  /// **'Deslize para cima para pular e segure para baixo para agachar. Desvie dos obstáculos o máximo que puder.'**
  String get gameRunnerHowToPlay;

  /// No description provided for @gameRunnerScoring.
  ///
  /// In pt, this message translates to:
  /// **'Cada obstáculo ultrapassado vale pontos. A velocidade aumenta com o tempo — quanto mais longe, mais pontos por obstáculo.'**
  String get gameRunnerScoring;

  /// No description provided for @gameRunnerCrash.
  ///
  /// In pt, this message translates to:
  /// **'Ops!'**
  String get gameRunnerCrash;

  /// No description provided for @gameRunnerHintJump.
  ///
  /// In pt, this message translates to:
  /// **'↑ Deslize p/ pular'**
  String get gameRunnerHintJump;

  /// No description provided for @gameRunnerHintDuck.
  ///
  /// In pt, this message translates to:
  /// **'↓ Segure p/ agachar'**
  String get gameRunnerHintDuck;

  /// No description provided for @gameRunnerDucking.
  ///
  /// In pt, this message translates to:
  /// **'Agachado'**
  String get gameRunnerDucking;

  /// No description provided for @gameSolitaireTitle.
  ///
  /// In pt, this message translates to:
  /// **'Paciência'**
  String get gameSolitaireTitle;

  /// No description provided for @gameSolitaireDescription.
  ///
  /// In pt, this message translates to:
  /// **'Organize as cartas nas fundações do Ás ao Rei.'**
  String get gameSolitaireDescription;

  /// No description provided for @gameSolitaireHowToPlay.
  ///
  /// In pt, this message translates to:
  /// **'Arraste cartas entre colunas (cor alternada, valor decrescente). Mova para as fundações do Ás ao Rei. Virar do monte recicla as cartas.'**
  String get gameSolitaireHowToPlay;

  /// No description provided for @gameSolitaireScoring.
  ///
  /// In pt, this message translates to:
  /// **'Mover para fundação vale pontos. Termine rápido para bônus de tempo. DICA custa {hintCost} moedas e revela uma carta jogável.'**
  String gameSolitaireScoring(int hintCost);

  /// No description provided for @gameSolitaireDropOnColumn.
  ///
  /// In pt, this message translates to:
  /// **'Solte na coluna'**
  String get gameSolitaireDropOnColumn;

  /// No description provided for @gameSolitaireRecycle.
  ///
  /// In pt, this message translates to:
  /// **'Reciclar'**
  String get gameSolitaireRecycle;

  /// No description provided for @gameSolitaireFlip.
  ///
  /// In pt, this message translates to:
  /// **'Virar'**
  String get gameSolitaireFlip;

  /// No description provided for @gameSudokuTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sudoku'**
  String get gameSudokuTitle;

  /// No description provided for @gameSudokuDescription.
  ///
  /// In pt, this message translates to:
  /// **'Preencha o grid 9×9 sem repetir números.'**
  String get gameSudokuDescription;

  /// No description provided for @gameSudokuHowToPlay.
  ///
  /// In pt, this message translates to:
  /// **'Toque uma célula vazia e escolha um número de 1 a 9. Cada linha, coluna e bloco 3×3 deve conter todos os dígitos sem repetição. DICA custa {hintCost} moedas e revela uma célula. Use APAGAR para limpar. A partida termina ao completar o grid ou após 5 erros.'**
  String gameSudokuHowToPlay(int hintCost);

  /// No description provided for @gameSudokuScoring.
  ///
  /// In pt, this message translates to:
  /// **'Cada acerto vale +12 pts. Erro −15 pts. Complete o puzzle para +500 pts, bônus de tempo (até 300 pts) e +100 pts se terminar sem erros nem dicas pagas.'**
  String get gameSudokuScoring;

  /// No description provided for @gameCrossSumsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cross Sums'**
  String get gameCrossSumsTitle;

  /// No description provided for @gameCrossSumsDescription.
  ///
  /// In pt, this message translates to:
  /// **'Marque os números certos para bater as soma das linhas e colunas.'**
  String get gameCrossSumsDescription;

  /// No description provided for @gameCrossSumsHowToPlay.
  ///
  /// In pt, this message translates to:
  /// **'Remova ou marque números na grade para que a soma dos ativos em cada linha e coluna bata com os alvos à esquerda e acima. Use a BORRACHA para remover e o LÁPIS para restaurar. DICA custa {hintCost} moedas. Termine ao acertar todas as células ou após 5 erros.'**
  String gameCrossSumsHowToPlay(int hintCost);

  /// No description provided for @gameCrossSumsScoring.
  ///
  /// In pt, this message translates to:
  /// **'Cada acerto vale +15 pts. Erro −18 pts. Complete o puzzle para +450 pts, bônus de tempo (até 280 pts) e +120 pts se terminar sem erros nem dicas pagas.'**
  String get gameCrossSumsScoring;

  /// No description provided for @gameCrossSumsLevel.
  ///
  /// In pt, this message translates to:
  /// **'Nível {level}'**
  String gameCrossSumsLevel(int level);

  /// No description provided for @gameColorBlocksTitle.
  ///
  /// In pt, this message translates to:
  /// **'Color Blocks'**
  String get gameColorBlocksTitle;

  /// No description provided for @gameColorBlocksDescription.
  ///
  /// In pt, this message translates to:
  /// **'Encaixe blocos coloridos e limpe linhas completas!'**
  String get gameColorBlocksDescription;

  /// No description provided for @gameColorBlocksHowToPlay.
  ///
  /// In pt, this message translates to:
  /// **'Arraste as peças da bandeja para o tabuleiro. Linhas ou colunas completas desaparecem. A partida termina quando nenhuma peça cabe no grid.'**
  String get gameColorBlocksHowToPlay;

  /// No description provided for @gameColorBlocksScoring.
  ///
  /// In pt, this message translates to:
  /// **'Cada célula colocada vale +10 pts. Cada linha ou coluna limpa vale +80 pts; várias de uma vez dão bônus de combo.'**
  String get gameColorBlocksScoring;

  /// No description provided for @gameColorBlocksNoFit.
  ///
  /// In pt, this message translates to:
  /// **'Não encaixa'**
  String get gameColorBlocksNoFit;

  /// No description provided for @gameColorBlocksOverlap.
  ///
  /// In pt, this message translates to:
  /// **'Sobrepõe bloco!'**
  String get gameColorBlocksOverlap;

  /// No description provided for @gameColorBlocksOutOfBounds.
  ///
  /// In pt, this message translates to:
  /// **'Fora do tabuleiro!'**
  String get gameColorBlocksOutOfBounds;

  /// No description provided for @gameColorBlocksLinesPreview.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 linha!} other{{count} linhas!}}'**
  String gameColorBlocksLinesPreview(int count);

  /// No description provided for @gameColorBlocksComboPreview.
  ///
  /// In pt, this message translates to:
  /// **'Combo ×{count}'**
  String gameColorBlocksComboPreview(int count);

  /// No description provided for @gameMinesweeperTitle.
  ///
  /// In pt, this message translates to:
  /// **'Campo Minado'**
  String get gameMinesweeperTitle;

  /// No description provided for @gameMinesweeperDescription.
  ///
  /// In pt, this message translates to:
  /// **'Revele células seguras e marque todas as minas.'**
  String get gameMinesweeperDescription;

  /// No description provided for @gameMinesweeperHowToPlay.
  ///
  /// In pt, this message translates to:
  /// **'Toque para revelar uma célula. O número indica minas vizinhas. Use BANDEIRA para marcar suspeitas ou segure para alternar bandeira. DICA custa {hintCost} moedas e revela uma célula segura. A primeira jogada nunca acerta mina. Vença revelando todas as células seguras.'**
  String gameMinesweeperHowToPlay(int hintCost);

  /// No description provided for @gameMinesweeperScoring.
  ///
  /// In pt, this message translates to:
  /// **'Cada célula revelada vale +8 pts. Complete o tabuleiro para +400 pts, bônus de tempo (até 250 pts) e +80 pts sem dicas pagas.'**
  String get gameMinesweeperScoring;

  /// No description provided for @gameMinesweeperMineHit.
  ///
  /// In pt, this message translates to:
  /// **'Boom!'**
  String get gameMinesweeperMineHit;

  /// No description provided for @gameDemoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Demo Tap'**
  String get gameDemoTitle;

  /// No description provided for @gameDemoDescription.
  ///
  /// In pt, this message translates to:
  /// **'Toque o botão o máximo que puder em 10 segundos.'**
  String get gameDemoDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
