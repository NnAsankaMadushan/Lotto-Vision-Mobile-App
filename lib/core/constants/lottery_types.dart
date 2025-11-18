/// Sri Lankan Lottery Types
enum LotteryType {
  mahajana('Mahajana Sampatha'),
  govisetha('Govisetha'),
  dhanaNidhanaya('Dhana Nidhanaya'),
  jathika('Jathika Sampatha'),
  megaPower('Mega Power'),
  shanida('Shanida'),
  vasana('Vasana Sampatha'),
  unknown('Unknown');

  final String displayName;
  const LotteryType(this.displayName);

  static LotteryType fromString(String name) {
    return LotteryType.values.firstWhere(
      (type) => type.displayName.toLowerCase().contains(name.toLowerCase()) ||
          name.toLowerCase().contains(type.displayName.toLowerCase()),
      orElse: () => LotteryType.unknown,
    );
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
