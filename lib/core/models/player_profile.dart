import '../economy/economy_config.dart';
import '../economy/level_curve.dart';

/// Perfil local do jogador (MVP — shared_preferences).
class PlayerProfile {
  const PlayerProfile({
    this.coins = EconomyConfig.startingCoins,
    this.xp = 0,
    this.lastDailyClaim,
    this.dailyStreak = 0,
    this.gamesPlayed = 0,
    this.lastGamePlayed,
  });

  final int coins;
  final int xp;
  final DateTime? lastDailyClaim;
  final int dailyStreak;
  final int gamesPlayed;
  final DateTime? lastGamePlayed;

  int get level => levelFromXp(xp);

  int get xpInCurrentLevel => xp - xpRequiredForLevel(level);

  int get xpNeededForNextLevel => xpRequiredForLevel(level + 1) - xpRequiredForLevel(level);

  double get levelProgress => levelProgressFromXp(xp);

  PlayerProfile copyWith({
    int? coins,
    int? xp,
    DateTime? lastDailyClaim,
    int? dailyStreak,
    int? gamesPlayed,
    DateTime? lastGamePlayed,
    bool clearLastDailyClaim = false,
    bool clearLastGamePlayed = false,
  }) {
    return PlayerProfile(
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      lastDailyClaim:
          clearLastDailyClaim ? null : (lastDailyClaim ?? this.lastDailyClaim),
      dailyStreak: dailyStreak ?? this.dailyStreak,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      lastGamePlayed: clearLastGamePlayed
          ? null
          : (lastGamePlayed ?? this.lastGamePlayed),
    );
  }

  Map<String, Object?> toJson() => {
        'coins': coins,
        'xp': xp,
        'lastDailyClaim': lastDailyClaim?.toIso8601String(),
        'dailyStreak': dailyStreak,
        'gamesPlayed': gamesPlayed,
        'lastGamePlayed': lastGamePlayed?.toIso8601String(),
      };

  factory PlayerProfile.fromJson(Map<String, Object?> json) {
    final claim = json['lastDailyClaim'] as String?;
    final lastGame = json['lastGamePlayed'] as String?;
    return PlayerProfile(
      coins: json['coins'] as int? ?? EconomyConfig.startingCoins,
      xp: json['xp'] as int? ?? 0,
      lastDailyClaim: claim != null ? DateTime.tryParse(claim) : null,
      dailyStreak: json['dailyStreak'] as int? ?? 0,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      lastGamePlayed: lastGame != null ? DateTime.tryParse(lastGame) : null,
    );
  }
}

double levelProgressFromXp(int xp) => levelProgress(xp);
