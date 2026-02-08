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
  String get history => 'ඉතිහාසය';

  @override
  String get results => 'ප්‍රතිඵල';

  @override
  String get settings => 'සැකසුම්';

  @override
  String get notifications => 'නිවේදන';

  @override
  String get scanTicket => 'ලොතරැයි ටිකට් පත ස්කෑන් කරන්න';

  @override
  String get takePhoto => 'ඡායාරූපයක් ගන්න';

  @override
  String get chooseFromGallery => 'ගැලරියෙන් තෝරන්න';

  @override
  String get scanning => 'ස්කෑන් කරමින්...';

  @override
  String get processing => 'සකසමින්...';

  @override
  String get checkingResults => 'ප්‍රතිඵල පරීක්ෂා කරමින්...';

  @override
  String get winner => 'ජයග්‍රාහකයා!';

  @override
  String get notWinner => 'ජයග්‍රාහකයෙක් නොවේ';

  @override
  String get congratulations => 'සුබ පැතුම්!';

  @override
  String youWon(Object amount) {
    return 'ඔබ රු. $amount ක් දිනා ඇත';
  }

  @override
  String matchedNumbers(Object count) {
    return 'අංක $count ක් ගැලපේ';
  }

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
  String get yourNumbers => 'ඔබේ අංක';

  @override
  String get lotteryType => 'ලොතරැයි වර්ගය';

  @override
  String get serialNumber => 'අනුක්‍රමික අංකය';

  @override
  String get checkTicket => 'ටිකට් පත පරීක්ෂා කරන්න';

  @override
  String get deleteTicket => 'ටිකට් පත මකන්න';

  @override
  String get noTickets => 'තවම ටිකට් පත් ස්කෑන් කර නැත';

  @override
  String get noResults => 'ප්‍රතිඵල නොමැත';

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
  String get language => 'භාෂාව';

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
  String get version => 'අනුවාදය';

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
  String get lotterySuperFifty => 'වසන සුපර් පණ්ඩෑස්';

  @override
  String get lotterySupiriVasana => 'සුපිරි වසන';

  @override
  String get lotteryVasana => 'වසන සම්පත';

  @override
  String get lotteryUnknown => 'නොදනී';
}
