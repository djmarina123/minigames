import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/locale/locale_repository.dart';
import '../../../core/theme/hub_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Seletor de idioma nas configurações do perfil.
class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeRepo = context.watch<LocaleRepository>();
    final current = localeRepo.locale;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HubTheme.cardBorder, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_rounded, color: HubTheme.removeAdsPurple),
              const SizedBox(width: 8),
              Text(
                l10n.settingsTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: HubTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.settingsLanguage,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: HubTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          for (final locale in AppLocales.supported) ...[
            _LanguageTile(
              label: l10n.languageLabel(locale),
              selected: current == locale,
              onTap: () => localeRepo.setLocale(locale),
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected
            ? HubTheme.removeAdsPurple.withValues(alpha: 0.1)
            : HubTheme.background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected
                          ? HubTheme.removeAdsPurple
                          : HubTheme.textPrimary,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: HubTheme.removeAdsPurple,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
