import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/flight_model.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/airport_selector.dart';
import '../widgets/app_button.dart';
import 'flight_results_screen.dart';

class SearchFlightsScreen extends StatefulWidget {
  const SearchFlightsScreen({super.key});

  @override
  State<SearchFlightsScreen> createState() => _SearchFlightsScreenState();
}

class _SearchFlightsScreenState extends State<SearchFlightsScreen> {
  int _tripType = 0; // 0 = One Way, 1 = Round Trip

  Map<String, String> _fromAirport = {
    'code': 'CJB',
    'city': 'Coimbatore',
    'name': 'Coimbatore International Airport',
  };

  Map<String, String> _toAirport = {
    'code': 'MAA',
    'city': 'Chennai',
    'name': 'Chennai International Airport',
  };

  DateTime _departureDate = DateTime.now().add(const Duration(days: 1));
  DateTime _returnDate = DateTime.now().add(const Duration(days: 5));

  int _adults = 1;
  int _children = 0;
  int _infants = 0;

  String _cabinClass = 'Economy';

  void _swapAirports() {
    setState(() {
      final temp = _fromAirport;
      _fromAirport = _toAirport;
      _toAirport = temp;
    });
  }

  Future<void> _selectAirport({required bool isFrom}) async {
    final selected = await AirportSelectorWidget.showAirportPicker(
      context: context,
      title: isFrom ? 'Select Origin Airport' : 'Select Destination Airport',
      currentCode: isFrom ? _fromAirport['code'] : _toAirport['code'],
    );

    if (selected != null) {
      setState(() {
        if (isFrom) {
          _fromAirport = selected;
        } else {
          _toAirport = selected;
        }
      });
    }
  }

  Future<void> _selectDate({required bool isDeparture}) async {
    final now = DateTime.now();
    final firstDate = isDeparture ? now : _departureDate;
    final initial = isDeparture
        ? _departureDate
        : (_returnDate.isBefore(_departureDate) ? _departureDate : _returnDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryNavy,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
          if (_returnDate.isBefore(_departureDate)) {
            _returnDate = _departureDate.add(const Duration(days: 3));
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  void _showPassengerPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Passengers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _passengerRow(
                    title: 'Adults',
                    subtitle: 'Age 12+ years',
                    count: _adults,
                    min: 1,
                    max: 9,
                    onChanged: (val) {
                      setSheetState(() => _adults = val);
                      setState(() {});
                    },
                  ),
                  const Divider(height: 24),
                  _passengerRow(
                    title: 'Children',
                    subtitle: 'Age 2 - 11 years',
                    count: _children,
                    min: 0,
                    max: 8,
                    onChanged: (val) {
                      setSheetState(() => _children = val);
                      setState(() {});
                    },
                  ),
                  const Divider(height: 24),
                  _passengerRow(
                    title: 'Infants',
                    subtitle: 'Under 2 years (on lap)',
                    count: _infants,
                    min: 0,
                    max: _adults, // Cannot exceed number of adults
                    onChanged: (val) {
                      setSheetState(() => _infants = val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Done',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _passengerRow({
    required String title,
    required String subtitle,
    required int count,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: count > min ? () => onChanged(count - 1) : null,
              icon: const Icon(Icons.remove_circle_outline_rounded),
              color: AppTheme.primaryNavy,
              disabledColor: AppTheme.textMuted,
            ),
            SizedBox(
              width: 28,
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            IconButton(
              onPressed: count < max ? () => onChanged(count + 1) : null,
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: AppTheme.primaryNavy,
              disabledColor: AppTheme.textMuted,
            ),
          ],
        ),
      ],
    );
  }

  void _searchFlights() {
    if (_fromAirport['code'] == _toAirport['code']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Origin and Destination airports cannot be the same!'),
          backgroundColor: AppTheme.dangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final criteria = FlightSearchCriteria(
      from: _fromAirport['city']!,
      fromCode: _fromAirport['code']!,
      to: _toAirport['city']!,
      toCode: _toAirport['code']!,
      departureDate: _departureDate,
      returnDate: _tripType == 1 ? _returnDate : null,
      tripType: _tripType,
      adults: _adults,
      children: _children,
      infants: _infants,
      cabinClass: _cabinClass,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlightResultsScreen(criteria: criteria),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Search Flights'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trip Type Toggle (One Way / Round Trip)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tripType = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _tripType == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _tripType == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'One Way',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _tripType == 0
                                ? AppTheme.primaryNavy
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tripType = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _tripType == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _tripType == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Round Trip',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _tripType == 1
                                ? AppTheme.primaryNavy
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Route Section with Swap button
            Stack(
              alignment: Alignment.centerRight,
              children: [
                Column(
                  children: [
                    AirportSelectorWidget(
                      label: 'From',
                      airportCode: _fromAirport['code']!,
                      cityName: _fromAirport['city']!,
                      icon: Icons.flight_takeoff_rounded,
                      onTap: () => _selectAirport(isFrom: true),
                    ),
                    const SizedBox(height: 12),
                    AirportSelectorWidget(
                      label: 'To',
                      airportCode: _toAirport['code']!,
                      cityName: _toAirport['city']!,
                      icon: Icons.flight_land_rounded,
                      onTap: () => _selectAirport(isFrom: false),
                    ),
                  ],
                ),
                Positioned(
                  right: 20,
                  child: FloatingActionButton.small(
                    heroTag: 'swapBtn',
                    onPressed: _swapAirports,
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    child: const Icon(Icons.swap_vert_rounded, size: 22),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dates Section
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(isDeparture: true),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  size: 14, color: AppTheme.textMuted),
                              SizedBox(width: 6),
                              Text(
                                'DEPARTURE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dateFormat.format(_departureDate),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_tripType == 1) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(isDeparture: false),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.event_repeat_rounded,
                                    size: 14, color: AppTheme.textMuted),
                                SizedBox(width: 6),
                                Text(
                                  'RETURN',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dateFormat.format(_returnDate),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Passengers Selector Card
            InkWell(
              onTap: _showPassengerPicker,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.people_outline_rounded,
                        color: AppTheme.primaryBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PASSENGERS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_adults Adult${_adults > 1 ? 's' : ''}'
                            '${_children > 0 ? ', $_children Child' : ''}'
                            '${_infants > 0 ? ', $_infants Infant' : ''}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: AppTheme.textMuted),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Cabin Class Selector Chips
            const Text(
              'Cabin Class',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.cabinClasses.map((cabin) {
                final isSelected = _cabinClass == cabin;
                return ChoiceChip(
                  label: Text(cabin),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _cabinClass = cabin);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Search Action Button
            AppButton(
              label: 'Search Flights',
              icon: Icons.search_rounded,
              onPressed: _searchFlights,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
