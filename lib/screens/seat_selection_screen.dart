import 'package:flutter/material.dart';
import '../models/flight_model.dart';
import '../models/passenger_model.dart';
import '../utils/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/seat_map_widget.dart';
import 'addons_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final FlightOffer flight;
  final FlightSearchCriteria criteria;
  final List<PassengerModel> passengers;

  const SeatSelectionScreen({
    super.key,
    required this.flight,
    required this.criteria,
    required this.passengers,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  // Map passenger index -> selected seat ID
  late final Map<int, String> _assignedSeats;
  int _activePassengerIndex = 0;

  @override
  void initState() {
    super.initState();
    _assignedSeats = {};
  }

  void _onSeatToggled(String seatId) {
    setState(() {
      // If this seat was already assigned to another passenger, remove it
      for (var entry in _assignedSeats.entries) {
        if (entry.value == seatId && entry.key != _activePassengerIndex) {
          _assignedSeats.remove(entry.key);
          break;
        }
      }

      // If active passenger already has this seat, unselect it
      if (_assignedSeats[_activePassengerIndex] == seatId) {
        _assignedSeats.remove(_activePassengerIndex);
      } else {
        // Assign to active passenger
        _assignedSeats[_activePassengerIndex] = seatId;

        // Auto advance to next passenger without seat
        for (int i = 0; i < widget.passengers.length; i++) {
          if (!_assignedSeats.containsKey(i)) {
            _activePassengerIndex = i;
            break;
          }
        }
      }
    });
  }

  int _calculateSeatCharges() {
    int total = 0;
    for (var seatId in _assignedSeats.values) {
      if (seatId.startsWith('1') || seatId.startsWith('11')) {
        total += 650;
      } else if (seatId.endsWith('A') || seatId.endsWith('F')) {
        total += 250;
      } else if (seatId.endsWith('C') || seatId.endsWith('D')) {
        total += 250;
      }
    }
    return total;
  }

  void _proceedToAddons() {
    if (_assignedSeats.length < widget.passengers.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a seat for all ${widget.passengers.length} passengers.',
          ),
          backgroundColor: AppTheme.dangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Update passengers with their selected seats
    final updatedPassengers = List.generate(widget.passengers.length, (i) {
      final seat = _assignedSeats[i] ?? '12A';
      return widget.passengers[i].copyWith(selectedSeat: seat);
    });

    final selectedSeatList = List.generate(
      widget.passengers.length,
      (i) => _assignedSeats[i] ?? '12A',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddonsScreen(
          flight: widget.flight,
          criteria: widget.criteria,
          passengers: updatedPassengers,
          selectedSeats: selectedSeatList,
          seatCharges: _calculateSeatCharges(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSeatList = _assignedSeats.values.toList();
    final seatCharges = _calculateSeatCharges();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Select Seats'),
      ),
      body: Column(
        children: [
          // Passenger Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(widget.passengers.length, (index) {
                  final p = widget.passengers[index];
                  final isCurrent = _activePassengerIndex == index;
                  final seat = _assignedSeats[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _activePassengerIndex = index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppTheme.primaryNavy
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrent
                                ? AppTheme.primaryNavy
                                : AppTheme.borderColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 16,
                              color: isCurrent ? Colors.white : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.firstName.isNotEmpty ? p.firstName : 'Pax ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isCurrent ? Colors.white : AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  seat != null ? 'Seat: $seat' : 'Tap to select',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isCurrent
                                        ? const Color(0xFF93C5FD)
                                        : (seat != null
                                            ? AppTheme.successGreen
                                            : AppTheme.textMuted),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const Divider(height: 1),

          // Seat Map & Legend
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SeatLegendWidget(),
                const SizedBox(height: 16),
                SeatMapWidget(
                  selectedSeatIds: selectedSeatList,
                  maxSeatsAllowed: widget.passengers.length,
                  onSeatToggled: _onSeatToggled,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Bottom Bar: Selected count, seat charges, continue button
          Container(
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
                          '${_assignedSeats.length}/${widget.passengers.length} Seats Picked',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          seatCharges > 0
                              ? '+₹$seatCharges seat fees'
                              : 'Standard seats free',
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
                      label: 'Add-ons',
                      icon: Icons.fastfood_outlined,
                      onPressed: _proceedToAddons,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
