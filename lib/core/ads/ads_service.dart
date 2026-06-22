/// Altere para `true` após configurar AdMob no console e no AndroidManifest.
const bool kAdsConfigured = false;

/// Serviço de anúncios — stub até IDs reais serem configurados.
class AdsService {
  AdsService._();

  static int _gamesSinceInterstitial = 0;
  static const _interstitialEvery = 3;

  static Future<void> initialize() async {
    if (!kAdsConfigured) return;
    // TODO(Fase 2): MobileAds.instance.initialize();
  }

  static Future<void> maybeShowInterstitial() async {
    if (!kAdsConfigured) return;
    _gamesSinceInterstitial++;
    if (_gamesSinceInterstitial < _interstitialEvery) return;
    _gamesSinceInterstitial = 0;
    // TODO(Fase 2): carregar e exibir interstitial
  }

  /// Retorna moedas extras simuladas quando ads não estão configurados.
  static Future<int> showRewardedAd() async {
    if (!kAdsConfigured) return 5;
    // TODO(Fase 2): rewarded ad real
    return 5;
  }
}
