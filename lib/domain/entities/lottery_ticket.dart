import 'package:equatable/equatable.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';

class LotteryTicket extends Equatable {
  final String id;
  final LotteryType lotteryType;
  final int drawNumber;
  final DateTime drawDate;
  final List<List<int>> numberSets;
  final String? serialNumber;
  final String? barcode;
  final String? imageUrl;
  final DateTime scannedAt;
  final bool isChecked;
  final CheckResult? checkResult;

  const LotteryTicket({
    required this.id,
    required this.lotteryType,
    required this.drawNumber,
    required this.drawDate,
    required this.numberSets,
    this.serialNumber,
    this.barcode,
    this.imageUrl,
    required this.scannedAt,
    this.isChecked = false,
    this.checkResult,
  });

  LotteryTicket copyWith({
    String? id,
    LotteryType? lotteryType,
    int? drawNumber,
    DateTime? drawDate,
    List<List<int>>? numberSets,
    String? serialNumber,
    String? barcode,
    String? imageUrl,
    DateTime? scannedAt,
    bool? isChecked,
    CheckResult? checkResult,
  }) {
    return LotteryTicket(
      id: id ?? this.id,
      lotteryType: lotteryType ?? this.lotteryType,
      drawNumber: drawNumber ?? this.drawNumber,
      drawDate: drawDate ?? this.drawDate,
      numberSets: numberSets ?? this.numberSets,
      serialNumber: serialNumber ?? this.serialNumber,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      scannedAt: scannedAt ?? this.scannedAt,
      isChecked: isChecked ?? this.isChecked,
      checkResult: checkResult ?? this.checkResult,
    );
  }

  @override
  List<Object?> get props => [
        id,
        lotteryType,
        drawNumber,
        drawDate,
        numberSets,
        serialNumber,
        barcode,
        imageUrl,
        scannedAt,
        isChecked,
        checkResult,
      ];
}

class CheckResult extends Equatable {
  final bool isWinner;
  final double totalWinnings;
  final List<WinningMatch> matches;
  final DateTime checkedAt;

  const CheckResult({
    required this.isWinner,
    required this.totalWinnings,
    required this.matches,
    required this.checkedAt,
  });

  @override
  List<Object?> get props => [isWinner, totalWinnings, matches, checkedAt];
}

class WinningMatch extends Equatable {
  final int setIndex;
  final List<int> matchedNumbers;
  final int matchCount;
  final String prizeName;
  final double prizeAmount;

  const WinningMatch({
    required this.setIndex,
    required this.matchedNumbers,
    required this.matchCount,
    required this.prizeName,
    required this.prizeAmount,
  });

  @override
  List<Object?> get props => [setIndex, matchedNumbers, matchCount, prizeName, prizeAmount];
}
