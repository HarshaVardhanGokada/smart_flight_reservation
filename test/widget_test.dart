import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_flight_reservation/models/flight_model.dart';
import 'package:smart_flight_reservation/utils/app_theme.dart';
import 'package:smart_flight_reservation/widgets/app_button.dart';
import 'package:smart_flight_reservation/widgets/flight_card.dart';

void main() {
  testWidgets('AppButton renders label and triggers callback', (tester) async {
    bool wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AppButton(
            label: 'Search Flights',
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Search Flights'), findsOneWidget);
    await tester.tap(find.text('Search Flights'));
    expect(wasPressed, true);
  });

  testWidgets('FlightCard displays airline, route, price, and select button', (
    tester,
  ) async {
    bool selected = false;
    const flight = FlightOffer(
      id: 'FL-TEST-1',
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

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: FlightCard(
            flight: flight,
            onSelect: () {
              selected = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('IndiGo'), findsOneWidget);
    expect(find.text('6E-339'), findsOneWidget);
    expect(find.text('CJB'), findsOneWidget);
    expect(find.text('MAA'), findsOneWidget);
    expect(find.text('₹3526'), findsOneWidget);
    expect(find.text('Select'), findsOneWidget);

    await tester.tap(find.text('Select'));
    expect(selected, true);
  });
}