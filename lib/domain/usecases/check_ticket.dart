import 'package:lotto_vision/core/utils/typedefs.dart';
import 'package:lotto_vision/domain/entities/lottery_ticket.dart';
import 'package:lotto_vision/domain/repositories/lottery_repository.dart';

class CheckTicket {
  final LotteryRepository repository;

  const CheckTicket(this.repository);

  ResultFuture<CheckResult> call(LotteryTicket ticket) async {
    return await repository.checkTicket(ticket);
  }
}
