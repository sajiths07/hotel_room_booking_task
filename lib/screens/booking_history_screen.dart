import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/room_data.dart';
import '../models/confirmed_booking.dart';
import '../providers/booking_provider.dart';
import '../utils/date_helper.dart';

const Color _navy = Color(0xFF0B1F3A);
const Color _muted = Color(0xFF64748B);
const Color _line = Color(0xFFE2E8F0);

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<BookingProvider>().bookingHistory;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: const Text(
          'Booking History',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _line),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      'No bookings stored yet.',
                      style: TextStyle(color: _muted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _HistoryCard(booking: history[index]);
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.booking});

  final ConfirmedBooking booking;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: _navy,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                booking.reference,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      roomImageAsset(booking.roomCode),
                      width: 120,
                      height: 84,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${booking.roomCode}  ${booking.roomType}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: _navy,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${DateHelper.formatDisplayDate(booking.checkIn)} – ${DateHelper.formatDisplayDate(booking.checkOut)}',
                          style: const TextStyle(color: _muted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${booking.nights} nights · ${booking.guests} guests · ${booking.paymentMethod ?? 'Cash'}',
                          style: const TextStyle(color: _muted),
                        ),
                        if (booking.proofFileName != null)
                          Text(
                            'Proof: ${booking.proofFileName}',
                            style: const TextStyle(color: _muted),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    _formatInr(booking.totalPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: _navy,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
