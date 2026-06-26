/// IDs de produto na Play Store / App Store — substituir pelos reais no console.
abstract final class IapConfig {
  static const removeAdsProductId = 'miniplay_remove_ads';
  static const coinPackProductId = 'miniplay_coins_500';

  static const coinPackAmount = 500;
}

/// Altere para `true` após criar produtos no Play Console / App Store Connect.
const bool kIapConfigured = false;
