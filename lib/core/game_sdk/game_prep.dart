import 'game_session_config.dart';

/// Textos de ajuda exibidos no modal (?).
class GameHelpContent {
  const GameHelpContent({
    required this.howToPlay,
    required this.scoring,
  });

  final String howToPlay;
  final String scoring;
}

/// Uma opção dentro de um grupo (ex.: 15 s, 30 s).
class GamePrepChoice {
  const GamePrepChoice({
    required this.label,
    required this.value,
    this.subtitle,
  });

  final String label;
  final Object value;
  final String? subtitle;
}

/// Grupo de opções mutuamente exclusivas (ex.: tempo, nº de cartas).
class GamePrepOptionGroup {
  const GamePrepOptionGroup({
    required this.label,
    required this.optionKey,
    required this.choices,
    this.defaultIndex = 0,
  });

  final String label;
  final String optionKey;
  final List<GamePrepChoice> choices;
  final int defaultIndex;
}

/// Definição da tela intermediária antes da partida.
///
/// Jogos sem opções podem expor só [help] (botão ? + Jogar).
/// Jogos sem preparação retornam `null` em [HubGame.prep].
class GamePrepDefinition {
  const GamePrepDefinition({
    required this.help,
    this.optionGroups = const [],
  });

  final GameHelpContent help;
  final List<GamePrepOptionGroup> optionGroups;

  GameSessionConfig defaultConfig() {
    final values = <String, Object?>{};
    for (final group in optionGroups) {
      if (group.choices.isEmpty) continue;
      final maxIdx = group.choices.length - 1;
      final idx = group.defaultIndex.clamp(0, maxIdx);
      values[group.optionKey] = group.choices[idx].value;
    }
    return GameSessionConfig(values: values);
  }
}
