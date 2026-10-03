import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_button.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();

  void _showEditProfileDialog(UserModel user) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final phoneCtrl = TextEditingController(text: user.phone);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        setDialogState(() => isSaving = true);
                        try {
                          await _authService.updateUserProfile(
                            fullName: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                          );
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully!'),
                              backgroundColor: AppTheme.successGreen,
                            ),
                          );
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update: $e'),
                              backgroundColor: AppTheme.dangerRed,
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Are you sure you want to sign out from Smart Flight?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Account Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<UserModel?>(
        stream: _authService.streamUserProfile(),
        builder: (context, snapshot) {
          final user = snapshot.data ??
              UserModel(
                uid: _authService.currentUser?.uid ?? '',
                fullName: _authService.currentUser?.displayName ?? 'Smart Flyer',
                email: _authService.currentUser?.email ?? '',
              );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.primaryNavy,
                      child: Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user.fullName.isNotEmpty ? user.fullName : 'Smart Flyer',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (user.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.phone,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium_rounded,
                              size: 16, color: AppTheme.accentGold),
                          SizedBox(width: 6),
                          Text(
                            'Smart Flyer Gold Tier',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _showEditProfileDialog(user),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit Profile'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(140, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Booking Stats Row
              FutureBuilder<List<BookingModel>>(
                future: BookingService().getUserBookings(),
                builder: (context, bSnap) {
                  final bookings = bSnap.data ?? [];
                  final confirmedCount =
                      bookings.where((b) => b.bookingStatus == 'Confirmed').length;

                  return Row(
                    children: [
                      Expanded(
                        child: _statBox(
                          'Upcoming Flights',
                          '$confirmedCount',
                          Icons.flight_takeoff_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statBox(
                          'Total Bookings',
                          '${bookings.length}',
                          Icons.confirmation_number_outlined,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // Navigation Preferences
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    _profileTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Information',
                      subtitle: 'Update government ID and contact details',
                      onTap: () => _showEditProfileDialog(user),
                    ),
                    const Divider(height: 1, indent: 56),
                    _profileTile(
                      icon: Icons.settings_outlined,
                      title: 'Settings & Preferences',
                      subtitle: 'Language, notifications, and security',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _profileTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Customer Support',
                      subtitle: '24x7 Flight reservation assistance',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout Button
              AppSecondaryButton(
                label: 'Sign Out',
                icon: Icons.logout_rounded,
                borderColor: AppTheme.dangerRed.withValues(alpha: 0.5),
                textColor: AppTheme.dangerRed,
                onPressed: _showLogoutDialog,
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _statBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppTheme.primaryNavy),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: AppTheme.textMuted),
      onTap: onTap,
    );
  }
}
