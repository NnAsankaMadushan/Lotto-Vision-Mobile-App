import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lotto_vision/core/constants/app_constants.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadLocale();
  }

  static const String _boxName = 'settings';

  Future<void> _loadLocale() async {
    final box = await Hive.openBox(_boxName);
    final languageCode = box.get(
      AppConstants.languageKey,
      defaultValue: 'en',
    ) as String;

    state = Locale(languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    final box = await Hive.openBox(_boxName);
    await box.put(AppConstants.languageKey, locale.languageCode);
    state = locale;
  }

  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'si':
        return 'සිංහල (Sinhala)';
      case 'ta':
        return 'தமிழ் (Tamil)';
      default:
        return 'English';
    }
  }
}
