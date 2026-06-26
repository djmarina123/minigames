/// Regras do catálogo do hub — badge "NOVO!", etc.
class HubCatalogConfig {
  const HubCatalogConfig._();

  /// Quantos jogos habilitados mais recentes exibem badge "NOVO!".
  static const featuredNewGameCount = 3;
}

/// Jogos com maior [catalogOrder] entre os habilitados recebem badge "NOVO!".
bool isCatalogGameFeatured({
  required int catalogOrder,
  required int maxCatalogOrderAmongEnabled,
  int featuredCount = HubCatalogConfig.featuredNewGameCount,
}) {
  if (featuredCount <= 0) return false;
  final threshold = maxCatalogOrderAmongEnabled - featuredCount + 1;
  return catalogOrder >= threshold;
}
