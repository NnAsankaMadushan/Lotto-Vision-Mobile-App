import 'package:lotto_vision/core/utils/typedefs.dart';
import 'package:lotto_vision/domain/entities/lottery_ticket.dart';
import 'package:lotto_vision/domain/repositories/lottery_repository.dart';

class ScanTicket {
  final LotteryRepository repository;

  const ScanTicket(this.repository);

  ResultFuture<(LotteryTicket, CheckResult?)> call(String imagePath) async {
    return await repository.scanTicket(imagePath);
  }
}
