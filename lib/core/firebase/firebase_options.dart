import 'package:firebase_core/firebase_core.dart';

/// Altere para `true` após rodar `flutterfire configure`.
const bool kFirebaseConfigured = false;

/// Opções geradas pelo FlutterFire CLI.
/// Substitua este arquivo ao configurar o Firebase no projeto.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (!kFirebaseConfigured) {
      throw StateError(
        'Firebase não configurado. Rode: dart pub global activate flutterfire_cli && flutterfire configure',
      );
    }

    return const FirebaseOptions(
      apiKey: 'REPLACE_ME',
      appId: 'REPLACE_ME',
      messagingSenderId: 'REPLACE_ME',
      projectId: 'REPLACE_ME',
    );
  }
}
