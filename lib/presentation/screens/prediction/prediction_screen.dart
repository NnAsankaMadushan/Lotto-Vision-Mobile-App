import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/core/di/injection_container.dart';
import 'package:lotto_vision/core/errors/failures.dart';
import 'package:lotto_vision/domain/entities/lottery_prediction.dart';
import 'package:lotto_vision/domain/usecases/generate_predictions.dart';
import 'package:lotto_vision/services/lottery/lottery_history_service.dart';

final List<LotteryType> _predictionTypes = (() {
  final types = LotteryConfig.configs.keys.toList();
  types.sort((a, b) => a.displayName.compareTo(b.displayName));
  return types;
})();

@immutable
class _PredictionQuery {
  final LotteryType type;
  final int sets;
  final int historyLimit;
  final int seed;

  const _PredictionQuery({
    required this.type,
    required this.sets,
    required this.historyLimit,
    required this.seed,
  });

  @override
  bool operator ==(Object other) =>
      other is _PredictionQuery &&
      other.type == type &&
      other.sets == sets &&
      other.historyLimit == historyLimit &&
      other.seed == seed;

  @override
  int get hashCode => Object.hash(type, sets, historyLimit, seed);
}

final _predictionProvider =
    FutureProvider.autoDispose.family<PredictionResult, _PredictionQuery>(
  (ref, query) async {
    final usecase = sl<GeneratePredictions>();
    final result = await usecase(
      type: query.type,
      sets: query.sets,
      maxHistory: query.historyLimit,
      seed: query.seed,
    );
    return result.fold(
      (failure) => throw failure,
      (prediction) => prediction,
    );
  },
);

class PredictionScreen extends ConsumerStatefulWidget {
  const PredictionScreen({super.key});

