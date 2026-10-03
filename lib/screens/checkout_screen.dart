import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/addon_model.dart';
import '../models/flight_model.dart';
import '../models/passenger_model.dart';
import '../utils/app_theme.dart';
import '../widgets/app_button.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final FlightOffer flight;
  final FlightSearchCriteria criteria;
  final List<PassengerModel> passengers;
  final List<String> selectedSeats;
  final int seatCharges;
  final List<AddonItem> selectedAddons;
  final int addonCharges;

  const CheckoutScreen({
    super.key,
    required this.flight,
    required this.criteria,
    required this.passengers,
    required this.selectedSeats,
    required this.seatCharges,
    required this.selectedAddons,
    required this.addonCharges,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _promoController = TextEditingController();
  int _discount = 0;
  String _appliedPromoCode = '';
  String _promoMessage = '';

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromoCode() {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    if (code == 'FLYSMART' || code == 'FIRSTFLY' || code == 'OFFER20') {
      setState(() {
        _discount = 500;
        _appliedPromoCode = code;
        _promoMessage = 'Promo code applied! ₹500 discount added.';
      });
    } else {
      setState(() {
        _discount = 0;
        _appliedPromoCode = '';
        _promoMessage = 'Invalid promo code. Try FLYSMART';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPax = widget.passengers.length;
    final baseFare = widget.flight.price * totalPax;
    final taxes = (baseFare * 0.12).round();
    const convenienceFee = 250;
    final subtotal = baseFare +
        taxes +
        convenienceFee +
        widget.seatCharges +
        widget.addonCharges;
    final totalAmount = (subtotal - _discount).clamp(0, 9999999);

    final dateFormat = DateFormat('EEE, dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Fare Summary & Review'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Flight Itinerary Card
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
                      '${widget.flight.airlineName} • ${widget.flight.flightNumber}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    Text(
                      widget.flight.cabinClass,
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
                  dateFormat.format(widget.criteria.departureDate),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.flight.departureTime,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${widget.flight.originCode} (${widget.flight.originCity})',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        color: AppTheme.primaryBlue),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.flight.arrivalTime,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${widget.flight.destinationCode} (${widget.flight.destinationCity})',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
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

          // Passengers & Seats Card
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
                ...List.generate(widget.passengers.length, (i) {
                  final p = widget.passengers[i];
                  final seat = i < widget.selectedSeats.length
                      ? widget.selectedSeats[i]
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

          // Promo Code Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Have a Promo Code?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          hintText: 'Enter FLYSMART',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _applyPromoCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
                if (_promoMessage.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    _promoMessage,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _discount > 0
                          ? AppTheme.successGreen
                          : AppTheme.dangerRed,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Itemized Price Breakdown Card
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
                  'Fare Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _fareRow(
                  'Base Airfare ($totalPax Passenger${totalPax > 1 ? 's' : ''})',
                  '₹$baseFare',
                ),
                _fareRow('Aviation Taxes & Fees (12% GST/ADF)', '₹$taxes'),
                _fareRow('Convenience & Booking Fee', '₹$convenienceFee'),
                if (widget.seatCharges > 0)
                  _fareRow('Seat Selection Charges', '₹${widget.seatCharges}'),
                if (widget.addonCharges > 0)
                  _fareRow('Add-ons (Meals/Baggage/Insurance)', '₹${widget.addonCharges}'),
                if (_discount > 0)
                  _fareRow(
                    'Promo Discount ($_appliedPromoCode)',
                    '-₹$_discount',
                    isDiscount: true,
                  ),
                const Divider(),
                _fareRow('Grand Total', '₹$totalAmount', isBold: true),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Proceed to Payment Action
          AppButton(
            label: 'Proceed to Payment (₹$totalAmount)',
            icon: Icons.lock_outline_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    flight: widget.flight,
                    criteria: widget.criteria,
                    passengers: widget.passengers,
                    selectedSeats: widget.selectedSeats,
                    selectedAddons: widget.selectedAddons,
                    baseFare: baseFare,
                    taxes: taxes,
                    seatCharges: widget.seatCharges,
                    addonCharges: widget.addonCharges,
                    discount: _discount,
                    totalAmount: totalAmount,
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

  Widget _fareRow(
    String label,
    String value, {
    bool isBold = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: isDiscount
                  ? AppTheme.successGreen
                  : (isBold ? AppTheme.textPrimary : AppTheme.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isDiscount
                  ? AppTheme.successGreen
                  : (isBold ? AppTheme.primaryNavy : AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
