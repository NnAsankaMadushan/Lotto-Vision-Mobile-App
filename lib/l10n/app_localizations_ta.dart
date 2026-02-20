// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'லோட்டோ விஷன்';

  @override
  String get home => 'முகப்பு';

  @override
  String get scan => 'டிக்கெட்டை ஸ்கேன் செய்';

  @override
  String get prediction => 'கணிப்பு';

  @override
  String get history => 'வரலாறு';

  @override
  String get results => 'முடிவுகள்';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get notifications => 'அறிவிப்புகள்';

  @override
  String get quickActions => 'விரைவு செயல்கள்';

  @override
  String get scanTicket => 'லாட்டரி டிக்கெட்டை ஸ்கேன் செய்';

  @override
  String get scanningTicketSection => 'டிக்கெட் ஸ்கேன்';

  @override
  String get takePhoto => 'புகைப்படம் எடுக்க';

  @override
  String get chooseFromGallery => 'கேலரியிலிருந்து தேர்வு செய்';

  @override
  String get chooseAnOption => 'ஒரு விருப்பத்தைத் தேர்வுசெய்க';

  @override
  String get processingImage => 'படம் செயலாக்கப்படுகிறது...';

  @override
  String get cameraPermissionRequired => 'கேமரா அனுமதி தேவை';

  @override
  String get galleryPermissionRequired => 'கேலரி அனுமதி தேவை';

  @override
  String errorWithMessage(Object message) {
    return 'பிழை: $message';
  }

  @override
  String get scanning => 'ஸ்கேன் செய்கிறது...';

  @override
  String get scanningTicketProgress => 'டிக்கெட் ஸ்கேன் செய்கிறது...';

  @override
  String get extractingLotteryInformation => 'லாட்டரி தகவல் எடுக்கப்படுகிறது';

  @override
  String get processing => 'செயலாக்குகிறது...';

  @override
  String get checkingResults => 'முடிவுகளை சரிபார்க்கிறது...';

  @override
  String get checkResults => 'முடிவுகளைச் சரிபார்';

  @override
  String get checkingResultsProgress => 'முடிவுகள் சரிபார்க்கப்படுகின்றன...';

  @override
  String get winner => 'வெற்றியாளர்!';

  @override
  String get notWinner => 'வெற்றியாளர் இல்லை';

  @override
  String get congratulations => 'வாழ்த்துக்கள்!';

  @override
  String get betterLuckNextTime => 'அடுத்த முறை நல்ல அதிர்ஷ்டம்';

  @override
  String youWon(Object amount) {
    return 'நீங்கள் ரூ. $amount வென்றீர்கள்';
  }

  @override
  String matchedNumbers(Object count) {
    return '$count எண்கள் பொருந்தின';
  }

  @override
  String get noneMatchedForDraw =>
      'இந்த டிராவிற்கு உங்கள் எண்களில் எதுவும் வெற்றி எண்களுடன் பொருந்தவில்லை.';

  @override
  String drawNumber(Object number) {
    return 'டிராவ் #$number';
  }

  @override
  String drawDate(Object date) {
    return 'டிராவ் தேதி: $date';
  }

  @override
  String get ticketDetails => 'டிக்கெட் விவரங்கள்';

  @override
  String get winningNumbers => 'வெற்றி எண்கள்';

  @override
  String get winningResults => 'வெற்றி முடிவுகள்';

  @override
  String get yourNumbers => 'உங்கள் எண்கள்';

  @override
  String get lotteryType => 'லாட்டரி வகை';

  @override
  String get lottery => 'லாட்டரி';

  @override
  String get luckyLetter => 'அதிர்ஷ்ட எழுத்து';

  @override
  String luckyLetterValue(Object value) {
    return 'அதிர்ஷ்ட எழுத்து: $value';
  }

  @override
  String get serial => 'வரிசை';

  @override
  String get serialNumber => 'வரிசை எண்';

  @override
  String get checkTicket => 'டிக்கெட்டை சரிபார்';

  @override
  String get checkFailed => 'சரிபார்ப்பு தோல்வி';

  @override
  String get deleteTicket => 'டிக்கெட்டை அழி';

  @override
  String get noTickets => 'இன்னும் டிக்கெட்டுகள் ஸ்கேன் செய்யப்படவில்லை';

  @override
  String get noResults => 'முடிவுகள் இல்லை';

  @override
  String get failedToLoadResults => 'முடிவுகளை ஏற்ற முடியவில்லை';

  @override
  String get pullToRefreshOrTryAgainLater =>
      'புதுப்பிக்க கீழே இழுக்கவும் அல்லது பின்னர் மீண்டும் முயற்சிக்கவும்';

  @override
  String get error => 'பிழை';

  @override
  String get tryAgain => 'மீண்டும் முயற்சி செய்';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get ok => 'சரி';

  @override
  String get retry => 'மீண்டும் முயற்சி செய்';

  @override
  String get recheck => 'மீண்டும் சரிபார்';

  @override
  String get takeAnotherPhoto => 'மற்றொரு புகைப்படம் எடுக்க';

  @override
  String get reload => 'மீண்டும் ஏற்று';

  @override
  String get language => 'மொழி';

  @override
  String get englishLanguageName => 'English';

  @override
  String get sinhalaLanguageName => 'සිංහල';

  @override
  String get tamilLanguageName => 'தமிழ்';

  @override
  String get theme => 'தீம்';

  @override
  String get lightMode => 'ஒளி பயன்முறை';

  @override
  String get darkMode => 'இருள் பயன்முறை';

  @override
  String get systemDefault => 'கணினி இயல்புநிலை';

  @override
  String get about => 'பற்றி';

  @override
  String get privacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get termsOfService => 'சேவை விதிமுறைகள்';

  @override
  String get aboutDescription =>
      'இலங்கை லாட்டரி டிக்கெட் ஸ்கேனர் மற்றும் முடிவு சரிபார்ப்பான்';

  @override
  String get aboutCopyright =>
      'பதிப்புரிமை (c) 2024-2026 LottoVision. MIT உரிமத்தில் வழங்கப்படுகிறது.';

  @override
  String get viewLicenses => 'உரிமங்கள் பார்க்க';

  @override
  String get licenses => 'உரிமங்கள்';

  @override
  String get version => 'பதிப்பு';

  @override
  String get markAllRead => 'அனைத்தையும் வாசித்ததாக குறிக்க';

  @override
  String get noNotificationsYet => 'இன்னும் அறிவிப்புகள் இல்லை';

  @override
  String get notificationsHint =>
      'லாட்டரி முடிவுகள் குறித்த அறிவிப்புகள் இங்கே கிடைக்கும்.';

  @override
  String get webResults => 'இணைய முடிவுகள்';

  @override
  String get myTickets => 'என் டிக்கெட்டுகள்';

  @override
  String get websiteDrawHistory => 'இணைய டிரா வரலாறு';

  @override
  String get syncLast100Draws => 'கடைசி 100 டிராவை ஒத்திசை';

  @override
  String get syncing => 'ஒத்திசைக்கிறது...';

  @override
  String get syncingHistory => 'வரலாறு ஒத்திசைக்கிறது...';

  @override
  String get syncNow => 'இப்போது ஒத்திசை';

  @override
  String get source => 'மூலம்';

  @override
  String historySyncReport(Object requested, Object saved, Object source) {
    return '$source இலிருந்து $saved/$requested ஒத்திசைக்கப்பட்டது';
  }

  @override
  String historySyncFailed(Object error) {
    return 'வரலாறு ஒத்திசைப்பு தோல்வி: $error';
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
  String get failedToLoadHistory => 'வரலாற்றை ஏற்ற முடியவில்லை';

  @override
  String get noDrawHistoryYet => 'இன்னும் டிரா வரலாறு இல்லை';

  @override
  String get tapSyncLast100Draws =>
      'இணையதளத்திலிருந்து பெற \"கடைசி 100 டிராவை ஒத்திசை\" என்பதைத் தட்டவும்.';

  @override
  String get predictionSettings => 'கணிப்பு அமைப்புகள்';

  @override
  String get numberOfSets => 'செட்களின் எண்ணிக்கை';

  @override
  String get historyDepth => 'வரலாறு ஆழம்';

  @override
  String nSets(Object count) {
    return '$count செட்கள்';
  }

  @override
  String lastN(Object count) {
    return 'கடைசி $count';
  }

  @override
  String get regenerate => 'மீண்டும் உருவாக்கு';

  @override
  String get noPastResultsFound =>
      'கடந்த முடிவுகள் இல்லை. கணிப்புகளை உருவாக்க வரலாற்றை ஒத்திசைக்கவும்.';

  @override
  String get predictedLetterZodiac => 'கணிக்கப்பட்ட எழுத்து / ராசி';

  @override
  String alternatives(Object items) {
    return 'மாற்றுகள்: $items';
  }

  @override
  String moreCount(Object count) {
    return '+$count மேலும்';
  }

  @override
  String basedOnCachedDraws(Object count, Object dateRange) {
    return 'கேஷ் செய்யப்பட்ட $count டிராக்களை அடிப்படையாகக் கொண்டு ($dateRange).';
  }

  @override
  String setNumber(Object number) {
    return 'செட் $number';
  }

  @override
  String scorePercent(Object score) {
    return 'மதிப்பெண் $score%';
  }

  @override
  String get numberTrends => 'எண் போக்குகள்';

  @override
  String get hotNumbers => 'ஹாட் எண்கள்';

  @override
  String get coldNumbers => 'கோல்ட் எண்கள்';

  @override
  String get predictionFailed => 'கணிப்பு தோல்வி';

  @override
  String get noHistoryRange => 'வரலாறு இல்லை';

  @override
  String get quickActionResultsSubtitle =>
      'சமீபத்திய டிரா முடிவுகளை பார்க்கவும்';

  @override
  String get quickActionHistorySubtitle =>
      'ஸ்கேன் செய்யப்பட்ட டிக்கெட்டுகளைப் பார்வையிடவும்';

  @override
  String get quickActionPredictionSubtitle =>
      'புத்திசாலி எண் தகவல்களைப் பார்க்கவும்';

  @override
  String get smartTicketScanner => 'ஸ்மார்ட் டிக்கெட் ஸ்கேனர்';

  @override
  String scanResultsVerifiedInSeconds(Object takePhotoLabel) {
    return '$takePhotoLabel. சில விநாடிகளில் முடிவுகள் சரிபார்க்கப்படும்.';
  }

  @override
  String get howItWorks => 'இது எப்படி செயல்படுகிறது';

  @override
  String get howItWorksStep1 =>
      'உங்கள் லாட்டரி டிக்கெட்டின் தெளிவான புகைப்படம் எடுக்கவும்';

  @override
  String get howItWorksStep2 =>
      'OCR தொழில்நுட்பத்தை பயன்படுத்தி எண்களை எடுக்கிறோம்';

  @override
  String get howItWorksStep3 => 'அதிகாரப்பூர்வ முடிவுகளுடன் ஒப்பிடவும்';

  @override
  String get howItWorksStep4 => 'உடனடி வெற்றி அறிவிப்புகளைப் பெறவும்';

  @override
  String get signLabel => 'ராசி';

  @override
  String get seedResultTitle => 'Mahajana முடிவுகள் தயாராக உள்ளன';

  @override
  String get seedResultMessage =>
      'Draw #2345 கிடைக்கிறது. இப்போது உங்கள் டிக்கெட்டைச் சரிபார்க்கவும்.';

  @override
  String get seedWinTitle => 'வெற்றி டிக்கெட் கண்டறியப்பட்டது';

  @override
  String get seedWinMessage =>
      'உங்கள் Mega Power டிக்கெட் பரிசு வென்றுள்ளது. விவரங்களுக்கு தட்டவும்.';

  @override
  String get seedScanTitle => 'ஸ்கேன் முடிந்தது';

  @override
  String get seedScanMessage =>
      'உங்கள் டிக்கெட் எண்களை எடுத்தோம். சரிபார்ப்பதற்கு முன் அவற்றைப் பார்வையிடவும்.';

  @override
  String get cameraPermissionDenied =>
      'டிக்கெட்டுகளை ஸ்கேன் செய்ய கேமரா அனுமதி தேவை';

  @override
  String get storagePermissionDenied => 'சேமிப்பக அனுமதி தேவை';

  @override
  String get grantPermission => 'அனுமதி வழங்கு';

  @override
  String get imageQualityLow =>
      'படத்தின் தரம் மிகக் குறைவு. தயவுசெய்து புகைப்படத்தை மீண்டும் எடுக்கவும்';

  @override
  String get noTextDetected => 'படத்தில் உரை கண்டறியப்படவில்லை';

  @override
  String get invalidTicket => 'தவறான லாட்டரி டிக்கெட்';

  @override
  String get couldNotDetectLotteryType => 'லாட்டரி வகையைக் கண்டறிய முடியவில்லை';

  @override
  String get fetchingResults => 'சமீபத்திய முடிவுகளைப் பெறுகிறது...';

  @override
  String get resultNotFound => 'இந்த டிராவுக்கான முடிவுகள் கிடைக்கவில்லை';

  @override
  String get noInternetConnection => 'இணைய இணைப்பு இல்லை';

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
