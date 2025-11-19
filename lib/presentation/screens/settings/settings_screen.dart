import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotto_vision/core/constants/app_constants.dart';
import 'package:lotto_vision/presentation/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    String getThemeLabel(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.light:
          return 'Light';
        case ThemeMode.dark:
          return 'Dark';
        case ThemeMode.system:
          return 'System default';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: const Text('English'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show language picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              subtitle: Text(getThemeLabel(currentTheme)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showThemePicker(context, ref, currentTheme);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: AppConstants.appVersion,
                  applicationLegalese: '© 2024 LottoVision',
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Sri Lankan Lottery Ticket Scanner & Result Checker',
                    ),
                  ],
                );
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
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, ThemeMode currentTheme) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_5),
                title: const Text('Light'),
                trailing: currentTheme == ThemeMode.light
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_2),
                title: const Text('Dark'),
                trailing: currentTheme == ThemeMode.dark
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_auto),
                title: const Text('System default'),
                trailing: currentTheme == ThemeMode.system
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
