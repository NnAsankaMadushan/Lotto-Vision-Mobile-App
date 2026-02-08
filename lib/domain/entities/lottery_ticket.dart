import 'package:equatable/equatable.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/data/models/lottery_result_model.dart';
import 'package:lotto_vision/domain/entities/lottery_result.dart';

class LotteryTicket extends Equatable {
  final String id;
  final LotteryType lotteryType;
  final int drawNumber;
  final DateTime drawDate;
  final List<List<int>> numberSets;
  final String? luckyLetter;
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
    this.luckyLetter,
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
    String? luckyLetter,
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
      luckyLetter: luckyLetter ?? this.luckyLetter,
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
        luckyLetter,
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
  final LotteryResult? winningResult;

  const CheckResult({
    required this.isWinner,
    required this.totalWinnings,
    required this.matches,
    required this.checkedAt,
    this.winningResult,
  });

  Map<String, dynamic> toMap() {
    return {
      'isWinner': isWinner,
      'totalWinnings': totalWinnings,
      'matches': matches.map((m) => m.toMap()).toList(),
      'checkedAt': checkedAt.toIso8601String(),
      'winningResult': winningResult != null ? LotteryResultModel.fromEntity(winningResult!).toMap() : null,
    };
  }

  factory CheckResult.fromMap(Map<String, dynamic> map) {
    return CheckResult(
      isWinner: map['isWinner'] as bool,
      totalWinnings: (map['totalWinnings'] as num).toDouble(),
      matches: (map['matches'] as List).map((m) => WinningMatch.fromMap(m as Map<String, dynamic>)).toList(),
      checkedAt: DateTime.parse(map['checkedAt'] as String),
      winningResult: map['winningResult'] != null ? LotteryResultModel.fromMap(map['winningResult'] as Map<String, dynamic>).toEntity() : null,
    );
  }

  @override
  List<Object?> get props => [isWinner, totalWinnings, matches, checkedAt, winningResult];
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

  Map<String, dynamic> toMap() {
    return {
      'setIndex': setIndex,
      'matchedNumbers': matchedNumbers,
      'matchCount': matchCount,
      'prizeName': prizeName,
      'prizeAmount': prizeAmount,
    };
  }

  factory WinningMatch.fromMap(Map<String, dynamic> map) {
    return WinningMatch(
      setIndex: map['setIndex'] as int,
      matchedNumbers: (map['matchedNumbers'] as List).map((n) => n as int).toList(),
      matchCount: map['matchCount'] as int,
      prizeName: map['prizeName'] as String,
      prizeAmount: (map['prizeAmount'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [setIndex, matchedNumbers, matchCount, prizeName, prizeAmount];
}
