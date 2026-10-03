import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../utils/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'booking':
        return Icons.check_circle_rounded;
      case 'payment':
        return Icons.receipt_rounded;
      case 'cancellation':
        return Icons.cancel_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'booking':
        return AppTheme.successGreen;
      case 'payment':
        return AppTheme.primaryBlue;
      case 'cancellation':
        return AppTheme.dangerRed;
      default:
        return AppTheme.primaryNavy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();
    final currentUser = AuthService().currentUser;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (currentUser != null)
            TextButton(
              onPressed: () async {
                await notificationService.markAllAsRead(currentUser.uid);
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: StreamBuilder<List<NotificationItem>>(
        stream: notificationService.streamUserNotifications(currentUser?.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppTheme.lightBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        size: 40,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No Notifications Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'You will receive real-time updates about your flight bookings, tickets, and payment receipts here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = notifications[index];
              final icon = _getIconForType(item.type);
              final iconColor = _getColorForType(item.type);
              final timeFormatted = DateFormat('dd MMM, hh:mm a').format(item.createdAt);

              return InkWell(
                onTap: () {
                  if (!item.read) {
                    notificationService.markAsRead(item.id);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: item.read
                          ? AppTheme.borderColor
                          : AppTheme.primaryBlue.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: iconColor, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          item.read ? FontWeight.w600 : FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  timeFormatted,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.message,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
