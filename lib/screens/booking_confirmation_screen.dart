import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/email_service.dart';
import '../services/ticket_pdf_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_button.dart';
import 'eticket_screen.dart';
import 'home_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final BookingModel booking;
  final EmailSendResult? emailResult;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    this.emailResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            const SizedBox(height: 16),

            // Success Badge
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 58,
                  color: AppTheme.successGreen,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Booking Confirmed!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your flight reservation has been successfully booked and saved to your account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),

            if (emailResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: emailResult!.isSuccess
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: emailResult!.isSuccess
                        ? const Color(0xFFBBF7D0)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      emailResult!.isSuccess
                          ? Icons.mark_email_read_rounded
                          : Icons.info_outline_rounded,
                      color: emailResult!.isSuccess
                          ? AppTheme.successGreen
                          : const Color(0xFFD97706),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        emailResult!.isSuccess
                            ? 'Invoice e-ticket sent to ${emailResult!.recipient} (SmartFlight_${booking.pnr}_Invoice.pdf)'
                            : (emailResult!.errorMessage ??
                                "Booking confirmed, but we couldn't send the invoice email. You can download your ticket from My Bookings."),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: emailResult!.isSuccess
                              ? const Color(0xFF166534)
                              : const Color(0xFF92400E),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Booking Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // PNR & Booking ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BOOKING PNR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.pnr,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'BOOKING ID',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.bookingId,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Flight and Route
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${booking.airline} (${booking.flightNumber})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        booking.departureDate,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.departureTime,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            booking.departure,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.flight_takeoff_rounded,
                          color: AppTheme.primaryBlue),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            booking.arrivalTime,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            booking.arrival,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Passengers & Seats
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Passengers',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: booking.passengerDetails.map((p) {
                            final seat = p.selectedSeat.isNotEmpty
                                ? p.selectedSeat
                                : '-';
                            return Text(
                              '${p.fullName} (Seat $seat)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Paid Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Paid',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '₹${booking.totalAmount}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // View Ticket CTA
            AppButton(
              label: 'View E-Ticket',
              icon: Icons.confirmation_number_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ETicketScreen(booking: booking),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // Download PDF Ticket CTA
            AppSecondaryButton(
              label: 'Download / Print PDF',
              icon: Icons.picture_as_pdf_outlined,
              onPressed: () async {
                await TicketPdfService.printOrShareTicket(booking);
              },
            ),

            const SizedBox(height: 10),

            // My Bookings CTA
            AppSecondaryButton(
              label: 'Go to My Bookings',
              icon: Icons.list_alt_rounded,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(initialIndex: 1),
                  ),
                  (route) => false,
                );
              },
            ),

            const SizedBox(height: 10),

            // Home CTA
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(initialIndex: 0),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Back to Home'),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
