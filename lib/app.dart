import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/l10n/l10n_scope.dart';
import 'core/locale/locale_repository.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/main_shell.dart';
import 'l10n/app_localizations.dart';

class MinigamesApp extends StatelessWidget {
  const MinigamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeRepo = context.watch<LocaleRepository>();

    return MaterialApp(
      title: 'MiniPlay',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: localeRepo.locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) =>
          L10nScope.wrap(context, child ?? const SizedBox.shrink()),
      home: const MainShell(),
    );
  }
}
