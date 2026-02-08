import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/domain/entities/lottery_result.dart';
import 'package:lotto_vision/domain/entities/lottery_ticket.dart';

class TicketChecker {
  CheckResult checkTicket(LotteryTicket ticket, LotteryResult result) {
    if (ticket.lotteryType != result.lotteryType) {
      throw ArgumentError('Lottery types do not match');
    }

    if (ticket.drawNumber != result.drawNumber) {
      throw ArgumentError('Draw numbers do not match');
    }

    final List<WinningMatch> matches = [];
    double totalWinnings = 0.0;
    bool letterMatched = false;

    // Check lucky letter/zodiac
    if (ticket.luckyLetter != null && result.luckyLetter != null) {
      if (ticket.luckyLetter!.trim().toUpperCase() == result.luckyLetter!.trim().toUpperCase()) {
        letterMatched = true;
      }
    }

    // Check each number set
    for (int i = 0; i < ticket.numberSets.length; i++) {
      final numberSet = ticket.numberSets[i];
      final matchedNumbers = numberSet
          .where((num) => result.winningNumbers.contains(num))
          .toList();

      if (matchedNumbers.isNotEmpty || (i == 0 && letterMatched)) {
        final match = _calculatePrize(
          matchedNumbers.length,
          matchedNumbers,
          i,
          ticket.lotteryType,
          result,
          letterMatched: i == 0 ? letterMatched : false,
        );

        if (match != null) {
          matches.add(match);
          totalWinnings += match.prizeAmount;
        }
      }
    }

    return CheckResult(
      isWinner: matches.isNotEmpty || letterMatched,
      totalWinnings: totalWinnings,
      matches: matches,
      checkedAt: DateTime.now(),
      winningResult: result,
    );
  }

  WinningMatch? _calculatePrize(
    int matchCount,
    List<int> matchedNumbers,
    int setIndex,
    LotteryType lotteryType,
    LotteryResult result, {
    bool letterMatched = false,
  }) {
    final config = LotteryConfig.getConfig(lotteryType);
    if (config == null) return null;

    // Special handling for letter-only prize if it exists in config
    // For now, let's look for a prize named 'Letter' or something similar if matchCount is 0
    
    // Find the prize tier for this match count
    Prize? prize;
    try {
      prize = config.prizes.firstWhere((p) => p.match == matchCount);
    } catch (_) {
      // If no exact match prize, but letter matched, maybe there's a letter prize
      if (letterMatched) {
        prize = const Prize(match: 0, name: 'Lucky Letter', estimatedAmount: 20);
      }
    }

    if (prize == null || (prize.match == 0 && !letterMatched)) return null;

    // Try to get actual prize amount from result, otherwise use estimated
    final prizeAmount = result.prizes[prize.name] ?? prize.estimatedAmount;

    return WinningMatch(
      setIndex: setIndex,
      matchedNumbers: matchedNumbers,
      matchCount: matchCount,
      prizeName: prize.name,
      prizeAmount: prizeAmount,
    );
  }

  /// Calculate probability of winning
  Map<String, double> calculateProbability(LotteryType lotteryType) {
    final config = LotteryConfig.getConfig(lotteryType);
    if (config == null) return {};

    final Map<String, double> probabilities = {};

    for (var prize in config.prizes) {
      final probability = _combinatorial(config.numbersCount, prize.match) /
          _combinatorial(config.maxNumber, config.numbersCount);
      probabilities[prize.name] = probability;
    }

    return probabilities;
  }

  /// Calculate combinations (n choose k)
  double _combinatorial(int n, int k) {
    if (k > n) return 0;
    if (k == 0 || k == n) return 1;

    double result = 1;
    for (int i = 0; i < k; i++) {
      result *= (n - i);
      result /= (i + 1);
    }
    return result;
  }

  /// Get winning statistics
  Map<String, dynamic> getWinningStats(List<LotteryTicket> tickets) {
    int totalTickets = tickets.length;
    int winningTickets = tickets.where((t) => t.checkResult?.isWinner ?? false).length;
    double totalWinnings = tickets
        .where((t) => t.checkResult != null)
        .fold(0.0, (sum, t) => sum + (t.checkResult!.totalWinnings));

    return {
      'totalTickets': totalTickets,
      'winningTickets': winningTickets,
      'winRate': totalTickets > 0 ? (winningTickets / totalTickets) : 0.0,
      'totalWinnings': totalWinnings,
      'averageWinning': winningTickets > 0 ? (totalWinnings / winningTickets) : 0.0,
    };
  }
}
