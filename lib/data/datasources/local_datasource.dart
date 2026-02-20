import 'package:hive/hive.dart';
import 'package:lotto_vision/core/constants/app_constants.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/core/errors/exceptions.dart';
import 'package:lotto_vision/data/models/lottery_result_model.dart';
import 'package:lotto_vision/data/models/lottery_ticket_model.dart';
import 'package:lotto_vision/domain/entities/lottery_result.dart';
import 'package:lotto_vision/domain/entities/lottery_ticket.dart';

abstract class LocalDataSource {
  Future<void> cacheTicket(LotteryTicket ticket);
  Future<List<LotteryTicket>> getAllTickets();
  Future<LotteryTicket> getTicketById(String id);
  Future<void> deleteTicket(String id);

  Future<void> cacheResult(LotteryResult result);
  Future<List<LotteryResult>> getAllResults();
  Future<LotteryResult?> getResultByDraw(LotteryType type, int drawNumber);
  Future<void> clearResultsByType(LotteryType type);
}

class LocalDataSourceImpl implements LocalDataSource {
  late Box<LotteryTicketModel> _ticketsBox;
  late Box<LotteryResultModel> _resultsBox;

  Future<void> init() async {
    _ticketsBox = await Hive.openBox<LotteryTicketModel>(AppConstants.ticketsBox);
    _resultsBox = await Hive.openBox<LotteryResultModel>(AppConstants.resultsBox);
  }

  @override
  Future<void> cacheTicket(LotteryTicket ticket) async {
    try {
      final model = LotteryTicketModel.fromEntity(ticket);
      await _ticketsBox.put(ticket.id, model);
    } catch (e) {
      throw CacheException('Failed to cache ticket: ${e.toString()}');
    }
  }

  @override
  Future<List<LotteryTicket>> getAllTickets() async {
    try {
      final tickets = _ticketsBox.values.map((model) => model.toEntity()).toList();
      // Sort by scanned date, most recent first
      tickets.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      return tickets;
    } catch (e) {
      throw CacheException('Failed to get tickets: ${e.toString()}');
    }
  }

  @override
  Future<LotteryTicket> getTicketById(String id) async {
    try {
      final model = _ticketsBox.get(id);
      if (model == null) {
        throw const CacheException('Ticket not found');
      }
      return model.toEntity();
    } catch (e) {
      throw CacheException('Failed to get ticket: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTicket(String id) async {
    try {
      await _ticketsBox.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete ticket: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheResult(LotteryResult result) async {
    try {
      final model = LotteryResultModel.fromEntity(result);
      await _resultsBox.put(result.id, model);
    } catch (e) {
      throw CacheException('Failed to cache result: ${e.toString()}');
    }
  }

  @override
  Future<List<LotteryResult>> getAllResults() async {
    try {
      final results = _resultsBox.values.map((model) => model.toEntity()).toList();
      // Sort by draw date, most recent first
      results.sort((a, b) => b.drawDate.compareTo(a.drawDate));
      return results;
    } catch (e) {
      throw CacheException('Failed to get results: ${e.toString()}');
    }
  }

  @override
  Future<LotteryResult?> getResultByDraw(LotteryType type, int drawNumber) async {
    try {
      final key = '${type.name}_$drawNumber';
      final model = _resultsBox.get(key);
      return model?.toEntity();
    } catch (e) {
      throw CacheException('Failed to get result: ${e.toString()}');
    }
  }

  @override
  Future<void> clearResultsByType(LotteryType type) async {
    try {
      final keysToDelete = <dynamic>[];
      for (final key in _resultsBox.keys) {
        final model = _resultsBox.get(key);
        if (model == null) continue;
        if (model.lotteryTypeName == type.name) {
          keysToDelete.add(key);
        }
      }
      if (keysToDelete.isNotEmpty) {
        await _resultsBox.deleteAll(keysToDelete);
      }
    } catch (e) {
      throw CacheException('Failed to clear results: ${e.toString()}');
    }
  }
}
