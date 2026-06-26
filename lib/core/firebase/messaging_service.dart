import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase_config.dart';
import 'messaging_config.dart';

/// Push notifications — inicialização básica (tópicos futuros).
class MessagingService {
  MessagingService._();

  static bool get isConfigured => kFirebaseConfigured && kMessagingEnabled;

  static Future<void> initialize() async {
    if (!isConfigured) return;

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final token = await messaging.getToken();
      debugPrint('MessagingService: FCM token — $token');
    } catch (e, st) {
      debugPrint('MessagingService.initialize: $e');
      debugPrint('$st');
    }
  }
}
