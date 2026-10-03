import 'flight_model.dart';
import 'passenger_model.dart';
import 'addon_model.dart';

class BookingModel {
  final String bookingId;
  final String pnr;
  final String userId;
  final String flightId;
  final String airline;
  final String airlineCode;
  final String flightNumber;
  final String departure;
  final String arrival;
  final String departureDate;
  final String departureTime;
  final String arrivalTime;
  final int passengers;
  final List<PassengerModel> passengerDetails;
  final List<String> selectedSeats;
  final List<AddonItem> selectedAddons;
  final int fare;
  final int taxes;
  final int seatCharges;
  final int addonCharges;
  final int discount;
  final int totalAmount;
  final String bookingStatus; // 'Confirmed', 'Cancelled', 'Completed'
  final String paymentStatus; // 'Paid', 'Refunded', 'Pending'
  final String paymentMethod; // 'UPI', 'Credit Card', etc.
  final String bookingDate;
  final int? createdAt;
  final FlightOffer flight;

  const BookingModel({
    required this.bookingId,
    required this.pnr,
    required this.userId,
    required this.flightId,
    required this.airline,
    required this.airlineCode,
    required this.flightNumber,
    required this.departure,
    required this.arrival,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.passengers,
    required this.passengerDetails,
    required this.selectedSeats,
    this.selectedAddons = const [],
    required this.fare,
    required this.taxes,
    this.seatCharges = 0,
    this.addonCharges = 0,
    this.discount = 0,
    required this.totalAmount,
    this.bookingStatus = 'Confirmed',
    this.paymentStatus = 'Paid',
    required this.paymentMethod,
    required this.bookingDate,
    this.createdAt,
    required this.flight,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'pnr': pnr,
      'userId': userId,
      'flightId': flightId,
      'airline': airline,
      'airlineCode': airlineCode,
      'flightNumber': flightNumber,
      'departure': departure,
      'arrival': arrival,
      'departureDate': departureDate,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'passengers': passengers,
      'passengerDetails': passengerDetails.map((p) => p.toMap()).toList(),
      'selectedSeats': selectedSeats,
      'selectedAddons': selectedAddons.map((a) => a.toMap()).toList(),
      'fare': fare,
      'taxes': taxes,
      'seatCharges': seatCharges,
      'addonCharges': addonCharges,
      'discount': discount,
      'totalAmount': totalAmount,
      'bookingStatus': bookingStatus,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'bookingDate': bookingDate,
      'createdAt': createdAt ?? DateTime.now().millisecondsSinceEpoch,
      'flight': flight.toMap(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      bookingId: map['bookingId'] ?? '',
      pnr: map['pnr'] ?? '',
      userId: map['userId'] ?? '',
      flightId: map['flightId'] ?? '',
      airline: map['airline'] ?? '',
      airlineCode: map['airlineCode'] ?? '',
      flightNumber: map['flightNumber'] ?? '',
      departure: map['departure'] ?? '',
      arrival: map['arrival'] ?? '',
      departureDate: map['departureDate'] ?? '',
      departureTime: map['departureTime'] ?? '',
      arrivalTime: map['arrivalTime'] ?? '',
      passengers: (map['passengers'] as num?)?.toInt() ?? 1,
      passengerDetails: (map['passengerDetails'] as List<dynamic>?)
              ?.map((item) => PassengerModel.fromMap(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      selectedSeats: (map['selectedSeats'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      selectedAddons: (map['selectedAddons'] as List<dynamic>?)
              ?.map((item) => AddonItem.fromMap(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      fare: (map['fare'] as num?)?.toInt() ?? 0,
      taxes: (map['taxes'] as num?)?.toInt() ?? 0,
      seatCharges: (map['seatCharges'] as num?)?.toInt() ?? 0,
      addonCharges: (map['addonCharges'] as num?)?.toInt() ?? 0,
      discount: (map['discount'] as num?)?.toInt() ?? 0,
      totalAmount: (map['totalAmount'] as num?)?.toInt() ?? 0,
      bookingStatus: map['bookingStatus'] ?? 'Confirmed',
      paymentStatus: map['paymentStatus'] ?? 'Paid',
      paymentMethod: map['paymentMethod'] ?? 'UPI',
      bookingDate: map['bookingDate'] ?? '',
      createdAt: (map['createdAt'] as num?)?.toInt(),
      flight: map['flight'] != null
          ? FlightOffer.fromMap(Map<String, dynamic>.from(map['flight']))
          : FlightOffer(
              id: map['flightId'] ?? '',
              airlineName: map['airline'] ?? '',
              airlineCode: map['airlineCode'] ?? '',
              flightNumber: map['flightNumber'] ?? '',
              originCode: map['departure'] ?? '',
              originCity: map['departure'] ?? '',
              destinationCode: map['arrival'] ?? '',
              destinationCity: map['arrival'] ?? '',
              departureTime: map['departureTime'] ?? '',
              arrivalTime: map['arrivalTime'] ?? '',
              duration: '',
              stops: 0,
              cabinClass: 'Economy',
              price: (map['fare'] as num?)?.toInt() ?? 0,
              refundable: true,
              includedBaggage: '15 kg',
            ),
    );
  }

  BookingModel copyWith({
    String? bookingStatus,
    String? paymentStatus,
  }) {
    return BookingModel(
      bookingId: bookingId,
      pnr: pnr,
      userId: userId,
      flightId: flightId,
      airline: airline,
      airlineCode: airlineCode,
      flightNumber: flightNumber,
      departure: departure,
      arrival: arrival,
      departureDate: departureDate,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      passengers: passengers,
      passengerDetails: passengerDetails,
      selectedSeats: selectedSeats,
      selectedAddons: selectedAddons,
      fare: fare,
      taxes: taxes,
      seatCharges: seatCharges,
      addonCharges: addonCharges,
      discount: discount,
      totalAmount: totalAmount,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod,
      bookingDate: bookingDate,
      createdAt: createdAt,
      flight: flight,
    );
  }
}
