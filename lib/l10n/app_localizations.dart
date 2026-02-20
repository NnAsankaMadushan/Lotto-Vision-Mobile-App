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

  /// No description provided for @prediction.
  ///
  /// In en, this message translates to:
  /// **'Prediction'**
  String get prediction;

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

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @scanTicket.
  ///
  /// In en, this message translates to:
  /// **'Scan Lottery Ticket'**
  String get scanTicket;

  /// No description provided for @scanningTicketSection.
  ///
  /// In en, this message translates to:
  /// **'Scanning Ticket'**
  String get scanningTicketSection;

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

  /// No description provided for @chooseAnOption.
  ///
  /// In en, this message translates to:
  /// **'Choose an option'**
  String get chooseAnOption;

  /// No description provided for @processingImage.
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get processingImage;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required'**
  String get cameraPermissionRequired;

  /// No description provided for @galleryPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Gallery permission is required'**
  String get galleryPermissionRequired;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(Object message);

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @scanningTicketProgress.
  ///
  /// In en, this message translates to:
  /// **'Scanning ticket...'**
  String get scanningTicketProgress;

  /// No description provided for @extractingLotteryInformation.
  ///
  /// In en, this message translates to:
  /// **'Extracting lottery information'**
  String get extractingLotteryInformation;

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

  /// No description provided for @checkResults.
  ///
  /// In en, this message translates to:
  /// **'Check Results'**
  String get checkResults;

  /// No description provided for @checkingResultsProgress.
  ///
  /// In en, this message translates to:
  /// **'Checking results...'**
  String get checkingResultsProgress;

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

  /// No description provided for @betterLuckNextTime.
  ///
  /// In en, this message translates to:
  /// **'Better Luck Next Time'**
  String get betterLuckNextTime;

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

  /// No description provided for @noneMatchedForDraw.
  ///
  /// In en, this message translates to:
  /// **'None of your numbers matched the winning numbers for this draw.'**
  String get noneMatchedForDraw;

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

  /// No description provided for @winningResults.
  ///
  /// In en, this message translates to:
  /// **'Winning Results'**
  String get winningResults;

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

  /// No description provided for @lottery.
  ///
  /// In en, this message translates to:
  /// **'Lottery'**
  String get lottery;

  /// No description provided for @luckyLetter.
  ///
  /// In en, this message translates to:
  /// **'Lucky Letter'**
  String get luckyLetter;

  /// No description provided for @luckyLetterValue.
  ///
  /// In en, this message translates to:
  /// **'Lucky Letter: {value}'**
  String luckyLetterValue(Object value);

  /// No description provided for @serial.
  ///
  /// In en, this message translates to:
  /// **'Serial'**
  String get serial;

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

  /// No description provided for @checkFailed.
  ///
  /// In en, this message translates to:
  /// **'Check Failed'**
  String get checkFailed;

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

  /// No description provided for @failedToLoadResults.
  ///
  /// In en, this message translates to:
  /// **'Failed to load results'**
  String get failedToLoadResults;

  /// No description provided for @pullToRefreshOrTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh or try again later'**
  String get pullToRefreshOrTryAgainLater;

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

  /// No description provided for @recheck.
  ///
  /// In en, this message translates to:
  /// **'Re-check'**
  String get recheck;

  /// No description provided for @takeAnotherPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Another Photo'**
  String get takeAnotherPhoto;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @englishLanguageName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguageName;

  /// No description provided for @sinhalaLanguageName.
  ///
  /// In en, this message translates to:
  /// **'Sinhala'**
  String get sinhalaLanguageName;

  /// No description provided for @tamilLanguageName.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamilLanguageName;

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

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sri Lankan Lottery Ticket Scanner & Result Checker'**
  String get aboutDescription;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright (c) 2024-2026 LottoVision. Licensed under MIT.'**
  String get aboutCopyright;

  /// No description provided for @viewLicenses.
  ///
  /// In en, this message translates to:
  /// **'View Licenses'**
  String get viewLicenses;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @notificationsHint.
  ///
  /// In en, this message translates to:
  /// **'You will receive notifications about lottery results here.'**
  String get notificationsHint;

  /// No description provided for @webResults.
  ///
  /// In en, this message translates to:
  /// **'Web Results'**
  String get webResults;

  /// No description provided for @myTickets.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get myTickets;

  /// No description provided for @websiteDrawHistory.
  ///
  /// In en, this message translates to:
  /// **'Website draw history'**
  String get websiteDrawHistory;

  /// No description provided for @syncLast100Draws.
  ///
  /// In en, this message translates to:
  /// **'Sync last 100 draws'**
  String get syncLast100Draws;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncingHistory.
  ///
  /// In en, this message translates to:
  /// **'Syncing history...'**
  String get syncingHistory;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @historySyncReport.
  ///
  /// In en, this message translates to:
  /// **'Synced {saved}/{requested} from {source}'**
  String historySyncReport(Object requested, Object saved, Object source);

  /// No description provided for @historySyncFailed.
  ///
  /// In en, this message translates to:
  /// **'History sync failed: {error}'**
  String historySyncFailed(Object error);

  /// No description provided for @lastSyncWithSource.
  ///
  /// In en, this message translates to:
  /// **'{lastSyncLabel}  |  {sourceLabel}: {source}'**
  String lastSyncWithSource(
    Object lastSyncLabel,
    Object source,
    Object sourceLabel,
  );

  /// No description provided for @failedToLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history'**
  String get failedToLoadHistory;

  /// No description provided for @noDrawHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No draw history yet'**
  String get noDrawHistoryYet;

  /// No description provided for @tapSyncLast100Draws.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Sync last 100 draws\" to pull from website.'**
  String get tapSyncLast100Draws;

  /// No description provided for @predictionSettings.
  ///
  /// In en, this message translates to:
  /// **'Prediction settings'**
  String get predictionSettings;

  /// No description provided for @numberOfSets.
  ///
  /// In en, this message translates to:
  /// **'Number of sets'**
  String get numberOfSets;

  /// No description provided for @historyDepth.
  ///
  /// In en, this message translates to:
  /// **'History depth'**
  String get historyDepth;

  /// No description provided for @nSets.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String nSets(Object count);

  /// No description provided for @lastN.
  ///
  /// In en, this message translates to:
  /// **'Last {count}'**
  String lastN(Object count);

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @noPastResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No past results found. Sync history to generate predictions.'**
  String get noPastResultsFound;

  /// No description provided for @predictedLetterZodiac.
  ///
  /// In en, this message translates to:
  /// **'Predicted letter / zodiac'**
  String get predictedLetterZodiac;

  /// No description provided for @alternatives.
  ///
  /// In en, this message translates to:
  /// **'Alternatives: {items}'**
  String alternatives(Object items);

  /// No description provided for @moreCount.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String moreCount(Object count);

  /// No description provided for @basedOnCachedDraws.
  ///
  /// In en, this message translates to:
  /// **'Based on {count} cached draws ({dateRange}).'**
  String basedOnCachedDraws(Object count, Object dateRange);

  /// No description provided for @setNumber.
  ///
  /// In en, this message translates to:
  /// **'Set {number}'**
  String setNumber(Object number);

  /// No description provided for @scorePercent.
  ///
  /// In en, this message translates to:
  /// **'Score {score}%'**
  String scorePercent(Object score);

  /// No description provided for @numberTrends.
  ///
  /// In en, this message translates to:
  /// **'Number trends'**
  String get numberTrends;

  /// No description provided for @hotNumbers.
  ///
  /// In en, this message translates to:
  /// **'Hot numbers'**
  String get hotNumbers;

  /// No description provided for @coldNumbers.
  ///
  /// In en, this message translates to:
  /// **'Cold numbers'**
  String get coldNumbers;

  /// No description provided for @predictionFailed.
  ///
  /// In en, this message translates to:
  /// **'Prediction failed'**
  String get predictionFailed;

  /// No description provided for @noHistoryRange.
  ///
  /// In en, this message translates to:
  /// **'no history'**
  String get noHistoryRange;

  /// No description provided for @quickActionResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check latest draw results'**
  String get quickActionResultsSubtitle;

  /// No description provided for @quickActionHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review scanned tickets'**
  String get quickActionHistorySubtitle;

  /// No description provided for @quickActionPredictionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View smart number insights'**
  String get quickActionPredictionSubtitle;

  /// No description provided for @smartTicketScanner.
  ///
  /// In en, this message translates to:
  /// **'Smart Ticket Scanner'**
  String get smartTicketScanner;

  /// No description provided for @scanResultsVerifiedInSeconds.
  ///
  /// In en, this message translates to:
  /// **'{takePhotoLabel}. Results are verified in seconds.'**
  String scanResultsVerifiedInSeconds(Object takePhotoLabel);

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @howItWorksStep1.
  ///
  /// In en, this message translates to:
  /// **'Take a clear photo of your lottery ticket'**
  String get howItWorksStep1;

  /// No description provided for @howItWorksStep2.
  ///
  /// In en, this message translates to:
  /// **'We extract the numbers using OCR technology'**
  String get howItWorksStep2;

  /// No description provided for @howItWorksStep3.
  ///
  /// In en, this message translates to:
  /// **'Check against official results'**
  String get howItWorksStep3;

  /// No description provided for @howItWorksStep4.
  ///
  /// In en, this message translates to:
  /// **'Get instant winning notifications'**
  String get howItWorksStep4;

  /// No description provided for @signLabel.
  ///
  /// In en, this message translates to:
  /// **'SIGN'**
  String get signLabel;

  /// No description provided for @seedResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Mahajana results are ready'**
  String get seedResultTitle;

  /// No description provided for @seedResultMessage.
  ///
  /// In en, this message translates to:
  /// **'Draw #2345 is available. Check your ticket now.'**
  String get seedResultMessage;

  /// No description provided for @seedWinTitle.
  ///
  /// In en, this message translates to:
  /// **'Winning ticket detected'**
  String get seedWinTitle;

  /// No description provided for @seedWinMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Mega Power ticket won a prize. Tap for details.'**
  String get seedWinMessage;

  /// No description provided for @seedScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan completed'**
  String get seedScanTitle;

  /// No description provided for @seedScanMessage.
  ///
  /// In en, this message translates to:
  /// **'We extracted your ticket numbers. Review them before checking.'**
  String get seedScanMessage;

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

  /// No description provided for @lotteryAdaKotipathi.
  ///
  /// In en, this message translates to:
  /// **'Ada Kotipathi'**
  String get lotteryAdaKotipathi;

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

  /// No description provided for @lotterySuperBall.
  ///
  /// In en, this message translates to:
  /// **'Super Ball'**
  String get lotterySuperBall;

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

  /// No description provided for @lotteryLagnaWasana.
  ///
  /// In en, this message translates to:
  /// **'Lagna Wasana'**
  String get lotteryLagnaWasana;

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
