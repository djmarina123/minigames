import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import 'firebase_config.dart';
import 'remote_config_config.dart';

/// Busca config remota com defaults locais.
class RemoteConfigService {
  RemoteConfigService._();

  static FirebaseRemoteConfig? _instance;
  static bool _initialized = false;

  static bool get isConfigured => kFirebaseConfigured && kRemoteConfigEnabled;

  static Future<void> initialize() async {
    if (!isConfigured || _initialized) return;

    try {
      _instance = FirebaseRemoteConfig.instance;
      await _instance!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? const Duration(minutes: 1)
              : const Duration(hours: 1),
        ),
      );
      await _instance!.setDefaults(const {
        RemoteConfigKeys.catalogEnabled: true,
        RemoteConfigKeys.interstitialEvery: 3,
      });
      await _instance!.fetchAndActivate();
      _initialized = true;
    } catch (e, st) {
      debugPrint('RemoteConfigService.initialize: $e');
      debugPrint('$st');
    }
  }

  static bool getBool(String key, {required bool fallback}) {
    if (!isConfigured || _instance == null) return fallback;
    return _instance!.getBool(key);
  }

  static int getInt(String key, {required int fallback}) {
    if (!isConfigured || _instance == null) return fallback;
    return _instance!.getInt(key);
  }
}
