import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/shell/main_shell.dart';

class MinigamesApp extends StatelessWidget {
  const MinigamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minigames Hub',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const MainShell(),
    );
  }
}
