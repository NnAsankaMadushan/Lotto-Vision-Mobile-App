import 'package:hive/hive.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/core/utils/typedefs.dart';
import 'package:lotto_vision/domain/entities/lottery_result.dart';

part 'lottery_result_model.g.dart';

@HiveType(typeId: 1)
class LotteryResultModel extends LotteryResult {
  @HiveField(0)
  final String modelId;

  @HiveField(1)
  final String lotteryTypeName;

  @HiveField(2)
  final int modelDrawNumber;

  @HiveField(3)
  final DateTime modelDrawDate;

  @HiveField(4)
  final List<int> modelWinningNumbers;

  @HiveField(5)
  final String? modelLuckyLetter;

  @HiveField(6)
  final int? modelBonusNumber;

  @HiveField(7)
  final Map<String, double> modelPrizes;

  @HiveField(8)
  final DateTime modelFetchedAt;

  const LotteryResultModel({
    required this.modelId,
    required this.lotteryTypeName,
    required this.modelDrawNumber,
    required this.modelDrawDate,
    required this.modelWinningNumbers,
    this.modelLuckyLetter,
    this.modelBonusNumber,
    required this.modelPrizes,
    required this.modelFetchedAt,
  }) : super(
          id: modelId,
          lotteryType: LotteryType.unknown,
          drawNumber: modelDrawNumber,
          drawDate: modelDrawDate,
          winningNumbers: modelWinningNumbers,
          luckyLetter: modelLuckyLetter,
          bonusNumber: modelBonusNumber,
          prizes: modelPrizes,
          fetchedAt: modelFetchedAt,
        );

  factory LotteryResultModel.fromEntity(LotteryResult result) {
    return LotteryResultModel(
      modelId: result.id,
      lotteryTypeName: result.lotteryType.name,
      modelDrawNumber: result.drawNumber,
      modelDrawDate: result.drawDate,
      modelWinningNumbers: result.winningNumbers,
      modelLuckyLetter: result.luckyLetter,
      modelBonusNumber: result.bonusNumber,
      modelPrizes: result.prizes,
      modelFetchedAt: result.fetchedAt,
    );
  }

  LotteryResult toEntity() {
    return LotteryResult(
      id: modelId,
      lotteryType: LotteryType.values.firstWhere(
        (e) => e.name == lotteryTypeName,
        orElse: () => LotteryType.unknown,
      ),
      drawNumber: modelDrawNumber,
      drawDate: modelDrawDate,
      winningNumbers: modelWinningNumbers,
      luckyLetter: modelLuckyLetter,
      bonusNumber: modelBonusNumber,
      prizes: modelPrizes,
      fetchedAt: modelFetchedAt,
    );
  }

  factory LotteryResultModel.fromMap(DataMap map) {
    return LotteryResultModel(
      modelId: map['id'] as String,
      lotteryTypeName: map['lotteryType'] as String,
      modelDrawNumber: map['drawNumber'] as int,
      modelDrawDate: DateTime.parse(map['drawDate'] as String),
      modelWinningNumbers: (map['winningNumbers'] as List).map((n) => n as int).toList(),
      modelLuckyLetter: map['luckyLetter'] as String?,
      modelBonusNumber: map['bonusNumber'] as int?,
      modelPrizes: Map<String, double>.from(map['prizes'] as Map),
      modelFetchedAt: DateTime.parse(map['fetchedAt'] as String),
    );
  }

  DataMap toMap() {
    return {
      'id': modelId,
      'lotteryType': lotteryTypeName,
      'drawNumber': modelDrawNumber,
      'drawDate': modelDrawDate.toIso8601String(),
      'winningNumbers': modelWinningNumbers,
      'luckyLetter': modelLuckyLetter,
      'bonusNumber': modelBonusNumber,
      'prizes': modelPrizes,
      'fetchedAt': modelFetchedAt.toIso8601String(),
    };
  }
}
