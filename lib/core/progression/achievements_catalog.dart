import 'progression_models.dart';

/// Catálogo de conquistas do hub (local — sync Firestore futuro).
abstract final class AchievementsCatalog {
  static const all = <AchievementDefinition>[
    AchievementDefinition(
      id: 'first_game',
      title: 'Primeira partida',
      description: 'Complete sua primeira partida no hub.',
      emoji: '🎮',
      coinReward: 10,
    ),
    AchievementDefinition(
      id: 'games_10',
      title: 'Viciado',
      description: 'Jogue 10 partidas no total.',
      emoji: '🔥',
      coinReward: 20,
    ),
    AchievementDefinition(
      id: 'games_50',
      title: 'Maratonista',
      description: 'Jogue 50 partidas no total.',
      emoji: '🏃',
      coinReward: 50,
    ),
    AchievementDefinition(
      id: 'streak_7',
      title: 'Semana firme',
      description: 'Mantenha sequência diária de 7 dias.',
      emoji: '📅',
      coinReward: 30,
    ),
    AchievementDefinition(
      id: 'level_5',
      title: 'Subindo de nível',
      description: 'Alcance o nível 5.',
      emoji: '⭐',
      coinReward: 25,
    ),
    AchievementDefinition(
      id: 'level_10',
      title: 'Veterano',
      description: 'Alcance o nível 10.',
      emoji: '🏆',
      coinReward: 40,
    ),
    AchievementDefinition(
      id: 'gold_once',
      title: 'Desempenho ouro',
      description: 'Conclua uma partida com faixa ouro.',
      emoji: '🥇',
      coinReward: 15,
    ),
    AchievementDefinition(
      id: 'new_record',
      title: 'Recorde pessoal',
      description: 'Bata seu recorde em qualquer jogo.',
      emoji: '🎯',
      coinReward: 15,
    ),
    AchievementDefinition(
      id: 'variety_5',
      title: 'Explorador',
      description: 'Jogue 5 jogos diferentes.',
      emoji: '🧭',
      coinReward: 25,
    ),
  ];

  static AchievementDefinition? byId(String id) {
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }

  static bool isUnlocked(String id, SessionEvent event) {
    return switch (id) {
      'first_game' => event.gamesPlayed >= 1,
      'games_10' => event.gamesPlayed >= 10,
      'games_50' => event.gamesPlayed >= 50,
      'streak_7' => event.dailyStreak >= 7,
      'level_5' => event.level >= 5,
      'level_10' => event.level >= 10,
      'gold_once' => event.tierName == 'gold',
      'new_record' => event.isNewRecord,
      'variety_5' => event.uniqueGamesPlayed >= 5,
      _ => false,
    };
  }
}
