import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_flight_reservation/models/flight_model.dart';
import 'package:smart_flight_reservation/models/passenger_model.dart';
import 'package:smart_flight_reservation/models/booking_model.dart';
import 'package:smart_flight_reservation/services/auth_service.dart';
import 'package:smart_flight_reservation/services/ticket_pdf_service.dart';
import 'package:smart_flight_reservation/utils/country_codes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Requirement 1, 2, 4: Dynamic Phone & Country Code Tests', () {
    test('Format Indian phone numbers dynamically to strict E.164', () {
      final india = CountryCodes.allCountries.firstWhere((c) => c.dialCode == '+91');

      // Test Customer A
      final phoneA = CountryCodes.formatE164(country: india, rawNumber: '9876543210');
      expect(phoneA, '+919876543210');

      // Test Customer B
      final phoneB = CountryCodes.formatE164(country: india, rawNumber: '9123456789');
      expect(phoneB, '+919123456789');

      // Raw with spaces/dashes
      final phoneFormatted = CountryCodes.formatE164(country: india, rawNumber: '98765 43210');
      expect(phoneFormatted, '+919876543210');

      // Raw with leading zero
      final phoneLeadingZero = CountryCodes.formatE164(country: india, rawNumber: '09876543210');
      expect(phoneLeadingZero, '+919876543210');
    });

    test('Format International phone numbers (US, UK, UAE) dynamically', () {
      final us = CountryCodes.allCountries.firstWhere((c) => c.dialCode == '+1' && c.code == 'US');
      final uk = CountryCodes.allCountries.firstWhere((c) => c.dialCode == '+44');
      final uae = CountryCodes.allCountries.firstWhere((c) => c.dialCode == '+971');

      // US Number: +1 2025550123
      expect(CountryCodes.formatE164(country: us, rawNumber: '2025550123'), '+12025550123');

      // UK Number: +44 7700900123
      expect(CountryCodes.formatE164(country: uk, rawNumber: '7700900123'), '+447700900123');

      // UAE Number: +971 501234567
      expect(CountryCodes.formatE164(country: uae, rawNumber: '501234567'), '+971501234567');
    });

    test('Validate phone numbers accurately', () {
      final india = CountryCodes.allCountries.firstWhere((c) => c.dialCode == '+91');
      final us = CountryCodes.allCountries.firstWhere((c) => c.dialCode == '+1' && c.code == 'US');

      expect(CountryCodes.isValidPhoneNumber(country: india, rawNumber: '9876543210'), isTrue);
      expect(CountryCodes.isValidPhoneNumber(country: india, rawNumber: '9123456789'), isTrue);
      expect(CountryCodes.isValidPhoneNumber(country: india, rawNumber: '123'), isFalse);
      expect(CountryCodes.isValidPhoneNumber(country: india, rawNumber: '1234567890123'), isFalse);

      expect(CountryCodes.isValidPhoneNumber(country: us, rawNumber: '2025550123'), isTrue);
      expect(CountryCodes.isValidPhoneNumber(country: us, rawNumber: '12345'), isFalse);
    });
  });

  group('Requirement 11: Error Message Translation Tests', () {
    final authService = AuthService();

    test('Translates all required error codes to exact specified messages', () {
      expect(
        authService.getFirebaseErrorMessage(
          FirebaseAuthException(code: 'invalid-phone-number'),
        ),
        'Please enter a valid phone number.',
      );

      expect(
        authService.getFirebaseErrorMessage(
          FirebaseAuthException(code: 'invalid-verification-code'),
        ),
        'Incorrect OTP. Please try again.',
      );

      expect(
        authService.getFirebaseErrorMessage(
          FirebaseAuthException(code: 'session-expired'),
        ),
        'OTP expired. Please request a new OTP.',
      );

      expect(
        authService.getFirebaseErrorMessage(
          FirebaseAuthException(code: 'too-many-requests'),
        ),
        'Too many OTP requests. Please wait and try again.',
      );

      expect(
        authService.getFirebaseErrorMessage(
          FirebaseAuthException(code: 'sms-send-failed'),
        ),
        'Unable to send OTP. Please check the phone number and try again.',
      );
    });
  });

  group('Requirement 7, 8, 9: Dynamic Invoice & PDF Ticket Tests', () {
    test('Generate PDF bytes dynamically with TicketPdfService', () async {
      const flight = FlightOffer(
        id: 'FL-TEST-1',
        airlineName: 'Air India',
        airlineCode: 'AI',
        flightNumber: 'AI-202',
        originCode: 'DEL',
        originCity: 'Delhi',
        destinationCode: 'BOM',
        destinationCity: 'Mumbai',
        departureTime: '10:00',
        arrivalTime: '12:15',
        duration: '2h 15m',
        stops: 0,
        cabinClass: 'Economy',
        price: 4500,
        refundable: true,
        includedBaggage: '25 kg Check-in',
      );

      const passenger = PassengerModel(
        title: 'Ms',
        firstName: 'Jane',
        lastName: 'Doe',
        dateOfBirth: '20/05/1995',
        gender: 'Female',
        nationality: 'Indian',
        idType: 'Passport',
        idNumber: 'P12345678',
        email: 'jane.doe@example.com',
        phone: '9876543210',
        passengerType: 'Adult',
        selectedSeat: '14B',
      );

      final booking = BookingModel(
        bookingId: 'BK-TEST-999',
        pnr: 'SMART99',
        userId: 'USER_TEST_1',
        flightId: flight.id,
        airline: flight.airlineName,
        airlineCode: flight.airlineCode,
        flightNumber: flight.flightNumber,
        departure: 'Delhi (DEL)',
        arrival: 'Mumbai (BOM)',
        departureDate: '15 Oct 2026',
        departureTime: flight.departureTime,
        arrivalTime: flight.arrivalTime,
        passengers: 1,
        passengerDetails: [passenger],
        selectedSeats: ['14B'],
        fare: 4500,
        taxes: 500,
        totalAmount: 5000,
        paymentMethod: 'UPI',
        bookingDate: '01 Oct 2026',
        flight: flight,
      );

      final pdfBytes = await TicketPdfService.generateTicketPdf(booking);
      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(1000));
    });
  });
}
