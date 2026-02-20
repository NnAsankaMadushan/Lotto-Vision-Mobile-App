import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/core/di/injection_container.dart';
import 'package:lotto_vision/core/errors/failures.dart';
import 'package:lotto_vision/domain/entities/lottery_result.dart';
import 'package:lotto_vision/domain/entities/lottery_ticket.dart';
import 'package:lotto_vision/domain/usecases/get_all_tickets.dart';
import 'package:lotto_vision/l10n/app_localizations.dart';
import 'package:lotto_vision/presentation/screens/results/ticket_detail_screen.dart';
import 'package:lotto_vision/presentation/widgets/screen_theme.dart';
import 'package:lotto_vision/services/lottery/dlb_results_service.dart';
import 'package:lotto_vision/services/lottery/lottery_history_service.dart';
import 'package:lotto_vision/services/lottery/lottery_results_service.dart';

final _ticketsProvider = FutureProvider.autoDispose<List<LotteryTicket>>((ref) async {
  final getAllTickets = sl<GetAllTickets>();
  final result = await getAllTickets();
  return result.fold(
    (failure) => throw failure,
    (tickets) => tickets,
  );
});

final _resultHistoryProvider =
    FutureProvider.autoDispose.family<List<LotteryResult>, LotteryType>(
  (ref, type) async {
    final service = sl<LotteryHistoryService>();
    return service.getCachedHistory(type: type, limit: 200);
  },
);

final _lotteryLogosProvider =
    FutureProvider.autoDispose<Map<LotteryType, String>>((ref) async {
  final logos = <LotteryType, String>{};
  final nlb = sl<LotteryResultsService>();
  final dlb = sl<DlbResultsService>();

  try {
    final nlbResults = await nlb.fetchAllLatestResultsWithMeta();
    for (final item in nlbResults) {
      final url = (item.logoUrl ?? '').trim();
      if (url.isEmpty) continue;
      logos[item.result.lotteryType] = url;
    }
  } catch (_) {}

  try {
    final dlbResults = await dlb.fetchAllLatestResultsWithMeta();
    for (final item in dlbResults) {
      final mappedType = LotteryType.fromString(item.name);
      final url = (item.logoUrl ?? '').trim();
      if (mappedType == LotteryType.unknown || url.isEmpty) continue;
      logos[mappedType] = url;
    }
  } catch (_) {}

  return logos;
});

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  static final List<LotteryType> _historyTypes = (() {
    final types = LotteryType.values
        .where((t) => t != LotteryType.unknown)
        .toList(growable: false);
    return types..sort((a, b) => a.displayName.compareTo(b.displayName));
  })();

  late LotteryType _selectedType;
  bool _isSyncing = false;
  String? _lastSyncLabel;

  @override
  void initState() {
    super.initState();
    _selectedType = _historyTypes.contains(LotteryType.mahajana)
        ? LotteryType.mahajana
        : _historyTypes.first;
  }

  bool _isDlbType(LotteryType type) {
    return type == LotteryType.adaKotipathi ||
        type == LotteryType.shanida ||
        type == LotteryType.lagnaWasana ||
        type == LotteryType.superBall;
  }

  String _sourceFor(LotteryType type) => _isDlbType(type) ? 'DLB' : 'NLB';

  Future<void> _syncHistory({bool showSnackBar = true}) async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);
    final service = sl<LotteryHistoryService>();

    try {
      final report = await service.syncLastDraws(
        type: _selectedType,
        draws: 100,
      );

      if (!mounted) return;
      final label = 'Synced ${report.saved}/${report.requested} from ${report.source}';
      setState(() {
        _isSyncing = false;
        _lastSyncLabel = label;
      });

      ref.invalidate(_resultHistoryProvider(_selectedType));
      await ref.read(_resultHistoryProvider(_selectedType).future);

      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(label)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSyncing = false);
      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('History sync failed: $e')),
        );
      }
    }
  }

  Future<void> _refreshHistoryOnly() async {
    ref.invalidate(_resultHistoryProvider(_selectedType));
    await ref.read(_resultHistoryProvider(_selectedType).future);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ticketsAsync = ref.watch(_ticketsProvider);
    final historyAsync = ref.watch(_resultHistoryProvider(_selectedType));
    final lotteryLogos = ref.watch(_lotteryLogosProvider).valueOrNull ?? const {};

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: buildLottoBackButton(context),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: buildLottoAppBarGradient(context),
        title: LottoBrandedAppBarTitle(
          section: l10n.history,
        ),
      ),
      body: LottoGradientBackground(
        child: SafeArea(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _HistoryTabs(),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _WebHistoryTab(
                        types: _historyTypes,
                        selectedType: _selectedType,
                        sourceLabel: _sourceFor(_selectedType),
                        logoByType: lotteryLogos,
                        isSyncing: _isSyncing,
                        lastSyncLabel: _lastSyncLabel,
                        historyAsync: historyAsync,
                        onTypeChanged: (value) {
                          if (value == null || value == _selectedType) return;
                          setState(() {
                            _selectedType = value;
                            _lastSyncLabel = null;
                          });
                          _syncHistory(showSnackBar: false);
                        },
                        onSync: () => _syncHistory(),
                        onRefresh: () => _syncHistory(showSnackBar: false),
                        onReloadCache: _refreshHistoryOnly,
                      ),
                      _buildTicketsTab(ticketsAsync, l10n),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketsTab(
    AsyncValue<List<LotteryTicket>> ticketsAsync,
    AppLocalizations l10n,
  ) {
    return ticketsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _EmptyState(
        title: l10n.error,
        subtitle: _errorMessage(error),
        icon: Icons.error_outline,
        actionLabel: l10n.tryAgain,
        onAction: () => ref.invalidate(_ticketsProvider),
      ),
      data: (tickets) {
        if (tickets.isEmpty) {
          return _EmptyState(
            title: l10n.noTickets,
            subtitle: l10n.scanTicket,
            icon: Icons.history,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_ticketsProvider);
            await ref.read(_ticketsProvider.future);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _TicketCard(ticket: tickets[index]);
            },
          ),
        );
      },
    );
  }
}

