import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hotel_room.dart';
import '../providers/booking_provider.dart';
import '../utils/date_helper.dart';
import 'booking_confirm_screen.dart';

const double _maxContentWidth = 1180;
const Color _navy = Color(0xFF0B1F3A);
const Color _muted = Color(0xFF64748B);
const Color _line = Color(0xFFE2E8F0);
const Color _field = Color(0xFFF8FAFC);
const Color _selectedFill = Color(0xFFEEF4FB);

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 20,
        title: const _BrandTitle(),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _line),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: FilledButton.icon(
              onPressed: () => context.read<BookingProvider>().clearSelection(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset'),
              style: FilledButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                minimumSize: const Size(108, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<BookingProvider>(
          builder: (context, booking, _) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                      child: wide
                          ? _WideLayout(booking: booking)
                          : _NarrowLayout(booking: booking),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _BrandMark(),
        SizedBox(width: 12),
        Column(
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
              'Hotel Room Booking',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 22),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.booking});

  final BookingProvider booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 7, child: _StayDetailsCard(booking: booking)),
              const SizedBox(width: 18),
              Expanded(flex: 5, child: _ResultPanel(booking: booking)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _AvailableRoomsCard(booking: booking),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.booking});

  final BookingProvider booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StayDetailsCard(booking: booking),
        const SizedBox(height: 18),
        _AvailableRoomsCard(booking: booking),
        const SizedBox(height: 18),
        _ResultPanel(booking: booking),
      ],
    );
  }
}

class _StayDetailsCard extends StatelessWidget {
  const _StayDetailsCard({required this.booking});

  final BookingProvider booking;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '1. Select Dates & Guests',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Check-in date',
                  value: booking.checkInDate,
                  onPressed: () => _pickCheckIn(context),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _DateField(
                  label: 'Check-out date',
                  value: booking.checkOutDate,
                  onPressed: () => _pickCheckOut(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: _line),
          const SizedBox(height: 16),
          _GuestStepper(booking: booking),
        ],
      ),
    );
  }

  Future<void> _pickCheckIn(BuildContext context) async {
    final today = booking.today;
    final lastDate = DateTime(today.year + 2, today.month, today.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: booking.checkInDate ?? today,
      firstDate: today,
      lastDate: lastDate,
      helpText: 'Select check-in date',
    );
    if (picked != null && context.mounted) {
      booking.selectCheckInDate(picked);
    }
  }

  Future<void> _pickCheckOut(BuildContext context) async {
    final today = booking.today;
    final checkIn = booking.checkInDate;
    final firstDate = checkIn != null
        ? DateTime(checkIn.year, checkIn.month, checkIn.day + 1)
        : DateTime(today.year, today.month, today.day + 1);
    final lastDate = DateTime(today.year + 2, today.month, today.day);
    if (firstDate.isAfter(lastDate)) {
      return;
    }

    var initialDate = booking.checkOutDate ?? firstDate;
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }
    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select check-out date',
    );
    if (picked != null && context.mounted) {
      booking.selectCheckOutDate(picked);
    }
  }
}

class _DateField extends StatefulWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPressed;

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final display = widget.value == null
        ? 'Select date'
        : DateHelper.formatDisplayDate(widget.value!);
    final active = widget.value != null || _hovered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _muted,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          button: true,
          label: widget.value == null
              ? 'Select ${widget.label}'
              : '${widget.label} $display',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: Material(
              color: _field,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: active ? _navy : _line,
                      width: active ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          display,
                          style: TextStyle(
                            color: widget.value == null
                                ? _muted
                                : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        widget.value == null
                            ? Icons.calendar_today_outlined
                            : Icons.event_available_outlined,
                        size: 18,
                        color: _navy,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GuestStepper extends StatelessWidget {
  const _GuestStepper({required this.booking});

  final BookingProvider booking;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guests',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _muted,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Rooms are filtered by this guest count.',
                style: TextStyle(fontSize: 13, color: _muted),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: _field,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              _StepperButton(
                tooltip: 'Decrease guests',
                icon: Icons.remove,
                onPressed: booking.guestCount > BookingProvider.minGuests
                    ? booking.decrementGuests
                    : null,
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '${booking.guestCount}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
              ),
              _StepperButton(
                tooltip: 'Increase guests',
                icon: Icons.add,
                onPressed:
                    booking.guestCount < BookingProvider.maxSelectableGuests
                    ? booking.incrementGuests
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        foregroundColor: _navy,
        disabledForegroundColor: const Color(0xFFCBD5E1),
        minimumSize: const Size(42, 42),
      ),
      icon: Icon(icon, size: 18),
    );
  }
}

class _AvailableRoomsCard extends StatelessWidget {
  const _AvailableRoomsCard({required this.booking});

  final BookingProvider booking;

