import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/addon_model.dart';
import '../models/booking_model.dart';
import '../models/flight_model.dart';
import '../models/passenger_model.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../services/email_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_button.dart';
import 'booking_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final FlightOffer flight;
  final FlightSearchCriteria criteria;
  final List<PassengerModel> passengers;
  final List<String> selectedSeats;
  final List<AddonItem> selectedAddons;
  final int baseFare;
  final int taxes;
  final int seatCharges;
  final int addonCharges;
  final int discount;
  final int totalAmount;

  const PaymentScreen({
    super.key,
    required this.flight,
    required this.criteria,
    required this.passengers,
    required this.selectedSeats,
    required this.selectedAddons,
    required this.baseFare,
    required this.taxes,
    required this.seatCharges,
    required this.addonCharges,
    required this.discount,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'UPI';

  // UPI inputs
  final TextEditingController _upiIdController = TextEditingController();

  // Card inputs
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();

  bool _isProcessing = false;
  String _processingStage = '';

  @override
  void dispose() {
    _upiIdController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  String _generatePnr() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return 'SF${List.generate(4, (_) => chars[random.nextInt(chars.length)]).join()}';
  }

  String _generateBookingId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomPart = Random().nextInt(9000) + 1000;
    return 'SF${timestamp.substring(timestamp.length - 4)}$randomPart';
  }

  Future<void> _processPaymentAndCreateBooking() async {
    final user = AuthService().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to complete your booking.'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingStage = 'Authorizing payment with banking network...';
    });

    try {
      // Simulate real bank gateway handshake
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;

      setState(() {
        _processingStage = 'Securing reservation & generating PNR...';
      });

      final bookingId = _generateBookingId();
      final pnr = _generatePnr();
      final bookingDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
      final depDateStr = DateFormat('yyyy-MM-dd').format(widget.criteria.departureDate);

      final booking = BookingModel(
        bookingId: bookingId,
        pnr: pnr,
        userId: user.uid,
        flightId: widget.flight.id,
        airline: widget.flight.airlineName,
        airlineCode: widget.flight.airlineCode,
        flightNumber: widget.flight.flightNumber,
        departure: widget.flight.originCode,
        arrival: widget.flight.destinationCode,
        departureDate: depDateStr,
        departureTime: widget.flight.departureTime,
        arrivalTime: widget.flight.arrivalTime,
        passengers: widget.passengers.length,
        passengerDetails: widget.passengers,
        selectedSeats: widget.selectedSeats,
        selectedAddons: widget.selectedAddons,
        fare: widget.baseFare,
        taxes: widget.taxes,
        seatCharges: widget.seatCharges,
        addonCharges: widget.addonCharges,
        discount: widget.discount,
        totalAmount: widget.totalAmount,
        bookingStatus: 'Confirmed',
        paymentStatus: 'Paid',
        paymentMethod: _selectedMethod,
        bookingDate: bookingDate,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        flight: widget.flight,
      );

      // Persist to Cloud Firestore: bookings/{bookingId}
      await BookingService().createBooking(booking);

      // Persist payment transaction record to Cloud Firestore: payments/{paymentId}
      final paymentId = 'PAY-${DateTime.now().millisecondsSinceEpoch}';
      final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
      try {
        await FirebaseFirestore.instance.collection('payments').doc(paymentId).set({
          'paymentId': paymentId,
          'bookingId': booking.bookingId,
          'userId': booking.userId,
          'amount': widget.totalAmount,
          'paymentStatus': 'Successful',
          'paymentMethod': _selectedMethod,
          'transactionId': transactionId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (payErr) {
        debugPrint('Payment record persistence notice: $payErr');
      }

      if (mounted) {
        setState(() {
          _processingStage = 'Generating invoice & sending e-ticket...';
        });
      }

      // Dynamically dispatch invoice PDF email to customer's actual registered email (Requirements 5, 7, 8, 9, 10, 11)
      EmailSendResult? emailResult;
      try {
        emailResult = await EmailService().sendBookingInvoiceEmail(booking);
      } catch (emailError) {
        // An email failure must NEVER cancel an already successful flight booking (Requirement 11)
        debugPrint('Notice sending invoice email: $emailError');
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            booking: booking,
            emailResult: emailResult,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment or booking creation failed: $e'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: _isProcessing
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppTheme.lightBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppTheme.primaryNavy),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Processing Payment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _processingStage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please do not press back or close the app.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Amount to Pay Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AMOUNT TO PAY',
                            style: TextStyle(
                              color: Color(0xFF93C5FD),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Smart Flight Reservation',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${widget.totalAmount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Select Payment Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                // Payment Method Options
                _paymentMethodTile(
                  id: 'UPI',
                  title: 'UPI (Google Pay, PhonePe, Paytm)',
                  subtitle: 'Instant approval via your UPI app or VPA ID',
                  icon: Icons.account_balance_wallet_rounded,
                ),

                if (_selectedMethod == 'UPI') ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: TextField(
                      controller: _upiIdController,
                      decoration: const InputDecoration(
                        labelText: 'Virtual Payment Address (UPI ID)',
                        hintText: 'e.g. mobile@upi or username@okaxis',
                        prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                      ),
                    ),
                  ),
                ],

                _paymentMethodTile(
                  id: 'Card',
                  title: 'Credit / Debit Card',
                  subtitle: 'Visa, MasterCard, RuPay, Amex',
                  icon: Icons.credit_card_rounded,
                ),

                if (_selectedMethod == 'Card') ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      children: [
                        TextField(
                          controller: _cardNumberController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Card Number',
                            prefixIcon: Icon(Icons.credit_card, size: 20),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _cardExpiryController,
                                decoration: const InputDecoration(
                                  labelText: 'Expiry (MM/YY)',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _cardCvvController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'CVV',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                _paymentMethodTile(
                  id: 'NetBanking',
                  title: 'Net Banking',
                  subtitle: 'HDFC, ICICI, SBI, Axis, and 50+ banks',
                  icon: Icons.account_balance_rounded,
                ),

                _paymentMethodTile(
                  id: 'Wallet',
                  title: 'Mobile Wallets',
                  subtitle: 'Amazon Pay, Paytm Wallet, Mobikwik',
                  icon: Icons.wallet_rounded,
                ),

                const SizedBox(height: 16),

                // Secure Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined,
                          size: 20, color: AppTheme.successGreen),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '256-bit SSL encrypted & RBI compliant banking checkout.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Pay CTA
                AppButton(
                  label: 'Pay ₹${widget.totalAmount} & Confirm Booking',
                  icon: Icons.check_circle_rounded,
                  onPressed: _processPaymentAndCreateBooking,
                ),

                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _paymentMethodTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primaryNavy : AppTheme.borderColor,
          width: isSelected ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _selectedMethod = id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppTheme.lightBlue : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? AppTheme.primaryNavy : AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
