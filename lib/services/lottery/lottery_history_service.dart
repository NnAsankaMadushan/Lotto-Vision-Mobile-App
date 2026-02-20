import 'package:flutter/foundation.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/data/datasources/local_datasource.dart';
import 'package:lotto_vision/domain/entities/lottery_result.dart';
import 'package:lotto_vision/services/lottery/dlb_results_service.dart';
import 'package:lotto_vision/services/lottery/lottery_results_service.dart';

class HistorySyncReport {
  final LotteryType type;
  final String source;
  final int requested;
  final int saved;
  final int attempts;
  final int pagesScanned;

  const HistorySyncReport({
    required this.type,
    required this.source,
    required this.requested,
    required this.saved,
    required this.attempts,
    required this.pagesScanned,
  });
}

class LotteryHistoryService {
  final LotteryResultsService nlbResultsService;
  final DlbResultsService dlbResultsService;
  final LocalDataSource localDataSource;

  const LotteryHistoryService({
    required this.nlbResultsService,
    required this.dlbResultsService,
    required this.localDataSource,
  });

  Future<HistorySyncReport> syncLastDraws({
    required LotteryType type,
    int draws = 100,
  }) async {
    if (_isDlbType(type)) {
      return _syncDlb(type, draws);
    }
    return _syncNlb(type, draws);
  }

  Future<List<LotteryResult>> getCachedHistory({
    required LotteryType type,
    int limit = 100,
  }) async {
    final all = await localDataSource.getAllResults();
    final filtered = all.where((r) => r.lotteryType == type).toList()
      ..sort((a, b) {
        final byDate = b.drawDate.compareTo(a.drawDate);
        if (byDate != 0) return byDate;
        return b.drawNumber.compareTo(a.drawNumber);
      });

    if (limit <= 0 || filtered.length <= limit) {
      return filtered;
    }
    return filtered.take(limit).toList();
  }

  bool _isDlbType(LotteryType type) {
    return type == LotteryType.adaKotipathi ||
        type == LotteryType.shanida ||
        type == LotteryType.lagnaWasana ||
        type == LotteryType.superBall;
  }

  Future<HistorySyncReport> _syncNlb(
    LotteryType type,
    int draws,
  ) async {
    var attempts = 0;
    var saved = 0;

    try {
      attempts++;
      final history = await nlbResultsService.fetchHistoryResults(
        type,
        limit: draws,
      );
      if (history.isNotEmpty) {
        await localDataSource.clearResultsByType(type);
      }
      for (final result in history) {
        await localDataSource.cacheResult(result);
        saved++;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HistorySync][NLB] history parse failed type=${type.name} err=$e');
      }
    }

    if (saved == 0) {
      attempts++;
      final latest = await nlbResultsService.fetchLatestResult(type);
      await localDataSource.cacheResult(latest);
      saved = 1;
    }

    return HistorySyncReport(
      type: type,
      source: 'NLB',
      requested: draws,
      saved: saved,
      attempts: attempts,
      pagesScanned: 0,
    );
  }

  Future<HistorySyncReport> _syncDlb(
    LotteryType type,
    int draws,
  ) async {
    int saved = 0;
    int pagesScanned = 0;
    int attempts = 0;
    final seenDraws = <int>{};
    var clearedTypeCache = false;

    await localDataSource.clearResultsByType(type);
    clearedTypeCache = true;

    try {
      final batch = await dlbResultsService.fetchHistoryForType(
        type,
        limit: draws,
        maxPages: draws + 40,
      );
      attempts += batch.attempts;
      pagesScanned += batch.pagesFetched;

      if (batch.results.isNotEmpty) {
        await localDataSource.clearResultsByType(type);
        clearedTypeCache = true;
      }
      for (final item in batch.results) {
        if (!seenDraws.add(item.drawNumber)) continue;
        final result = _toLotteryResult(type, item);
        await localDataSource.cacheResult(result);
        saved++;
        if (saved >= draws) break;
      }

      if (saved >= draws || saved > 0) {
        return HistorySyncReport(
          type: type,
          source: 'DLB',
          requested: draws,
          saved: saved,
          attempts: attempts,
          pagesScanned: pagesScanned,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HistorySync][DLB] modern flow failed type=${type.name} err=$e');
      }
    }

    final maxPages = draws + 20;
    List<String> paths = const [];
    try {
      paths = await dlbResultsService.fetchHistoryPathsForType(
        type,
        maxPages: maxPages,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HistorySync][DLB] failed to resolve history paths type=${type.name} err=$e');
      }
    }

    if (paths.isEmpty) {
      for (int page = 1; page <= maxPages && saved < draws; page++) {
        attempts++;
        List<DlbResultWithMeta> pageResults;
        try {
          pageResults = await dlbResultsService.fetchResultsPage(page);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[HistorySync][DLB] page=$page fetch failed type=${type.name} err=$e');
          }
          continue;
        }

        pagesScanned++;
        for (final item in pageResults) {
          final mappedType = LotteryType.fromString(item.name);
          if (mappedType != LotteryType.unknown && mappedType != type) {
            continue;
          }
          if (item.drawNumber <= 0) continue;
          if (!seenDraws.add(item.drawNumber)) continue;
          if (!clearedTypeCache) {
            await localDataSource.clearResultsByType(type);
            clearedTypeCache = true;
          }
          final result = _toLotteryResult(type, item);
          await localDataSource.cacheResult(result);
          saved++;
          if (saved >= draws) break;
        }
      }
    } else {
      for (final path in paths) {
        if (saved >= draws) break;
        attempts++;
        List<DlbResultWithMeta> pageResults;
        try {
          pageResults = await dlbResultsService.fetchResultsByPath(path);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[HistorySync][DLB] path=$path fetch failed type=${type.name} err=$e');
          }
          continue;
        }

        pagesScanned++;
        for (final item in pageResults) {
          final mappedType = LotteryType.fromString(item.name);
          if (mappedType != LotteryType.unknown && mappedType != type) {
            continue;
          }
          if (item.drawNumber <= 0) continue;
          if (!seenDraws.add(item.drawNumber)) continue;
          if (!clearedTypeCache) {
            await localDataSource.clearResultsByType(type);
            clearedTypeCache = true;
          }
          final result = _toLotteryResult(type, item);
          await localDataSource.cacheResult(result);
          saved++;
          if (saved >= draws) break;
        }
      }
    }

    return HistorySyncReport(
      type: type,
      source: 'DLB',
      requested: draws,
      saved: saved,
      attempts: attempts,
      pagesScanned: pagesScanned,
    );
  }

  LotteryResult _toLotteryResult(
    LotteryType type,
    DlbResultWithMeta item,
  ) {
    final numbers = <int>[];
    for (final value in item.values) {
      final n = int.tryParse(value);
      if (n != null) numbers.add(n);
    }

    final config = LotteryConfig.getConfig(type);
    final winningNumbers =
        config == null ? numbers : numbers.take(config.numbersCount).toList();

    final sign = (item.sign ?? '').trim().isEmpty
        ? item.values.firstWhere(
            (v) => int.tryParse(v) == null,
            orElse: () => '',
          )
        : item.sign;

    return LotteryResult(
      id: '${type.name}_${item.drawNumber}',
      lotteryType: type,
      drawNumber: item.drawNumber,
      drawDate: item.drawDate,
      winningNumbers: winningNumbers,
      luckyLetter: (sign == null || sign.trim().isEmpty) ? null : sign,
      prizes: {
        for (final p in (config?.prizes ?? const <Prize>[]))
          p.name: p.estimatedAmount,
      },
      fetchedAt: DateTime.now(),
    );
  }
}
