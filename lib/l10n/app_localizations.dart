import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'LottoVision'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan Ticket'**
  String get scan;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @scanTicket.
  ///
  /// In en, this message translates to:
  /// **'Scan Lottery Ticket'**
  String get scanTicket;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @checkingResults.
  ///
  /// In en, this message translates to:
  /// **'Checking Results...'**
  String get checkingResults;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'Winner!'**
  String get winner;

  /// No description provided for @notWinner.
  ///
  /// In en, this message translates to:
  /// **'Not a Winner'**
  String get notWinner;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @youWon.
  ///
  /// In en, this message translates to:
  /// **'You won LKR {amount}'**
  String youWon(Object amount);

  /// No description provided for @matchedNumbers.
  ///
  /// In en, this message translates to:
  /// **'Matched {count} numbers'**
  String matchedNumbers(Object count);

  /// No description provided for @drawNumber.
  ///
  /// In en, this message translates to:
  /// **'Draw #{number}'**
  String drawNumber(Object number);

  /// No description provided for @drawDate.
  ///
  /// In en, this message translates to:
  /// **'Draw Date: {date}'**
  String drawDate(Object date);

  /// No description provided for @ticketDetails.
  ///
  /// In en, this message translates to:
  /// **'Ticket Details'**
  String get ticketDetails;

  /// No description provided for @winningNumbers.
  ///
  /// In en, this message translates to:
  /// **'Winning Numbers'**
  String get winningNumbers;

  /// No description provided for @yourNumbers.
  ///
  /// In en, this message translates to:
  /// **'Your Numbers'**
  String get yourNumbers;

  /// No description provided for @lotteryType.
  ///
  /// In en, this message translates to:
  /// **'Lottery Type'**
  String get lotteryType;

  /// No description provided for @serialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial Number'**
  String get serialNumber;

  /// No description provided for @checkTicket.
  ///
  /// In en, this message translates to:
  /// **'Check Ticket'**
  String get checkTicket;

  /// No description provided for @deleteTicket.
  ///
  /// In en, this message translates to:
  /// **'Delete Ticket'**
  String get deleteTicket;

  /// No description provided for @noTickets.
  ///
  /// In en, this message translates to:
  /// **'No tickets scanned yet'**
  String get noTickets;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results available'**
  String get noResults;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan tickets'**
  String get cameraPermissionDenied;

  /// No description provided for @storagePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Storage permission is required'**
  String get storagePermissionDenied;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @imageQualityLow.
  ///
  /// In en, this message translates to:
  /// **'Image quality too low. Please retake the photo'**
  String get imageQualityLow;

  /// No description provided for @noTextDetected.
  ///
  /// In en, this message translates to:
  /// **'No text detected in the image'**
  String get noTextDetected;

  /// No description provided for @invalidTicket.
  ///
  /// In en, this message translates to:
  /// **'Invalid lottery ticket'**
  String get invalidTicket;

  /// No description provided for @couldNotDetectLotteryType.
  ///
  /// In en, this message translates to:
  /// **'Could not detect lottery type'**
  String get couldNotDetectLotteryType;

  /// No description provided for @fetchingResults.
  ///
  /// In en, this message translates to:
  /// **'Fetching latest results...'**
  String get fetchingResults;

  /// No description provided for @resultNotFound.
  ///
  /// In en, this message translates to:
  /// **'Results not found for this draw'**
  String get resultNotFound;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @lotteryAdaSampatha.
  ///
  /// In en, this message translates to:
  /// **'Ada Sampatha'**
  String get lotteryAdaSampatha;

  /// No description provided for @lotteryDaruDiriSampatha.
  ///
  /// In en, this message translates to:
  /// **'Daru Diri Sampatha'**
  String get lotteryDaruDiriSampatha;

  /// No description provided for @lotteryDelakshapathi.
  ///
  /// In en, this message translates to:
  /// **'Delakshapathi Double Dreams'**
  String get lotteryDelakshapathi;

  /// No description provided for @lotteryDhanaNidhanaya.
  ///
  /// In en, this message translates to:
  /// **'Dhana Nidhanaya'**
  String get lotteryDhanaNidhanaya;

  /// No description provided for @lotteryDollarFortune.
  ///
  /// In en, this message translates to:
  /// **'Dollar Fortune'**
  String get lotteryDollarFortune;

  /// No description provided for @lotteryGovisetha.
  ///
  /// In en, this message translates to:
  /// **'Govisetha'**
  String get lotteryGovisetha;

  /// No description provided for @lotteryHandahana.
  ///
  /// In en, this message translates to:
  /// **'Handahana'**
  String get lotteryHandahana;

  /// No description provided for @lotteryJathika.
  ///
  /// In en, this message translates to:
  /// **'Jathika Sampatha'**
  String get lotteryJathika;

  /// No description provided for @lotteryMahajana.
  ///
  /// In en, this message translates to:
  /// **'Mahajana Sampatha'**
  String get lotteryMahajana;

  /// No description provided for @lotteryMega60.
  ///
  /// In en, this message translates to:
  /// **'Mega 60'**
  String get lotteryMega60;

  /// No description provided for @lotteryMegaMillions.
  ///
  /// In en, this message translates to:
  /// **'Mega Millions'**
  String get lotteryMegaMillions;

  /// No description provided for @lotteryMegaPower.
  ///
  /// In en, this message translates to:
  /// **'Mega Power'**
  String get lotteryMegaPower;

  /// No description provided for @lotteryNeeroga.
  ///
  /// In en, this message translates to:
  /// **'Neeroga Lagna Jaya'**
  String get lotteryNeeroga;

  /// No description provided for @lotteryNlbJaya.
  ///
  /// In en, this message translates to:
  /// **'NLB Jaya'**
  String get lotteryNlbJaya;

  /// No description provided for @lotterySampathRekha.
  ///
  /// In en, this message translates to:
  /// **'Sampath Rekha'**
  String get lotterySampathRekha;

  /// No description provided for @lotterySampathaLagnaVarama.
  ///
  /// In en, this message translates to:
  /// **'Sampatha Lagna Varama'**
  String get lotterySampathaLagnaVarama;

  /// No description provided for @lotterySevana.
  ///
  /// In en, this message translates to:
  /// **'Sevana'**
  String get lotterySevana;

  /// No description provided for @lotteryShanida.
  ///
  /// In en, this message translates to:
  /// **'Shanida'**
  String get lotteryShanida;

  /// No description provided for @lotterySubaDawasak.
  ///
  /// In en, this message translates to:
  /// **'Suba Dawasak'**
  String get lotterySubaDawasak;

  /// No description provided for @lotterySuperFifty.
  ///
  /// In en, this message translates to:
  /// **'Vasana Super Fifty'**
  String get lotterySuperFifty;

  /// No description provided for @lotterySupiriVasana.
  ///
  /// In en, this message translates to:
  /// **'Supiri Vasana'**
  String get lotterySupiriVasana;

  /// No description provided for @lotteryVasana.
  ///
  /// In en, this message translates to:
  /// **'Vasana Sampatha'**
  String get lotteryVasana;

  /// No description provided for @lotteryUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get lotteryUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
