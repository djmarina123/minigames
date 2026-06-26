import 'hub_catalog_config.dart';
import 'hub_game.dart';

/// Registro central de jogos disponíveis no hub.
class GameRegistry {
  GameRegistry._();

  static final GameRegistry instance = GameRegistry._();

  final Map<String, HubGame> _games = {};
  final Map<String, int> _catalogOrder = {};
  int _nextCatalogOrder = 0;

  void register(HubGame game) {
    final id = game.metadata.id;
    _games[id] = game;
    _catalogOrder.putIfAbsent(id, () => _nextCatalogOrder++);
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

  /// Jogos habilitados na ordem de [register]/[registerAll] (catálogo base).
  List<HubGame> get enabledInCatalogOrder {
    final list = enabled;
    list.sort(
      (a, b) => catalogOrderFor(a.metadata.id)!
          .compareTo(catalogOrderFor(b.metadata.id)!),
    );
    return list;
  }

  int? catalogOrderFor(String id) => _catalogOrder[id];

  /// Badge "NOVO!" — últimos [HubCatalogConfig.featuredNewGameCount] habilitados
  /// na ordem de [register]/[registerAll] (novos jogos no fim de `registerBundledGames`).
  bool isFeatured(String id) =>
      featured.any((game) => game.metadata.id == id);

  List<HubGame> get featured {
    final sorted = List<HubGame>.from(enabledInCatalogOrder.reversed);
    return sorted.take(HubCatalogConfig.featuredNewGameCount).toList();
  }

  /// Limpa o registro — usar em testes para evitar vazamento de estado.
  void resetForTesting() {
    _games.clear();
    _catalogOrder.clear();
    _nextCatalogOrder = 0;
  }
}
