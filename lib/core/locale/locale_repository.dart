import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Idiomas suportados pelo app. Expandir aqui ao adicionar novos ARB.
abstract final class AppLocales {
  static const pt = Locale('pt');
  static const en = Locale('en');
  static const es = Locale('es');

  static const supported = <Locale>[pt, en, es];

  static const defaultLocale = pt;

  static Locale? fromLanguageCode(String? code) {
    if (code == null) return null;
    for (final locale in supported) {
      if (locale.languageCode == code) return locale;
    }
    return null;
  }

  /// Resolve idioma inicial: preferência salva ou idioma do dispositivo.
  static const localePrefsKey = 'app_locale';

  /// Resolve idioma inicial: preferência salva ou idioma do dispositivo.
  static Locale resolveInitial(SharedPreferences prefs) {
    final saved = prefs.getString(localePrefsKey);
    final fromSaved = fromLanguageCode(saved);
    if (fromSaved != null) return fromSaved;

    final device = WidgetsBinding.instance.platformDispatcher.locale;
    return fromLanguageCode(device.languageCode) ?? defaultLocale;
  }
}

/// Persiste e notifica mudanças de idioma.
class LocaleRepository extends ChangeNotifier {
  LocaleRepository(this._prefs, {required Locale initial}) : _locale = initial;

  final SharedPreferences _prefs;
  Locale _locale;

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (!AppLocales.supported.contains(locale)) return;
    if (_locale == locale) return;
    _locale = locale;
    await _prefs.setString(AppLocales.localePrefsKey, locale.languageCode);
    notifyListeners();
  }
}
