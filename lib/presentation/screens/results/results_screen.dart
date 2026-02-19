import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:lotto_vision/core/di/injection_container.dart';
import 'package:lotto_vision/services/lottery/dlb_results_service.dart';
import 'package:lotto_vision/services/lottery/lottery_results_service.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(_latestResultsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest Results'),
      ),
      body: SafeArea(
        child: resultsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _EmptyState(
            title: 'Failed to load results',
            subtitle: e.toString(),
            icon: Icons.error_outline,
            onRetry: () => ref.invalidate(_latestResultsProvider),
          ),
          data: (results) {
            if (results.isEmpty) {
              return _EmptyState(
                title: 'No results available',
                subtitle: 'Pull to refresh or try again later',
                icon: Icons.emoji_events_outlined,
                onRetry: () => ref.invalidate(_latestResultsProvider),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(_latestResultsProvider);
                await ref.read(_latestResultsProvider.future);
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _ResultCard(item: results[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

final _latestResultsProvider = FutureProvider<List<_ResultListItem>>((ref) async {
  final nlb = sl<LotteryResultsService>();
  final dlb = sl<DlbResultsService>();
  if (kDebugMode) {
    debugPrint('[Results] fetching all latest results (NLB + DLB)');
  }
  final nlbResults = await nlb.fetchAllLatestResultsWithMeta();
  final dlbResults = await dlb.fetchAllLatestResultsWithMeta();

  final items = <_ResultListItem>[
    for (final r in nlbResults)
      _ResultListItem(
        provider: _ResultProvider.nlb,
        title: r.result.lotteryType.displayName,
        drawNumber: r.result.drawNumber,
        drawDate: r.result.drawDate,
        numbers: r.result.winningNumbers.map((n) => n.toString()).toList(),
        sign: r.sign,
        logoUrl: r.logoUrl,
      ),
    for (final r in dlbResults)
      _ResultListItem(
        provider: _ResultProvider.dlb,
        title: r.name,
        drawNumber: r.drawNumber,
        drawDate: r.drawDate,
        numbers: r.values.where((v) => int.tryParse(v) != null).toList(),
        sign: r.sign,
        logoUrl: r.logoUrl,
      ),
  ];

  items.sort((a, b) => b.drawDate.compareTo(a.drawDate));
  if (kDebugMode) {
    debugPrint('[Results] done, count=${items.length}');
  }
  return items;
});

class _ResultCard extends StatelessWidget {
  final _ResultListItem item;
  const _ResultCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMMd().format(item.drawDate);
    final sign = (item.sign ?? '').trim();
    final hasSign = sign.isNotEmpty && int.tryParse(sign) == null;
    final useThreeRows = _usesThreeRowLayout(item.title);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _LotteryLogo(url: item.logoUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '#${item.drawNumber}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (useThreeRows)
              _ThreeRowNumbers(
                numbers: item.numbers,
                sign: hasSign ? sign : null,
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasSign) _SignBadge(sign: sign),
                  if (hasSign) const SizedBox(width: 10),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var i = 0; i < item.numbers.length; i++)
                          _NumberChip(
                            number: int.tryParse(item.numbers[i]) ?? 0,
                            isHighlighted: item.provider == _ResultProvider.nlb &&
                                item.title.toLowerCase().contains('mega power') &&
                                i == 0,
                          ),
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

bool _usesThreeRowLayout(String title) {
  final normalized = title.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  return normalized.contains('adasampatha') ||
      normalized.contains('jayasampatha');
}

class _ThreeRowNumbers extends StatelessWidget {
  final List<String> numbers;
  final String? sign;

  const _ThreeRowNumbers({
    required this.numbers,
    required this.sign,
  });

  @override
  Widget build(BuildContext context) {
    final rows = _splitIntoThreeRows(numbers);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          if (rowIndex > 0) const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < rows[rowIndex].length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _NumberChip(
                  number: int.tryParse(rows[rowIndex][i]) ?? 0,
                  padToTwoDigits: false,
                ),
              ],
              if (rowIndex == rows.length - 1 && sign != null) ...[
                const SizedBox(width: 8),
                _SignBadge(sign: sign!),
              ],
            ],
          ),
        ],
      ],
    );
  }

  List<List<String>> _splitIntoThreeRows(List<String> values) {
    const rowSizes = [2, 3, 4];
    final rows = <List<String>>[];
    var cursor = 0;

    for (final size in rowSizes) {
      if (cursor >= values.length) break;
      final end = (cursor + size > values.length) ? values.length : cursor + size;
      rows.add(values.sublist(cursor, end));
      cursor = end;
    }

    if (cursor < values.length) {
      rows.add(values.sublist(cursor));
    }
    return rows;
  }
}

enum _ResultProvider { nlb, dlb }

class _ResultListItem {
  final _ResultProvider provider;
  final String title;
  final int drawNumber;
  final DateTime drawDate;
  final List<String> numbers;
  final String? sign;
  final String? logoUrl;

  const _ResultListItem({
    required this.provider,
    required this.title,
    required this.drawNumber,
    required this.drawDate,
    required this.numbers,
    required this.sign,
    required this.logoUrl,
  });
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

class _NumberChip extends StatelessWidget {
  final int number;
  final bool isHighlighted;
  final bool padToTwoDigits;

  const _NumberChip({
    required this.number,
    this.isHighlighted = false,
    this.padToTwoDigits = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isHighlighted
        ? Colors.red.shade600
        : const Color(0xFFF5B400);
    final fg = isHighlighted ? Colors.white : Colors.black;

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
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
        padToTwoDigits ? number.toString().padLeft(2, '0') : number.toString(),
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: fg, fontWeight: FontWeight.w700),
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
      // Icon-only badge for zodiac results.
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

class _LotteryLogo extends StatelessWidget {
  final String? url;
  const _LotteryLogo({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const SizedBox(width: 40, height: 40);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) => const SizedBox(width: 40, height: 40),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onRetry;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: color.withOpacity(0.6)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
