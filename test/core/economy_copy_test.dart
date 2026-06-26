import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/l10n/l10n_extensions.dart';
import 'package:minigames_hub/l10n/app_localizations.dart';

void main() {
  group('HubL10n economy strings', () {
    late AppLocalizations l10n;

    setUp(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('pt'));
    });

    test('rótulos de nível e sessão', () {
      expect(l10n.economyLevelShort(3), 'Nv. 3');
      expect(
        l10n.economyLevelProgress(2, 40, 100),
        'Nível 2 · 40 / 100 XP',
      );
      expect(l10n.economySessionXp(25), '+25');
    });

    test('mensagem de level up', () {
      expect(
        l10n.levelUpMessage(1, 12),
        'Nível up! +12 moedas de bônus',
      );
    });
  });
}
