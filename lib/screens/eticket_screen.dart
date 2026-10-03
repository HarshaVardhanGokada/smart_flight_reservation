import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/booking_model.dart';
import '../services/ticket_pdf_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_button.dart';

class ETicketScreen extends StatelessWidget {
  final BookingModel booking;

  const ETicketScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final flight = booking.flight;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('E-Ticket / Boarding Pass'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () async {
              await TicketPdfService.printOrShareTicket(booking);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Boarding Pass Outer Container
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Header Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryNavy,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(23)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.flight_takeoff_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SMART FLIGHT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                '${booking.airline} • ${booking.flightNumber}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: booking.bookingStatus == 'Cancelled'
                              ? AppTheme.dangerRed
                              : AppTheme.successGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking.bookingStatus.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Flight Route & Times
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.departure,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                flight.originCity,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                booking.departureTime,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                              Text(
                                'Terminal ${flight.departureTerminal}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                flight.duration,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 80, child: Divider(height: 14)),
                              const Icon(
                                Icons.flight_rounded,
                                color: AppTheme.primaryBlue,
                                size: 22,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                flight.stopsLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                booking.arrival,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                flight.destinationCity,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                booking.arrivalTime,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                              Text(
                                'Terminal ${flight.arrivalTerminal}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Perforated Tear Line with Semicircle Cutouts
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppTheme.scaffoldBackground,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: List.generate(
                              (constraints.constrainWidth() / 10).floor(),
                              (_) => const SizedBox(
                                width: 5,
                                height: 1.5,
                                child: DecoratedBox(
                                  decoration:
                                      BoxDecoration(color: Color(0xFFCBD5E1)),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 16,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppTheme.scaffoldBackground,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom Ticket Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Passenger list with seats
                      ...List.generate(booking.passengerDetails.length, (i) {
                        final p = booking.passengerDetails[i];
                        final seat = i < booking.selectedSeats.length
                            ? booking.selectedSeats[i]
                            : '-';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PASSENGER ${i + 1}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  Text(
                                    p.fullName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'SEAT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  Text(
                                    seat,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primaryNavy,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      const Divider(height: 18),

                      // Meta details grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ticketInfoBlock('PNR', booking.pnr),
                          _ticketInfoBlock('CABIN', flight.cabinClass),
                          _ticketInfoBlock('DATE', booking.departureDate),
                          _ticketInfoBlock('GATE', '04B'),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ticketInfoBlock('BAGGAGE', flight.includedBaggage.split('+').first),
                          _ticketInfoBlock('PAYMENT', booking.paymentMethod),
                          _ticketInfoBlock('TOTAL FARE', '₹${booking.totalAmount}'),
                          _ticketInfoBlock('STATUS', booking.paymentStatus),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Scannable QR Code
                      Center(
                        child: Column(
                          children: [
                            QrImageView(
                              data:
                                  'SMART_FLIGHT|PNR:${booking.pnr}|ID:${booking.bookingId}|FLIGHT:${booking.flightNumber}|PAX:${booking.passengers}',
                              version: QrVersions.auto,
                              size: 150,
                              semanticsLabel: 'Boarding pass verification QR',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'PNR: ${booking.pnr} • Booking ID: ${booking.bookingId}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Download PDF Ticket Action
          AppButton(
            label: 'Download / Print PDF Ticket',
            icon: Icons.print_rounded,
            onPressed: () async {
              await TicketPdfService.printOrShareTicket(booking);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _ticketInfoBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
