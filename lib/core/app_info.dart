import 'package:package_info_plus/package_info_plus.dart';

/// ISO 8601 UTC — injetado em release via `--dart-define=BUILD_TIMESTAMP=...`.
const String kBuildTimestamp = String.fromEnvironment(
  'BUILD_TIMESTAMP',
  defaultValue: '',
);

/// Rótulo da versão exibida no perfil (`1.0.0 (1)`).
String appInfoVersionLabel(PackageInfo info) =>
    '${info.version} (${info.buildNumber})';

/// Data/hora do build em PT-BR; `null` quando não há timestamp de release.
String? appInfoBuildDateTimeLabel([String timestamp = kBuildTimestamp]) {
  if (timestamp.isEmpty) return null;
  final parsed = DateTime.tryParse(timestamp);
  if (parsed == null) return timestamp;
  final local = parsed.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/${local.year} às $hour:$minute';
}

Future<PackageInfo> loadAppPackageInfo() => PackageInfo.fromPlatform();
