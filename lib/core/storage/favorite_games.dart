import '../game_sdk/hub_game.dart';

/// Ordena jogos com favoritos no topo, na ordem em que foram marcados.
List<HubGame> sortGamesByFavorites(
  List<HubGame> games,
  List<String> favoriteIds,
) {
  if (favoriteIds.isEmpty) return List<HubGame>.from(games);

  final favoriteOrder = {
    for (var i = 0; i < favoriteIds.length; i++) favoriteIds[i]: i,
  };
  final originalOrder = {
    for (var i = 0; i < games.length; i++) games[i].metadata.id: i,
  };

  return List<HubGame>.from(games)
    ..sort((a, b) {
      final aId = a.metadata.id;
      final bId = b.metadata.id;
      final aFav = favoriteOrder.containsKey(aId);
      final bFav = favoriteOrder.containsKey(bId);

      if (aFav && !bFav) return -1;
      if (!aFav && bFav) return 1;
      if (aFav && bFav) {
        return favoriteOrder[aId]!.compareTo(favoriteOrder[bId]!);
      }
      return originalOrder[aId]!.compareTo(originalOrder[bId]!);
    });
}
