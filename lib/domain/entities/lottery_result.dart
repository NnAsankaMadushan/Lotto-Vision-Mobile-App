import 'package:equatable/equatable.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';

class LotteryResult extends Equatable {
  final String id;
  final LotteryType lotteryType;
  final int drawNumber;
  final DateTime drawDate;
  final List<int> winningNumbers;
  final String? luckyLetter;
  final int? bonusNumber;
  final Map<String, double> prizes;
  final DateTime fetchedAt;

  const LotteryResult({
    required this.id,
    required this.lotteryType,
    required this.drawNumber,
    required this.drawDate,
    required this.winningNumbers,
    this.luckyLetter,
    this.bonusNumber,
    required this.prizes,
    required this.fetchedAt,
  });

  @override
  List<Object?> get props => [
        id,
        lotteryType,
        drawNumber,
        drawDate,
        winningNumbers,
        luckyLetter,
        bonusNumber,
        prizes,
        fetchedAt,
      ];
}
