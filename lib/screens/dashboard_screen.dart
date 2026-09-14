import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/booking_provider.dart';
import '../utils/date_helper.dart';
import 'booking_history_screen.dart';
import 'booking_screen.dart';

const Color _navy = Color(0xFF0B1F3A);
const Color _muted = Color(0xFF64748B);
const Color _line = Color(0xFFE2E8F0);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RAINTECH HOTEL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: _muted,
              ),
            ),
            Text(
              'Main Dashboard',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 720;
                    final tiles = [
                      _ActionTile(
                        icon: Icons.event_available_outlined,
                        title: 'Book a Room',
                        subtitle: 'Select dates, guests, and a room',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BookingScreen(),
                            ),
                          );
                        },
                      ),
                      _ActionTile(
                        icon: Icons.history,
                        title: 'Booking History',
                        subtitle: 'View locally stored reservations',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BookingHistoryScreen(),
                            ),
                          );
                        },
                      ),
                    ];

                    if (wide) {
                      return Row(
                        children: [
                          Expanded(child: tiles[0]),
                          const SizedBox(width: 16),
                          Expanded(child: tiles[1]),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        tiles[0],
                        const SizedBox(height: 16),
                        tiles[1],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Operational Overview',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: _navy,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatCard(
                      label: 'Total rooms',
                      value: '${booking.totalRoomCount}',
                    ),
                    _StatCard(
                      label: 'Occupied today',
                      value: '${booking.occupiedRoomCount}',
                    ),
                    _StatCard(
                      label: 'Available today',
                      value: '${booking.availableRoomCount}',
                    ),
                    _StatCard(
                      label: 'Stored bookings',
                      value: '${booking.bookingHistory.length}',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Recent Bookings',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: _navy,
                  ),
                ),
                const SizedBox(height: 12),
                if (booking.bookingHistory.isEmpty)
                  const Text(
                    'No bookings yet.',
                    style: TextStyle(color: _muted),
                  )
                else
                  ...booking.bookingHistory.take(3).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: _line),
                        ),
                        title: Text(
                          '${item.roomCode}  ${item.roomType}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${DateHelper.formatDisplayDate(item.checkIn)} – ${DateHelper.formatDisplayDate(item.checkOut)}',
                        ),
                        trailing: Text(
                          item.reference,
                          style: const TextStyle(
                            color: _navy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _navy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: _navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: _muted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _navy,
            ),
          ),
        ],
      ),
    );
  }
}
