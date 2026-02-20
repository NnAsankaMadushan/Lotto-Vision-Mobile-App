import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotto_vision/core/constants/app_constants.dart';
import 'package:lotto_vision/l10n/app_localizations.dart';
import 'package:lotto_vision/presentation/providers/locale_provider.dart';
import 'package:lotto_vision/presentation/providers/theme_provider.dart';
import 'package:lotto_vision/presentation/screens/settings/licenses_screen.dart';
import 'package:lotto_vision/presentation/widgets/screen_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    String getThemeLabel(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.light:
          return l10n.lightMode;
        case ThemeMode.dark:
          return l10n.darkMode;
        case ThemeMode.system:
          return l10n.systemDefault;
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: buildLottoBackButton(context),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: buildLottoAppBarGradient(context),
        title: LottoBrandedAppBarTitle(
          section: l10n.settings,
        ),
      ),
      body: LottoGradientBackground(
        child: SafeArea(
          child: ListView(
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text(
                  currentLocale != null
                      ? ref
                          .read(localeProvider.notifier)
                          .getLanguageName(currentLocale)
                      : 'English',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showLanguagePicker(context, ref, currentLocale);
                },
              ),
              ListTile(
                leading: const Icon(Icons.palette),
                title: Text(l10n.theme),
                subtitle: Text(getThemeLabel(currentTheme)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showThemePicker(context, ref, currentTheme);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.about),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showAboutSheet(context, l10n);
                },
              ),
              ListTile(
                leading: const Icon(Icons.policy_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Show privacy policy
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Show terms
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    Locale? currentLocale,
  ) {
    final supportedLocales = [
      const Locale('en', ''),
      const Locale('si', ''),
      const Locale('ta', ''),
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: supportedLocales.map((locale) {
              final isSelected =
                  currentLocale?.languageCode == locale.languageCode;
              final languageName =
                  ref.read(localeProvider.notifier).getLanguageName(locale);

              return ListTile(
                leading: const Icon(Icons.language),
                title: Text(languageName),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(locale);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentTheme,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext modalContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_5),
                title: Text(l10n.lightMode),
                trailing: currentTheme == ThemeMode.light
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light);
                  Navigator.pop(modalContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_2),
                title: Text(l10n.darkMode),
                trailing: currentTheme == ThemeMode.dark
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);
                  Navigator.pop(modalContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_auto),
                title: Text(l10n.systemDefault),
                trailing: currentTheme == ThemeMode.system
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system);
                  Navigator.pop(modalContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutSheet(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final closeLabel = MaterialLocalizations.of(dialogContext).closeButtonLabel;

        return AlertDialog(
          title: Text(l10n.about),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text('Version ${AppConstants.appVersion}'),
              SizedBox(height: 10),
              Text('Sri Lankan Lottery Ticket Scanner & Result Checker'),
              SizedBox(height: 10),
              Text(
                'Copyright (c) 2024-2026 LottoVision. Licensed under MIT.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(closeLabel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BrandedLicensesScreen(),
                  ),
                );
              },
              child: const Text('View Licenses'),
            ),
          ],
        );
      },
    );
  }
}
