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
          Material(
            color: HubTheme.background,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _showLanguagePicker(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    _LanguageFlag(locale: current),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.settingsLanguage,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: HubTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      l10n.languageLabel(current),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: HubTheme.removeAdsPurple,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: HubTheme.textSecondary,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showLanguagePicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: HubTheme.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      final localeRepo = sheetContext.watch<LocaleRepository>();
      final current = localeRepo.locale;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: HubTheme.textSecondary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.settingsLanguage,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: HubTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              for (final locale in AppLocales.supported) ...[
                _LanguageTile(
                  locale: locale,
                  label: l10n.languageLabel(locale),
                  selected: current == locale,
                  onTap: () {
                    localeRepo.setLocale(locale);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class _LanguageFlag extends StatelessWidget {
  const _LanguageFlag({required this.locale, this.size = 24});

  final Locale locale;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: HubTheme.cardBorder.withValues(alpha: 0.6),
        ),
      ),
      child: Text(
        AppLocales.flagEmoji(locale),
        style: TextStyle(fontSize: size),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.locale,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Locale locale;
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
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _LanguageFlag(locale: locale, size: 22),
                const SizedBox(width: 12),
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
