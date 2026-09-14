import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/room_data.dart';
import '../providers/booking_provider.dart';
import '../utils/date_helper.dart';

const Color _navy = Color(0xFF0B1F3A);
const Color _muted = Color(0xFF64748B);

class BookingSuccessScreen extends StatefulWidget {
  const BookingSuccessScreen({super.key});

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 4), _goToDashboard);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToDashboard() {
    if (!mounted) {
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final confirmed = context.watch<BookingProvider>().lastConfirmed;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: confirmed == null
                  ? const Text('No completed booking found.')
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF15803D),
                          size: 72,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Payment complete',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: _navy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          confirmed.reference,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _navy,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            roomImageAsset(confirmed.roomCode),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${confirmed.roomType} · ${confirmed.roomCode}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${DateHelper.formatDisplayDate(confirmed.checkIn)} – ${DateHelper.formatDisplayDate(confirmed.checkOut)}',
                          style: const TextStyle(color: _muted),
                        ),
                        Text(
                          '${confirmed.paymentMethod ?? 'Cash'} · ${_formatInr(confirmed.totalPrice)}',
                          style: const TextStyle(color: _muted),
                        ),
                        if (confirmed.proofFileName != null)
                          Text(
                            'Proof: ${confirmed.proofFileName}',
                            style: const TextStyle(color: _muted),
                          ),
                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: _goToDashboard,
                          style: FilledButton.styleFrom(
                            backgroundColor: _navy,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('Back to dashboard'),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatInr(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer('₹');
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    if (i > 0 && remaining % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
