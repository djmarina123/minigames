import 'hub_game.dart';

/// Registro central de jogos disponíveis no hub.
class GameRegistry {
  GameRegistry._();

  static final GameRegistry instance = GameRegistry._();

  final Map<String, HubGame> _games = {};

  void register(HubGame game) {
    _games[game.metadata.id] = game;
  }

  void registerAll(Iterable<HubGame> games) {
    for (final game in games) {
      register(game);
    }
  }

  HubGame? findById(String id) => _games[id];

  List<HubGame> get all => _games.values.toList();

  List<HubGame> get enabled =>
      _games.values.where((g) => g.metadata.enabled).toList();

  List<HubGame> get featured =>
      enabled.where((g) => g.metadata.featured).toList();

  /// Limpa o registro — usar em testes para evitar vazamento de estado.
  void resetForTesting() => _games.clear();
}
