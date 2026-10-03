import 'package:flutter/material.dart';
import '../models/flight_model.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class FlightCard extends StatelessWidget {
  final FlightOffer flight;
  final VoidCallback onSelect;

  const FlightCard({
    super.key,
    required this.flight,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final airlineColor = AppConstants.getAirlineColor(flight.airlineCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Airline badge, Flight number, Cabin class tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: airlineColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: airlineColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.flight_takeoff_rounded,
                                size: 14,
                                color: airlineColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                flight.airlineName,
                                style: TextStyle(
                                  color: airlineColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          flight.flightNumber,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        flight.cabinClass,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Flight Timeline & Airport codes
                Row(
                  children: [
                    // Departure
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.departureTime,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            flight.originCode,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          Text(
                            flight.originCity,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Flight Path Graphic
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Text(
                            flight.duration,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1.5,
                                      color: const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              Transform.rotate(
                                angle: 1.57, // 90 degrees
                                child: const Icon(
                                  Icons.flight_rounded,
                                  size: 18,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: flight.stops == 0
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              flight.stopsLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: flight.stops == 0
                                    ? AppTheme.successGreen
                                    : AppTheme.accentGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrival
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            flight.arrivalTime,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            flight.destinationCode,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          Text(
                            flight.destinationCity,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Bottom row: Baggage tag + Price + Select CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.luggage_outlined,
                          size: 15,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          flight.includedBaggage.split('+').first.trim(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'from',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            Text(
                              '₹${flight.price}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: onSelect,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            minimumSize: const Size(0, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Select',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