  @override
  Widget build(BuildContext context) {
    final rooms = booking.availableRooms;

    return _SectionCard(
      title: '2. Available Rooms',
      child: rooms.isEmpty
          ? Text(
              booking.hiddenBookedRoomCount > 0
                  ? 'No rooms left for these dates. Booked rooms are hidden.'
                  : 'No rooms available for ${booking.guestCount} guests.',
              style: const TextStyle(color: _muted),
            )
          : RadioGroup<String>(
              groupValue: booking.selectedRoom?.roomCode,
              onChanged: (roomCode) {
                if (roomCode == null) {
                  return;
                }
                final room = rooms.firstWhere(
                  (item) => item.roomCode == roomCode,
                );
                if (!booking.isRoomBooked(room)) {
                  booking.selectRoom(room);
                }
              },
              child: Column(
                children: [
                  const _RoomTableHeader(),
                  const Divider(height: 1, color: _line),
                  for (var i = 0; i < rooms.length; i++) ...[
                    _RoomRow(
                      room: rooms[i],
                      selectedRoomCode: booking.selectedRoom?.roomCode,
                      booked: booking.isRoomBooked(rooms[i]),
                      onTap: () => booking.selectRoom(rooms[i]),
                    ),
                    if (i != rooms.length - 1)
                      const Divider(height: 1, color: _line),
                  ],
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      booking.hiddenBookedRoomCount > 0
                          ? '${booking.hiddenBookedRoomCount} booked room(s) hidden for the selected dates.'
                          : 'Select dates to hide rooms already reserved in booking history.',
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _RoomTableHeader extends StatelessWidget {
  const _RoomTableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Row(
        children: [
          SizedBox(width: 40),
          SizedBox(width: 82),
          SizedBox(width: 64, child: Text('CODE', style: _headerStyle)),
          Expanded(child: Text('ROOM TYPE', style: _headerStyle)),
          SizedBox(
            width: 110,
            child: Text('PRICE / NIGHT', style: _headerStyle),
          ),
          SizedBox(
            width: 64,
            child: Text(
              'GUESTS',
              style: _headerStyle,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.6,
  color: _muted,
);

class _RoomRow extends StatefulWidget {
  const _RoomRow({
    required this.room,
    required this.selectedRoomCode,
    required this.booked,
    required this.onTap,
  });

  final HotelRoom room;
  final String? selectedRoomCode;
  final bool booked;
  final VoidCallback onTap;

  @override
  State<_RoomRow> createState() => _RoomRowState();
}

class _RoomRowState extends State<_RoomRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected =
        !widget.booked && widget.selectedRoomCode == widget.room.roomCode;
    final background = widget.booked
        ? const Color(0xFFF8FAFC)
        : selected
        ? _selectedFill
        : _hovered
        ? const Color(0xFFF8FAFC)
        : Colors.white;

    return MouseRegion(
      cursor: widget.booked
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: background,
        child: InkWell(
          onTap: widget.booked ? null : widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: selected ? _navy : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              children: [
                if (widget.booked)
                  const SizedBox(
                    width: 40,
                    child: Icon(Icons.lock_outline, size: 18, color: _muted),
                  )
                else
                  Radio<String>(value: widget.room.roomCode),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    widget.room.imageAsset,
                    width: 72,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 64,
                  child: Text(
                    widget.room.roomCode,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: widget.booked ? _muted : _navy,
                    ),
                  ),
                ),
                Expanded(
                  child: Semantics(
                    selected: selected,
                    label:
                        '${widget.room.roomCode}, ${widget.room.roomType}, ${_formatInr(widget.room.pricePerNight)} per night, maximum ${widget.room.maxGuests} guests${widget.booked ? ', booked' : ''}',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          widget.room.roomType,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: widget.booked
                                ? _muted
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        if (selected)
                          const _StatusChip(
                            label: 'Selected',
                            color: _navy,
                            fill: Color(0xFFD8E4F2),
                          ),
                        if (widget.booked)
                          const _StatusChip(
                            label: 'Booked',
                            color: Color(0xFFB45309),
                            fill: Color(0xFFFEF3C7),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    _formatInr(widget.room.pricePerNight),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: widget.booked ? _muted : _navy,
                    ),
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    '${widget.room.maxGuests}',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: widget.booked ? _muted : _navy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.fill,
  });

  final String label;
  final Color color;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.booking});

  final BookingProvider booking;

  @override
  Widget build(BuildContext context) {
    if (booking.isBookingValid) {
      return _BookingSummaryCard(booking: booking);
    }
    return _ValidationMessage(booking: booking);
  }
}

class _ValidationMessage extends StatelessWidget {
  const _ValidationMessage({required this.booking});

  final BookingProvider booking;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '3. Booking Status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            liveRegion: true,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFB91C1C)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      booking.validationMessage!,
                      style: const TextStyle(
                        color: Color(0xFF991B1B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ChecklistRow(
            done: booking.checkInDate != null,
            label: 'Check-in date',
          ),
          _ChecklistRow(
            done: booking.checkOutDate != null && booking.areDatesValid,
            label: 'Valid check-out date',
          ),
          _ChecklistRow(
            done: booking.selectedRoom != null,
            label: 'Room selected',
          ),
          const _ChecklistRow(done: false, label: 'Confirmation and payment'),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.done, required this.label});

  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: done ? const Color(0xFF15803D) : _muted,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: done ? const Color(0xFF14532D) : _muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingSummaryCard extends StatelessWidget {
  const _BookingSummaryCard({required this.booking});

  final BookingProvider booking;

  @override
  Widget build(BuildContext context) {
    final room = booking.selectedRoom!;
    final nights = booking.numberOfNights!;
    final total = booking.totalPrice!;

    return _SectionCard(
      title: '3. Booking Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            room.roomType,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            room.roomCode,
            style: const TextStyle(color: _muted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Check-in',
            value: DateHelper.formatDisplayDate(booking.checkInDate!),
          ),
          _SummaryRow(
            label: 'Check-out',
            value: DateHelper.formatDisplayDate(booking.checkOutDate!),
          ),
          _SummaryRow(
            label: 'Price per night',
            value: _formatInr(room.pricePerNight),
          ),
          _SummaryRow(label: 'Number of nights', value: '$nights'),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: _navy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text(
                  'Total amount',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatInr(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BookingConfirmScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Continue to confirmation'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: _muted)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              color: _navy,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.all(18), child: child),
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
