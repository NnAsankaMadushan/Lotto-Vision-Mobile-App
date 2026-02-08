import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/core/di/injection_container.dart';
import 'package:lotto_vision/core/errors/failures.dart';
import 'package:lotto_vision/domain/entities/lottery_ticket.dart';
import 'package:lotto_vision/domain/usecases/get_all_tickets.dart';
import 'package:lotto_vision/l10n/app_localizations.dart';
import 'package:lotto_vision/presentation/screens/results/ticket_detail_screen.dart';

final _ticketsProvider = FutureProvider.autoDispose<List<LotteryTicket>>((ref) async {
  final getAllTickets = sl<GetAllTickets>();
  final result = await getAllTickets();
  return result.fold(
    (failure) => throw failure,
    (tickets) => tickets,
  );
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ticketsAsync = ref.watch(_ticketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
      ),
      body: SafeArea(
        child: ticketsAsync.when(
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
