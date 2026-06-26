/// Chaves Remote Config — fallback local quando offline ou desligado.
abstract final class RemoteConfigKeys {
  static const catalogEnabled = 'catalog_enabled';
  static const interstitialEvery = 'interstitial_every';
}

/// Altere para `true` após validar Remote Config no Firebase Console.
const bool kRemoteConfigEnabled = false;
