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
  String get history => 'History';

  @override
  String get results => 'Results';

  @override
  String get settings => 'Settings';

  @override
  String get scanTicket => 'Scan Lottery Ticket';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get scanning => 'Scanning...';

  @override
  String get processing => 'Processing...';

  @override
  String get checkingResults => 'Checking Results...';

  @override
  String get winner => 'Winner!';

  @override
  String get notWinner => 'Not a Winner';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String youWon(Object amount) {
    return 'You won LKR $amount';
  }

  @override
  String matchedNumbers(Object count) {
    return 'Matched $count numbers';
  }

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
  String get yourNumbers => 'Your Numbers';

  @override
  String get lotteryType => 'Lottery Type';

  @override
  String get serialNumber => 'Serial Number';

  @override
  String get checkTicket => 'Check Ticket';

  @override
  String get deleteTicket => 'Delete Ticket';

  @override
  String get noTickets => 'No tickets scanned yet';

  @override
  String get noResults => 'No results available';

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
  String get language => 'Language';

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
  String get version => 'Version';

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
