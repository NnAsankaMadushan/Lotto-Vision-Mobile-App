import 'package:equatable/equatable.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';

class PredictionSet extends Equatable {
  final List<int> numbers;
  final double score;

  const PredictionSet({
    required this.numbers,
    required this.score,
  });

  @override
  List<Object?> get props => [numbers, score];
}

class PredictionResult extends Equatable {
  final LotteryType lotteryType;
  final DateTime generatedAt;
  final int drawsUsed;
  final DateTime? historyStart;
  final DateTime? historyEnd;
  final String strategy;
  final List<PredictionSet> sets;
  final List<int> hotNumbers;
  final List<int> coldNumbers;
  final String? predictedSign;
  final List<String> predictedSigns;
  final bool isFallback;

  const PredictionResult({
    required this.lotteryType,
    required this.generatedAt,
    required this.drawsUsed,
    required this.historyStart,
    required this.historyEnd,
    required this.strategy,
    required this.sets,
    required this.hotNumbers,
    required this.coldNumbers,
    required this.predictedSign,
    required this.predictedSigns,
    required this.isFallback,
  });

  @override
  List<Object?> get props => [
        lotteryType,
        generatedAt,
        drawsUsed,
        historyStart,
        historyEnd,
        strategy,
        sets,
        hotNumbers,
        coldNumbers,
        predictedSign,
        predictedSigns,
        isFallback,
      ];
}
