import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _flightAlerts = true;
  bool _promoAlerts = true;
  bool _smsUpdates = false;

  void _showHelpSupport() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '24x7 Customer Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Reach out anytime for flight reschedules, refund status, or luggage queries.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppTheme.lightBlue,
                child: Icon(Icons.phone_in_talk_rounded,
                    color: AppTheme.primaryBlue),
              ),
              title: const Text('Toll-Free Helpline',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('1800 123 4567 • (Mon-Sun 24/7)'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppTheme.lightBlue,
                child: Icon(Icons.email_outlined, color: AppTheme.primaryBlue),
              ),
              title: const Text('Email Support',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('support@smartflight.io'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPolicyDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
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
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Notifications Settings Card
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _flightAlerts,
                  activeThumbColor: AppTheme.primaryNavy,
                  title: const Text(
                    'Flight Status Alerts',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Gate changes, boarding reminders, delay notifications',
                    style: TextStyle(fontSize: 12),
                  ),
                  onChanged: (val) => setState(() => _flightAlerts = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _promoAlerts,
                  activeThumbColor: AppTheme.primaryNavy,
                  title: const Text(
                    'Fare Drops & Promotions',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Exclusive discounts and seasonal airline offers',
                    style: TextStyle(fontSize: 12),
                  ),
                  onChanged: (val) => setState(() => _promoAlerts = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _smsUpdates,
                  activeThumbColor: AppTheme.primaryNavy,
                  title: const Text(
                    'SMS Updates',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Receive PNR confirmation directly on mobile SMS',
                    style: TextStyle(fontSize: 12),
                  ),
                  onChanged: (val) => setState(() => _smsUpdates = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Legal & Support Card
          const Text(
            'Support & Legal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.support_agent_rounded,
                      color: AppTheme.primaryNavy),
                  title: const Text(
                    'Customer Support',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppTheme.textMuted),
                  onTap: _showHelpSupport,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined,
                      color: AppTheme.primaryNavy),
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppTheme.textMuted),
                  onTap: () => _showPolicyDialog(
                    'Privacy Policy',
                    'Smart Flight Reservation is committed to safeguarding user personal and travel information. Data collected during ticket reservations, passenger manifests, and payments are encrypted using bank-grade protocols and utilized solely for travel facilitation as governed by aviation security mandates.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined,
                      color: AppTheme.primaryNavy),
                  title: const Text(
                    'Terms & Conditions',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppTheme.textMuted),
                  onTap: () => _showPolicyDialog(
                    'Terms of Service',
                    'By booking flights on Smart Flight, you agree to adhere to airline carrier conditions of carriage, baggage size limitations, government photo ID mandates at boarding gates, and stated refund cancellation timelines.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded,
                      color: AppTheme.primaryNavy),
                  title: const Text(
                    'About Smart Flight',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  trailing: const Text(
                    'v1.0.0',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  onTap: () => _showPolicyDialog(
                    'About Smart Flight',
                    'Smart Flight Reservation System is a full-featured, production-style flight booking platform built with Flutter, Firebase Authentication, and Cloud Firestore.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sign Out Tile
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: ListTile(
              leading:
                  const Icon(Icons.logout_rounded, color: AppTheme.dangerRed),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppTheme.dangerRed,
                ),
              ),
              onTap: () async {
                await AuthService().signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
