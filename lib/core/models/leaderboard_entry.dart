class LeaderboardEntry {
  const LeaderboardEntry({
    required this.gameId,
    required this.gameTitle,
    required this.score,
    required this.recordedAt,
  });

  final String gameId;
  final String gameTitle;
  final int score;
  final DateTime recordedAt;

  Map<String, Object?> toJson() => {
        'gameId': gameId,
        'gameTitle': gameTitle,
        'score': score,
        'recordedAt': recordedAt.toIso8601String(),
      };

  factory LeaderboardEntry.fromJson(Map<String, Object?> json) {
    return LeaderboardEntry(
      gameId: json['gameId'] as String,
      gameTitle: json['gameTitle'] as String,
      score: json['score'] as int,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }
}
