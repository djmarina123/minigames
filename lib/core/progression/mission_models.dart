/// Definição de uma missão diária.
class MissionDefinition {
  const MissionDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.target,
    required this.coinReward,
    required this.kind,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final int target;
  final int coinReward;
  final MissionKind kind;
}

enum MissionKind {
  gamesPlayedToday,
  scoreToday,
  goldToday,
}

/// Progresso de uma missão no dia atual.
class MissionProgress {
  const MissionProgress({
    required this.definition,
    required this.current,
    required this.claimed,
  });

  final MissionDefinition definition;
  final int current;
  final bool claimed;

  bool get isComplete => current >= definition.target;
  bool get canClaim => isComplete && !claimed;
  double get ratio =>
      definition.target == 0 ? 0 : (current / definition.target).clamp(0.0, 1.0);
}
