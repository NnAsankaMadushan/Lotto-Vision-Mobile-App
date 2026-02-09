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

  bool _isDlbType(LotteryType type) {
    return type == LotteryType.shanida ||
        type == LotteryType.lagnaWasana ||
        type == LotteryType.superBall;
  }

  Future<HistorySyncReport> _syncNlb(
    LotteryType type,
    int draws,
  ) async {
    final latest = await nlbResultsService.fetchLatestResult(type);
    await localDataSource.cacheResult(latest);

    int saved = 1;
    int attempts = 0;

    final latestDraw = latest.drawNumber;
    final maxAttempts = draws * 2;

    for (int offset = 1; offset < draws && attempts < maxAttempts; offset++) {
      final drawNumber = latestDraw - offset;
      if (drawNumber <= 0) break;
      attempts++;

      try {
        final result =
            await nlbResultsService.fetchResultByDraw(type, drawNumber);
        await localDataSource.cacheResult(result);
        saved++;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[HistorySync][NLB] miss draw=$drawNumber type=${type.name} err=$e');
        }
      }
    }

    return HistorySyncReport(
      type: type,
      source: 'NLB',
      requested: draws,
      saved: saved,
      attempts: attempts + 1,
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

    final maxPages = draws + 20;
    for (int page = 1; page <= maxPages && saved < draws; page++) {
      attempts++;
      final pageResults = await dlbResultsService.fetchResultsPage(page);
      pagesScanned++;

      for (final item in pageResults) {
        final mappedType = LotteryType.fromString(item.name);
        if (mappedType != type) continue;
        if (!seenDraws.add(item.drawNumber)) continue;

        final result = _toLotteryResult(mappedType, item);
        await localDataSource.cacheResult(result);
        saved++;
        break;
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
