import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotto_vision/core/di/injection_container.dart';
import 'package:lotto_vision/domain/usecases/scan_ticket.dart';
import 'package:lotto_vision/presentation/screens/results/ticket_detail_screen.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const ScannerScreen({super.key, required this.imagePath});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  bool _isScanning = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scanTicket();
  }

  Future<void> _scanTicket() async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    final scanTicket = sl<ScanTicket>();
    final result = await scanTicket(widget.imagePath);

    result.fold(
      (failure) {
        setState(() {
          _isScanning = false;
          _errorMessage = failure.message;
        });
      },
      (ticket) {
        if (!mounted) return;

        setState(() {
          _isScanning = false;
        });

        // Navigate to ticket details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailScreen(ticket: ticket),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanning Ticket'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (_isScanning) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  'Scanning ticket...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Extracting lottery information',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ] else if (_errorMessage != null) ...[
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan Failed',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _scanTicket,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Take Another Photo'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
