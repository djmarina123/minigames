import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/iap/purchase_service.dart';
import 'package:minigames_hub/core/leaderboard/leaderboard_repository.dart';
import 'package:minigames_hub/core/progression/achievements_repository.dart';
import 'package:minigames_hub/core/progression/missions_repository.dart';
import 'package:minigames_hub/core/locale/locale_repository.dart';
import 'package:minigames_hub/core/storage/player_repository.dart';
import 'package:minigames_hub/features/shell/main_shell.dart';

import '../helpers/load_test_fonts.dart';
import '../helpers/test_app.dart';

/// Viewports usados nos goldens (largura × altura lógica).
abstract final class GoldenViewports {
  static const mobile = Size(390, 844);
  static const tablet = Size(768, 1024);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadTestFonts);

  group('Home golden', () {
    late ({
      LocaleRepository localeRepo,
      PlayerRepository playerRepo,
      LeaderboardRepository leaderboardRepo,
      AchievementsRepository achievementsRepo,
      MissionsRepository missionsRepo,
      PurchaseService purchaseService,
    }) repos;

    setUp(() async {
      repos = await setupTestRepositories();
    });

    Future<void> captureHome(
      WidgetTester tester, {
      required Size viewport,
      required String goldenFile,
    }) async {
      await pumpGoldenApp(
        tester,
        app: buildTestApp(
          localeRepo: repos.localeRepo,
          playerRepo: repos.playerRepo,
          leaderboardRepo: repos.leaderboardRepo,
          achievementsRepo: repos.achievementsRepo,
          missionsRepo: repos.missionsRepo,
          purchaseService: repos.purchaseService,
        ),
        surfaceSize: viewport,
      );

      await expectLater(
        find.byType(MainShell),
        matchesGoldenFile(goldenFile),
      );
    }

    testWidgets('mobile 390×844', (tester) async {
      await captureHome(
        tester,
        viewport: GoldenViewports.mobile,
        goldenFile: '../goldens/home_mobile.png',
      );
    });

    testWidgets('tablet 768×1024', (tester) async {
      await captureHome(
        tester,
        viewport: GoldenViewports.tablet,
        goldenFile: '../goldens/home_tablet.png',
      );
    });
  });
}
