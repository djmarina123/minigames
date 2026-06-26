import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/app_info.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  group('appInfoVersionLabel', () {
    test('combina versão e build number', () {
      final info = PackageInfo(
        appName: 'MiniPlay',
        packageName: 'com.miniplay.games',
        version: '1.0.0',
        buildNumber: '42',
        buildSignature: '',
        installerStore: null,
      );
      expect(appInfoVersionLabel(info), '1.0.0 (42)');
    });
  });

  group('appInfoBuildDateTimeLabel', () {
    test('retorna null sem timestamp', () {
      expect(appInfoBuildDateTimeLabel(''), isNull);
    });

    test('formata ISO 8601 em PT-BR no fuso local', () {
      final utc = DateTime.utc(2025, 6, 25, 14, 30);
      final label = appInfoBuildDateTimeLabel(utc.toIso8601String());
      final local = utc.toLocal();
      final day = local.day.toString().padLeft(2, '0');
      final month = local.month.toString().padLeft(2, '0');
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      expect(label, '$day/$month/${local.year} às $hour:$minute');
    });

    test('repassa valor inválido sem quebrar', () {
      expect(appInfoBuildDateTimeLabel('not-a-date'), 'not-a-date');
    });
  });
}
