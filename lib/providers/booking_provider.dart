import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/room_data.dart';
import '../models/confirmed_booking.dart';
import '../models/hotel_room.dart';
import '../utils/date_helper.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider({
    DateTime Function()? now,
    List<ConfirmedBooking>? initialBookings,
    this.enableLocalStorage = false,
  }) : _now = now ?? DateTime.now,
       _bookings = List<ConfirmedBooking>.from(initialBookings ?? seedBookings);

  static const int minGuests = 1;
  static const int maxSelectableGuests = 4;
  static const int defaultGuestCount = 2;
  static const String defaultPaymentMethod = 'Cash';
  static const List<String> paymentMethods = ['Cash', 'Credit Card', 'UPI'];
  static const String _storageKey = 'hotel_confirmed_bookings';

  final DateTime Function() _now;
  final bool enableLocalStorage;

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  HotelRoom? _selectedRoom;
  int _guestCount = defaultGuestCount;
  bool _isConfirmed = false;
  ConfirmedBooking? _lastConfirmed;
  String? _proofFileName;
  String _paymentMethod = defaultPaymentMethod;
  List<ConfirmedBooking> _bookings;

  DateTime get today => DateHelper.dateOnly(_now());

  DateTime? get checkInDate => _checkInDate;
  DateTime? get checkOutDate => _checkOutDate;
  HotelRoom? get selectedRoom => _selectedRoom;
  int get guestCount => _guestCount;
  bool get isConfirmed => _isConfirmed;
  ConfirmedBooking? get lastConfirmed => _lastConfirmed;
  String? get proofFileName => _proofFileName;
  String get paymentMethod => _paymentMethod;

  int get totalRoomCount => hotelRooms.length;

  int get occupiedRoomCount {
    final occupied = <String>{};
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    for (final booking in _bookings) {
      if (DateHelper.staysOverlap(
        startA: booking.checkIn,
        endA: booking.checkOut,
        startB: today,
        endB: tomorrow,
      )) {
        occupied.add(booking.roomCode);
      }
    }
    return occupied.length;
  }

  int get availableRoomCount => totalRoomCount - occupiedRoomCount;

  int get totalRevenue {
    return _bookings.fold(0, (sum, booking) => sum + booking.totalPrice);
  }

  List<ConfirmedBooking> get bookingHistory {
    return _bookings.reversed.toList(growable: false);
  }

  String? get bookingReference => _lastConfirmed?.reference;

  List<HotelRoom> get availableRooms {
    return hotelRooms
        .where((room) {
          if (room.maxGuests < _guestCount) {
            return false;
          }
          if (areDatesValid && isRoomBooked(room)) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  int get hiddenBookedRoomCount {
    if (!areDatesValid) {
      return 0;
    }
    return hotelRooms.where((room) {
      return room.maxGuests >= _guestCount && isRoomBooked(room);
    }).length;
  }

  bool isRoomBooked(HotelRoom room) {
    if (!areDatesValid) {
      return false;
    }

    return _bookings.any((booking) {
      return booking.roomCode == room.roomCode &&
          DateHelper.staysOverlap(
            startA: booking.checkIn,
            endA: booking.checkOut,
            startB: _checkInDate!,
            endB: _checkOutDate!,
          );
    });
  }

  bool get areDatesValid {
    if (_checkInDate == null || _checkOutDate == null) {
      return false;
    }
    if (DateHelper.isBeforeToday(_checkInDate!, today)) {
      return false;
    }
    return DateHelper.nightsBetween(_checkInDate, _checkOutDate) != null;
  }

  int? get numberOfNights {
    if (!areDatesValid) {
      return null;
    }
    return DateHelper.nightsBetween(_checkInDate, _checkOutDate);
  }

  int? get totalPrice {
    final nights = numberOfNights;
    final room = _selectedRoom;
    if (nights == null || room == null) {
      return null;
    }
    return nights * room.pricePerNight;
  }

  bool get isBookingValid => validationMessage == null;

  String? get validationMessage {
    if (_checkInDate == null) {
      return 'Please select a check-in date.';
    }
    if (DateHelper.isBeforeToday(_checkInDate!, today)) {
      return 'Check-in date cannot be in the past.';
    }
    if (_checkOutDate == null) {
      return 'Please select a check-out date.';
    }
    if (!DateHelper.isAfterDay(_checkOutDate!, _checkInDate!)) {
      return 'Check-out date must be after check-in date.';
    }
    if (_selectedRoom == null) {
      return 'Please select a room.';
    }
    return null;
  }

  Future<void> loadSavedBookings() async {
    if (!enableLocalStorage) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      _bookings = List<ConfirmedBooking>.from(seedBookings);
      await _saveBookings();
    } else {
      _bookings = ConfirmedBooking.decodeList(raw);
    }
    notifyListeners();
  }

  void selectCheckInDate(DateTime date) {
    final normalized = DateHelper.dateOnly(date);
    if (_checkInDate == normalized) {
      return;
    }
    _checkInDate = normalized;
    _clearRoomIfUnavailable();
    _clearConfirmation();
    notifyListeners();
  }

  void selectCheckOutDate(DateTime date) {
    final normalized = DateHelper.dateOnly(date);
    if (_checkOutDate == normalized) {
      return;
    }
    _checkOutDate = normalized;
    _clearRoomIfUnavailable();
    _clearConfirmation();
    notifyListeners();
  }

  void selectRoom(HotelRoom room) {
    if (isRoomBooked(room) || _selectedRoom?.roomCode == room.roomCode) {
      return;
    }
    _selectedRoom = room;
    _clearConfirmation();
    notifyListeners();
  }

  void setGuestCount(int count) {
    final next = count.clamp(minGuests, maxSelectableGuests);
    if (_guestCount == next) {
      return;
    }
    _guestCount = next;
    _clearRoomIfGuestCountExceedsCapacity();
    _clearConfirmation();
    notifyListeners();
  }

  void incrementGuests() => setGuestCount(_guestCount + 1);

  void decrementGuests() => setGuestCount(_guestCount - 1);

  void setProofFileName(String? fileName) {
    if (_proofFileName == fileName) {
      return;
    }
    _proofFileName = fileName;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    if (_paymentMethod == method) {
      return;
    }
    _paymentMethod = method;
    notifyListeners();
  }

  void confirmBooking() {
    if (!isBookingValid || _isConfirmed) {
      return;
    }

    final room = _selectedRoom!;
    final confirmed = ConfirmedBooking(
      reference: _buildReference(),
      roomCode: room.roomCode,
      roomType: room.roomType,
      pricePerNight: room.pricePerNight,
      guests: _guestCount,
      checkIn: _checkInDate!,
      checkOut: _checkOutDate!,
      nights: numberOfNights!,
      totalPrice: totalPrice!,
      proofFileName: _proofFileName,
      paymentMethod: _paymentMethod,
    );
    _bookings = [..._bookings, confirmed];
    _lastConfirmed = confirmed;
    _isConfirmed = true;
    _resetForm();
    _saveBookings();
    notifyListeners();
  }

  void clearSelection() {
    if (_checkInDate == null &&
        _checkOutDate == null &&
        _selectedRoom == null &&
        _guestCount == defaultGuestCount &&
        !_isConfirmed &&
        _lastConfirmed == null) {
      return;
    }

    _resetForm();
    _isConfirmed = false;
    _lastConfirmed = null;
    notifyListeners();
  }

  String _buildReference() {
    final room = _selectedRoom!;
    final checkIn = _checkInDate!;
    final day = checkIn.day.toString().padLeft(2, '0');
    final month = checkIn.month.toString().padLeft(2, '0');
    return 'BK-${room.roomCode}-$day$month${checkIn.year}';
  }

  Future<void> _saveBookings() async {
    if (!enableLocalStorage) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, ConfirmedBooking.encodeList(_bookings));
  }

  void _clearRoomIfGuestCountExceedsCapacity() {
    final room = _selectedRoom;
    if (room != null && room.maxGuests < _guestCount) {
      _selectedRoom = null;
    }
  }

  void _clearRoomIfUnavailable() {
    final room = _selectedRoom;
    if (room != null && isRoomBooked(room)) {
      _selectedRoom = null;
    }
  }

  void _resetForm() {
    _checkInDate = null;
    _checkOutDate = null;
    _selectedRoom = null;
    _guestCount = defaultGuestCount;
    _proofFileName = null;
    _paymentMethod = defaultPaymentMethod;
  }

  void _clearConfirmation() {
    _isConfirmed = false;
    _lastConfirmed = null;
  }
}
