import 'package:flutter/material.dart';
import '../models/addon_model.dart';
import '../models/flight_model.dart';
import '../models/passenger_model.dart';
import '../utils/app_theme.dart';
import '../widgets/app_button.dart';
import 'checkout_screen.dart';

class AddonsScreen extends StatefulWidget {
  final FlightOffer flight;
  final FlightSearchCriteria criteria;
  final List<PassengerModel> passengers;
  final List<String> selectedSeats;
  final int seatCharges;

  const AddonsScreen({
    super.key,
    required this.flight,
    required this.criteria,
    required this.passengers,
    required this.selectedSeats,
    required this.seatCharges,
  });

  @override
  State<AddonsScreen> createState() => _AddonsScreenState();
}

class _AddonsScreenState extends State<AddonsScreen> {
  final List<AddonItem> _selectedAddons = [];
  bool _hasTravelInsurance = false;
  bool _hasPriorityBoarding = false;

  int _calculateAddonTotal() {
    int sum = 0;
    for (var a in _selectedAddons) {
      sum += a.price;
    }
    if (_hasTravelInsurance) {
      sum += AvailableAddons.travelInsurance.price * widget.passengers.length;
    }
    if (_hasPriorityBoarding) {
      sum += AvailableAddons.priorityBoarding.price * widget.passengers.length;
    }
    return sum;
  }

  void _proceedToCheckout() {
    final finalAddons = List<AddonItem>.from(_selectedAddons);
    if (_hasTravelInsurance) {
      finalAddons.add(AvailableAddons.travelInsurance);
    }
    if (_hasPriorityBoarding) {
      finalAddons.add(AvailableAddons.priorityBoarding);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          flight: widget.flight,
          criteria: widget.criteria,
          passengers: widget.passengers,
          selectedSeats: widget.selectedSeats,
          seatCharges: widget.seatCharges,
          selectedAddons: finalAddons,
          addonCharges: _calculateAddonTotal(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addonTotal = _calculateAddonTotal();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Add-ons & Services'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // In-Flight Meals Section
          const Text(
            'In-Flight Dining (Optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pre-order hot chef-curated meals served fresh at your seat',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),

          ...AvailableAddons.meals.map((meal) {
            final isSelected = _selectedAddons.any((a) => a.id == meal.id);
            return _buildMealTile(meal, isSelected);
          }),

          const SizedBox(height: 24),

          // Extra Baggage Section
          const Text(
            'Pre-paid Excess Baggage',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Save up to 40% compared to airport check-in counter fees',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),

          ...AvailableAddons.baggage.map((bag) {
            final isSelected = _selectedAddons.any((a) => a.id == bag.id);
            return _buildBaggageTile(bag, isSelected);
          }),

          const SizedBox(height: 24),

          // Travel Insurance Checkbox Card
          _buildInsuranceCard(),

          const SizedBox(height: 16),

          // Priority Boarding Checkbox Card
          _buildPriorityCard(),

          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add-ons: ₹$addonTotal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    Text(
                      '${_selectedAddons.length + (_hasTravelInsurance ? 1 : 0) + (_hasPriorityBoarding ? 1 : 0)} services selected',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 170,
                child: AppButton(
                  label: 'Review Fare',
                  icon: Icons.receipt_long_rounded,
                  onPressed: _proceedToCheckout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealTile(AddonItem meal, bool isSelected) {
    Color tagColor = AppTheme.successGreen;
    if (meal.dietaryType == 'non-veg') {
      tagColor = AppTheme.dangerRed;
    } else if (meal.dietaryType == 'jain') {
      tagColor = AppTheme.accentGold;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primaryNavy : AppTheme.borderColor,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: tagColor, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.circle, size: 8, color: tagColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  meal.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${meal.price}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              setState(() {
                if (isSelected) {
                  _selectedAddons.removeWhere((a) => a.id == meal.id);
                } else {
                  _selectedAddons.add(meal);
                }
              });
            },
            icon: Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_outline_rounded,
              color: isSelected ? AppTheme.primaryNavy : AppTheme.textMuted,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaggageTile(AddonItem bag, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primaryNavy : AppTheme.borderColor,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.luggage_rounded,
              color: AppTheme.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bag.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  bag.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${bag.price}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                if (isSelected) {
                  _selectedAddons.removeWhere((a) => a.id == bag.id);
                } else {
                  _selectedAddons.add(bag);
                }
              });
            },
            icon: Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_outline_rounded,
              color: isSelected ? AppTheme.primaryNavy : AppTheme.textMuted,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceCard() {
    final item = AvailableAddons.travelInsurance;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasTravelInsurance ? AppTheme.primaryNavy : AppTheme.borderColor,
          width: _hasTravelInsurance ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _hasTravelInsurance,
            activeColor: AppTheme.primaryNavy,
            onChanged: (val) =>
                setState(() => _hasTravelInsurance = val ?? false),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '₹${item.price}/pax',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityCard() {
    final item = AvailableAddons.priorityBoarding;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasPriorityBoarding ? AppTheme.primaryNavy : AppTheme.borderColor,
          width: _hasPriorityBoarding ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _hasPriorityBoarding,
            activeColor: AppTheme.primaryNavy,
            onChanged: (val) =>
                setState(() => _hasPriorityBoarding = val ?? false),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '₹${item.price}/pax',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
