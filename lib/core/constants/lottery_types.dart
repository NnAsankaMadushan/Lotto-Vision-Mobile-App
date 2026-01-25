import 'package:lotto_vision/l10n/app_localizations.dart';

/// Sri Lankan Lottery Types
enum LotteryType {
  adaSampatha('Ada Sampatha', 'lotteryAdaSampatha'),
  daruDiriSampatha('Daru Diri Sampatha', 'lotteryDaruDiriSampatha'),
  delakshapathi('Delakshapathi Double Dreams', 'lotteryDelakshapathi'),
  dhanaNidhanaya('Dhana Nidhanaya', 'lotteryDhanaNidhanaya'),
  dollarFortune('Dollar Fortune', 'lotteryDollarFortune'),
  govisetha('Govisetha', 'lotteryGovisetha'),
  handahana('Handahana', 'lotteryHandahana'),
  jathika('Jathika Sampatha', 'lotteryJathika'),
  mahajana('Mahajana Sampatha', 'lotteryMahajana'),
  mega60('Mega 60', 'lotteryMega60'),
  megaMillions('Mega Millions', 'lotteryMegaMillions'),
  megaPower('Mega Power', 'lotteryMegaPower'),
  neeroga('Neeroga Lagna Jaya', 'lotteryNeeroga'),
  nlbJaya('NLB Jaya', 'lotteryNlbJaya'),
  sampathRekha('Sampath Rekha', 'lotterySampathRekha'),
  sampathaLagnaVarama('Sampatha Lagna Varama', 'lotterySampathaLagnaVarama'),
  sevana('Sevana', 'lotterySevana'),
  shanida('Shanida', 'lotteryShanida'),
  subaDawasak('Suba Dawasak', 'lotterySubaDawasak'),
  superFifty('Vasana Super Fifty', 'lotterySuperFifty'),
  supiriVasana('Supiri Vasana', 'lotterySupiriVasana'),
  vasana('Vasana Sampatha', 'lotteryVasana'),
  unknown('Unknown', 'lotteryUnknown');

  final String displayName;
  final String l10nKey;
  const LotteryType(this.displayName, this.l10nKey);

  static String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');

  static LotteryType fromString(String name) {
    final n = _normalize(name);
    return LotteryType.values.firstWhere(
      (type) =>
          _normalize(type.displayName).contains(n) ||
          n.contains(_normalize(type.displayName)),
      orElse: () => LotteryType.unknown,
    );
  }
}

String getLotteryDisplayName(LotteryType type, AppLocalizations l10n) {
  switch (type) {
    case LotteryType.adaSampatha:
      return l10n.lotteryAdaSampatha;
    case LotteryType.daruDiriSampatha:
      return l10n.lotteryDaruDiriSampatha;
    case LotteryType.delakshapathi:
      return l10n.lotteryDelakshapathi;
    case LotteryType.dhanaNidhanaya:
      return l10n.lotteryDhanaNidhanaya;
    case LotteryType.dollarFortune:
      return l10n.lotteryDollarFortune;
    case LotteryType.govisetha:
      return l10n.lotteryGovisetha;
    case LotteryType.handahana:
      return l10n.lotteryHandahana;
    case LotteryType.jathika:
      return l10n.lotteryJathika;
    case LotteryType.mahajana:
      return l10n.lotteryMahajana;
    case LotteryType.mega60:
      return l10n.lotteryMega60;
    case LotteryType.megaMillions:
      return l10n.lotteryMegaMillions;
    case LotteryType.megaPower:
      return l10n.lotteryMegaPower;
    case LotteryType.neeroga:
      return l10n.lotteryNeeroga;
    case LotteryType.nlbJaya:
      return l10n.lotteryNlbJaya;
    case LotteryType.sampathRekha:
      return l10n.lotterySampathRekha;
    case LotteryType.sampathaLagnaVarama:
      return l10n.lotterySampathaLagnaVarama;
    case LotteryType.sevana:
      return l10n.lotterySevana;
    case LotteryType.shanida:
      return l10n.lotteryShanida;
    case LotteryType.subaDawasak:
      return l10n.lotterySubaDawasak;
    case LotteryType.superFifty:
      return l10n.lotterySuperFifty;
    case LotteryType.supiriVasana:
      return l10n.lotterySupiriVasana;
    case LotteryType.vasana:
      return l10n.lotteryVasana;
    case LotteryType.unknown:
      return l10n.lotteryUnknown;
  }
}

class LotteryConfig {
  final LotteryType type;
  final int numbersCount;
  final int minNumber;
  final int maxNumber;
  final List<Prize> prizes;

  const LotteryConfig({
    required this.type,
    required this.numbersCount,
    required this.minNumber,
    required this.maxNumber,
    required this.prizes,
  });

  static final Map<LotteryType, LotteryConfig> configs = {
    LotteryType.mahajana: const LotteryConfig(
      type: LotteryType.mahajana,
      numbersCount: 6,
      minNumber: 1,
      maxNumber: 42,
      prizes: [
        Prize(match: 6, name: 'Jackpot', estimatedAmount: 50000000),
        Prize(match: 5, name: '2nd Prize', estimatedAmount: 500000),
        Prize(match: 4, name: '3rd Prize', estimatedAmount: 10000),
        Prize(match: 3, name: '4th Prize', estimatedAmount: 1000),
      ],
    ),
    LotteryType.govisetha: const LotteryConfig(
      type: LotteryType.govisetha,
      numbersCount: 5,
      minNumber: 1,
      maxNumber: 40,
      prizes: [
        Prize(match: 5, name: 'Jackpot', estimatedAmount: 25000000),
        Prize(match: 4, name: '2nd Prize', estimatedAmount: 250000),
        Prize(match: 3, name: '3rd Prize', estimatedAmount: 5000),
      ],
    ),
    LotteryType.megaPower: const LotteryConfig(
      type: LotteryType.megaPower,
      numbersCount: 6,
      minNumber: 1,
      maxNumber: 45,
      prizes: [
        Prize(match: 6, name: 'Jackpot', estimatedAmount: 100000000),
        Prize(match: 5, name: '2nd Prize', estimatedAmount: 1000000),
        Prize(match: 4, name: '3rd Prize', estimatedAmount: 20000),
        Prize(match: 3, name: '4th Prize', estimatedAmount: 2000),
      ],
    ),
  };

  static LotteryConfig? getConfig(LotteryType type) => configs[type];
}

class Prize {
  final int match;
  final String name;
  final double estimatedAmount;

  const Prize({
    required this.match,
    required this.name,
    required this.estimatedAmount,
  });
}
