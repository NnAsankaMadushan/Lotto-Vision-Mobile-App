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
  void initState() {
    super.initState();
    // Initialize with existing result if available
    _checkResult = widget.ticket.checkResult;
    
    // Automatically trigger a check if we don't have results yet
    if (_checkResult == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkTicket();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // TODO: Implement delete ticket
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
                      if (widget.ticket.luckyLetter != null)
                        _buildInfoRow('Lucky Letter', widget.ticket.luckyLetter!),
                      if (widget.ticket.serialNumber != null)
                        _buildInfoRow('Serial', widget.ticket.serialNumber!),
                      const Divider(height: 24),
                      Text(
                        'Your Numbers',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                  const SizedBox(height: 12),
                  ...widget.ticket.numberSets.asMap().entries.map((entry) {
                    final i = entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SET ${i + 1}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (widget.ticket.luckyLetter != null)
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: (_checkResult?.winningResult?.luckyLetter == widget.ticket.luckyLetter)
                                            ? Colors.orange.shade800
                                            : Theme.of(context).colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.orange.shade900.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        widget.ticket.luckyLetter!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: (_checkResult?.winningResult?.luckyLetter == widget.ticket.luckyLetter)
                                              ? Colors.white
                                              : Theme.of(context).colorScheme.onSecondaryContainer,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'SIGN',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ...entry.value.map((num) {
                                // Highlight if it's a winning number
                                final isWinningNumber = _checkResult?.matches
                                        .any((m) => m.setIndex == entry.key && m.matchedNumbers.contains(num)) ?? 
                                    false;
                                
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isWinningNumber 
                                        ? Colors.green.shade600 
                                        : Theme.of(context).colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    num.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isWinningNumber ? Colors.white : null,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                            const SizedBox(width: 8),
                            Text(
                              'Check Failed',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (_checkResult == null && _errorMessage == null && !_isChecking)
                FilledButton.icon(
                  onPressed: _checkTicket,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Check Results'),
                )
              else if (_isChecking)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Checking results...'),
                    ],
                  ),
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
      elevation: 4,
      color: isWinner
          ? Colors.green.shade50
          : Theme.of(context).colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isWinner ? Colors.green.shade300 : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              isWinner ? Icons.celebration : Icons.sentiment_dissatisfied,
              size: 64,
              color: isWinner
                  ? Colors.green.shade700
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              isWinner ? 'Congratulations!' : 'Better Luck Next Time',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isWinner ? Colors.green.shade800 : null,
                  ),
            ),
            const SizedBox(height: 16),
            if (result.winningResult != null) ...[
              Text(
                'Winning Results',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                   if (result.winningResult!.luckyLetter != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        result.winningResult!.luckyLetter!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ...result.winningResult!.winningNumbers.map((num) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade500,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        num.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const Divider(height: 32),
            ],
            const SizedBox(height: 8),
            if (isWinner) ...[
              Text(
                'You won LKR ${NumberFormat('#,###').format(result.totalWinnings)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Divider(height: 32),
              ...result.matches.map((match) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        radius: 12,
                        child: Text('${match.setIndex + 1}', style: const TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Matched ${match.matchCount} numbers',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(match.prizeName, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Text(
                        'LKR ${NumberFormat('#,###').format(match.prizeAmount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else
              const Text(
                'None of your numbers matched the winning numbers for this draw.',
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _checkTicket,
              icon: const Icon(Icons.refresh),
              label: const Text('Re-check'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkTicket() async {
    if (!mounted) return;
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      final checkTicket = sl<CheckTicket>();
      final result = await checkTicket(widget.ticket);

      if (!mounted) return;

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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isChecking = false;
        _errorMessage = e.toString();
      });
    }
  }
}
