import 'package:dartz/dartz.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/core/errors/exceptions.dart';
import 'package:lotto_vision/core/errors/failures.dart';
import 'package:lotto_vision/core/utils/typedefs.dart';
import 'package:lotto_vision/data/datasources/local_datasource.dart';
import 'package:lotto_vision/data/datasources/remote_datasource.dart';
import 'package:lotto_vision/domain/entities/lottery_result.dart';
import 'package:lotto_vision/domain/entities/lottery_ticket.dart';
import 'package:lotto_vision/domain/repositories/lottery_repository.dart';
import 'package:lotto_vision/services/lottery/ticket_checker.dart';

class LotteryRepositoryImpl implements LotteryRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final TicketChecker ticketChecker;

  LotteryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.ticketChecker,
  });

  @override
  ResultFuture<LotteryTicket> scanTicket(String imagePath) async {
    try {
      final ticket = await remoteDataSource.scanTicket(imagePath);
      await localDataSource.cacheTicket(ticket);
      return Right(ticket);
    } on OCRException catch (e) {
      return Left(OCRFailure(e.message));
    } on ImageProcessingException catch (e) {
      return Left(ImageProcessingFailure(e.message));
    } on LotteryParseException catch (e) {
      return Left(LotteryParseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<LotteryTicket>> getAllTickets() async {
    try {
      final tickets = await localDataSource.getAllTickets();
      return Right(tickets);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  ResultFuture<LotteryTicket> getTicketById(String id) async {
    try {
      final ticket = await localDataSource.getTicketById(id);
      return Right(ticket);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  ResultVoid saveTicket(LotteryTicket ticket) async {
    try {
      await localDataSource.cacheTicket(ticket);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  ResultVoid deleteTicket(String id) async {
    try {
      await localDataSource.deleteTicket(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  ResultFuture<LotteryResult> fetchLatestResult(LotteryType type) async {
    try {
      final result = await remoteDataSource.fetchLatestResult(type);
      await localDataSource.cacheResult(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<LotteryResult> fetchResultByDraw(LotteryType type, int drawNumber) async {
    try {
      // Try cache first
      final cachedResult = await localDataSource.getResultByDraw(type, drawNumber);
      if (cachedResult != null) {
        return Right(cachedResult);
      }

      // Fetch from remote
      final result = await remoteDataSource.fetchResultByDraw(type, drawNumber);
      await localDataSource.cacheResult(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<LotteryResult>> getAllResults() async {
    try {
      final results = await localDataSource.getAllResults();
      return Right(results);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  ResultVoid cacheResult(LotteryResult result) async {
    try {
      await localDataSource.cacheResult(result);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  ResultFuture<CheckResult> checkTicket(LotteryTicket ticket) async {
    try {
      // Fetch the result for this ticket's draw
      final resultEither = await fetchResultByDraw(ticket.lotteryType, ticket.drawNumber);

      return resultEither.fold(
        (failure) => Left(failure),
        (result) {
          try {
            final checkResult = ticketChecker.checkTicket(ticket, result);
            return Right(checkResult);
          } catch (e) {
            return Left(ServerFailure('Failed to check ticket: ${e.toString()}'));
          }
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
