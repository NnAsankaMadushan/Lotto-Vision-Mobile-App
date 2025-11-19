import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lotto_vision/core/constants/app_constants.dart';
import 'package:lotto_vision/core/theme/app_theme.dart';
import 'package:lotto_vision/presentation/screens/home/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lotto_vision/core/di/injection_container.dart' as di;
import 'package:lotto_vision/presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize dependency injection
  await di.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: LottoVisionApp(),
    ),
  );
}

class LottoVisionApp extends ConsumerWidget {
  const LottoVisionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('si', ''),
        Locale('ta', ''),
      ],
      home: const HomeScreen(),
    );
  }
}
