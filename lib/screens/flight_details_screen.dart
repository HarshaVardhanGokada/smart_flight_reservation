import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/flight_model.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/app_button.dart';
import 'passenger_details_screen.dart';

class FlightDetailsScreen extends StatelessWidget {
  final FlightOffer flight;
  final FlightSearchCriteria criteria;

  const FlightDetailsScreen({
    super.key,
    required this.flight,
    required this.criteria,
  });

  @override
  Widget build(BuildContext context) {
    final airlineColor = AppConstants.getAirlineColor(flight.airlineCode);
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy');

    final baseFare = flight.price * criteria.totalPassengers;
    final taxes = (baseFare * 0.12).round();
    final total = baseFare + taxes;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Flight Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Flight Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Airline info & Flight number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: airlineColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: airlineColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            flight.airlineName,
                            style: TextStyle(
                              color: airlineColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          flight.flightNumber,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      flight.aircraftType,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Text(
                  dateFormat.format(criteria.departureDate),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                // Departure & Arrival Vertical Timeline
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline nodes
                    Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryBlue,
                              width: 3,
                            ),
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 60,
                          color: const Color(0xFFCBD5E1),
                        ),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 14),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Origin
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${flight.departureTime} • ${flight.originCode}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Terminal ${flight.departureTerminal}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            flight.originCity,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // Destination
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${flight.arrivalTime} • ${flight.destinationCode}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Terminal ${flight.arrivalTerminal}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            flight.destinationCity,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),

                // Badges row: Duration, Cabin, Stops
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoBadge(Icons.timer_outlined, flight.duration),
                    _infoBadge(Icons.airline_seat_recline_normal_rounded, flight.cabinClass),
                    _infoBadge(Icons.commit_rounded, flight.stopsLabel),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Baggage Allowance Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Baggage Allowance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.work_outline_rounded,
                        color: AppTheme.primaryNavy, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Cabin Baggage: 7 kg (1 piece per passenger)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.luggage_outlined,
                        color: AppTheme.primaryNavy, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Check-in Baggage: ${flight.includedBaggage}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Cancellation & Policies Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fare Policies & Cancellation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _policyRow(
                  Icons.check_circle_outline_rounded,
                  'Cancellation: Eligible up to 2 hours before departure. Flat cancellation fee ₹1,500/passenger applies.',
                  AppTheme.successGreen,
                ),
                const SizedBox(height: 8),
                _policyRow(
                  Icons.sync_rounded,
                  'Date change: Allowed up to 4 hours before departure with fare difference + ₹1,000 airline fee.',
                  AppTheme.primaryBlue,
                ),
                const SizedBox(height: 8),
                _policyRow(
                  Icons.restaurant_menu_rounded,
                  flight.mealIncluded
                      ? 'Complimentary in-flight meal included in this cabin.'
                      : 'In-flight meals can be pre-booked in the add-ons step.',
                  AppTheme.accentGold,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Price Breakdown
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated Fare Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _fareRow(
                  'Base Fare (${criteria.totalPassengers} Passenger${criteria.totalPassengers > 1 ? 's' : ''})',
                  '₹$baseFare',
                ),
                _fareRow('Taxes & Airport Development Fee', '₹$taxes'),
                const Divider(),
                _fareRow('Total Base Price', '₹$total', isBold: true),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Continue CTA
          AppButton(
            label: 'Continue to Passenger Details',
            icon: Icons.person_add_alt_1_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PassengerDetailsScreen(
                    flight: flight,
                    criteria: criteria,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _policyRow(IconData icon, String text, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fareRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isBold ? AppTheme.primaryNavy : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
