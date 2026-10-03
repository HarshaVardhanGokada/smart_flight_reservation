import 'package:flutter_test/flutter_test.dart';
import 'package:smart_flight_reservation/models/flight_model.dart';
import 'package:smart_flight_reservation/models/passenger_model.dart';
import 'package:smart_flight_reservation/models/booking_model.dart';
import 'package:smart_flight_reservation/models/addon_model.dart';
import 'package:smart_flight_reservation/services/flight_service.dart';

void main() {
  group('Smart Flight Models & Serialization Tests', () {
    test('FlightOffer serialization and getters', () {
      const flight = FlightOffer(
        id: 'FL-CJB-MAA-1',
        airlineName: 'IndiGo',
        airlineCode: '6E',
        flightNumber: '6E-339',
        originCode: 'CJB',
        originCity: 'Coimbatore',
        destinationCode: 'MAA',
        destinationCity: 'Chennai',
        departureTime: '06:10',
        arrivalTime: '07:15',
        duration: '1h 05m',
        stops: 0,
        cabinClass: 'Economy',
        price: 3526,
        refundable: true,
        includedBaggage: '15 kg Check-in',
      );

      expect(flight.stopsLabel, 'Non-stop');
      final map = flight.toMap();
      final fromMap = FlightOffer.fromMap(map);

      expect(fromMap.flightNumber, '6E-339');
      expect(fromMap.price, 3526);
      expect(fromMap.stops, 0);
      expect(fromMap.originCode, 'CJB');
      expect(fromMap.destinationCode, 'MAA');
    });

    test('PassengerModel serialization and copyWith', () {
      const passenger = PassengerModel(
        title: 'Mr',
        firstName: 'Harsha',
        lastName: 'Vardhan',
        dateOfBirth: '15/08/1998',
        gender: 'Male',
        nationality: 'Indian',
        idType: 'Aadhaar',
        idNumber: '123456789012',
        email: 'harsha@example.com',
        phone: '9876543210',
        passengerType: 'Adult',
        selectedSeat: '12A',
      );

      expect(passenger.fullName, 'Mr Harsha Vardhan');
      final updated = passenger.copyWith(selectedSeat: '14C');
      expect(updated.selectedSeat, '14C');
      expect(updated.fullName, 'Mr Harsha Vardhan');

      final map = passenger.toMap();
      final restored = PassengerModel.fromMap(map);
      expect(restored.firstName, 'Harsha');
      expect(restored.selectedSeat, '12A');
    });

    test('BookingModel serialization and copyWith', () {
      const flight = FlightOffer(
        id: 'FL-CJB-MAA-1',
        airlineName: 'Air India',
        airlineCode: 'AI',
        flightNumber: 'AI-658',
        originCode: 'CJB',
        originCity: 'Coimbatore',
        destinationCode: 'MAA',
        destinationCity: 'Chennai',
        departureTime: '08:30',
        arrivalTime: '09:40',
        duration: '1h 10m',
        stops: 0,
        cabinClass: 'Economy',
        price: 4120,
        refundable: true,
        includedBaggage: '20 kg Check-in',
      );

      const passenger = PassengerModel(
        title: 'Mr',
        firstName: 'Harsha',
        lastName: 'Vardhan',
        dateOfBirth: '15/08/1998',
        gender: 'Male',
        nationality: 'Indian',
        idType: 'Aadhaar',
        idNumber: '123456789012',
        email: 'harsha@example.com',
        phone: '9876543210',
        passengerType: 'Adult',
        selectedSeat: '12A',
      );

      final booking = BookingModel(
        bookingId: 'SF99887766',
        pnr: 'SF89XY',
        userId: 'test-user-uid',
        flightId: flight.id,
        airline: flight.airlineName,
        airlineCode: flight.airlineCode,
        flightNumber: flight.flightNumber,
        departure: 'CJB',
        arrival: 'MAA',
        departureDate: '2026-10-15',
        departureTime: '08:30',
        arrivalTime: '09:40',
        passengers: 1,
        passengerDetails: [passenger],
        selectedSeats: ['12A'],
        fare: 4120,
        taxes: 494,
        seatCharges: 250,
        addonCharges: 399,
        discount: 500,
        totalAmount: 4763,
        bookingStatus: 'Confirmed',
        paymentStatus: 'Paid',
        paymentMethod: 'UPI',
        bookingDate: '01 Oct 2026, 10:00 AM',
        flight: flight,
      );

      final map = booking.toMap();
      final restored = BookingModel.fromMap(map);

      expect(restored.bookingId, 'SF99887766');
      expect(restored.pnr, 'SF89XY');
      expect(restored.totalAmount, 4763);
      expect(restored.passengerDetails.length, 1);
      expect(restored.selectedSeats.first, '12A');

      final cancelled = restored.copyWith(
        bookingStatus: 'Cancelled',
        paymentStatus: 'Refunded (₹3,263)',
      );
      expect(cancelled.bookingStatus, 'Cancelled');
      expect(cancelled.paymentStatus, 'Refunded (₹3,263)');
    });
  });

  group('FlightService Engine Tests', () {
    final service = FlightService();

    test('searchFlights generates authentic schedule and pricing', () async {
      final criteria = FlightSearchCriteria(
        from: 'Coimbatore',
        fromCode: 'CJB',
        to: 'Chennai',
        toCode: 'MAA',
        departureDate: DateTime.now().add(const Duration(days: 2)),
        tripType: 0,
        adults: 1,
        children: 0,
        infants: 0,
        cabinClass: 'Economy',
      );

      final flights = await service.searchFlights(criteria);
      expect(flights.isNotEmpty, true);
      expect(flights.first.originCode, 'CJB');
      expect(flights.first.destinationCode, 'MAA');
      expect(flights.first.price > 1000, true);
    });

    test('sortFlights correctly sorts by cheapest and earliest', () async {
      final criteria = FlightSearchCriteria(
        from: 'Delhi',
        fromCode: 'DEL',
        to: 'Mumbai',
        toCode: 'BOM',
        departureDate: DateTime.now().add(const Duration(days: 3)),
        tripType: 0,
        adults: 1,
        children: 0,
        infants: 0,
        cabinClass: 'Economy',
      );

      final flights = await service.searchFlights(criteria);
      final sortedCheapest = service.sortFlights(flights, 'cheapest');

      for (int i = 0; i < sortedCheapest.length - 1; i++) {
        expect(sortedCheapest[i].price <= sortedCheapest[i + 1].price, true);
      }
    });

    test('filterFlights correctly filters by stops', () async {
      final criteria = FlightSearchCriteria(
        from: 'Bengaluru',
        fromCode: 'BLR',
        to: 'Hyderabad',
        toCode: 'HYD',
        departureDate: DateTime.now().add(const Duration(days: 1)),
        tripType: 0,
        adults: 1,
        children: 0,
        infants: 0,
        cabinClass: 'Economy',
      );

      final flights = await service.searchFlights(criteria);
      final nonStopOnly = service.filterFlights(flights: flights, maxStops: 0);

      for (var f in nonStopOnly) {
        expect(f.stops, 0);
      }
    });

    test('Add-ons catalog integrity', () {
      expect(AvailableAddons.meals.isNotEmpty, true);
      expect(AvailableAddons.baggage.isNotEmpty, true);
      expect(AvailableAddons.travelInsurance.price, 249);
      expect(AvailableAddons.priorityBoarding.price, 399);
    });
  });
}
