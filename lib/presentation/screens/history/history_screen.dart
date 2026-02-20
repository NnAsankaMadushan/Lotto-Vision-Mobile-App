import 'dart:io';

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
import 'package:lotto_vision/services/lottery/lottery_history_service.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncHistory(showSnackBar: false);
    });
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        tabs: const [
          Tab(text: 'Web Results'),
          Tab(text: 'My Tickets'),
        ],
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
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
                    items: [
                      for (final type in types)
                        DropdownMenuItem(
                          value: type,
                          child: Text('${type.displayName} (${_sourceTag(type)})'),
                        ),
                    ],
                    onChanged: isSyncing ? null : onTypeChanged,
                    decoration: const InputDecoration(
                      labelText: 'Lottery type',
                      border: OutlineInputBorder(),
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
                    return _ResultHistoryCard(result: results[index]);
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

class _ResultHistoryCard extends StatelessWidget {
  final LotteryResult result;

  const _ResultHistoryCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final drawDate = DateFormat.yMMMMd().format(result.drawDate);
    final lucky = result.luckyLetter?.trim();
    final hasLucky = lucky != null && lucky.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
            if (hasLucky) ...[
              const SizedBox(height: 8),
              Text(
                'Lucky Letter: $lucky',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in result.winningNumbers)
                  _ResultNumberChip(number: value),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultNumberChip extends StatelessWidget {
  final int number;

  const _ResultNumberChip({required this.number});

  @override
  Widget build(BuildContext context) {
    final label = number >= 0 && number < 100
        ? number.toString().padLeft(2, '0')
        : number.toString();

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF5B400),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
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
