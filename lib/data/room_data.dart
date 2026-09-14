import '../models/confirmed_booking.dart';
import '../models/hotel_room.dart';

const List<HotelRoom> hotelRooms = [
  HotelRoom(
    roomCode: 'R101',
    roomType: 'Deluxe Room',
    pricePerNight: 3500,
    maxGuests: 2,
    imageAsset: 'assets/images/deluxe_room.png',
  ),
  HotelRoom(
    roomCode: 'R102',
    roomType: 'Deluxe Room',
    pricePerNight: 3500,
    maxGuests: 2,
    imageAsset: 'assets/images/deluxe_room.png',
  ),
  HotelRoom(
    roomCode: 'R201',
    roomType: 'Executive Suite',
    pricePerNight: 5800,
    maxGuests: 3,
    imageAsset: 'assets/images/executive_suite.png',
  ),
  HotelRoom(
    roomCode: 'R202',
    roomType: 'Executive Suite',
    pricePerNight: 5800,
    maxGuests: 3,
    imageAsset: 'assets/images/executive_suite.png',
  ),
  HotelRoom(
    roomCode: 'R301',
    roomType: 'Family Room',
    pricePerNight: 4200,
    maxGuests: 4,
    imageAsset: 'assets/images/family_room.png',
  ),
];

/// Seed reservation so availability can be tested before the user books.
final List<ConfirmedBooking> seedBookings = [
  ConfirmedBooking(
    reference: 'BK-R101-20092026',
    roomCode: 'R101',
    roomType: 'Deluxe Room',
    pricePerNight: 3500,
    guests: 2,
    checkIn: DateTime(2026, 9, 20),
    checkOut: DateTime(2026, 9, 22),
    nights: 2,
    totalPrice: 7000,
    paymentMethod: 'Cash',
  ),
];

String roomImageAsset(String roomCode) {
  return hotelRooms
      .firstWhere(
        (room) => room.roomCode == roomCode,
        orElse: () => hotelRooms.first,
      )
      .imageAsset;
}
