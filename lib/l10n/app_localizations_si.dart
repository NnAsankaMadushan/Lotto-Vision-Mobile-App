// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appName => 'ලොටෝ විෂන්';

  @override
  String get home => 'මුල් පිටුව';

  @override
  String get scan => 'ටිකට් පතය ස්කෑන් කරන්න';

  @override
  String get prediction => 'අනාවැකි';

  @override
  String get history => 'ඉතිහාසය';

  @override
  String get results => 'ප්‍රතිඵල';

  @override
  String get settings => 'සැකසුම්';

  @override
  String get notifications => 'නිවේදන';

  @override
  String get quickActions => 'වේගවත් ක්‍රියා';

  @override
  String get scanTicket => 'ලොතරැයි ටිකට් පත ස්කෑන් කරන්න';

  @override
  String get scanningTicketSection => 'ටිකට් පත ස්කෑන් කිරීම';

  @override
  String get takePhoto => 'ඡායාරූපයක් ගන්න';

  @override
  String get chooseFromGallery => 'ගැලරියෙන් තෝරන්න';

  @override
  String get chooseAnOption => 'විකල්පයක් තෝරන්න';

  @override
  String get processingImage => 'රූපය සකසමින්...';

  @override
  String get cameraPermissionRequired => 'කැමරා අවසරය අවශ්‍යයි';

  @override
  String get galleryPermissionRequired => 'ගැලරිය අවසරය අවශ්‍යයි';

  @override
  String errorWithMessage(Object message) {
    return 'දෝෂය: $message';
  }

  @override
  String get scanning => 'ස්කෑන් කරමින්...';

  @override
  String get scanningTicketProgress => 'ටිකට් පත ස්කෑන් කරමින්...';

  @override
  String get extractingLotteryInformation => 'ලොතරැයි තොරතුරු උපුටා ගනිමින්';

  @override
  String get processing => 'සකසමින්...';

  @override
  String get checkingResults => 'ප්‍රතිඵල පරීක්ෂා කරමින්...';

  @override
  String get checkResults => 'ප්‍රතිඵල පරීක්ෂා කරන්න';

  @override
  String get checkingResultsProgress => 'ප්‍රතිඵල පරීක්ෂා කරමින්...';

  @override
  String get winner => 'ජයග්‍රාහකයා!';

  @override
  String get notWinner => 'ජයග්‍රාහකයෙක් නොවේ';

  @override
  String get congratulations => 'සුබ පැතුම්!';

  @override
  String get betterLuckNextTime => 'ඊළඟ වතාවේ වාසනාවන්ත වෙන්න';

  @override
  String youWon(Object amount) {
    return 'ඔබ රු. $amount ක් දිනා ඇත';
  }

  @override
  String matchedNumbers(Object count) {
    return 'අංක $count ක් ගැලපේ';
  }

  @override
  String get noneMatchedForDraw =>
      'මෙම දිනුම සඳහා ඔබගේ කිසිදු අංකයක් ජයග්‍රාහී අංක සමඟ ගැලපුණේ නැත.';

  @override
  String drawNumber(Object number) {
    return 'දිනුම් අංකය #$number';
  }

  @override
  String drawDate(Object date) {
    return 'දිනුම් දිනය: $date';
  }

  @override
  String get ticketDetails => 'ටිකට් පත් විස්තර';

  @override
  String get winningNumbers => 'ජයග්‍රාහී අංක';

  @override
  String get winningResults => 'ජයග්‍රාහී ප්‍රතිඵල';

  @override
  String get yourNumbers => 'ඔබේ අංක';

  @override
  String get lotteryType => 'ලොතරැයි වර්ගය';

  @override
  String get lottery => 'ලොතරැයි';

  @override
  String get luckyLetter => 'වාසනා අකුර';

  @override
  String luckyLetterValue(Object value) {
    return 'වාසනා අකුර: $value';
  }

  @override
  String get serial => 'අනුක්‍රමික අංකය';

  @override
  String get serialNumber => 'අනුක්‍රමික අංකය';

  @override
  String get checkTicket => 'ටිකට් පත පරීක්ෂා කරන්න';

  @override
  String get checkFailed => 'පරීක්ෂාව අසාර්ථකයි';

  @override
  String get deleteTicket => 'ටිකට් පත මකන්න';

  @override
  String get noTickets => 'තවම ටිකට් පත් ස්කෑන් කර නැත';

  @override
  String get noResults => 'ප්‍රතිඵල නොමැත';

  @override
  String get failedToLoadResults => 'ප්‍රතිඵල පූරණය කළ නොහැකි විය';

  @override
  String get pullToRefreshOrTryAgainLater =>
      'නවීකරණයට පහළට ඇද නැවත උත්සාහ කරන්න හෝ පසුව උත්සාහ කරන්න';

  @override
  String get error => 'දෝෂයකි';

  @override
  String get tryAgain => 'නැවත උත්සාහ කරන්න';

  @override
  String get cancel => 'අවලංගු කරන්න';

  @override
  String get ok => 'හරි';

  @override
  String get retry => 'නැවත උත්සාහ කරන්න';

  @override
  String get recheck => 'නැවත පරීක්ෂා කරන්න';

  @override
  String get takeAnotherPhoto => 'තවත් ඡායාරූපයක් ගන්න';

  @override
  String get reload => 'නැවත පූරණය කරන්න';

  @override
  String get language => 'භාෂාව';

  @override
  String get englishLanguageName => 'English';

  @override
  String get sinhalaLanguageName => 'සිංහල';

  @override
  String get tamilLanguageName => 'தமிழ்';

  @override
  String get theme => 'තේමාව';

  @override
  String get lightMode => 'ආලෝක ප්‍රකාරය';

  @override
  String get darkMode => 'අඳුරු ප්‍රකාරය';

  @override
  String get systemDefault => 'පද්ධති පෙරනිමිය';

  @override
  String get about => 'පිළිබඳව';

  @override
  String get privacyPolicy => 'රහස්‍යතා ප්‍රතිපත්තිය';

  @override
  String get termsOfService => 'සේවා කොන්දේසි';

  @override
  String get aboutDescription =>
      'ශ්‍රී ලාංකීය ලොතරැයි ටිකට් ස්කෑනර් සහ ප්‍රතිඵල පරීක්ෂක';

  @override
  String get aboutCopyright =>
      'ප්‍රකාශන හිමිකම (c) 2024-2026 LottoVision. MIT යටතේ බලපත්‍ර ලබා ඇත.';

  @override
  String get viewLicenses => 'බලපත්‍ර බලන්න';

  @override
  String get licenses => 'බලපත්‍ර';

  @override
  String get version => 'අනුවාදය';

  @override
  String get markAllRead => 'සියල්ල කියවූ ලෙස සලකුණු කරන්න';

  @override
  String get noNotificationsYet => 'තවම නිවේදන නොමැත';

  @override
  String get notificationsHint =>
      'ලොතරැයි ප්‍රතිඵල පිළිබඳ නිවේදන ඔබට මෙහි ලැබේ.';

  @override
  String get webResults => 'වෙබ් ප්‍රතිඵල';

  @override
  String get myTickets => 'මගේ ටිකට්';

  @override
  String get websiteDrawHistory => 'වෙබ් අඩවි දිනුම් ඉතිහාසය';

  @override
  String get syncLast100Draws => 'අවසන් දිනුම් 100 සමමුහුර්ත කරන්න';

  @override
  String get syncing => 'සමමුහුර්ත කරමින්...';

  @override
  String get syncingHistory => 'ඉතිහාසය සමමුහුර්ත කරමින්...';

  @override
  String get syncNow => 'දැන් සමමුහුර්ත කරන්න';

  @override
  String get source => 'මූලාශ්‍රය';

  @override
  String historySyncReport(Object requested, Object saved, Object source) {
    return '$source වෙතින් $saved/$requested සමමුහුර්ත කරන ලදී';
  }

  @override
  String historySyncFailed(Object error) {
    return 'ඉතිහාස සමමුහුර්ත කිරීම අසාර්ථකයි: $error';
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
  String get failedToLoadHistory => 'ඉතිහාසය පූරණය කළ නොහැකි විය';

  @override
  String get noDrawHistoryYet => 'තවම දිනුම් ඉතිහාසයක් නොමැත';

  @override
  String get tapSyncLast100Draws =>
      'වෙබ් අඩවියෙන් ලබා ගැනීමට \"අවසන් දිනුම් 100 සමමුහුර්ත කරන්න\" තට්ටු කරන්න.';

  @override
  String get predictionSettings => 'අනාවැකි සැකසුම්';

  @override
  String get numberOfSets => 'කට්ටල ගණන';

  @override
  String get historyDepth => 'ඉතිහාස පරාසය';

  @override
  String nSets(Object count) {
    return 'කට්ටල $count';
  }

  @override
  String lastN(Object count) {
    return 'අවසන් $count';
  }

  @override
  String get regenerate => 'නැවත උත්පාදනය කරන්න';

  @override
  String get noPastResultsFound =>
      'පසුගිය ප්‍රතිඵල හමු නොවීය. අනාවැකි ජනනය කිරීමට ඉතිහාසය සමමුහුර්ත කරන්න.';

  @override
  String get predictedLetterZodiac => 'අනාවැකි වාසනා අකුර / රාශිය';

  @override
  String alternatives(Object items) {
    return 'විකල්ප: $items';
  }

  @override
  String moreCount(Object count) {
    return 'තවත් +$count';
  }

  @override
  String basedOnCachedDraws(Object count, Object dateRange) {
    return 'කැෂ් කළ දිනුම් $count මත පදනම්ව ($dateRange).';
  }

  @override
  String setNumber(Object number) {
    return 'කට්ටලය $number';
  }

  @override
  String scorePercent(Object score) {
    return 'ලකුණු $score%';
  }

  @override
  String get numberTrends => 'අංක ප්‍රවණතා';

  @override
  String get hotNumbers => 'උණුසුම් අංක';

  @override
  String get coldNumbers => 'ශීත අංක';

  @override
  String get predictionFailed => 'අනාවැකිය අසාර්ථකයි';

  @override
  String get noHistoryRange => 'ඉතිහාසය නැත';

  @override
  String get quickActionResultsSubtitle => 'නවතම දිනුම් ප්‍රතිඵල පරීක්ෂා කරන්න';

  @override
  String get quickActionHistorySubtitle => 'ස්කෑන් කළ ටිකට් සමාලෝචනය කරන්න';

  @override
  String get quickActionPredictionSubtitle => 'බුද්ධිමත් අංක අවබෝධ බලන්න';

  @override
  String get smartTicketScanner => 'බුද්ධිමත් ටිකට් ස්කෑනර්';

  @override
  String scanResultsVerifiedInSeconds(Object takePhotoLabel) {
    return '$takePhotoLabel. ප්‍රතිඵල තත්පර කිහිපයකින් සත්‍යාපනය වේ.';
  }

  @override
  String get howItWorks => 'මෙය ක්‍රියා කරන ආකාරය';

  @override
  String get howItWorksStep1 =>
      'ඔබගේ ලොතරැයි ටිකට් පතේ පැහැදිලි ඡායාරූපයක් ගන්න';

  @override
  String get howItWorksStep2 => 'අපි OCR තාක්ෂණයෙන් අංක උපුටා ගනිමු';

  @override
  String get howItWorksStep3 => 'නිල ප්‍රතිඵල සමඟ සැසඳෙන්න';

  @override
  String get howItWorksStep4 => 'ක්ෂණික ජයග්‍රාහී නිවේදන ලබාගන්න';

  @override
  String get signLabel => 'ලග්න';

  @override
  String get seedResultTitle => 'මහජන ප්‍රතිඵල සූදානම්';

  @override
  String get seedResultMessage =>
      'දිනුම #2345 ලಭ್ಯයි. දැන් ඔබගේ ටිකට් පත පරීක්ෂා කරන්න.';

  @override
  String get seedWinTitle => 'ජයග්‍රාහී ටිකට් පතක් හමු විය';

  @override
  String get seedWinMessage =>
      'ඔබගේ මෙගා පවර් ටිකට් පතට ත්‍යාගයක් ලැබී ඇත. විස්තර සඳහා තට්ටු කරන්න.';

  @override
  String get seedScanTitle => 'ස්කෑන් කිරීම සම්පූර්ණයි';

  @override
  String get seedScanMessage =>
      'අපි ඔබගේ ටිකට් අංක උපුටා ගත්තා. පරීක්ෂා කිරීමට පෙර ඒවා සමාලෝචනය කරන්න.';

  @override
  String get cameraPermissionDenied =>
      'ටිකට් පත් ස්කෑන් කිරීමට කැමරා අවසරය අවශ්‍යයි';

  @override
  String get storagePermissionDenied => 'ගබඩා අවසරය අවශ්‍යයි';

  @override
  String get grantPermission => 'අවසරය ලබා දෙන්න';

  @override
  String get imageQualityLow =>
      'රූප ගුණාත්මකභාවය ඉතා අඩුයි. කරුණාකර නැවත ඡායාරූපය ගන්න';

  @override
  String get noTextDetected => 'රූපයෙන් පෙළ හඳුනා නොගත්';

  @override
  String get invalidTicket => 'වලංගු නොවන ලොතරැයි ටිකට් පතක්';

  @override
  String get couldNotDetectLotteryType => 'ලොතරැයි වර්ගය හඳුනාගත නොහැක';

  @override
  String get fetchingResults => 'නවතම ප්‍රතිඵල ලබා ගනිමින්...';

  @override
  String get resultNotFound => 'මෙම දිනුම සඳහා ප්‍රතිඵල හමු නොවීය';

  @override
  String get noInternetConnection => 'අන්තර්ජාල සම්බන්ධතාවයක් නැත';

  @override
  String get lotteryAdaKotipathi => 'අද කෝටිපති';

  @override
  String get lotteryAdaSampatha => 'අද සම්පත';

  @override
  String get lotteryDaruDiriSampatha => 'දරු දිරි සම්පත';

  @override
  String get lotteryDelakshapathi => 'දෙලක්ෂපති ද්විත්ව ස්වප්න';

  @override
  String get lotteryDhanaNidhanaya => 'ධන නිධානය';

  @override
  String get lotteryDollarFortune => 'ඩොලර් සම්පත';

  @override
  String get lotteryGovisetha => 'ගෝවිසේත';

  @override
  String get lotteryHandahana => 'හන්දහන';

  @override
  String get lotteryJathika => 'ජාතික සම්පත';

  @override
  String get lotteryMahajana => 'මහජන සම්පත';

  @override
  String get lotteryMega60 => 'මෙගා 60';

  @override
  String get lotteryMegaMillions => 'මෙගා මිලියන';

  @override
  String get lotteryMegaPower => 'මෙගා පවර්';

  @override
  String get lotteryNeeroga => 'නීරෝග ලග්න ජය';

  @override
  String get lotteryNlbJaya => 'එන්.එල්.බී ජය';

  @override
  String get lotterySampathRekha => 'සම්පත් රේඛා';

  @override
  String get lotterySampathaLagnaVarama => 'සම්පත ලග්න වරම';

  @override
  String get lotterySevana => 'සේවන';

  @override
  String get lotteryShanida => 'ශනිද';

  @override
  String get lotterySubaDawasak => 'සුබ දවසක්';

  @override
  String get lotterySuperBall => 'සුපර් බෝල්';

  @override
  String get lotterySuperFifty => 'වසන සුපර් පණ්ඩෑස්';

  @override
  String get lotterySupiriVasana => 'සුපිරි වසන';

  @override
  String get lotteryVasana => 'වසන සම්පත';

  @override
  String get lotteryLagnaWasana => 'ලග්න වාසනා';

  @override
  String get lotteryUnknown => 'නොදනී';
}
