import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/ticket_pdf_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_button.dart';
import 'eticket_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late BookingModel _currentBooking;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
  }

  void _showCancelDialog() {
    const int cancellationFee = 1500;
    final int refund = (_currentBooking.totalAmount - cancellationFee).clamp(0, 999999);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.dangerRed),
            SizedBox(width: 8),
            Text(
              'Cancel Booking?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel booking ${_currentBooking.pnr}?',
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  _dialogRow('Total Paid', '₹${_currentBooking.totalAmount}'),
                  _dialogRow('Airline Cancellation Fee', '-₹$cancellationFee', isNegative: true),
                  const Divider(),
                  _dialogRow('Estimated Refund', '₹$refund', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Refund will be credited to original payment source within 3-5 business days.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _executeCancellation(cancellationFee, refund);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
              foregroundColor: Colors.white,
              minimumSize: const Size(110, 44),
            ),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value,
      {bool isBold = false, bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isNegative
                  ? AppTheme.dangerRed
                  : (isBold ? AppTheme.primaryNavy : AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeCancellation(int fee, int refund) async {
    setState(() => _isCancelling = true);

    try {
      await BookingService().cancelBooking(
        bookingId: _currentBooking.bookingId,
        cancellationFee: fee,
        refundAmount: refund,
      );

      final updated = await BookingService().getBookingById(_currentBooking.bookingId);
      if (updated != null && mounted) {
        setState(() {
          _currentBooking = updated;
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking ${_currentBooking.pnr} has been cancelled. Refund of ₹$refund processed.',
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel booking: $e'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flight = _currentBooking.flight;
    final isCancelled = _currentBooking.bookingStatus == 'Cancelled';

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text('Booking ${_currentBooking.pnr}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () => TicketPdfService.printOrShareTicket(_currentBooking),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCancelled
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCancelled
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFF86EFAC),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCancelled
                      ? Icons.cancel_outlined
                      : Icons.check_circle_outline_rounded,
                  color: isCancelled ? AppTheme.dangerRed : AppTheme.successGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCancelled
                            ? 'Booking Cancelled'
                            : 'Confirmed & Scheduled',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isCancelled
                              ? AppTheme.dangerRed
                              : AppTheme.successGreen,
                        ),
                      ),
                      Text(
                        isCancelled
                            ? 'Payment status: ${_currentBooking.paymentStatus}'
                            : 'Your flight is confirmed. Gate opens 45 mins prior to departure.',
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
          ),

          const SizedBox(height: 16),

          // Flight Card
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentBooking.airline} (${_currentBooking.flightNumber})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    Text(
                      flight.cabinClass,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _currentBooking.departureDate,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentBooking.departureTime,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${_currentBooking.departure} (${flight.originCity})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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
                    const Icon(
                      Icons.flight_takeoff_rounded,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _currentBooking.arrivalTime,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${_currentBooking.arrival} (${flight.destinationCity})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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

          const SizedBox(height: 16),

          // Passenger & Seats Card
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
                  'Passengers & Assigned Seats',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(_currentBooking.passengerDetails.length, (i) {
                  final p = _currentBooking.passengerDetails[i];
                  final seat = i < _currentBooking.selectedSeats.length
                      ? _currentBooking.selectedSeats[i]
                      : '-';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${i + 1}. ${p.fullName} (${p.passengerType})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Seat $seat',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Fare Summary Card
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
                  'Fare & Payment Summary',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _fareRow('Base Fare', '₹${_currentBooking.fare}'),
                _fareRow('Taxes & Fees', '₹${_currentBooking.taxes}'),
                if (_currentBooking.seatCharges > 0)
                  _fareRow('Seat Charges', '₹${_currentBooking.seatCharges}'),
                if (_currentBooking.addonCharges > 0)
                  _fareRow('Add-ons', '₹${_currentBooking.addonCharges}'),
                if (_currentBooking.discount > 0)
                  _fareRow('Discount', '-₹${_currentBooking.discount}'),
                const Divider(),
                _fareRow('Total Amount', '₹${_currentBooking.totalAmount}', isBold: true),
                const SizedBox(height: 6),
                Text(
                  'Payment: ${_currentBooking.paymentMethod} • Status: ${_currentBooking.paymentStatus}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Actions
          AppButton(
            label: 'View E-Ticket & QR Pass',
            icon: Icons.qr_code_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ETicketScreen(booking: _currentBooking),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          AppSecondaryButton(
            label: 'Download PDF Ticket',
            icon: Icons.picture_as_pdf_outlined,
            onPressed: () =>
                TicketPdfService.printOrShareTicket(_currentBooking),
          ),

          if (!isCancelled) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: TextButton.icon(
                onPressed: _isCancelling ? null : _showCancelDialog,
                icon: const Icon(Icons.cancel_outlined,
                    color: AppTheme.dangerRed, size: 20),
                label: Text(
                  _isCancelling ? 'Processing...' : 'Cancel Reservation',
                  style: const TextStyle(
                    color: AppTheme.dangerRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _fareRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isBold ? AppTheme.primaryNavy : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
