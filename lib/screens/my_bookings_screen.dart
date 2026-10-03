import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../utils/app_theme.dart';
import '../widgets/empty_state.dart';
import 'booking_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryNavy,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryNavy,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: BookingService().streamUserBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.error_outline_rounded,
              title: 'Error Loading Bookings',
              message: 'Failed to retrieve your reservations: ${snapshot.error}',
            );
          }

          final allBookings = snapshot.data ?? [];

          final upcoming = allBookings
              .where((b) => b.bookingStatus == 'Confirmed')
              .toList();

          final completed = allBookings
              .where((b) => b.bookingStatus == 'Completed')
              .toList();

          final cancelled = allBookings
              .where((b) => b.bookingStatus == 'Cancelled')
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingsList(upcoming, 'No upcoming flights',
                  'When you book a flight, your tickets will appear here.'),
              _buildBookingsList(completed, 'No completed flights',
                  'Past completed journeys will be archived here.'),
              _buildBookingsList(cancelled, 'No cancelled bookings',
                  'Any cancelled reservations will be documented here.'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingsList(
      List<BookingModel> list, String emptyTitle, String emptyMessage) {
    if (list.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.flight_takeoff_rounded,
        title: emptyTitle,
        message: emptyMessage,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final booking = list[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final isCancelled = booking.bookingStatus == 'Cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingDetailsScreen(booking: booking),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Airline + PNR + Status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          booking.airline,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${booking.flightNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isCancelled
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        booking.bookingStatus.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isCancelled
                              ? AppTheme.dangerRed
                              : AppTheme.successGreen,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Route & Times
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
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        color: AppTheme.primaryBlue, size: 20),
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
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Footer: PNR + Passengers + Fare
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'PNR: ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          booking.pnr,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${booking.passengers} Pax',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${booking.totalAmount}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
