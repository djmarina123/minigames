/// IDs de teste do Google — seguros para desenvolvimento.
/// Substitua pelos IDs reais do AdMob Console antes de publicar.
abstract final class AdsConfig {
  /// App ID Android (já em AndroidManifest).
  static const androidAppId = 'ca-app-pub-3940256099942544~3347511713';

  /// App ID iOS (Info.plist).
  static const iosAppId = 'ca-app-pub-3940256099942544~1458002511';

  static const rewardedAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const rewardedAdUnitIdIos = 'ca-app-pub-3940256099942544/1712485313';

  static const interstitialAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const interstitialAdUnitIdIos =
      'ca-app-pub-3940256099942544/4411468910';

  /// Partidas entre interstitials quando ads estão ativos.
  static const interstitialEvery = 3;

  /// Moedas simuladas quando ads não estão configurados (stub dev).
  static const stubRewardSuccess = 5;
}

/// Altere para `true` após validar AdMob no device (IDs de teste funcionam).
const bool kAdsConfigured = false;
