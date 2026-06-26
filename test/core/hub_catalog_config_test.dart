import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/game_sdk/hub_catalog_config.dart';

void main() {
  group('isCatalogGameFeatured', () {
    test('destaca os N jogos com maior catalogOrder', () {
      expect(
        isCatalogGameFeatured(
          catalogOrder: 7,
          maxCatalogOrderAmongEnabled: 7,
          featuredCount: 3,
        ),
        isTrue,
      );
      expect(
        isCatalogGameFeatured(
          catalogOrder: 6,
          maxCatalogOrderAmongEnabled: 7,
          featuredCount: 3,
        ),
        isTrue,
      );
      expect(
        isCatalogGameFeatured(
          catalogOrder: 5,
          maxCatalogOrderAmongEnabled: 7,
          featuredCount: 3,
        ),
        isTrue,
      );
      expect(
        isCatalogGameFeatured(
          catalogOrder: 4,
          maxCatalogOrderAmongEnabled: 7,
          featuredCount: 3,
        ),
        isFalse,
      );
    });

    test('com menos jogos que o limite, todos são destacados', () {
      expect(
        isCatalogGameFeatured(
          catalogOrder: 0,
          maxCatalogOrderAmongEnabled: 1,
          featuredCount: 3,
        ),
        isTrue,
      );
    });

    test('featuredCount zero desliga badge', () {
      expect(
        isCatalogGameFeatured(
          catalogOrder: 99,
          maxCatalogOrderAmongEnabled: 99,
          featuredCount: 0,
        ),
        isFalse,
      );
    });
  });
}
