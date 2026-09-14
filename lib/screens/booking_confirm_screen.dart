import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/booking_provider.dart';
import '../utils/date_helper.dart';
import 'booking_success_screen.dart';

const Color _navy = Color(0xFF0B1F3A);
const Color _muted = Color(0xFF64748B);
const Color _line = Color(0xFFE2E8F0);
const Color _field = Color(0xFFF8FAFC);

class BookingConfirmScreen extends StatelessWidget {
  const BookingConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();
    if (!booking.isBookingValid) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirm Booking')),
        body: const Center(
          child: Text('Please complete room and date selection.'),
        ),
      );
    }

    final room = booking.selectedRoom!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirm Booking',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    room.imageAsset,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 18),
                _InfoRow(
                  label: 'Room',
                  value: '${room.roomType} · ${room.roomCode}',
                ),
                _InfoRow(label: 'Guests', value: '${booking.guestCount}'),
                _InfoRow(
                  label: 'Check-in',
                  value: DateHelper.formatDisplayDate(booking.checkInDate!),
                ),
                _InfoRow(
                  label: 'Check-out',
                  value: DateHelper.formatDisplayDate(booking.checkOutDate!),
                ),
                _InfoRow(label: 'Nights', value: '${booking.numberOfNights}'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _navy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Total amount due',
                        style: TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        _formatInr(booking.totalPrice!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'ID proof (optional)',
                  style: TextStyle(fontWeight: FontWeight.w700, color: _navy),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload a local file such as an ID image or PDF. It is stored as a file name only.',
                  style: TextStyle(color: _muted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _pickProof(booking),
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(booking.proofFileName ?? 'Choose file'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _navy,
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: _field,
                  ),
                ),
                if (booking.proofFileName != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => booking.setProofFileName(null),
                    child: const Text('Remove file'),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Payment',
                  style: TextStyle(fontWeight: FontWeight.w700, color: _navy),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: booking.paymentMethod,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _line),
                    ),
                  ),
                  items: BookingProvider.paymentMethods
                      .map(
                        (method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ),
                      )
                      .toList(),
                  onChanged: (method) {
                    if (method != null) {
                      booking.setPaymentMethod(method);
                    }
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'This is a local demo payment. No real charge is made.',
                  style: TextStyle(color: _muted, fontSize: 13),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    booking.confirmBooking();
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const BookingSuccessScreen(),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Complete payment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickProof(BookingProvider booking) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    booking.setProofFileName(result.files.single.name);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: _muted)),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, color: _navy),
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
