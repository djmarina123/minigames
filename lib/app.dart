import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'features/home/home_screen.dart';

class MinigamesApp extends StatelessWidget {
  const MinigamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minigames Hub',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
