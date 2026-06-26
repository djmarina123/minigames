import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/iap/iap_config.dart';
import '../../../core/iap/purchase_service.dart';
import '../../../core/theme/hub_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Compras no app — remover anúncios e pacote de moedas.
class ShopPanel extends StatelessWidget {
  const ShopPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shop = context.watch<PurchaseService>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HubTheme.cardBorder, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded, color: HubTheme.removeAdsPurple),
              const SizedBox(width: 8),
              Text(
                l10n.shopTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: HubTheme.textPrimary,
                ),
              ),
            ],
          ),
          if (shop.lastError != null) ...[
            const SizedBox(height: 8),
            Text(
              _localizedError(l10n, shop.lastError!),
              style: const TextStyle(
                fontSize: 12,
                color: HubTheme.featuredBadge,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _ShopTile(
            icon: Icons.block_rounded,
            title: l10n.shopRemoveAdsTitle,
            subtitle: shop.adsRemoved
                ? l10n.shopRemoveAdsPurchased
                : l10n.shopRemoveAdsSubtitle,
            price: shop.removeAdsProduct?.price ?? (kIapConfigured ? '—' : l10n.shopPriceTest),
            enabled: !shop.adsRemoved && !shop.loading,
            onTap: shop.adsRemoved ? null : () => shop.buyRemoveAds(),
          ),
          const SizedBox(height: 8),
          _ShopTile(
            icon: HubTheme.coinIcon,
            title: l10n.shopCoinPackTitle(IapConfig.coinPackAmount),
            subtitle: l10n.shopCoinPackSubtitle,
            price: shop.coinPackProduct?.price ?? (kIapConfigured ? '—' : l10n.shopPriceTest),
            enabled: !shop.loading,
            onTap: () => shop.buyCoinPack(),
          ),
          if (kIapConfigured && !shop.adsRemoved) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: shop.loading ? null : () => shop.restorePurchases(),
              child: Text(l10n.shopRestorePurchases),
            ),
          ],
        ],
      ),
    );
  }

  static String _localizedError(AppLocalizations l10n, String error) {
    return switch (error) {
      PurchaseService.errorProductUnavailable => l10n.iapProductUnavailable,
      PurchaseService.errorPurchase => l10n.iapPurchaseError,
      _ => error,
    };
  }
}

class _ShopTile extends StatelessWidget {
  const _ShopTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.enabled,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String price;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HubTheme.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: HubTheme.removeAdsPurple),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: HubTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: HubTheme.removeAdsPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
