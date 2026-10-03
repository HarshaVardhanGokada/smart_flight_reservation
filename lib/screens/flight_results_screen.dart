import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/flight_model.dart';
import '../services/flight_service.dart';
import '../utils/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/flight_card.dart';
import 'flight_details_screen.dart';

class FlightResultsScreen extends StatefulWidget {
  final FlightSearchCriteria criteria;

  const FlightResultsScreen({super.key, required this.criteria});

  @override
  State<FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  final _flightService = FlightService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<FlightOffer> _allFlights = [];

  // Sorting: 'cheapest', 'fastest', 'earliest', 'latest'
  String _sortBy = 'cheapest';

  // Filters
  int? _maxPrice;
  List<String> _selectedAirlines = [];
  int? _maxStops;
  String _timeSlot = 'all';

  @override
  void initState() {
    super.initState();
    _fetchFlights();
  }

  Future<void> _fetchFlights() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await _flightService.searchFlights(widget.criteria);
      if (!mounted) return;
      setState(() {
        _allFlights = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load flights. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  List<FlightOffer> get _displayedFlights {
    var filtered = _flightService.filterFlights(
      flights: _allFlights,
      maxPrice: _maxPrice,
      selectedAirlines: _selectedAirlines,
      maxStops: _maxStops,
      timeSlot: _timeSlot,
    );
    return _flightService.sortFlights(filtered, _sortBy);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final availableAirlines =
                _allFlights.map((f) => f.airlineName).toSet().toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header with Reset
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Flights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            _maxPrice = null;
                            _selectedAirlines = [];
                            _maxStops = null;
                            _timeSlot = 'all';
                          });
                          setState(() {});
                        },
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                  const Divider(),

                  Expanded(
                    child: ListView(
                      children: [
                        // Stops Filter
                        const Text(
                          'Stops',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilterChip(
                              label: const Text('All Flights'),
                              selected: _maxStops == null,
                              onSelected: (_) {
                                setSheetState(() => _maxStops = null);
                                setState(() {});
                              },
                            ),
                            FilterChip(
                              label: const Text('Non-Stop Only'),
                              selected: _maxStops == 0,
                              onSelected: (_) {
                                setSheetState(() => _maxStops = 0);
                                setState(() {});
                              },
                            ),
                            FilterChip(
                              label: const Text('Up to 1 Stop'),
                              selected: _maxStops == 1,
                              onSelected: (_) {
                                setSheetState(() => _maxStops = 1);
                                setState(() {});
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Departure Time Slot Filter
                        const Text(
                          'Departure Time',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Any Time'),
                              selected: _timeSlot == 'all',
                              onSelected: (_) {
                                setSheetState(() => _timeSlot = 'all');
                                setState(() {});
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Morning (5 AM - 12 PM)'),
                              selected: _timeSlot == 'morning',
                              onSelected: (_) {
                                setSheetState(() => _timeSlot = 'morning');
                                setState(() {});
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Afternoon (12 PM - 5 PM)'),
                              selected: _timeSlot == 'afternoon',
                              onSelected: (_) {
                                setSheetState(() => _timeSlot = 'afternoon');
                                setState(() {});
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Evening (5 PM - 9 PM)'),
                              selected: _timeSlot == 'evening',
                              onSelected: (_) {
                                setSheetState(() => _timeSlot = 'evening');
                                setState(() {});
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Airlines Filter
                        const Text(
                          'Airlines',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: availableAirlines.map((airline) {
                            final isSelected = _selectedAirlines.contains(airline);
                            return FilterChip(
                              label: Text(airline),
                              selected: isSelected,
                              onSelected: (val) {
                                setSheetState(() {
                                  if (val) {
                                    _selectedAirlines.add(airline);
                                  } else {
                                    _selectedAirlines.remove(airline);
                                  }
                                });
                                setState(() {});
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Apply CTA
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, dd MMM');
    final displayed = _displayedFlights;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              '${widget.criteria.fromCode} → ${widget.criteria.toCode}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryNavy,
              ),
            ),
            Text(
              '${dateFormat.format(widget.criteria.departureDate)} • ${widget.criteria.totalPassengers} Pax • ${widget.criteria.cabinClass}',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.tune_rounded),
                if (_selectedAirlines.isNotEmpty ||
                    _maxStops != null ||
                    _timeSlot != 'all')
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sort Options Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.sort_rounded, size: 18, color: AppTheme.textMuted),
                const SizedBox(width: 8),
                const Text(
                  'Sort by: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _sortChip('cheapest', 'Cheapest'),
                        _sortChip('fastest', 'Fastest'),
                        _sortChip('earliest', 'Earliest'),
                        _sortChip('latest', 'Latest'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Flight List or Loader or Empty
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Searching best flight deals...',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : _errorMessage.isNotEmpty
                    ? EmptyStateWidget(
                        icon: Icons.cloud_off_rounded,
                        title: 'Connection Error',
                        message: _errorMessage,
                        actionLabel: 'Retry',
                        onAction: _fetchFlights,
                      )
                    : displayed.isEmpty
                        ? EmptyStateWidget(
                            icon: Icons.flight_takeoff_rounded,
                            title: 'No flights found',
                            message:
                                'No flights match your filter criteria. Try adjusting or clearing your filters.',
                            actionLabel: 'Clear Filters',
                            onAction: () {
                              setState(() {
                                _maxPrice = null;
                                _selectedAirlines = [];
                                _maxStops = null;
                                _timeSlot = 'all';
                              });
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: displayed.length,
                            itemBuilder: (context, index) {
                              final flight = displayed[index];
                              return FlightCard(
                                flight: flight,
                                onSelect: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FlightDetailsScreen(
                                        flight: flight,
                                        criteria: widget.criteria,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String key, String label) {
    final isSelected = _sortBy == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        visualDensity: VisualDensity.compact,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.textPrimary,
        ),
        onSelected: (val) {
          if (val) setState(() => _sortBy = key);
        },
      ),
    );
  }
}
