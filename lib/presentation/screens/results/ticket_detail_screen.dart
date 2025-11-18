import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotto_vision/core/di/injection_container.dart';
import 'package:lotto_vision/domain/entities/lottery_ticket.dart';
import 'package:lotto_vision/domain/usecases/check_ticket.dart';
import 'package:intl/intl.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final LotteryTicket ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  bool _isChecking = false;
  CheckResult? _checkResult;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // Delete ticket
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.ticket.imageUrl != null)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(
                      File(widget.ticket.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ticket.lotteryType.displayName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Draw Number', '#${widget.ticket.drawNumber}'),
                      _buildInfoRow(
                        'Draw Date',
                        DateFormat('MMM dd, yyyy').format(widget.ticket.drawDate),
                      ),
                      if (widget.ticket.serialNumber != null)
                        _buildInfoRow('Serial', widget.ticket.serialNumber!),
                      const Divider(height: 24),
                      Text(
                        'Your Numbers',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...widget.ticket.numberSets.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  children: entry.value.map((num) {
                                    return Chip(
                                      label: Text(
                                        num.toString().padLeft(2, '0'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_checkResult != null) _buildResultCard(),
              if (_errorMessage != null)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isChecking ? null : _checkTicket,
                icon: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(_isChecking ? 'Checking...' : 'Check Results'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final result = _checkResult!;
    final isWinner = result.isWinner;

    return Card(
      color: isWinner
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              isWinner ? Icons.celebration : Icons.info_outline,
              size: 48,
              color: isWinner
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              isWinner ? 'Congratulations!' : 'Not a Winner',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isWinner
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
            ),
            if (isWinner) ...[
              const SizedBox(height: 8),
              Text(
                'You won LKR ${NumberFormat('#,###').format(result.totalWinnings)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ...result.matches.map((match) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${match.setIndex + 1}'),
                  ),
                  title: Text('${match.matchCount} numbers matched'),
                  subtitle: Text(match.prizeName),
                  trailing: Text(
                    'LKR ${NumberFormat('#,###').format(match.prizeAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _checkTicket() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    final checkTicket = sl<CheckTicket>();
    final result = await checkTicket(widget.ticket);

    result.fold(
      (failure) {
        setState(() {
          _isChecking = false;
          _errorMessage = failure.message;
        });
      },
      (checkResult) {
        setState(() {
          _isChecking = false;
          _checkResult = checkResult;
        });
      },
    );
  }
}
