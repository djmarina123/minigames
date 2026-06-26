import 'mission_models.dart';

/// Missões diárias rotativas (local).
abstract final class MissionsCatalog {
  static const daily = <MissionDefinition>[
    MissionDefinition(
      id: 'daily_play_3',
      title: 'Três partidas',
      description: 'Jogue 3 partidas hoje.',
      emoji: '🎲',
      target: 3,
      coinReward: 15,
      kind: MissionKind.gamesPlayedToday,
    ),
    MissionDefinition(
      id: 'daily_score_500',
      title: 'Pontuador',
      description: 'Some 500 pontos hoje.',
      emoji: '💯',
      target: 500,
      coinReward: 20,
      kind: MissionKind.scoreToday,
    ),
    MissionDefinition(
      id: 'daily_gold',
      title: 'Faixa ouro',
      description: 'Conclua uma partida com desempenho ouro.',
      emoji: '🥇',
      target: 1,
      coinReward: 25,
      kind: MissionKind.goldToday,
    ),
  ];
}
