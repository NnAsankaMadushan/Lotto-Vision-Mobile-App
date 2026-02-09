import 'dart:math';

import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/domain/entities/lottery_prediction.dart';
import 'package:lotto_vision/domain/entities/lottery_result.dart';

class LotteryPredictionEngine {
  final double decay;
  final double baseScore;
  final double lastDrawPenalty;
  final double diversityPenalty;
  final int hotCount;
  final int coldCount;

  const LotteryPredictionEngine({
    this.decay = 0.97,
    this.baseScore = 0.12,
    this.lastDrawPenalty = 0.85,
    this.diversityPenalty = 0.9,
    this.hotCount = 10,
    this.coldCount = 10,
  });

  PredictionResult generate({
    required LotteryType type,
    required List<LotteryResult> history,
    int sets = 5,
    int maxHistory = 60,
    int? seed,
  }) {
    final config = LotteryConfig.getConfig(type);
    if (config == null) {
      throw ArgumentError('No lottery config for ${type.name}');
    }

    final rng = Random(seed ?? DateTime.now().millisecondsSinceEpoch);

    final filtered = history
        .where((r) => r.lotteryType == type)
        .toList()
      ..sort((a, b) => b.drawDate.compareTo(a.drawDate));

    final limited = (maxHistory > 0 && filtered.length > maxHistory)
        ? filtered.take(maxHistory).toList()
        : filtered;

    if (limited.isEmpty) {
      final fallbackSets = _generateUniformSets(config, rng, sets);
      return PredictionResult(
        lotteryType: type,
        generatedAt: DateTime.now(),
        drawsUsed: 0,
        historyStart: null,
        historyEnd: null,
        strategy: 'Uniform random (no history available)',
        sets: fallbackSets,
        hotNumbers: const [],
        coldNumbers: const [],
        predictedSign: null,
        isFallback: true,
      );
    }

    final scores = _scoreNumbers(config, limited);
    final scoreEntries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final hotNumbers = scoreEntries
        .take(min(hotCount, scoreEntries.length))
        .map((e) => e.key)
        .toList();
    final coldNumbers = scoreEntries
        .reversed
        .take(min(coldCount, scoreEntries.length))
        .map((e) => e.key)
        .toList();

    final predictedSign = _predictSign(limited);

    final maxScore = scoreEntries.isEmpty ? 1.0 : scoreEntries.first.value;
    final usage = <int, int>{};
    final setsOut = <PredictionSet>[];

    for (var i = 0; i < max(1, sets); i++) {
      final adjusted = Map<int, double>.from(scores);
      for (final entry in usage.entries) {
        adjusted[entry.key] =
            adjusted[entry.key]! * pow(diversityPenalty, entry.value);
      }

      final numbers = _weightedSample(
        adjusted,
        config.numbersCount,
        rng,
      )..sort();

      for (final n in numbers) {
        usage[n] = (usage[n] ?? 0) + 1;
      }

      final score = numbers.isEmpty
          ? 0.0
          : numbers
                  .map((n) => scores[n]! / maxScore)
                  .reduce((a, b) => a + b) /
              numbers.length;

      setsOut.add(
        PredictionSet(
          numbers: numbers,
          score: score,
        ),
      );
    }

    final historyStart = limited.last.drawDate;
    final historyEnd = limited.first.drawDate;

    return PredictionResult(
      lotteryType: type,
      generatedAt: DateTime.now(),
      drawsUsed: limited.length,
      historyStart: historyStart,
      historyEnd: historyEnd,
      strategy: 'Weighted frequency with recency decay',
      sets: setsOut,
      hotNumbers: hotNumbers,
      coldNumbers: coldNumbers,
      predictedSign: predictedSign,
      isFallback: false,
    );
  }

  Map<int, double> _scoreNumbers(
    LotteryConfig config,
    List<LotteryResult> history,
  ) {
    final scores = <int, double>{
      for (var n = config.minNumber; n <= config.maxNumber; n++) n: baseScore
    };

    for (var i = 0; i < history.length; i++) {
      final draw = history[i];
      final weight = pow(decay, i).toDouble();
      final uniqueNumbers = draw.winningNumbers.toSet();
      for (final n in uniqueNumbers) {
        final current = scores[n];
        if (current != null) {
          scores[n] = current + weight;
        }
      }
    }

    if (history.isNotEmpty) {
      final recentNumbers = history.first.winningNumbers.toSet();
      for (final n in recentNumbers) {
        final current = scores[n];
        if (current != null) {
          scores[n] = max(baseScore, current * lastDrawPenalty);
        }
      }
    }

    return scores;
  }

  String? _predictSign(List<LotteryResult> history) {
    final scores = <String, double>{};
    final display = <String, String>{};

    for (var i = 0; i < history.length; i++) {
      final raw = history[i].luckyLetter;
      if (raw == null) continue;
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      final key = _normalizeSign(trimmed);
      final weight = pow(decay, i).toDouble();
      scores[key] = (scores[key] ?? 0) + weight;
      display.putIfAbsent(key, () => _formatSign(trimmed));
    }

    if (scores.isEmpty) return null;

    String? bestKey;
    double bestScore = -1;
    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestKey = entry.key;
      }
    }

    if (bestKey == null) return null;
    return display[bestKey] ?? bestKey;
  }

  String _normalizeSign(String sign) {
    return sign.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _formatSign(String sign) {
    final trimmed = sign.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.length == 1) return trimmed.toUpperCase();
    return trimmed;
  }

  List<PredictionSet> _generateUniformSets(
    LotteryConfig config,
    Random rng,
    int sets,
  ) {
    final setsOut = <PredictionSet>[];
    for (var i = 0; i < max(1, sets); i++) {
      final numbers = _uniformSample(config, rng)..sort();
      setsOut.add(
        PredictionSet(
          numbers: numbers,
          score: 0.0,
        ),
      );
    }
    return setsOut;
  }

  List<int> _uniformSample(LotteryConfig config, Random rng) {
    final pool = [
      for (var n = config.minNumber; n <= config.maxNumber; n++) n
    ];
    pool.shuffle(rng);
    return pool.take(config.numbersCount).toList();
  }

  List<int> _weightedSample(
    Map<int, double> weights,
    int count,
    Random rng,
  ) {
    final selected = <int>[];
    final pool = Map<int, double>.from(weights);

    while (selected.length < count && pool.isNotEmpty) {
      final total = pool.values.fold(0.0, (sum, v) => sum + v);
      int? pick;

      if (total <= 0) {
        final keys = pool.keys.toList();
        pick = keys[rng.nextInt(keys.length)];
      } else {
        var roll = rng.nextDouble() * total;
        for (final entry in pool.entries) {
          roll -= entry.value;
          if (roll <= 0) {
            pick = entry.key;
            break;
          }
        }
        pick ??= pool.keys.first;
      }

      selected.add(pick);
      pool.remove(pick);
    }

    return selected;
  }
}
