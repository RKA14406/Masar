import 'package:flutter/material.dart';
import '../../core/services/settings_service.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsService settingsService;

  const SettingsScreen({super.key, required this.settingsService});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListenableBuilder(
        listenable: settingsService,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader(title: l10n.theme),
              Card(
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: Text(l10n.lightMode),
                      value: ThemeMode.light,
                      groupValue: settingsService.themeMode,
                      onChanged: (value) => settingsService.updateThemeMode(value),
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text(l10n.darkMode),
                      value: ThemeMode.dark,
                      groupValue: settingsService.themeMode,
                      onChanged: (value) => settingsService.updateThemeMode(value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: l10n.language),
              Card(
                child: Column(
                  children: [
                    RadioListTile<Locale>(
                      title: Text(l10n.arabic),
                      value: const Locale('ar'),
                      groupValue: settingsService.locale,
                      onChanged: (value) {
                        if (value != null) settingsService.updateLocale(value);
                      },
                    ),
                    RadioListTile<Locale>(
                      title: Text(l10n.english),
                      value: const Locale('en'),
                      groupValue: settingsService.locale,
                      onChanged: (value) {
                        if (value != null) settingsService.updateLocale(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
