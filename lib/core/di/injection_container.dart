import 'package:get_it/get_it.dart';
import 'package:lotto_vision/data/datasources/local_datasource.dart';
import 'package:lotto_vision/data/datasources/remote_datasource.dart';
import 'package:lotto_vision/data/repositories/lottery_repository_impl.dart';
import 'package:lotto_vision/domain/repositories/lottery_repository.dart';
import 'package:lotto_vision/domain/usecases/check_ticket.dart';
import 'package:lotto_vision/domain/usecases/get_all_tickets.dart';
import 'package:lotto_vision/domain/usecases/scan_ticket.dart';
import 'package:lotto_vision/services/lottery/lottery_results_service.dart';
import 'package:lotto_vision/services/lottery/ticket_checker.dart';
import 'package:lotto_vision/services/ocr/lottery_parser.dart';
import 'package:lotto_vision/services/ocr/ocr_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton(() => OCRService());
  sl.registerLazySingleton(() => LotteryParser());
  sl.registerLazySingleton(() => LotteryResultsService());
  sl.registerLazySingleton(() => TicketChecker());

  // Data sources
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(
      ocrService: sl(),
      lotteryParser: sl(),
      resultsService: sl(),
    ),
  );

  sl.registerLazySingleton<LocalDataSource>(() => LocalDataSourceImpl());

  // Repository
  sl.registerLazySingleton<LotteryRepository>(
    () => LotteryRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      ticketChecker: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => ScanTicket(sl()));
  sl.registerLazySingleton(() => CheckTicket(sl()));
  sl.registerLazySingleton(() => GetAllTickets(sl()));

  // Initialize local database
  await (sl<LocalDataSource>() as LocalDataSourceImpl).init();
}
