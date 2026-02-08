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
  String get history => 'வரலாறு';

  @override
  String get results => 'முடிவுகள்';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get notifications => 'அறிவிப்புகள்';

  @override
  String get scanTicket => 'லாட்டரி டிக்கெட்டை ஸ்கேன் செய்';

  @override
  String get takePhoto => 'புகைப்படம் எடுக்க';

  @override
  String get chooseFromGallery => 'கேலரியிலிருந்து தேர்வு செய்';

  @override
  String get scanning => 'ஸ்கேன் செய்கிறது...';

  @override
  String get processing => 'செயலாக்குகிறது...';

  @override
  String get checkingResults => 'முடிவுகளை சரிபார்க்கிறது...';

  @override
  String get winner => 'வெற்றியாளர்!';

  @override
  String get notWinner => 'வெற்றியாளர் இல்லை';

  @override
  String get congratulations => 'வாழ்த்துக்கள்!';

  @override
  String youWon(Object amount) {
    return 'நீங்கள் ரூ. $amount வென்றீர்கள்';
  }

  @override
  String matchedNumbers(Object count) {
    return '$count எண்கள் பொருந்தின';
  }

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
  String get yourNumbers => 'உங்கள் எண்கள்';

  @override
  String get lotteryType => 'லாட்டரி வகை';

  @override
  String get serialNumber => 'வரிசை எண்';

  @override
  String get checkTicket => 'டிக்கெட்டை சரிபார்';

  @override
  String get deleteTicket => 'டிக்கெட்டை அழி';

  @override
  String get noTickets => 'இன்னும் டிக்கெட்டுகள் ஸ்கேன் செய்யப்படவில்லை';

  @override
  String get noResults => 'முடிவுகள் இல்லை';

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
  String get language => 'மொழி';

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
  String get version => 'பதிப்பு';

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
  String get lotterySuperFifty => 'Vasana Super Fifty';

  @override
  String get lotterySupiriVasana => 'Supiri Vasana';

  @override
  String get lotteryVasana => 'Vasana Sampatha';

  @override
  String get lotteryUnknown => 'Unknown';
}
