import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Smart Flight';
  static const String appTagline = 'Smart Flight Reservation';
  
  // Default currency symbol
  static const String currency = '₹';

  // Major Airports dataset
  static const List<Map<String, String>> airports = [
    {
      'code': 'CJB',
      'city': 'Coimbatore',
      'name': 'Coimbatore International Airport',
      'country': 'India',
      'terminal': 'T1',
    },
    {
      'code': 'MAA',
      'city': 'Chennai',
      'name': 'Chennai International Airport',
      'country': 'India',
      'terminal': 'T2',
    },
    {
      'code': 'DEL',
      'city': 'New Delhi',
      'name': 'Indira Gandhi International Airport',
      'country': 'India',
      'terminal': 'T3',
    },
    {
      'code': 'BOM',
      'city': 'Mumbai',
      'name': 'Chhatrapati Shivaji Maharaj International Airport',
      'country': 'India',
      'terminal': 'T2',
    },
    {
      'code': 'BLR',
      'city': 'Bengaluru',
      'name': 'Kempegowda International Airport',
      'country': 'India',
      'terminal': 'T1',
    },
    {
      'code': 'HYD',
      'city': 'Hyderabad',
      'name': 'Rajiv Gandhi International Airport',
      'country': 'India',
      'terminal': 'T1',
    },
    {
      'code': 'CCU',
      'city': 'Kolkata',
      'name': 'Netaji Subhash Chandra Bose Airport',
      'country': 'India',
      'terminal': 'T1',
    },
    {
      'code': 'GOI',
      'city': 'Goa',
      'name': 'Dabolim Airport',
      'country': 'India',
      'terminal': 'T1',
    },
    {
      'code': 'COK',
      'city': 'Kochi',
      'name': 'Cochin International Airport',
      'country': 'India',
      'terminal': 'T3',
    },
    {
      'code': 'DXB',
      'city': 'Dubai',
      'name': 'Dubai International Airport',
      'country': 'United Arab Emirates',
      'terminal': 'T3',
    },
    {
      'code': 'SIN',
      'city': 'Singapore',
      'name': 'Singapore Changi Airport',
      'country': 'Singapore',
      'terminal': 'T4',
    },
    {
      'code': 'LHR',
      'city': 'London',
      'name': 'Heathrow Airport',
      'country': 'United Kingdom',
      'terminal': 'T5',
    },
  ];

  // Cabin Classes
  static const List<String> cabinClasses = [
    'Economy',
    'Premium Economy',
    'Business',
    'First Class',
  ];

  // Airline Brand Colors
  static Color getAirlineColor(String code) {
    switch (code) {
      case '6E': // IndiGo
        return const Color(0xFF003B95);
      case 'AI': // Air India
        return const Color(0xFFD61821);
      case 'UK': // Vistara
        return const Color(0xFF531E44);
      case 'QP': // Akasa Air
        return const Color(0xFFFF5C00);
      case 'SG': // SpiceJet
        return const Color(0xFFED1C24);
      case 'IX': // Air India Express
        return const Color(0xFFF15A24);
      case 'EK': // Emirates
        return const Color(0xFFD71921);
      case 'SQ': // Singapore Airlines
        return const Color(0xFF0C2340);
      default:
        return const Color(0xFF0B1F3A);
    }
  }
}
