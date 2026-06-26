import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../locale/locale_repository.dart';

/// Acesso a [AppLocalizations] fora de widgets com [BuildContext] (ex.: Flame).
abstract final class L10nScope {
  static AppLocalizations? _current;

  static AppLocalizations get of {
    final l10n = _current;
    assert(l10n != null, 'L10nScope not installed');
    return l10n!;
  }

  static void install(AppLocalizations l10n) => _current = l10n;

  /// Instala strings para testes unitários fora de widget tree.
  static Future<void> installForTest([Locale locale = AppLocales.pt]) async {
    install(await AppLocalizations.delegate.load(locale));
  }

  /// Widget que instala o escopo para descendentes e jogos Flame.
  static Widget wrap(BuildContext context, Widget child) {
    final l10n = AppLocalizations.of(context);
    install(l10n);
    return child;
  }
}
