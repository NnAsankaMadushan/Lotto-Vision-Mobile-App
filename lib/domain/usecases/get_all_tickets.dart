import 'package:lotto_vision/core/utils/typedefs.dart';
import 'package:lotto_vision/domain/entities/lottery_ticket.dart';
import 'package:lotto_vision/domain/repositories/lottery_repository.dart';

class GetAllTickets {
  final LotteryRepository repository;

  const GetAllTickets(this.repository);

  ResultFuture<List<LotteryTicket>> call() async {
    return await repository.getAllTickets();
  }
}
