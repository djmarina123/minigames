import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'firebase_config.dart';
import 'firebase_options.dart';

/// Inicializa Firebase (Auth anônimo, Analytics, Crashlytics).
/// Sem configuração, o app continua em modo local para desenvolvimento.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;

  static bool get isConfigured => kFirebaseConfigured;
  static bool get isInitialized => _initialized;

  static FirebaseAuth? get auth => _initialized ? FirebaseAuth.instance : null;
  static FirebaseAnalytics? get analytics =>
      _initialized ? FirebaseAnalytics.instance : null;
  static FirebaseCrashlytics? get crashlytics =>
      _initialized ? FirebaseCrashlytics.instance : null;

  static Future<void> initialize() async {
    if (_initialized || !kFirebaseConfigured) {
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      await FirebaseAnalytics.instance.logAppOpen();
      _initialized = true;
    } catch (error, stack) {
      debugPrint('FirebaseBootstrap: falha ao inicializar — $error\n$stack');
    }
  }
}
