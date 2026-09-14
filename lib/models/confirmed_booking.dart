import 'dart:convert';

class ConfirmedBooking {
  const ConfirmedBooking({
    required this.reference,
    required this.roomCode,
    required this.roomType,
    required this.pricePerNight,
    required this.guests,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.totalPrice,
    this.proofFileName,
    this.paymentMethod,
  });

  final String reference;
  final String roomCode;
  final String roomType;
  final int pricePerNight;
  final int guests;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final int totalPrice;
  final String? proofFileName;
  final String? paymentMethod;

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'roomCode': roomCode,
      'roomType': roomType,
      'pricePerNight': pricePerNight,
      'guests': guests,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'nights': nights,
      'totalPrice': totalPrice,
      'proofFileName': proofFileName,
      'paymentMethod': paymentMethod,
    };
  }

  factory ConfirmedBooking.fromJson(Map<String, dynamic> json) {
    return ConfirmedBooking(
      reference: json['reference'] as String,
      roomCode: json['roomCode'] as String,
      roomType: json['roomType'] as String,
      pricePerNight: json['pricePerNight'] as int,
      guests: json['guests'] as int,
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      nights: json['nights'] as int,
      totalPrice: json['totalPrice'] as int,
      proofFileName: json['proofFileName'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
    );
  }

  static String encodeList(List<ConfirmedBooking> bookings) {
    return jsonEncode(bookings.map((booking) => booking.toJson()).toList());
  }

  static List<ConfirmedBooking> decodeList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ConfirmedBooking.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
