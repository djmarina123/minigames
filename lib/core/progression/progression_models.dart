/// Definição estática de uma conquista.
class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.coinReward,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final int coinReward;
}

/// Conquista desbloqueada pelo jogador.
class UnlockedAchievement {
  const UnlockedAchievement({
    required this.definition,
    required this.unlockedAt,
  });

  final AchievementDefinition definition;
  final DateTime unlockedAt;
}

/// Evento de sessão usado para avaliar conquistas e missões.
class SessionEvent {
  const SessionEvent({
    required this.gameId,
    required this.score,
    required this.tierName,
    required this.isNewRecord,
    required this.gamesPlayed,
    required this.level,
    required this.dailyStreak,
    required this.uniqueGamesPlayed,
    this.won,
  });

  final String gameId;
  final int score;
  final String? tierName;
  final bool isNewRecord;
  final int gamesPlayed;
  final int level;
  final int dailyStreak;
  final int uniqueGamesPlayed;
  final bool? won;
}
