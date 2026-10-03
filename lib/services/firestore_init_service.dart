import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreInitService {
  static final FirestoreInitService _instance = FirestoreInitService._internal();
  factory FirestoreInitService() => _instance;
  FirestoreInitService._internal();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Automatically checks and seeds initial Firestore collections
  /// (flights, airports, reviews) so faculty demonstration immediately
  /// sees live documents in Firebase Console -> Firestore Database.
  Future<void> initializeDemoDataIfNeeded({bool force = false}) async {
    try {
      final flightsSnapshot = await _firestore.collection('flights').limit(1).get();
      if (flightsSnapshot.docs.isEmpty || force) {
        await seedFlights();
      }

      final airportsSnapshot = await _firestore.collection('airports').limit(1).get();
      if (airportsSnapshot.docs.isEmpty || force) {
        await seedAirports();
      }

      final reviewsSnapshot = await _firestore.collection('reviews').limit(1).get();
      if (reviewsSnapshot.docs.isEmpty || force) {
        await seedReviews();
      }
    } catch (e) {
      debugPrint('FirestoreInitService notice: $e');
    }
  }

  /// Seeds authentic flight documents to Firestore 'flights'
  Future<void> seedFlights() async {
    final batch = _firestore.batch();
    final flightsCol = _firestore.collection('flights');

    final sampleFlights = [
      {
        'id': 'FL-6E-339',
        'airline': 'IndiGo',
        'airlineCode': '6E',
        'flightNumber': '6E-339',
        'from': 'Coimbatore (CJB)',
        'to': 'Chennai (MAA)',
        'originCode': 'CJB',
        'destinationCode': 'MAA',
        'departureTime': '06:10',
        'arrivalTime': '07:15',
        'duration': '1h 05m',
        'stops': 0,
        'stopsLabel': 'Non-stop',
        'price': 3450,
        'availableSeats': 42,
        'cabinClass': 'Economy',
        'aircraft': 'Airbus A321neo',
        'terminal': 'T1',
        'includedBaggage': '15 kg Check-in + 7 kg Cabin',
        'refundable': true,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'FL-AI-658',
        'airline': 'Air India',
        'airlineCode': 'AI',
        'flightNumber': 'AI-658',
        'from': 'Coimbatore (CJB)',
        'to': 'Chennai (MAA)',
        'originCode': 'CJB',
        'destinationCode': 'MAA',
        'departureTime': '09:30',
        'arrivalTime': '10:45',
        'duration': '1h 15m',
        'stops': 0,
        'stopsLabel': 'Non-stop',
        'price': 4150,
        'availableSeats': 28,
        'cabinClass': 'Economy',
        'aircraft': 'Airbus A320neo',
        'terminal': 'T1',
        'includedBaggage': '20 kg Check-in + 7 kg Cabin',
        'refundable': true,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'FL-6E-2041',
        'airline': 'IndiGo',
        'airlineCode': '6E',
        'flightNumber': '6E-2041',
        'from': 'Delhi (DEL)',
        'to': 'Mumbai (BOM)',
        'originCode': 'DEL',
        'destinationCode': 'BOM',
        'departureTime': '07:00',
        'arrivalTime': '09:10',
        'duration': '2h 10m',
        'stops': 0,
        'stopsLabel': 'Non-stop',
        'price': 4890,
        'availableSeats': 56,
        'cabinClass': 'Economy',
        'aircraft': 'Airbus A321neo',
        'terminal': 'T1D',
        'includedBaggage': '15 kg Check-in + 7 kg Cabin',
        'refundable': true,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'FL-UK-995',
        'airline': 'Vistara',
        'airlineCode': 'UK',
        'flightNumber': 'UK-995',
        'from': 'Delhi (DEL)',
        'to': 'Mumbai (BOM)',
        'originCode': 'DEL',
        'destinationCode': 'BOM',
        'departureTime': '11:45',
        'arrivalTime': '14:00',
        'duration': '2h 15m',
        'stops': 0,
        'stopsLabel': 'Non-stop',
        'price': 5850,
        'availableSeats': 34,
        'cabinClass': 'Economy',
        'aircraft': 'Boeing 787-9 Dreamliner',
        'terminal': 'T3',
        'includedBaggage': '20 kg Check-in + 7 kg Cabin',
        'refundable': true,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'FL-QP-1314',
        'airline': 'Akasa Air',
        'airlineCode': 'QP',
        'flightNumber': 'QP-1314',
        'from': 'Bengaluru (BLR)',
        'to': 'Delhi (DEL)',
        'originCode': 'BLR',
        'destinationCode': 'DEL',
        'departureTime': '08:20',
        'arrivalTime': '11:05',
        'duration': '2h 45m',
        'stops': 0,
        'stopsLabel': 'Non-stop',
        'price': 4200,
        'availableSeats': 60,
        'cabinClass': 'Economy',
        'aircraft': 'Boeing 737 MAX 8',
        'terminal': 'T1',
        'includedBaggage': '15 kg Check-in + 7 kg Cabin',
        'refundable': true,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'FL-AI-506',
        'airline': 'Air India',
        'airlineCode': 'AI',
        'flightNumber': 'AI-506',
        'from': 'Bengaluru (BLR)',
        'to': 'Delhi (DEL)',
        'originCode': 'BLR',
        'destinationCode': 'DEL',
        'departureTime': '16:30',
        'arrivalTime': '19:15',
        'duration': '2h 45m',
        'stops': 0,
        'stopsLabel': 'Non-stop',
        'price': 5100,
        'availableSeats': 40,
        'cabinClass': 'Economy',
        'aircraft': 'Airbus A350-900',
        'terminal': 'T2',
        'includedBaggage': '25 kg Check-in + 7 kg Cabin',
        'refundable': true,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'FL-6E-728',
        'airline': 'IndiGo',
        'airlineCode': '6E',
        'flightNumber': '6E-728',
        'from': 'Hyderabad (HYD)',
        'to': 'Mumbai (BOM)',
        'originCode': 'HYD',
        'destinationCode': 'BOM',
        'departureTime': '13:10',
        'arrivalTime': '14:35',
        'duration': '1h 25m',
        'stops': 0,
        'stopsLabel': 'Non-stop',
        'price': 3650,
        'availableSeats': 38,
        'cabinClass': 'Economy',
        'aircraft': 'Airbus A320neo',
        'terminal': 'T1',
        'includedBaggage': '15 kg Check-in + 7 kg Cabin',
        'refundable': true,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'FL-EK-501',
        'airline': 'Emirates',
        'airlineCode': 'EK',
        'flightNumber': 'EK-501',
        'from': 'Mumbai (BOM)',
        'to': 'Dubai (DXB)',
        'originCode': 'BOM',
        'destinationCode': 'DXB',
        'departureTime': '04:30',
        'arrivalTime': '06:15',
        'duration': '3h 15m',
        'stops': 0,
        'stopsLabel': 'Non-stop',
        'price': 14200,
        'availableSeats': 50,
        'cabinClass': 'Economy',
        'aircraft': 'Boeing 777-300ER',
        'terminal': 'T2',
        'includedBaggage': '30 kg Check-in + 7 kg Cabin',
        'refundable': true,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final flight in sampleFlights) {
      final docRef = flightsCol.doc(flight['id'] as String);
      batch.set(docRef, flight, SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// Seeds authentic airport records to Firestore 'airports'
  Future<void> seedAirports() async {
    final batch = _firestore.batch();
    final airportsCol = _firestore.collection('airports');

    final sampleAirports = [
      {'code': 'CJB', 'city': 'Coimbatore', 'name': 'Coimbatore International Airport', 'country': 'India'},
      {'code': 'MAA', 'city': 'Chennai', 'name': 'Chennai International Airport', 'country': 'India'},
      {'code': 'DEL', 'city': 'Delhi', 'name': 'Indira Gandhi International Airport', 'country': 'India'},
      {'code': 'BOM', 'city': 'Mumbai', 'name': 'Chhatrapati Shivaji Maharaj International Airport', 'country': 'India'},
      {'code': 'BLR', 'city': 'Bengaluru', 'name': 'Kempegowda International Airport', 'country': 'India'},
      {'code': 'HYD', 'city': 'Hyderabad', 'name': 'Rajiv Gandhi International Airport', 'country': 'India'},
      {'code': 'CCU', 'city': 'Kolkata', 'name': 'Netaji Subhash Chandra Bose International Airport', 'country': 'India'},
      {'code': 'GOI', 'city': 'Goa', 'name': 'Dabolim Airport', 'country': 'India'},
      {'code': 'DXB', 'city': 'Dubai', 'name': 'Dubai International Airport', 'country': 'United Arab Emirates'},
      {'code': 'SIN', 'city': 'Singapore', 'name': 'Singapore Changi Airport', 'country': 'Singapore'},
      {'code': 'LHR', 'city': 'London', 'name': 'Heathrow Airport', 'country': 'United Kingdom'},
    ];

    for (final airport in sampleAirports) {
      final docRef = airportsCol.doc(airport['code'] as String);
      batch.set(docRef, {
        ...airport,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// Seeds customer reviews to Firestore 'reviews'
  Future<void> seedReviews() async {
    final batch = _firestore.batch();
    final reviewsCol = _firestore.collection('reviews');

    final sampleReviews = [
      {
        'id': 'REV-1',
        'userName': 'Harsha Vardhan',
        'rating': 5,
        'comment': 'Outstanding experience! Got my PDF e-ticket immediately and seat selection was seamless.',
        'route': 'Coimbatore (CJB) → Chennai (MAA)',
        'date': 'October 2026',
        'verified': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'REV-2',
        'userName': 'Priya Sharma',
        'rating': 5,
        'comment': 'Super clean flight booking UI. Real-time PNR tracking and fast payment made it a breeze.',
        'route': 'Delhi (DEL) → Mumbai (BOM)',
        'date': 'September 2026',
        'verified': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'REV-3',
        'userName': 'Rajesh Kumar',
        'rating': 4.8,
        'comment': 'Zero hidden charges and genuine airline schedule. Highly recommend Smart Flight!',
        'route': 'Bengaluru (BLR) → Delhi (DEL)',
        'date': 'August 2026',
        'verified': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final rev in sampleReviews) {
      final docRef = reviewsCol.doc(rev['id'] as String);
      batch.set(docRef, rev, SetOptions(merge: true));
    }

    await batch.commit();
  }
}
