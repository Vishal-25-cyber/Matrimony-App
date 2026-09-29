import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/notification_model.dart';
import '../../services/mock_data_service.dart';
import '../../core/utils/navigation_helper.dart';

class NotificationsScreen extends StatefulWidget {
  final MockDataService mockData;

  const NotificationsScreen({super.key, required this.mockData});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final notifications = widget.mockData.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A132B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          tooltip: "பின்செல்க / Back",
          onPressed: () => SafeNavigation.safePop(context),
        ),
        title: const Text(
          'அறிவிப்புகள் / Notifications',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  widget.mockData.markAllNotificationsRead();
                });
              },
              child: const Text('Mark all read', style: TextStyle(color: Color(0xFFF3E5AB), fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(color: AppColors.textLight),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: item.isRead ? Colors.white : AppColors.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: item.isRead ? AppColors.border : AppColors.primaryLight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getNotificationColor(item.type).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getNotificationIcon(item.type),
                          color: _getNotificationColor(item.type),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  item.timeAgo,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.message,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.view:
        return Icons.visibility_outlined;
      case NotificationType.interest:
        return Icons.favorite_rounded;
      case NotificationType.unlock:
        return Icons.key_rounded;
      case NotificationType.verification:
        return Icons.verified_rounded;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.view:
        return const Color(0xFF1976D2);
      case NotificationType.interest:
        return AppColors.favorite;
      case NotificationType.unlock:
        return AppColors.accentGoldDark;
      case NotificationType.verification:
        return AppColors.success;
    }
  }
}
