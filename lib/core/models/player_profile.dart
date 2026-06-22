/// Perfil local do jogador (MVP — shared_preferences).
class PlayerProfile {
  const PlayerProfile({
    this.coins = 0,
    this.xp = 0,
    this.lastDailyClaim,
    this.dailyStreak = 0,
    this.gamesPlayed = 0,
  });

  final int coins;
  final int xp;
  final DateTime? lastDailyClaim;
  final int dailyStreak;
  final int gamesPlayed;

  int get level => (xp ~/ 100) + 1;

  PlayerProfile copyWith({
    int? coins,
    int? xp,
    DateTime? lastDailyClaim,
    int? dailyStreak,
    int? gamesPlayed,
    bool clearLastDailyClaim = false,
  }) {
    return PlayerProfile(
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      lastDailyClaim:
          clearLastDailyClaim ? null : (lastDailyClaim ?? this.lastDailyClaim),
      dailyStreak: dailyStreak ?? this.dailyStreak,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    );
  }

  Map<String, Object?> toJson() => {
        'coins': coins,
        'xp': xp,
        'lastDailyClaim': lastDailyClaim?.toIso8601String(),
        'dailyStreak': dailyStreak,
        'gamesPlayed': gamesPlayed,
      };

  factory PlayerProfile.fromJson(Map<String, Object?> json) {
    final claim = json['lastDailyClaim'] as String?;
    return PlayerProfile(
      coins: json['coins'] as int? ?? 0,
      xp: json['xp'] as int? ?? 0,
      lastDailyClaim: claim != null ? DateTime.tryParse(claim) : null,
      dailyStreak: json['dailyStreak'] as int? ?? 0,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
    );
  }
}
