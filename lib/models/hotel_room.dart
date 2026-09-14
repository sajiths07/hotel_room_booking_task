class HotelRoom {
  const HotelRoom({
    required this.roomCode,
    required this.roomType,
    required this.pricePerNight,
    required this.maxGuests,
    required this.imageAsset,
  });

  final String roomCode;
  final String roomType;
  final int pricePerNight;
  final int maxGuests;
  final String imageAsset;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is HotelRoom && other.roomCode == roomCode;
  }

  @override
  int get hashCode => roomCode.hashCode;
}
