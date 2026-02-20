import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lotto_vision/core/constants/app_constants.dart';
import 'package:lotto_vision/core/theme/app_theme.dart';
import 'package:lotto_vision/presentation/screens/home/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lotto_vision/l10n/app_localizations.dart';
import 'package:lotto_vision/core/di/injection_container.dart' as di;
import 'package:lotto_vision/presentation/providers/theme_provider.dart';
import 'package:lotto_vision/presentation/providers/locale_provider.dart';
import 'package:lotto_vision/data/models/lottery_ticket_model.dart';
import 'package:lotto_vision/data/models/lottery_result_model.dart';
import 'package:lotto_vision/services/notifications/notification_background_handler.dart';
import 'package:lotto_vision/services/notifications/notification_service.dart';

const String _appMitLicense = '''
MIT License

Copyright (c) 2024-2026 LottoVision

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
''';

void _registerAppLicense() {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(['LottoVision'], _appMitLicense);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerAppLicense();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(LotteryTicketModelAdapter());
  Hive.registerAdapter(LotteryResultModelAdapter());

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

class LottoVisionApp extends ConsumerStatefulWidget {
  const LottoVisionApp({super.key});

  @override
  ConsumerState<LottoVisionApp> createState() => _LottoVisionAppState();
}

class _LottoVisionAppState extends ConsumerState<LottoVisionApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationServiceProvider).init());
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
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
