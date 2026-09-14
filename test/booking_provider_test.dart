import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_room_booking/data/room_data.dart';
import 'package:hotel_room_booking/models/hotel_room.dart';
import 'package:hotel_room_booking/providers/booking_provider.dart';

void main() {
  final today = DateTime(2026, 9, 14);

  BookingProvider createBooking() {
    return BookingProvider(now: () => today);
  }

  HotelRoom roomByCode(String roomCode) {
    return hotelRooms.firstWhere((room) => room.roomCode == roomCode);
  }

  group('BookingProvider', () {
    test('calculates a valid one-night booking', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 15, 18, 45));
      booking.selectCheckOutDate(DateTime(2026, 9, 16, 9, 10));
      booking.selectRoom(roomByCode('R101'));

      expect(booking.numberOfNights, 1);
      expect(booking.totalPrice, 3500);
      expect(booking.isBookingValid, isTrue);
      expect(booking.validationMessage, isNull);
    });

    test('calculates a valid multiple-night booking', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 15));
      booking.selectCheckOutDate(DateTime(2026, 9, 18));
      booking.selectRoom(roomByCode('R101'));

      expect(booking.numberOfNights, 3);
      expect(booking.totalPrice, 10500);
      expect(booking.isBookingValid, isTrue);
    });

    test('rejects same-day check-in and check-out', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 15));
      booking.selectCheckOutDate(DateTime(2026, 9, 15));
      booking.selectRoom(roomByCode('R101'));

      expect(booking.isBookingValid, isFalse);
      expect(booking.numberOfNights, isNull);
      expect(booking.totalPrice, isNull);
      expect(
        booking.validationMessage,
        'Check-out date must be after check-in date.',
      );
    });

    test('rejects check-out before check-in', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 18));
      booking.selectCheckOutDate(DateTime(2026, 9, 15));
      booking.selectRoom(roomByCode('R101'));

      expect(booking.isBookingValid, isFalse);
      expect(booking.numberOfNights, isNull);
      expect(booking.totalPrice, isNull);
      expect(
        booking.validationMessage,
        'Check-out date must be after check-in date.',
      );
    });

    test('rejects a past check-in date', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 13));
      booking.selectCheckOutDate(DateTime(2026, 9, 16));
      booking.selectRoom(roomByCode('R101'));

      expect(booking.isBookingValid, isFalse);
      expect(booking.numberOfNights, isNull);
      expect(booking.totalPrice, isNull);
      expect(booking.validationMessage, 'Check-in date cannot be in the past.');
    });

    test('allows check-in on today', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 14, 23, 59));
      booking.selectCheckOutDate(DateTime(2026, 9, 15));
      booking.selectRoom(roomByCode('R101'));

      expect(booking.isBookingValid, isTrue);
      expect(booking.numberOfNights, 1);
    });

    test('reports a missing check-in date', () {
      final booking = createBooking();
      booking.selectCheckOutDate(DateTime(2026, 9, 18));
      booking.selectRoom(roomByCode('R101'));

      expect(booking.isBookingValid, isFalse);
      expect(booking.numberOfNights, isNull);
      expect(booking.validationMessage, 'Please select a check-in date.');
    });

    test('reports a missing check-out date', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 15));
      booking.selectRoom(roomByCode('R101'));

      expect(booking.isBookingValid, isFalse);
      expect(booking.numberOfNights, isNull);
      expect(booking.validationMessage, 'Please select a check-out date.');
    });

    test('reports a missing room selection', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 15));
      booking.selectCheckOutDate(DateTime(2026, 9, 18));

      expect(booking.isBookingValid, isFalse);
      expect(booking.numberOfNights, 3);
      expect(booking.totalPrice, isNull);
      expect(booking.validationMessage, 'Please select a room.');
    });

    test('calculates the deluxe room total for 3 nights', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 15));
      booking.selectCheckOutDate(DateTime(2026, 9, 18));
      booking.selectRoom(roomByCode('R101'));

      expect(booking.selectedRoom?.pricePerNight, 3500);
      expect(booking.numberOfNights, 3);
      expect(booking.totalPrice, 10500);
    });

    test('calculates a different room price for 2 nights', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 15));
      booking.selectCheckOutDate(DateTime(2026, 9, 17));
      booking.selectRoom(roomByCode('R201'));

      expect(booking.selectedRoom?.pricePerNight, 5800);
      expect(booking.numberOfNights, 2);
      expect(booking.totalPrice, 11600);
    });

    test('clears stale nights and total when dates become invalid', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 15));
      booking.selectCheckOutDate(DateTime(2026, 9, 18));
      booking.selectRoom(roomByCode('R101'));

      expect(booking.numberOfNights, 3);
      expect(booking.totalPrice, 10500);
      expect(booking.isBookingValid, isTrue);

      booking.selectCheckInDate(DateTime(2026, 9, 20));

      expect(booking.isBookingValid, isFalse);
      expect(booking.numberOfNights, isNull);
      expect(booking.totalPrice, isNull);
      expect(
        booking.validationMessage,
        'Check-out date must be after check-in date.',
      );
    });

    test('filters rooms by selected guest count', () {
      final booking = createBooking();

      expect(booking.availableRooms, hasLength(5));

      booking.setGuestCount(4);

      expect(booking.availableRooms.map((room) => room.roomCode), ['R301']);
    });

    test('clears a selected room that no longer fits the guest count', () {
      final booking = createBooking();
      booking.selectRoom(roomByCode('R101'));
      booking.setGuestCount(4);

      expect(booking.selectedRoom, isNull);
      expect(booking.validationMessage, 'Please select a check-in date.');
    });

    test('blocks R101 when the stay overlaps the hardcoded booking', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 21));
      booking.selectCheckOutDate(DateTime(2026, 9, 23));
      booking.selectRoom(roomByCode('R101'));

      expect(booking.isRoomBooked(roomByCode('R101')), isTrue);
      expect(booking.selectedRoom, isNull);
      expect(booking.isRoomBooked(roomByCode('R102')), isFalse);
      expect(
        booking.availableRooms.map((room) => room.roomCode),
        isNot(contains('R101')),
      );
      expect(
        booking.availableRooms.map((room) => room.roomCode),
        contains('R102'),
      );
    });

    test(
      'allows R101 when the new stay starts on the existing checkout day',
      () {
        final booking = createBooking();
        booking.selectCheckInDate(DateTime(2026, 9, 22));
        booking.selectCheckOutDate(DateTime(2026, 9, 24));
        booking.selectRoom(roomByCode('R101'));

        expect(booking.isRoomBooked(roomByCode('R101')), isFalse);
        expect(booking.selectedRoom?.roomCode, 'R101');
      },
    );

    test('confirms a valid booking and creates a local reference', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 15));
      booking.selectCheckOutDate(DateTime(2026, 9, 18));
      booking.selectRoom(roomByCode('R101'));
      booking.confirmBooking();

      expect(booking.isConfirmed, isTrue);
      expect(booking.lastConfirmed?.reference, 'BK-R101-15092026');
      expect(booking.bookingReference, 'BK-R101-15092026');
      expect(booking.checkInDate, isNull);
      expect(booking.checkOutDate, isNull);
      expect(booking.selectedRoom, isNull);
      expect(booking.guestCount, BookingProvider.defaultGuestCount);
      expect(booking.bookingHistory.first.reference, 'BK-R101-15092026');
      expect(booking.availableRooms, hasLength(5));
      expect(booking.lastConfirmed?.paymentMethod, 'Cash');
    });

    test('stores optional proof and selected payment method', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 15));
      booking.selectCheckOutDate(DateTime(2026, 9, 18));
      booking.selectRoom(roomByCode('R102'));
      booking.setProofFileName('id-proof.pdf');
      booking.setPaymentMethod('UPI');
      booking.confirmBooking();

      expect(booking.lastConfirmed?.proofFileName, 'id-proof.pdf');
      expect(booking.lastConfirmed?.paymentMethod, 'UPI');
    });

    test('does not confirm an incomplete booking', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 15));
      booking.confirmBooking();

      expect(booking.isConfirmed, isFalse);
      expect(booking.bookingReference, isNull);
    });

    test('hides a confirmed room when the same dates are chosen again', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 15));
      booking.selectCheckOutDate(DateTime(2026, 9, 18));
      booking.selectRoom(roomByCode('R101'));
      booking.confirmBooking();

      booking.selectCheckInDate(DateTime(2026, 9, 15));
      booking.selectCheckOutDate(DateTime(2026, 9, 18));

      expect(
        booking.availableRooms.map((room) => room.roomCode),
        isNot(contains('R101')),
      );
    });

    test('changing dates after confirm returns to draft state', () {
      final booking = createBooking();
      booking.selectCheckInDate(DateTime(2026, 9, 15));
      booking.selectCheckOutDate(DateTime(2026, 9, 18));
      booking.selectRoom(roomByCode('R101'));
      booking.confirmBooking();

      booking.selectCheckInDate(DateTime(2026, 9, 16));

      expect(booking.isConfirmed, isFalse);
      expect(booking.bookingReference, isNull);
    });
  });
}
