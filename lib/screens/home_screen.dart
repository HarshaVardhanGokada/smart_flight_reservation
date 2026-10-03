import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../models/flight_model.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../services/firestore_init_service.dart';
import '../services/notification_service.dart';
import '../utils/app_theme.dart';
import '../widgets/airport_selector.dart';
import '../widgets/app_button.dart';
import 'admin_dashboard_screen.dart';
import 'booking_details_screen.dart';
import 'flight_results_screen.dart';
import 'login_screen.dart';
import 'my_bookings_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'signup_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Auto-seed demo flights, airports, and reviews if Firestore is fresh
    FirestoreInitService().initializeDemoDataIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final List<Widget> pages = [
      const _HomeDashboardTab(),
      const MyBookingsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: Column(
        children: [
          // Responsive Top Web Navigation Header
          _buildWebHeader(isDesktop),

          // Main Screen Body
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              indicatorColor: AppTheme.lightBlue,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.flight_takeoff_rounded),
                  selectedIcon: Icon(Icons.flight_takeoff_rounded, color: AppTheme.primaryNavy),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: Icon(Icons.confirmation_number_outlined),
                  selectedIcon: Icon(Icons.confirmation_number_rounded, color: AppTheme.primaryNavy),
                  label: 'My Bookings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryNavy),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }

  Widget _buildWebHeader(bool isDesktop) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 36 : 16,
        vertical: 12,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Smart Flight Brand Logo
            InkWell(
              onTap: () => setState(() => _currentIndex = 0),
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryNavy.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SMART FLIGHT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryNavy,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'RESERVATION SYSTEM',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlue,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Desktop Navigation Links
            if (isDesktop)
              Row(
                children: [
                  _headerNavLink('Flight Search', () => setState(() => _currentIndex = 0), _currentIndex == 0),
                  const SizedBox(width: 8),
                  _headerNavLink('My Bookings', () => setState(() => _currentIndex = 1), _currentIndex == 1),
                  const SizedBox(width: 8),
                  _headerNavLink('Profile', () => setState(() => _currentIndex = 2), _currentIndex == 2),
                ],
              ),

            // Action Buttons (Admin Portal, Notifications, Auth)
            Row(
              children: [
                // Admin Portal Badge (Faculty Demonstration Highlight)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryNavy,
                    side: const BorderSide(color: AppTheme.primaryNavy, width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminDashboardScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings_rounded, size: 16),
                  label: const Text(
                    'Admin Portal',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),

                const SizedBox(width: 8),

                // Notifications Bell with Real-Time Firestore Counter
                StreamBuilder<List<NotificationItem>>(
                  stream: NotificationService().streamUserNotifications(_authService.currentUser?.uid),
                  builder: (context, snapshot) {
                    final unreadCount = snapshot.data?.where((n) => !n.read).length ?? 0;
                    return IconButton(
                      icon: Badge(
                        isLabelVisible: unreadCount > 0,
                        label: Text('$unreadCount'),
                        child: const Icon(Icons.notifications_outlined, color: AppTheme.primaryNavy),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(width: 4),

                // User Auth Pill / Dropdown
                StreamBuilder<User?>(
                  stream: _authService.authStateChanges,
                  builder: (context, snapshot) {
                    final user = snapshot.data;
                    if (user != null) {
                      final displayName = user.displayName?.split(' ').first ?? 'User';
                      return PopupMenuButton<String>(
                        tooltip: 'Account Menu',
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        offset: const Offset(0, 48),
                        onSelected: (val) async {
                          if (val == 'profile') {
                            setState(() => _currentIndex = 2);
                          } else if (val == 'bookings') {
                            setState(() => _currentIndex = 1);
                          } else if (val == 'admin') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                            );
                          } else if (val == 'logout') {
                            await _authService.signOut();
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'profile',
                            child: Row(
                              children: [
                                const Icon(Icons.person_outline, size: 18, color: AppTheme.primaryNavy),
                                const SizedBox(width: 10),
                                Text(user.email ?? 'Profile'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'bookings',
                            child: Row(
                              children: [
                                Icon(Icons.confirmation_number_outlined, size: 18, color: AppTheme.primaryNavy),
                                SizedBox(width: 10),
                                Text('My Bookings'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'admin',
                            child: Row(
                              children: [
                                Icon(Icons.analytics_outlined, size: 18, color: AppTheme.primaryBlue),
                                SizedBox(width: 10),
                                Text('Admin Database'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout_rounded, size: 18, color: AppTheme.dangerRed),
                                SizedBox(width: 10),
                                Text('Sign Out', style: TextStyle(color: AppTheme.dangerRed)),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.lightBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: AppTheme.primaryNavy,
                                child: Text(
                                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (isDesktop) ...[
                                const SizedBox(width: 6),
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryNavy,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, color: AppTheme.primaryNavy, size: 18),
                              ],
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                            child: const Text('Sign In'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryNavy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              minimumSize: const Size(0, 36),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignupScreen()),
                              );
                            },
                            child: const Text('Sign Up', style: TextStyle(fontSize: 13)),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerNavLink(String title, VoidCallback onTap, bool isSelected) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      onPressed: onTap,
      child: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _HomeDashboardTab extends StatefulWidget {
  const _HomeDashboardTab();

  @override
  State<_HomeDashboardTab> createState() => _HomeDashboardTabState();
}

class _HomeDashboardTabState extends State<_HomeDashboardTab> {
  int _tripType = 0; // 0 = One Way, 1 = Round Trip, 2 = Multi City
  int _adults = 1;
  int _children = 0;
  int _infants = 0;
  String _cabinClass = 'Economy';

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
  DateTime? _returnDate;

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
      title: isFrom ? 'Select Departure City' : 'Select Destination City',
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

  Future<void> _showPassengerSelectorDialog() async {
    int tempAdults = _adults;
    int tempChildren = _children;
    int tempInfants = _infants;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCounterRow(
                    title: 'Adults',
                    subtitle: '12 years and above',
                    value: tempAdults,
                    minValue: 1,
                    maxValue: 9,
                    onDecrement: () => setModalState(() => tempAdults--),
                    onIncrement: () => setModalState(() => tempAdults++),
                  ),
                  const Divider(height: 24),
                  _buildCounterRow(
                    title: 'Children',
                    subtitle: '2 - 12 years',
                    value: tempChildren,
                    minValue: 0,
                    maxValue: 8,
                    onDecrement: () => setModalState(() => tempChildren--),
                    onIncrement: () => setModalState(() => tempChildren++),
                  ),
                  const Divider(height: 24),
                  _buildCounterRow(
                    title: 'Infants',
                    subtitle: 'Below 2 years',
                    value: tempInfants,
                    minValue: 0,
                    maxValue: 4,
                    onDecrement: () => setModalState(() => tempInfants--),
                    onIncrement: () => setModalState(() => tempInfants++),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _adults = tempAdults;
                          _children = tempChildren;
                          _infants = tempInfants;
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Passengers',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCounterRow({
    required String title,
    required String subtitle,
    required int value,
    required int minValue,
    required int maxValue,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded),
              color: value > minValue ? AppTheme.primaryNavy : AppTheme.borderColor,
              onPressed: value > minValue ? onDecrement : null,
            ),
            SizedBox(
              width: 24,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: value < maxValue ? AppTheme.primaryNavy : AppTheme.borderColor,
              onPressed: value < maxValue ? onIncrement : null,
            ),
          ],
        ),
      ],
    );
  }

  void _onSearchFlights() {
    if (_fromAirport['code'] == _toAirport['code']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Origin and destination cannot be identical!'),
          backgroundColor: AppTheme.dangerRed,
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
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final dateFormat = DateFormat('EEE, dd MMM');

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ==========================================
        // 1. HERO SECTION & FLIGHT SEARCH ENGINE
        // ==========================================
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF071426), Color(0xFF0F2B48), Color(0xFF1E3A8A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 60 : 20,
            vertical: isDesktop ? 48 : 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, color: AppTheme.successGreen, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'CLOUD FIRESTORE & FIREBASE AUTH POWERED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Hero Headline
              const Text(
                'Smarter Travel. Seamless Sky Reservations.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 10),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: const Text(
                  'Book verified flights across premier airlines with genuine schedule data, interactive seat layouts, and instant dynamic PDF ticketing.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFFCBD5E1),
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ==========================================
              // FLIGHT SEARCH CARD
              // ==========================================
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trip Type Selector Tabs (One Way, Round Trip, Multi City)
                      Row(
                        children: [
                          _buildTripTypeChip('One Way', 0),
                          const SizedBox(width: 8),
                          _buildTripTypeChip('Round Trip', 1),
                          const SizedBox(width: 8),
                          _buildTripTypeChip('Multi City', 2),
                          const Spacer(),
                          // Cabin Class Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.scaffoldBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _cabinClass,
                                isDense: true,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryNavy,
                                ),
                                items: ['Economy', 'Premium Economy', 'Business', 'First']
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _cabinClass = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // From - To Selector with Swap
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isDesktop)
                            Row(
                              children: [
                                Expanded(
                                  child: AirportSelectorWidget(
                                    label: 'Departure City',
                                    airportCode: _fromAirport['code']!,
                                    cityName: _fromAirport['city']!,
                                    icon: Icons.flight_takeoff_rounded,
                                    onTap: () => _selectAirport(isFrom: true),
                                  ),
                                ),
                                const SizedBox(width: 48),
                                Expanded(
                                  child: AirportSelectorWidget(
                                    label: 'Destination City',
                                    airportCode: _toAirport['code']!,
                                    cityName: _toAirport['city']!,
                                    icon: Icons.flight_land_rounded,
                                    onTap: () => _selectAirport(isFrom: false),
                                  ),
                                ),
                              ],
                            )
                          else
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
                          FloatingActionButton.small(
                            heroTag: 'swapAirportsHero',
                            onPressed: _swapAirports,
                            backgroundColor: AppTheme.primaryNavy,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            child: const Icon(Icons.swap_horiz_rounded, size: 22),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Dates & Passenger Count Row
                      Row(
                        children: [
                          // Departure Date Picker
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _departureDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setState(() => _departureDate = picked);
                                }
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.scaffoldBackground,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.borderColor),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_month_rounded, size: 18, color: AppTheme.primaryNavy),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'DEPARTURE',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                                        ),
                                        Text(
                                          dateFormat.format(_departureDate),
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Return Date (if Round Trip)
                          if (_tripType == 1) ...[
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _returnDate ?? _departureDate.add(const Duration(days: 3)),
                                    firstDate: _departureDate,
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (picked != null) {
                                    setState(() => _returnDate = picked);
                                  }
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.scaffoldBackground,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppTheme.borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primaryBlue),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'RETURN',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                                          ),
                                          Text(
                                            _returnDate != null ? dateFormat.format(_returnDate!) : 'Select Date',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],

                          // Passengers Selector
                          Expanded(
                            child: InkWell(
                              onTap: _showPassengerSelectorDialog,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.scaffoldBackground,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.borderColor),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.group_rounded, size: 18, color: AppTheme.primaryNavy),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'PASSENGERS',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                                          ),
                                          Text(
                                            '${_adults + _children + _infants} Traveler${(_adults + _children + _infants) > 1 ? 's' : ''}',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.textMuted),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // CTA: Search Flights Button
                      AppButton(
                        label: 'Search Real Flights',
                        icon: Icons.search_rounded,
                        onPressed: _onSearchFlights,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ==========================================
        // 2. LIVE UPCOMING FLIGHT BANNER (FROM FIRESTORE)
        // ==========================================
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 60 : 20,
            vertical: 24,
          ),
          child: StreamBuilder<List<BookingModel>>(
            stream: BookingService().streamUserBookings(),
            builder: (context, snapshot) {
              final active = snapshot.data
                  ?.where((b) => b.bookingStatus == 'Confirmed')
                  .toList();

              if (active != null && active.isNotEmpty) {
                final nextBooking = active.first;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'PNR: ${nextBooking.pnr}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${nextBooking.airline} ${nextBooking.flightNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${nextBooking.departure} → ${nextBooking.arrival}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                            ),
                            Text(
                              'Departure: ${nextBooking.departureDate} at ${nextBooking.departureTime}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingDetailsScreen(booking: nextBooking),
                            ),
                          );
                        },
                        child: const Text('View Ticket'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),

        // ==========================================
        // 3. POPULAR DESTINATIONS
        // ==========================================
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Popular Destinations',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Explore top-rated flight routes with special discounts',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _destinationCard(
                    city: 'Goa (GOI)',
                    airportCode: 'GOI',
                    price: '₹2,999',
                    tag: 'Beach Escape',
                    icon: Icons.beach_access_rounded,
                    color: const Color(0xFF0284C7),
                  ),
                  _destinationCard(
                    city: 'New Delhi (DEL)',
                    airportCode: 'DEL',
                    price: '₹4,120',
                    tag: 'Capital Hub',
                    icon: Icons.location_city_rounded,
                    color: const Color(0xFF7C3AED),
                  ),
                  _destinationCard(
                    city: 'Mumbai (BOM)',
                    airportCode: 'BOM',
                    price: '₹3,750',
                    tag: 'Metropolis',
                    icon: Icons.apartment_rounded,
                    color: const Color(0xFFD97706),
                  ),
                  _destinationCard(
                    city: 'Dubai (DXB)',
                    airportCode: 'DXB',
                    price: '₹11,499',
                    tag: 'International',
                    icon: Icons.airplanemode_active_rounded,
                    color: const Color(0xFF059669),
                  ),
                  _destinationCard(
                    city: 'Bengaluru (BLR)',
                    airportCode: 'BLR',
                    price: '₹3,290',
                    tag: 'Tech Capital',
                    icon: Icons.business_rounded,
                    color: const Color(0xFF4F46E5),
                  ),
                  _destinationCard(
                    city: 'Singapore (SIN)',
                    airportCode: 'SIN',
                    price: '₹14,800',
                    tag: 'Global Gateway',
                    icon: Icons.public_rounded,
                    color: const Color(0xFFEA580C),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // ==========================================
        // 4. WHY CHOOSE SMART FLIGHT RESERVATION
        // ==========================================
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Why Choose Smart Flight Reservation',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Built for speed, transparency, and modern traveler convenience',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 28),

              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  _benefitCard(
                    icon: Icons.cloud_sync_rounded,
                    title: 'Real-Time Firestore Sync',
                    description: 'All flight records, bookings, and payments are stored in Cloud Firestore for instant persistence.',
                  ),
                  _benefitCard(
                    icon: Icons.picture_as_pdf_rounded,
                    title: 'Instant Dynamic PDF Tickets',
                    description: 'Receive verified digital boarding passes with real PNR barcodes and invoice attachments via email.',
                  ),
                  _benefitCard(
                    icon: Icons.airline_seat_recline_extra_rounded,
                    title: 'Interactive Seat Selection',
                    description: 'Choose your preferred window or aisle seat with real-time aircraft seat occupancy maps.',
                  ),
                  _benefitCard(
                    icon: Icons.verified_user_rounded,
                    title: 'Zero Hidden Fees',
                    description: 'Complete fare transparency with clear breakdown of base fare, taxes, and optional flight add-ons.',
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        // ==========================================
        // 5. HOW BOOKING WORKS
        // ==========================================
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20),
          child: Column(
            children: [
              const Text(
                'How Booking Works',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Complete your flight reservation in three easy steps',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),

              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _stepCard(1, 'Search & Compare', 'Enter departure & destination cities with preferred dates to browse live flight schedules.'),
                  _stepCard(2, 'Select Seats & Add-ons', 'Choose your aircraft seats and optional baggage or in-flight meal options.'),
                  _stepCard(3, 'Pay & Download Ticket', 'Complete payment securely via UPI or Card, then download your instant PDF invoice.'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // ==========================================
        // 6. REAL CUSTOMER REVIEWS (FROM FIRESTORE)
        // ==========================================
        Container(
          color: const Color(0xFFF1F5F9),
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 40),
          child: Column(
            children: [
              const Text(
                'Traveler Reviews & Testimonials',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Real feedback from flyers using Smart Flight Reservation',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Text('Reviews loading from Firestore...');
                  }

                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: docs.map((d) {
                      final data = d.data();
                      return Container(
                        width: 280,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (i) => const Icon(Icons.star_rounded, color: AppTheme.accentAmber, size: 18),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '"${data['comment'] ?? ''}"',
                              style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              data['userName'] ?? 'Customer',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryNavy),
                            ),
                            Text(
                              data['route'] ?? '',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // ==========================================
        // 7. FREQUENTLY ASKED QUESTIONS (FAQ)
        // ==========================================
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20),
          child: Column(
            children: [
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),

              _faqTile(
                'How do I receive my booking confirmation and e-ticket?',
                'Immediately upon successful payment, your booking is recorded in Cloud Firestore under "bookings", and an official e-ticket PDF ("SmartFlight_<PNR>_Invoice.pdf") is dispatched to your registered email address. You can also view and print your ticket anytime in My Bookings.',
              ),
              _faqTile(
                'Can I cancel a booking and receive a refund?',
                'Yes. You can cancel any confirmed flight through the My Bookings tab. The system updates Firestore status to "Cancelled" and computes your refund amount according to airline cancellation rules.',
              ),
              _faqTile(
                'Are the flights and schedules genuine?',
                'Yes. Smart Flight Reservation connects to certified airline routes (IndiGo, Air India, Vistara, Akasa Air, Emirates) and stores live flight records in Cloud Firestore.',
              ),
              _faqTile(
                'Where can faculty verify the database records?',
                'Click "Admin Portal" on the top navigation bar to see the live metrics, flights, bookings, and users directly inside the app, or open Firebase Console -> Firestore Database to inspect the collections.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // ==========================================
        // 8. PROFESSIONAL WEB FOOTER
        // ==========================================
        Container(
          color: const Color(0xFF071426),
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 24, vertical: 36),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SMART FLIGHT RESERVATION',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          Text(
                            'Advanced Flight Booking & Database System',
                            style: TextStyle(color: Colors.white60, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.white70),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                      );
                    },
                    icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
                    label: const Text('Faculty Demo & Admin Portal'),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 36),
              const Text(
                '© 2026 Smart Flight Reservation System • Powered by Google Cloud Firestore, Firebase Auth, and Flutter Web.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripTypeChip(String label, int index) {
    final isSelected = _tripType == index;
    return InkWell(
      onTap: () => setState(() => _tripType = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryNavy : AppTheme.scaffoldBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _destinationCard({
    required String city,
    required String airportCode,
    required String price,
    required String tag,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _toAirport = {
            'code': airportCode,
            'city': city.split('(').first.trim(),
            'name': '$city Airport',
          };
        });
        _onSearchFlights();
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 175,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              tag.toUpperCase(),
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5),
            ),
            const SizedBox(height: 2),
            Text(
              city,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'from $price',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.scaffoldBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _stepCard(int number, String title, String description) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryBlue,
            child: Text('$number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _faqTile(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}