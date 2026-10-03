import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../models/flight_model.dart';
import '../models/user_model.dart';
import '../services/booking_service.dart';
import '../services/flight_service.dart';
import '../services/firestore_init_service.dart';
import '../utils/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _bookingService = BookingService();
  final _flightService = FlightService();
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _seedDemoData() async {
    setState(() => _isSeeding = true);
    try {
      await FirestoreInitService().initializeDemoDataIfNeeded(force: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Demo data successfully synchronized with Cloud Firestore! Flights, airports & reviews are live.',
          ),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initializing demo data: $e'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  void _showAddFlightDialog() {
    final formKey = GlobalKey<FormState>();
    final airlineController = TextEditingController(text: 'IndiGo');
    final codeController = TextEditingController(text: '6E');
    final numberController = TextEditingController(text: '6E-450');
    final originCodeController = TextEditingController(text: 'DEL');
    final originCityController = TextEditingController(text: 'Delhi');
    final destCodeController = TextEditingController(text: 'BOM');
    final destCityController = TextEditingController(text: 'Mumbai');
    final depTimeController = TextEditingController(text: '08:30');
    final arrTimeController = TextEditingController(text: '10:45');
    final durationController = TextEditingController(text: '2h 15m');
    final priceController = TextEditingController(text: '4500');
    final seatsController = TextEditingController(text: '60');
    final aircraftController = TextEditingController(text: 'Airbus A321neo');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.flight_takeoff_rounded, color: AppTheme.primaryNavy),
              SizedBox(width: 8),
              Text('Add New Flight (Firestore)'),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: airlineController,
                            decoration: const InputDecoration(labelText: 'Airline Name'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: codeController,
                            decoration: const InputDecoration(labelText: 'Code'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: numberController,
                            decoration: const InputDecoration(labelText: 'Flight No'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: originCityController,
                            decoration: const InputDecoration(labelText: 'Origin City'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: originCodeController,
                            decoration: const InputDecoration(labelText: 'Origin IATA'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: destCityController,
                            decoration: const InputDecoration(labelText: 'Dest City'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: destCodeController,
                            decoration: const InputDecoration(labelText: 'Dest IATA'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: depTimeController,
                            decoration: const InputDecoration(labelText: 'Dep Time (HH:MM)'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: arrTimeController,
                            decoration: const InputDecoration(labelText: 'Arr Time (HH:MM)'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: durationController,
                            decoration: const InputDecoration(labelText: 'Duration'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Price (₹)'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: seatsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Seats'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final originCode = originCodeController.text.trim().toUpperCase();
                final destCode = destCodeController.text.trim().toUpperCase();
                final flightNumber = numberController.text.trim().toUpperCase();
                final flightId = 'FL-$originCode-$destCode-$flightNumber';

                final newFlight = FlightOffer(
                  id: flightId,
                  airlineName: airlineController.text.trim(),
                  airlineCode: codeController.text.trim().toUpperCase(),
                  flightNumber: flightNumber,
                  originCode: originCode,
                  originCity: originCityController.text.trim(),
                  destinationCode: destCode,
                  destinationCity: destCityController.text.trim(),
                  departureTime: depTimeController.text.trim(),
                  arrivalTime: arrTimeController.text.trim(),
                  duration: durationController.text.trim(),
                  stops: 0,
                  cabinClass: 'Economy',
                  price: int.tryParse(priceController.text.trim()) ?? 4500,
                  refundable: true,
                  includedBaggage: '15 kg Check-in + 7 kg Cabin',
                  aircraftType: aircraftController.text.trim(),
                );

                await _flightService.addFlight(newFlight);
                if (ctx.mounted) Navigator.pop(ctx);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Flight $flightNumber created in Firestore!'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                }
              },
              child: const Text('Add to Firestore'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('SmartFlight Admin Portal'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryNavy,
                backgroundColor: AppTheme.lightBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isSeeding ? null : _seedDemoData,
              icon: _isSeeding
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_sync_rounded, size: 18),
              label: Text(_isSeeding ? 'Seeding...' : 'Seed Demo Data'),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryNavy,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryNavy,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Overview'),
            Tab(icon: Icon(Icons.flight_outlined), text: 'Flights'),
            Tab(icon: Icon(Icons.confirmation_number_outlined), text: 'Bookings'),
            Tab(icon: Icon(Icons.people_outline_rounded), text: 'Users'),
          ],
        ),
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: _bookingService.streamAllBookings(),
        builder: (context, bookingsSnapshot) {
          final allBookings = bookingsSnapshot.data ?? [];
          return StreamBuilder<List<FlightOffer>>(
            stream: _flightService.streamAllFlights(),
            builder: (context, flightsSnapshot) {
              final allFlights = flightsSnapshot.data ?? [];
              return StreamBuilder<List<UserModel>>(
                stream: _bookingService.streamAllUsers(),
                builder: (context, usersSnapshot) {
                  final allUsers = usersSnapshot.data ?? [];

                  final totalRevenue = allBookings.fold<int>(
                    0,
                    (acc, b) => b.bookingStatus == 'Cancelled' ? acc : acc + b.totalAmount,
                  );
                  final cancelledBookings =
                      allBookings.where((b) => b.bookingStatus == 'Cancelled').length;
                  final activeFlightsCount = allFlights.length;

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: OVERVIEW & STATS
                      _buildOverviewTab(
                        totalBookings: allBookings.length,
                        totalRevenue: totalRevenue,
                        totalUsers: allUsers.length,
                        activeFlights: activeFlightsCount,
                        cancelledCount: cancelledBookings,
                        recentBookings: allBookings.take(8).toList(),
                      ),

                      // TAB 2: FLIGHTS MANAGEMENT
                      _buildFlightsTab(allFlights),

                      // TAB 3: BOOKINGS OVERVIEW
                      _buildBookingsTab(allBookings),

                      // TAB 4: USERS MANAGEMENT
                      _buildUsersTab(allUsers),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab({
    required int totalBookings,
    required int totalRevenue,
    required int totalUsers,
    required int activeFlights,
    required int cancelledCount,
    required List<BookingModel> recentBookings,
  }) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Metrics Row
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              title: 'Total Bookings',
              value: '$totalBookings',
              icon: Icons.confirmation_number_rounded,
              color: AppTheme.primaryNavy,
            ),
            _buildStatCard(
              title: 'Total Revenue',
              value: '₹${NumberFormat('#,##,###').format(totalRevenue)}',
              icon: Icons.currency_rupee_rounded,
              color: AppTheme.successGreen,
            ),
            _buildStatCard(
              title: 'Registered Users',
              value: '$totalUsers',
              icon: Icons.people_alt_rounded,
              color: AppTheme.primaryBlue,
            ),
            _buildStatCard(
              title: 'Active Flights',
              value: '$activeFlights',
              icon: Icons.flight_takeoff_rounded,
              color: AppTheme.accentAmber,
            ),
            _buildStatCard(
              title: 'Cancellations',
              value: '$cancelledCount',
              icon: Icons.cancel_outlined,
              color: AppTheme.dangerRed,
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Recent Bookings Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Live Bookings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Synced with Firestore',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.successGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (recentBookings.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: const Center(
              child: Text(
                'No bookings recorded yet in Firestore. Complete a booking in the app to see it here live!',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          )
        else
          ...recentBookings.map((b) => _buildBookingCard(b)),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightsTab(List<FlightOffer> flights) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Live Flights (${flights.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _showAddFlightDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Flight'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (flights.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No flights found in Firestore. Tap "Seed Demo Data" above!'),
            ),
          )
        else
          ...flights.map(
            (f) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      f.airlineCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  '${f.airlineName} (${f.flightNumber}) • ${f.originCode} → ${f.destinationCode}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${f.departureTime} - ${f.arrivalTime} (${f.duration}) • ${f.stopsLabel} • ${f.aircraftType}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${f.price}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.dangerRed, size: 20),
                      onPressed: () async {
                        await _flightService.deleteFlight(f.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Flight ${f.flightNumber} deleted')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBookingsTab(List<BookingModel> bookings) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Total Firestore Bookings (${bookings.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        if (bookings.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No bookings found in Firestore yet.'),
            ),
          )
        else
          ...bookings.map((b) => _buildBookingCard(b)),
      ],
    );
  }

  Widget _buildBookingCard(BookingModel b) {
    final isCancelled = b.bookingStatus == 'Cancelled';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PNR: ${b.pnr}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${b.airline} ${b.flightNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCancelled
                        ? AppTheme.dangerRed.withValues(alpha: 0.12)
                        : AppTheme.successGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    b.bookingStatus,
                    style: TextStyle(
                      color: isCancelled ? AppTheme.dangerRed : AppTheme.successGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${b.departure} → ${b.arrival} • ${b.departureDate} at ${b.departureTime}',
              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Customer UID: ${b.userId} • Passengers: ${b.passengers} • Paid: ₹${b.totalAmount} (${b.paymentMethod})',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab(List<UserModel> users) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Registered Users in Firestore (${users.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        if (users.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No users in Firestore yet.'),
            ),
          )
        else
          ...users.map(
            (u) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryNavy,
                  child: Text(
                    u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                title: Text(
                  u.fullName.isNotEmpty ? u.fullName : 'Unnamed User',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${u.email} • ${u.phone.isNotEmpty ? u.phone : 'No phone'}\nUID: ${u.uid}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                isThreeLine: true,
              ),
            ),
          ),
      ],
    );
  }
}
