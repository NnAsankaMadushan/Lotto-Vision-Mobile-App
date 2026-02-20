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
  final int shortWindow;
  final int longWindow;
  final int trainingEpochs;
  final double learningRate;
  final double l2Penalty;

  const LotteryPredictionEngine({
    this.decay = 0.97,
    this.baseScore = 0.05,
    this.lastDrawPenalty = 0.85,
    this.diversityPenalty = 0.9,
    this.hotCount = 10,
    this.coldCount = 10,
    this.shortWindow = 12,
    this.longWindow = 60,
    this.trainingEpochs = 14,
    this.learningRate = 0.14,
    this.l2Penalty = 0.0008,
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

    final filtered = history
        .where((r) => r.lotteryType == type)
        .toList()
      ..sort((a, b) => b.drawDate.compareTo(a.drawDate));

    final limited = (maxHistory > 0 && filtered.length > maxHistory)
        ? filtered.take(maxHistory).toList()
        : filtered;

    if (limited.isEmpty) {
      return PredictionResult(
        lotteryType: type,
        generatedAt: DateTime.now(),
        drawsUsed: 0,
        historyStart: null,
        historyEnd: null,
        strategy: 'No cached history available',
        sets: const [],
        hotNumbers: const [],
        coldNumbers: const [],
        predictedSign: null,
        predictedSigns: const [],
        isFallback: true,
      );
    }

    final rng = Random(seed ?? DateTime.now().millisecondsSinceEpoch);
    final chronological = limited.reversed.toList(growable: false);
    final numberScores = _scoreNumbersWithModel(config, chronological);
    final scoreEntries = numberScores.entries.toList()
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

    final signPredictionCount = max(max(1, sets) * 2, 8);
    final predictedSigns = _predictSignCandidates(
      limited,
      top: signPredictionCount,
    );
    final predictedSign = predictedSigns.isEmpty ? null : predictedSigns.first;

    final maxScore = scoreEntries.isEmpty ? 1.0 : scoreEntries.first.value;
    final usage = <int, int>{};
    final setsOut = <PredictionSet>[];

    for (var i = 0; i < max(1, sets); i++) {
      final numbers = _generateDiverseNumbers(
        config: config,
        baseScores: numberScores,
        existingSets: setsOut,
        usage: usage,
        historyLatestFirst: limited,
        rng: rng,
      )..sort();

      if (numbers.length < config.numbersCount) {
        continue;
      }

      for (final n in numbers) {
        usage[n] = (usage[n] ?? 0) + 1;
      }

      final score = numbers
              .map((n) => numberScores[n]! / maxScore)
              .reduce((a, b) => a + b) /
          numbers.length;

      setsOut.add(
        PredictionSet(
          numbers: numbers,
          score: score,
        ),
      );
    }

    if (setsOut.isEmpty) {
      final fallbackNumbers = _weightedSample(
        numberScores,
        config.numbersCount,
        rng,
      )..sort();

      for (final n in fallbackNumbers) {
        usage[n] = (usage[n] ?? 0) + 1;
      }

      final fallbackScore = fallbackNumbers
              .map((n) => numberScores[n]! / maxScore)
              .reduce((a, b) => a + b) /
          fallbackNumbers.length;

      setsOut.add(
        PredictionSet(
          numbers: fallbackNumbers,
          score: fallbackScore,
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
      strategy: 'ML ensemble (past-draw trends + diversity constraints)',
      sets: setsOut,
      hotNumbers: hotNumbers,
      coldNumbers: coldNumbers,
      predictedSign: predictedSign,
      predictedSigns: predictedSigns,
      isFallback: false,
    );
  }

  Map<int, double> _scoreNumbersWithModel(
    LotteryConfig config,
    List<LotteryResult> historyChronological,
  ) {
    final weights = _trainLogisticWeights(config, historyChronological);
    final recencyScores = _buildRecencyScores(config, historyChronological);

    final recencyValues = recencyScores.values.toList(growable: false);
    final recencyMin =
        recencyValues.isEmpty ? 0.0 : recencyValues.reduce(min).toDouble();
    final recencyMax =
        recencyValues.isEmpty ? 1.0 : recencyValues.reduce(max).toDouble();

    final totalNumbers = config.maxNumber - config.minNumber + 1;
    final prior = config.numbersCount / max(1, totalNumbers);
    final predictIndex = historyChronological.length;

    final output = <int, double>{};
    for (var n = config.minNumber; n <= config.maxNumber; n++) {
      final features = _buildNumberFeatures(
        historyChronological,
        predictIndex,
        n,
      );
      final mlProb = _sigmoid(_dot(weights, features));
      final recency = recencyScores[n] ?? baseScore;
      final normalizedRecency = (recencyMax - recencyMin).abs() < 1e-9
          ? 0.5
          : (recency - recencyMin) / (recencyMax - recencyMin);
      var score = (mlProb * 0.65) + (normalizedRecency * 0.25) + (prior * 0.1);

      if (features[4] > 0.5) {
        score *= lastDrawPenalty;
      }
      output[n] = max(0.0001, score + (baseScore * 0.02));
    }

    return output;
  }

  List<double> _trainLogisticWeights(
    LotteryConfig config,
    List<LotteryResult> historyChronological,
  ) {
    const featureCount = 6;
    final weights = List<double>.filled(featureCount, 0.0);

    if (historyChronological.length < 3) {
      return weights;
    }

    for (var epoch = 0; epoch < max(1, trainingEpochs); epoch++) {
      for (var targetIdx = 1;
          targetIdx < historyChronological.length;
          targetIdx++) {
        final targetNumbers = historyChronological[targetIdx].winningNumbers.toSet();

        for (var n = config.minNumber; n <= config.maxNumber; n++) {
          final features = _buildNumberFeatures(
            historyChronological,
            targetIdx,
            n,
          );
          final y = targetNumbers.contains(n) ? 1.0 : 0.0;
          final prediction = _sigmoid(_dot(weights, features));
          final error = prediction - y;

          for (var j = 0; j < weights.length; j++) {
            final gradient = (error * features[j]) + (l2Penalty * weights[j]);
            weights[j] -= learningRate * gradient;
          }
        }
      }
    }

    return weights;
  }

  Map<int, double> _buildRecencyScores(
    LotteryConfig config,
    List<LotteryResult> historyChronological,
  ) {
    final scores = <int, double>{
      for (var n = config.minNumber; n <= config.maxNumber; n++) n: baseScore,
    };

    for (var i = 0; i < historyChronological.length; i++) {
      final draw = historyChronological[historyChronological.length - 1 - i];
      final weight = pow(decay, i).toDouble();
      final uniqueNumbers = draw.winningNumbers.toSet();
      for (final n in uniqueNumbers) {
        final current = scores[n];
        if (current != null) {
          scores[n] = current + weight;
        }
      }
    }

    return scores;
  }

  List<double> _buildNumberFeatures(
    List<LotteryResult> historyChronological,
    int upToExclusive,
    int number,
  ) {
    final effectiveLongWindow = max(1, min(longWindow, upToExclusive));
    final effectiveShortWindow = max(1, min(shortWindow, upToExclusive));
    var shortHits = 0;
    var longHits = 0;
    int? lastSeenGap;

    for (var offset = 1; offset <= effectiveLongWindow; offset++) {
      final draw = historyChronological[upToExclusive - offset];
      final hit = draw.winningNumbers.contains(number);
      if (!hit) continue;

      longHits++;
      if (offset <= effectiveShortWindow) {
        shortHits++;
      }
      lastSeenGap ??= offset - 1;
    }

    final shortFreq = shortHits / effectiveShortWindow;
    final longFreq = longHits / effectiveLongWindow;
    final gap = (lastSeenGap ?? effectiveLongWindow).toDouble();
    final gapNorm = min(gap, effectiveLongWindow.toDouble()) / effectiveLongWindow;
    final inLastDraw = upToExclusive > 0 &&
            historyChronological[upToExclusive - 1].winningNumbers.contains(number)
        ? 1.0
        : 0.0;
    final trend = shortFreq - longFreq;

    return <double>[
      1.0,
      shortFreq,
      longFreq,
      gapNorm,
      inLastDraw,
      trend,
    ];
  }

  List<String> _predictSignCandidates(
    List<LotteryResult> history, {
    int top = 3,
  }) {
    final scores = <String, double>{};
    final display = <String, String>{};

    for (var i = 0; i < history.length; i++) {
      final key = _extractSignKey(history[i].luckyLetter);
      if (key == null) continue;
      final recencyWeight = pow(decay, i).toDouble();
      scores[key] = (scores[key] ?? 0) + (recencyWeight * 1.4);
      display.putIfAbsent(key, () => _formatSign(history[i].luckyLetter!));
    }

    final chronological = history.reversed.toList(growable: false);
    final transitions = <String, Map<String, int>>{};
    for (var i = 0; i < chronological.length - 1; i++) {
      final from = _extractSignKey(chronological[i].luckyLetter);
      final to = _extractSignKey(chronological[i + 1].luckyLetter);
      if (from == null || to == null) continue;
      final bucket = transitions.putIfAbsent(from, () => <String, int>{});
      bucket[to] = (bucket[to] ?? 0) + 1;
      display.putIfAbsent(from, () => _formatSign(chronological[i].luckyLetter!));
      display.putIfAbsent(to, () => _formatSign(chronological[i + 1].luckyLetter!));
    }

    String? latestKey;
    for (final draw in history) {
      latestKey = _extractSignKey(draw.luckyLetter);
      if (latestKey != null) break;
    }

    if (latestKey != null) {
      final nextCandidates = transitions[latestKey];
      if (nextCandidates != null && nextCandidates.isNotEmpty) {
        final total = nextCandidates.values.fold<int>(0, (sum, v) => sum + v);
        for (final entry in nextCandidates.entries) {
          final transitionWeight = entry.value / max(1, total);
          scores[entry.key] =
              (scores[entry.key] ?? 0) + (transitionWeight * 2.0);
          display.putIfAbsent(entry.key, () => _displayFromSignKey(entry.key));
        }
      }
    }

    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (ranked.isEmpty) {
      return const [];
    }

    return ranked
        .take(max(1, top))
        .map((e) => display[e.key] ?? _displayFromSignKey(e.key))
        .toList(growable: false);
  }

  String? _extractSignKey(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return _normalizeSign(trimmed);
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

  String _displayFromSignKey(String key) {
    if (key.length == 1) return key.toUpperCase();
    return key
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) => '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  double _dot(List<double> weights, List<double> features) {
    var total = 0.0;
    final length = min(weights.length, features.length);
    for (var i = 0; i < length; i++) {
      total += weights[i] * features[i];
    }
    return total;
  }

  double _sigmoid(double x) {
    if (x >= 0) {
      final z = exp(-x);
      return 1.0 / (1.0 + z);
    }
    final z = exp(x);
    return z / (1.0 + z);
  }

  List<int> _generateDiverseNumbers({
    required LotteryConfig config,
    required Map<int, double> baseScores,
    required List<PredictionSet> existingSets,
    required Map<int, int> usage,
    required List<LotteryResult> historyLatestFirst,
    required Random rng,
  }) {
    final recentPatterns = historyLatestFirst
        .take(min(40, historyLatestFirst.length))
        .map((r) => r.winningNumbers.toSet())
        .toList(growable: false);
    final minDifferent = max(2, (config.numbersCount / 2).ceil());
    final maxOverlapAllowed = max(1, config.numbersCount - minDifferent);

    for (var attempt = 0; attempt < 90; attempt++) {
      final temperature = 1.0 + (attempt * 0.05);
      final adjusted = <int, double>{};
      for (final entry in baseScores.entries) {
        final used = usage[entry.key] ?? 0;
        final usageFactor = pow(diversityPenalty, used).toDouble();
        final tempered = pow(max(entry.value, 0.0001), 1.0 / temperature);
        adjusted[entry.key] = max(0.0001, tempered.toDouble() * usageFactor);
      }

      final candidate = _weightedSample(
        adjusted,
        config.numbersCount,
        rng,
      )..sort();
      if (candidate.length < config.numbersCount) continue;
      if (_isTooSimilarToExisting(candidate, existingSets, maxOverlapAllowed)) {
        continue;
      }
      if (_matchesRecentHistory(candidate, recentPatterns)) {
        continue;
      }
      return candidate;
    }

    final fallbackScores = <int, double>{};
    for (final entry in baseScores.entries) {
      final used = usage[entry.key] ?? 0;
      fallbackScores[entry.key] = max(
        0.0001,
        entry.value * pow(diversityPenalty, used + 2).toDouble(),
      );
    }
    return _weightedSample(
      fallbackScores,
      config.numbersCount,
      rng,
    )..sort();
  }

  bool _isTooSimilarToExisting(
    List<int> candidate,
    List<PredictionSet> existingSets,
    int maxOverlapAllowed,
  ) {
    if (existingSets.isEmpty) return false;
    final candidateSet = candidate.toSet();
    for (final set in existingSets) {
      final overlap = set.numbers.where(candidateSet.contains).length;
      if (overlap > maxOverlapAllowed) {
        return true;
      }
    }
    return false;
  }

  bool _matchesRecentHistory(
    List<int> candidate,
    List<Set<int>> recentPatterns,
  ) {
    if (recentPatterns.isEmpty) return false;
    final candidateSet = candidate.toSet();
    for (final pattern in recentPatterns) {
      if (pattern.length == candidateSet.length &&
          pattern.containsAll(candidateSet)) {
        return true;
      }
    }
    return false;
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