class _HistoryTabs extends StatelessWidget {
  const _HistoryTabs();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TabBar(
        tabs: const [
          Tab(text: 'Web Results'),
          Tab(text: 'My Tickets'),
        ],
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        splashBorderRadius: BorderRadius.circular(12),
        indicator: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        dividerColor: Colors.transparent,
      ),
    );
  }
}

class _WebHistoryTab extends StatelessWidget {
  final List<LotteryType> types;
  final LotteryType selectedType;
  final String sourceLabel;
  final Map<LotteryType, String> logoByType;
  final bool isSyncing;
  final String? lastSyncLabel;
  final AsyncValue<List<LotteryResult>> historyAsync;
  final ValueChanged<LotteryType?> onTypeChanged;
  final VoidCallback onSync;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onReloadCache;

  const _WebHistoryTab({
    required this.types,
    required this.selectedType,
    required this.sourceLabel,
    required this.logoByType,
    required this.isSyncing,
    required this.lastSyncLabel,
    required this.historyAsync,
    required this.onTypeChanged,
    required this.onSync,
    required this.onRefresh,
    required this.onReloadCache,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Website draw history',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<LotteryType>(
                    value: selectedType,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    borderRadius: BorderRadius.circular(12),
                    menuMaxHeight: 380,
                    items: [
                      for (final type in types)
                        DropdownMenuItem(
                          value: type,
                          child: _LotteryTypeMenuItem(
                            type: type,
                            sourceTag: _sourceTag(type),
                            logoUrl: logoByType[type],
                          ),
                        ),
                    ],
                    onChanged: isSyncing ? null : onTypeChanged,
                    decoration: InputDecoration(
                      labelText: 'Lottery type',
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.3),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isSyncing ? null : onSync,
                          icon: isSyncing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.cloud_download_outlined),
                          label: Text(
                            isSyncing ? 'Syncing...' : 'Sync last 100 draws',
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (lastSyncLabel != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '$lastSyncLabel  |  Source: $sourceLabel',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: historyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _EmptyState(
              title: 'Failed to load history',
              subtitle: _errorMessage(error),
              icon: Icons.error_outline,
              actionLabel: 'Reload',
              onAction: () {
                onReloadCache();
              },
            ),
            data: (results) {
              if (results.isEmpty) {
                return _EmptyState(
                  title: 'No draw history yet',
                  subtitle: 'Tap "Sync last 100 draws" to pull from website.',
                  icon: Icons.cloud_download_outlined,
                  actionLabel: 'Sync now',
                  onAction: onSync,
                );
              }

              return RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return _ResultHistoryCard(
                      result: result,
                      logoUrl: logoByType[result.lotteryType],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _sourceTag(LotteryType type) {
    if (type == LotteryType.adaKotipathi ||
        type == LotteryType.shanida ||
        type == LotteryType.lagnaWasana ||
        type == LotteryType.superBall) {
      return 'DLB';
    }
    return 'NLB';
  }
}

String _errorMessage(Object error) {
  if (error is Failure) {
    return error.message;
  }
  return error.toString();
}

class _LotteryTypeMenuItem extends StatelessWidget {
  final LotteryType type;
  final String sourceTag;
  final String? logoUrl;

  const _LotteryTypeMenuItem({
    required this.type,
    required this.sourceTag,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HistoryLotteryLogo(
          type: type,
          logoUrl: logoUrl,
          size: 24,
          radius: 6,
        ),
        const SizedBox(width: 10),
        Text(
          '${type.displayName} ($sourceTag)',
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ResultHistoryCard extends StatelessWidget {
  final LotteryResult result;
  final String? logoUrl;

  const _ResultHistoryCard({
    required this.result,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final drawDate = DateFormat.yMMMMd().format(result.drawDate);
    final sign = (result.luckyLetter ?? '').trim();
    final hasSign = sign.isNotEmpty && int.tryParse(sign) == null;
    final useThreeRows = _usesThreeRowLayout(result.lotteryType.displayName);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _HistoryLotteryLogo(
                  type: result.lotteryType,
                  logoUrl: logoUrl,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.lotteryType.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '#${result.drawNumber}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              drawDate,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (useThreeRows)
              _HistoryThreeRowNumbers(
                numbers: result.winningNumbers,
                sign: hasSign ? sign : null,
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasSign) _HistorySignBadge(sign: sign),
                  if (hasSign) const SizedBox(width: 10),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var i = 0; i < result.winningNumbers.length; i++)
                          _ResultNumberChip(
                            number: result.winningNumbers[i],
                            isHighlighted:
                                result.lotteryType == LotteryType.megaPower &&
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

class _HistoryThreeRowNumbers extends StatelessWidget {
  final List<int> numbers;
  final String? sign;

  const _HistoryThreeRowNumbers({
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
                _ResultNumberChip(
                  number: rows[rowIndex][i],
                  padToTwoDigits: false,
                ),
              ],
              if (rowIndex == rows.length - 1 && sign != null) ...[
                const SizedBox(width: 8),
                _HistorySignBadge(sign: sign!),
              ],
            ],
          ),
        ],
      ],
    );
  }

  List<List<int>> _splitIntoThreeRows(List<int> values) {
    const rowSizes = [2, 3, 4];
    final rows = <List<int>>[];
    var cursor = 0;

    for (final size in rowSizes) {
      if (cursor >= values.length) break;
      final end = (cursor + size > values.length)
          ? values.length
          : cursor + size;
      rows.add(values.sublist(cursor, end));
      cursor = end;
    }

    if (cursor < values.length) {
      rows.add(values.sublist(cursor));
    }

    return rows;
  }
}

class _ResultNumberChip extends StatelessWidget {
  final int number;
  final bool isHighlighted;
  final bool padToTwoDigits;

  const _ResultNumberChip({
    required this.number,
    this.isHighlighted = false,
    this.padToTwoDigits = true,
  });

  @override
  Widget build(BuildContext context) {
    final label = padToTwoDigits ? number.toString().padLeft(2, '0') : '$number';
    final bg = isHighlighted ? Colors.red.shade600 : const Color(0xFFF5B400);
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
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _HistorySignBadge extends StatelessWidget {
  final String sign;
  const _HistorySignBadge({required this.sign});

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

class _HistoryLotteryLogo extends StatelessWidget {
  final LotteryType type;
  final String? logoUrl;
  final double size;
  final double radius;

  const _HistoryLotteryLogo({
    required this.type,
    required this.logoUrl,
    this.size = 40,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = (logoUrl ?? '').trim();
    if (cleanUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: cleanUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorWidget: (_, __, ___) => _fallback(context),
        ),
      );
    }

    return _fallback(context);
  }

  Widget _fallback(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        _lotteryBadgeLabel(type.displayName),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

String _lotteryBadgeLabel(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) return '?';
  if (words.length == 1) {
    final one = words.first.toUpperCase();
    return one.length <= 2 ? one : one.substring(0, 2);
  }
  return '${words[0][0]}${words[1][0]}'.toUpperCase();
}

String? _zodiacIconUrl(String sign) {
  final normalized = sign.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '').trim();
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

class _TicketCard extends StatelessWidget {
  final LotteryTicket ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final drawDate = DateFormat.yMMMd().format(ticket.drawDate);
    final status = ticket.checkResult == null
        ? null
        : (ticket.checkResult!.isWinner ? l10n.winner : l10n.notWinner);
    final statusColor = ticket.checkResult?.isWinner == true
        ? Colors.green.shade700
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TicketDetailScreen(ticket: ticket),
            ),
          );
        },
        leading: _TicketThumbnail(imageUrl: ticket.imageUrl),
        title: Text(getLotteryDisplayName(ticket.lotteryType, l10n)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(l10n.drawNumber(ticket.drawNumber)),
            Text(l10n.drawDate(drawDate)),
            if (ticket.luckyLetter != null && ticket.luckyLetter!.trim().isNotEmpty)
              Text('Lucky Letter: ${ticket.luckyLetter!.trim()}'),
            if (status != null)
              Text(
                status,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _TicketThumbnail extends StatelessWidget {
  final String? imageUrl;

  const _TicketThumbnail({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.receipt_long,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(imageUrl!),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 56,
          height: 56,
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Icon(
            Icons.image_not_supported,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const _EmptyState({
    required this.title,
    required this.icon,
    this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
