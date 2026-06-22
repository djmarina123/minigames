import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carrega Roboto + Material Icons para goldens legíveis (texto real, não blocos).
Future<void> loadTestFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final dir = _materialFontsDir();

  Future<ByteData> readFont(String file) async {
    return ByteData.sublistView(await File('$dir/$file').readAsBytes());
  }

  Future<void> loadFamily(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final file in files) {
      loader.addFont(readFont(file));
    }
    await loader.load();
  }

  await loadFamily('Roboto', [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
  ]);
  await loadFamily('MaterialIcons', ['MaterialIcons-Regular.otf']);
}

String _materialFontsDir() {
  final fromEnv = Platform.environment['FLUTTER_ROOT'];
  if (fromEnv != null) {
    final path = '$fromEnv/bin/cache/artifacts/material_fonts';
    if (Directory(path).existsSync()) return path;
  }

  final home = Platform.environment['HOME'];
  if (home != null) {
    final path = '$home/flutter/bin/cache/artifacts/material_fonts';
    if (Directory(path).existsSync()) return path;
  }

  throw StateError(
    'Fontes Material não encontradas. '
    'Defina FLUTTER_ROOT ou instale Flutter em ~/flutter.',
  );
}
