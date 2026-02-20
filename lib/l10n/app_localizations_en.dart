// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'LottoVision';

  @override
  String get home => 'Home';

  @override
  String get scan => 'Scan Ticket';

  @override
  String get prediction => 'Prediction';

  @override
  String get history => 'History';

  @override
  String get results => 'Results';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get scanTicket => 'Scan Lottery Ticket';

  @override
  String get scanningTicketSection => 'Scanning Ticket';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get chooseAnOption => 'Choose an option';

  @override
  String get processingImage => 'Processing image...';

  @override
  String get cameraPermissionRequired => 'Camera permission is required';

  @override
  String get galleryPermissionRequired => 'Gallery permission is required';

  @override
  String errorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String get scanning => 'Scanning...';

  @override
  String get scanningTicketProgress => 'Scanning ticket...';

  @override
  String get extractingLotteryInformation => 'Extracting lottery information';

  @override
  String get processing => 'Processing...';

  @override
  String get checkingResults => 'Checking Results...';

  @override
  String get checkResults => 'Check Results';

  @override
  String get checkingResultsProgress => 'Checking results...';

  @override
  String get winner => 'Winner!';

  @override
  String get notWinner => 'Not a Winner';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get betterLuckNextTime => 'Better Luck Next Time';

  @override
  String youWon(Object amount) {
    return 'You won LKR $amount';
  }

  @override
  String matchedNumbers(Object count) {
    return 'Matched $count numbers';
  }

  @override
  String get noneMatchedForDraw =>
      'None of your numbers matched the winning numbers for this draw.';

  @override
  String drawNumber(Object number) {
    return 'Draw #$number';
  }

  @override
  String drawDate(Object date) {
    return 'Draw Date: $date';
  }

  @override
  String get ticketDetails => 'Ticket Details';

  @override
  String get winningNumbers => 'Winning Numbers';

  @override
  String get winningResults => 'Winning Results';

  @override
  String get yourNumbers => 'Your Numbers';

  @override
  String get lotteryType => 'Lottery Type';

  @override
  String get lottery => 'Lottery';

  @override
  String get luckyLetter => 'Lucky Letter';

  @override
  String luckyLetterValue(Object value) {
    return 'Lucky Letter: $value';
  }

  @override
  String get serial => 'Serial';

  @override
  String get serialNumber => 'Serial Number';

  @override
  String get checkTicket => 'Check Ticket';

  @override
  String get checkFailed => 'Check Failed';

  @override
  String get deleteTicket => 'Delete Ticket';

  @override
  String get noTickets => 'No tickets scanned yet';

  @override
  String get noResults => 'No results available';

  @override
  String get failedToLoadResults => 'Failed to load results';

  @override
  String get pullToRefreshOrTryAgainLater =>
      'Pull to refresh or try again later';

  @override
  String get error => 'Error';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Retry';

  @override
  String get recheck => 'Re-check';

  @override
  String get takeAnotherPhoto => 'Take Another Photo';

  @override
  String get reload => 'Reload';

  @override
  String get language => 'Language';

  @override
  String get englishLanguageName => 'English';

  @override
  String get sinhalaLanguageName => 'Sinhala';

  @override
  String get tamilLanguageName => 'Tamil';

  @override
  String get theme => 'Theme';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get aboutDescription =>
      'Sri Lankan Lottery Ticket Scanner & Result Checker';

  @override
  String get aboutCopyright =>
      'Copyright (c) 2024-2026 LottoVision. Licensed under MIT.';

  @override
  String get viewLicenses => 'View Licenses';

  @override
  String get licenses => 'Licenses';

  @override
  String get version => 'Version';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get notificationsHint =>
      'You will receive notifications about lottery results here.';

  @override
  String get webResults => 'Web Results';

  @override
  String get myTickets => 'My Tickets';

  @override
  String get websiteDrawHistory => 'Website draw history';

  @override
  String get syncLast100Draws => 'Sync last 100 draws';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncingHistory => 'Syncing history...';

  @override
  String get syncNow => 'Sync now';

  @override
  String get source => 'Source';

  @override
  String historySyncReport(Object requested, Object saved, Object source) {
    return 'Synced $saved/$requested from $source';
  }

  @override
  String historySyncFailed(Object error) {
    return 'History sync failed: $error';
  }

  @override
  String lastSyncWithSource(
    Object lastSyncLabel,
    Object source,
    Object sourceLabel,
  ) {
    return '$lastSyncLabel  |  $sourceLabel: $source';
  }

  @override
  String get failedToLoadHistory => 'Failed to load history';

  @override
  String get noDrawHistoryYet => 'No draw history yet';

  @override
  String get tapSyncLast100Draws =>
      'Tap \"Sync last 100 draws\" to pull from website.';

  @override
  String get predictionSettings => 'Prediction settings';

  @override
  String get numberOfSets => 'Number of sets';

  @override
  String get historyDepth => 'History depth';

  @override
  String nSets(Object count) {
    return '$count sets';
  }

  @override
  String lastN(Object count) {
    return 'Last $count';
  }

  @override
  String get regenerate => 'Regenerate';

  @override
  String get noPastResultsFound =>
      'No past results found. Sync history to generate predictions.';

  @override
  String get predictedLetterZodiac => 'Predicted letter / zodiac';

  @override
  String alternatives(Object items) {
    return 'Alternatives: $items';
  }

  @override
  String moreCount(Object count) {
    return '+$count more';
  }

  @override
  String basedOnCachedDraws(Object count, Object dateRange) {
    return 'Based on $count cached draws ($dateRange).';
  }

  @override
  String setNumber(Object number) {
    return 'Set $number';
  }

  @override
  String scorePercent(Object score) {
    return 'Score $score%';
  }

  @override
  String get numberTrends => 'Number trends';

  @override
  String get hotNumbers => 'Hot numbers';

  @override
  String get coldNumbers => 'Cold numbers';

  @override
  String get predictionFailed => 'Prediction failed';

  @override
  String get noHistoryRange => 'no history';

  @override
  String get quickActionResultsSubtitle => 'Check latest draw results';

  @override
  String get quickActionHistorySubtitle => 'Review scanned tickets';

  @override
  String get quickActionPredictionSubtitle => 'View smart number insights';

  @override
  String get smartTicketScanner => 'Smart Ticket Scanner';

  @override
  String scanResultsVerifiedInSeconds(Object takePhotoLabel) {
    return '$takePhotoLabel. Results are verified in seconds.';
  }

  @override
  String get howItWorks => 'How it works';

  @override
  String get howItWorksStep1 => 'Take a clear photo of your lottery ticket';

  @override
  String get howItWorksStep2 => 'We extract the numbers using OCR technology';

  @override
  String get howItWorksStep3 => 'Check against official results';

  @override
  String get howItWorksStep4 => 'Get instant winning notifications';

  @override
  String get signLabel => 'SIGN';

  @override
  String get seedResultTitle => 'Mahajana results are ready';

  @override
  String get seedResultMessage =>
      'Draw #2345 is available. Check your ticket now.';

  @override
  String get seedWinTitle => 'Winning ticket detected';

  @override
  String get seedWinMessage =>
      'Your Mega Power ticket won a prize. Tap for details.';

  @override
  String get seedScanTitle => 'Scan completed';

  @override
  String get seedScanMessage =>
      'We extracted your ticket numbers. Review them before checking.';

  @override
  String get cameraPermissionDenied =>
      'Camera permission is required to scan tickets';

  @override
  String get storagePermissionDenied => 'Storage permission is required';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get imageQualityLow =>
      'Image quality too low. Please retake the photo';

  @override
  String get noTextDetected => 'No text detected in the image';

  @override
  String get invalidTicket => 'Invalid lottery ticket';

  @override
  String get couldNotDetectLotteryType => 'Could not detect lottery type';

  @override
  String get fetchingResults => 'Fetching latest results...';

  @override
  String get resultNotFound => 'Results not found for this draw';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get lotteryAdaKotipathi => 'Ada Kotipathi';

  @override
  String get lotteryAdaSampatha => 'Ada Sampatha';

  @override
  String get lotteryDaruDiriSampatha => 'Daru Diri Sampatha';

  @override
  String get lotteryDelakshapathi => 'Delakshapathi Double Dreams';

  @override
  String get lotteryDhanaNidhanaya => 'Dhana Nidhanaya';

  @override
  String get lotteryDollarFortune => 'Dollar Fortune';

  @override
  String get lotteryGovisetha => 'Govisetha';

  @override
  String get lotteryHandahana => 'Handahana';

  @override
  String get lotteryJathika => 'Jathika Sampatha';

  @override
  String get lotteryMahajana => 'Mahajana Sampatha';

  @override
  String get lotteryMega60 => 'Mega 60';

  @override
  String get lotteryMegaMillions => 'Mega Millions';

  @override
  String get lotteryMegaPower => 'Mega Power';

  @override
  String get lotteryNeeroga => 'Neeroga Lagna Jaya';

  @override
  String get lotteryNlbJaya => 'NLB Jaya';

  @override
  String get lotterySampathRekha => 'Sampath Rekha';

  @override
  String get lotterySampathaLagnaVarama => 'Sampatha Lagna Varama';

  @override
  String get lotterySevana => 'Sevana';

  @override
  String get lotteryShanida => 'Shanida';

  @override
  String get lotterySubaDawasak => 'Suba Dawasak';

  @override
  String get lotterySuperBall => 'Super Ball';

  @override
  String get lotterySuperFifty => 'Vasana Super Fifty';

  @override
  String get lotterySupiriVasana => 'Supiri Vasana';

  @override
  String get lotteryVasana => 'Vasana Sampatha';

  @override
  String get lotteryLagnaWasana => 'Lagna Wasana';

  @override
  String get lotteryUnknown => 'Unknown';
}
