import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/core/utils/typedefs.dart';
import 'package:lotto_vision/domain/entities/lottery_result.dart';
import 'package:lotto_vision/domain/entities/lottery_ticket.dart';

abstract class LotteryRepository {
  // Ticket operations
  ResultFuture<(LotteryTicket, CheckResult?)> scanTicket(String imagePath);
  ResultFuture<List<LotteryTicket>> getAllTickets();
  ResultFuture<LotteryTicket> getTicketById(String id);
  ResultVoid saveTicket(LotteryTicket ticket);
  ResultVoid deleteTicket(String id);

  // Results operations
  ResultFuture<LotteryResult> fetchLatestResult(LotteryType type);
  ResultFuture<LotteryResult> fetchResultByDraw(LotteryType type, int drawNumber);
  ResultFuture<List<LotteryResult>> getAllResults();
  ResultVoid cacheResult(LotteryResult result);

  // Check ticket against results
  ResultFuture<CheckResult> checkTicket(LotteryTicket ticket);
}