  @override
  ConsumerState<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends ConsumerState<PredictionScreen> {
  late LotteryType _selectedType;
  int _sets = 5;
  int _historyLimit = 60;
  int _seedBump = 0;
  bool _isSyncing = false;
  String? _lastSyncLabel;

  @override
  void initState() {
    super.initState();
    _selectedType = _predictionTypes.isNotEmpty
        ? _predictionTypes.first
        : LotteryType.mahajana;
  }

  int _dailySeed(LotteryType type) {
    final now = DateTime.now();
    final base = (now.year * 10000) + (now.month * 100) + now.day;
    return base + ((type.index + 1) * 1000000) + _seedBump;
  }

  Future<void> _syncHistory() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    final service = sl<LotteryHistoryService>();
    try {
      final report = await service.syncLastDraws(
        type: _selectedType,
        draws: 100,
      );

      final label =
          'Synced ${report.saved}/${report.requested} from ${report.source}';
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _lastSyncLabel = label;
          _seedBump += 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(label)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('History sync failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _PredictionQuery(
      type: _selectedType,
      sets: _sets,
      historyLimit: _historyLimit,
      seed: _dailySeed(_selectedType),
    );
    final predictionAsync = ref.watch(_predictionProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _InfoCard(),
            const SizedBox(height: 16),
            _ControlsCard(
              selectedType: _selectedType,
              sets: _sets,
              historyLimit: _historyLimit,
              isSyncing: _isSyncing,
              lastSyncLabel: _lastSyncLabel,
              onTypeChanged: (value) {
                if (value == null) return;
                setState(() => _selectedType = value);
              },
              onSetsChanged: (value) {
                if (value == null) return;
                setState(() => _sets = value);
              },
              onHistoryChanged: (value) {
                if (value == null) return;
                setState(() => _historyLimit = value);
              },
              onRegenerate: () {
                setState(() => _seedBump += 1);
              },
              onSyncHistory: _syncHistory,
            ),
            const SizedBox(height: 16),
            predictionAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => _ErrorState(
                message: _errorMessage(error),
                onRetry: () => ref.invalidate(_predictionProvider(query)),
              ),
              data: (prediction) => _PredictionContent(
                prediction: prediction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Predictions are statistical suggestions based on cached draw history. '
                'Lottery outcomes are random and no model can guarantee a win.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlsCard extends StatelessWidget {
  final LotteryType selectedType;
  final int sets;
  final int historyLimit;
  final bool isSyncing;
  final String? lastSyncLabel;
  final ValueChanged<LotteryType?> onTypeChanged;
  final ValueChanged<int?> onSetsChanged;
  final ValueChanged<int?> onHistoryChanged;
  final VoidCallback onRegenerate;
  final VoidCallback onSyncHistory;

  const _ControlsCard({
    required this.selectedType,
    required this.sets,
    required this.historyLimit,
    required this.isSyncing,
    required this.lastSyncLabel,
    required this.onTypeChanged,
    required this.onSetsChanged,
    required this.onHistoryChanged,
    required this.onRegenerate,
    required this.onSyncHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prediction settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<LotteryType>(
              value: selectedType,
              items: [
                for (final type in _predictionTypes)
                  DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  ),
              ],
              onChanged: onTypeChanged,
              decoration: const InputDecoration(
                labelText: 'Lottery',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: sets,
                    items: const [
                      DropdownMenuItem(value: 3, child: Text('3 sets')),
                      DropdownMenuItem(value: 5, child: Text('5 sets')),
                      DropdownMenuItem(value: 8, child: Text('8 sets')),
                    ],
                    onChanged: onSetsChanged,
                    decoration: const InputDecoration(
                      labelText: 'Number of sets',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: historyLimit,
                    items: const [
                      DropdownMenuItem(value: 20, child: Text('Last 20')),
                      DropdownMenuItem(value: 60, child: Text('Last 60')),
                      DropdownMenuItem(value: 120, child: Text('Last 120')),
                    ],
                    onChanged: onHistoryChanged,
                    decoration: const InputDecoration(
                      labelText: 'History depth',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onRegenerate,
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerate'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSyncing ? null : onSyncHistory,
                    icon: isSyncing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_download_outlined),
                    label: Text(
                      isSyncing ? 'Syncing history...' : 'Sync last 100 draws',
                    ),
                  ),
                ),
              ],
            ),
            if (lastSyncLabel != null) ...[
              const SizedBox(height: 8),
              Text(
                lastSyncLabel!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PredictionContent extends StatelessWidget {
  final PredictionResult prediction;

  const _PredictionContent({
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    final dateRange = _formatHistoryRange(prediction);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SummaryCard(
          prediction: prediction,
          dateRange: dateRange,
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < prediction.sets.length; i++) ...[
          _PredictionSetCard(
            index: i,
            set: prediction.sets[i],
            sign: prediction.predictedSign,
          ),
          const SizedBox(height: 12),
        ],
        if (prediction.hotNumbers.isNotEmpty ||
            prediction.coldNumbers.isNotEmpty)
          _HotColdCard(
            hotNumbers: prediction.hotNumbers,
            coldNumbers: prediction.coldNumbers,
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final PredictionResult prediction;
  final String dateRange;

  const _SummaryCard({
    required this.prediction,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = prediction.isFallback
        ? 'No cached results yet. Showing random suggestions.'
        : 'Based on ${prediction.drawsUsed} cached draws ($dateRange).';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prediction.strategy,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}

class _PredictionSetCard extends StatelessWidget {
  final int index;
  final PredictionSet set;
  final String? sign;

  const _PredictionSetCard({
    required this.index,
    required this.set,
    required this.sign,
  });

  @override
  Widget build(BuildContext context) {
    final score = (set.score * 100).clamp(0, 100).toStringAsFixed(0);
    final normalizedSign = (sign ?? '').trim();
    final hasSign = normalizedSign.isNotEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Set ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  'Score $score%',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasSign) _SignBadge(sign: normalizedSign),
                if (hasSign) const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final n in set.numbers) _NumberChip(number: n),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HotColdCard extends StatelessWidget {
  final List<int> hotNumbers;
  final List<int> coldNumbers;

  const _HotColdCard({
    required this.hotNumbers,
    required this.coldNumbers,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Number trends',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (hotNumbers.isNotEmpty) ...[
              Text(
                'Hot numbers',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final n in hotNumbers) _NumberChip(number: n),
                ],
              ),
            ],
            if (coldNumbers.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Cold numbers',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final n in coldNumbers) _NumberChip(number: n),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NumberChip extends StatelessWidget {
  final int number;

  const _NumberChip({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF5B400),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        number.toString().padLeft(2, '0'),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SignBadge extends StatelessWidget {
  final String sign;
  const _SignBadge({required this.sign});

  @override
  Widget build(BuildContext context) {
    final zodiacUrl = _zodiacIconUrl(sign);
    if (zodiacUrl != null) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF2F6FDE),
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: CachedNetworkImage(
            imageUrl: zodiacUrl,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => const SizedBox(width: 36, height: 36),
          ),
        ),
      );
    }

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF2F6FDE),
        shape: BoxShape.circle,
      ),
      child: Text(
        _signFallbackLetter(sign),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }
}

String? _zodiacIconUrl(String sign) {
  final normalized =
      sign.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '').trim();
  const urls = <String, String>{
    'aries':
        'https://lakpura.com/cdn/shop/files/LKI9255924-01-E_1f745fc1-2b2a-4de7-bba4-f30ca81e3d6c.jpg?v=1655362824&width=750',
    'taurus':
        'https://lakpura.com/cdn/shop/files/LKI9255919-01-E_aeae55c4-ce72-4494-94f8-4868fe3db15f.jpg?v=1655362676&width=750',
    'gemini':
        'https://lakpura.com/cdn/shop/files/LKI9255920-01-E_c365d7c3-2099-47e9-b7f5-5a34210340a6.jpg?v=1655362699&width=750',
    'cancer':
        'https://lakpura.com/cdn/shop/files/LKI9255921-01-E_1a01da09-d298-44cd-a781-242f06bbd3f2.jpg?v=1655362715&width=750',
    'leo':
        'https://lakpura.com/cdn/shop/files/LKI9255939-01-E_66b61f4b-f459-4392-8af7-20f90f7bd2ea.jpg?v=1655362909&width=750',
    'virgo':
        'https://lakpura.com/cdn/shop/files/LKI9255940-01-E_6a784b0a-df93-4e8f-8b7c-ed6591485525.jpg?v=1655362999&width=750',
    'libra':
        'https://lakpura.com/cdn/shop/files/LKI9255918-01-E_6a3a8a60-f4c1-43eb-897a-9624a7c9ae94.jpg?v=1655362623&width=750',
    'scorpio':
        'https://lakpura.com/cdn/shop/files/LKI9255925-01-E_30d0a5fd-114d-4fcf-843b-75343c4efd4e.jpg?v=1655362891&width=750',
    'sagittarius':
        'https://lakpura.com/cdn/shop/files/LKI9255927-01-E_0fe3e99b-51a6-4fe0-9b10-f6b5ffc60699.jpg?v=1655362948&width=750',
    'capricorn':
        'https://lakpura.com/cdn/shop/files/LKI9255928-01-E_9bd3f62c-360a-4db2-8a03-58bae621a66e.jpg?v=1655362969&width=750',
    'aquarius':
        'https://lakpura.com/cdn/shop/files/LKI9255941-01-E_994881db-0aca-4343-8302-1f3f051456c5.jpg?v=1655363014&width=750',
    'pisces':
        'https://lakpura.com/cdn/shop/files/LKI9255929-01-E_0c2fb07c-7091-4ed4-89cf-a83a15a4a36b.jpg?v=1655362985&width=750',
  };
  return urls[normalized];
}

String _signFallbackLetter(String sign) {
  final trimmed = sign.trim();
  if (trimmed.isEmpty) return '?';
  if (trimmed.length == 1) return trimmed.toUpperCase();
  final upper = trimmed.toUpperCase();
  return upper.length <= 2 ? upper : upper.substring(0, 2);
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prediction failed',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _errorMessage(Object error) {
  if (error is Failure) {
    return error.message;
  }
  return error.toString();
}

String _formatHistoryRange(PredictionResult prediction) {
  final start = prediction.historyStart;
  final end = prediction.historyEnd;
  if (start == null || end == null) {
    return 'no history';
  }
  final formatter = DateFormat.yMMMd();
  return '${formatter.format(start)} - ${formatter.format(end)}';
}
