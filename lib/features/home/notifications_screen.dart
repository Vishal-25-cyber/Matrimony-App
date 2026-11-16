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
  /// Shows a confirmation dialog before clearing all notifications
  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear All Notifications?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Text(
          'All notifications will be permanently deleted.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC81E1E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.mockData.clearAllNotifications();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  /// Deletes a single notification with undo snack-bar
  void _deleteOne(int index, NotificationModel item) {
    widget.mockData.deleteNotification(index);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF2C161A),
        duration: const Duration(seconds: 3),
        content: Text(
          '"${item.title}" deleted',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: const Color(0xFFD4AF37),
          onPressed: () {
            // Re-insert at same position
            widget.mockData.notifications.insert(index, item);
            // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
            widget.mockData.notifyListeners();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.mockData,
      builder: (context, _) {
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
              tooltip: 'பின்செல்க / Back',
              onPressed: () => SafeNavigation.safePop(context),
            ),
            title: const Text(
              'அறிவிப்புகள் / Notifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            actions: [
              if (notifications.isNotEmpty) ...[
                TextButton(
                  onPressed: () => widget.mockData.markAllNotificationsRead(),
                  child: const Text(
                    'Mark read',
                    style: TextStyle(color: Color(0xFFF3E5AB), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFFFCDD2)),
                  tooltip: 'Clear All',
                  onPressed: _confirmClearAll,
                ),
              ],
            ],
          ),
          body: notifications.isEmpty
              ? _buildEmpty()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return _NotificationCard(
                      item: item,
                      onDelete: () => _deleteOne(index, item),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded, size: 48, color: Color(0xFF7A132B)),
          ),
          const SizedBox(height: 16),
          const Text(
            'அறிவிப்புகள் இல்லை',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C161A)),
          ),
          const SizedBox(height: 6),
          const Text(
            'No notifications yet',
            style: TextStyle(fontSize: 13, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Individual notification card with swipe + delete button
// ─────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final VoidCallback onDelete;

  const _NotificationCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.hashCode ^ item.title.hashCode ^ item.message.hashCode),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFC81E1E),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: item.isRead
              ? Colors.white
              : AppColors.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead
                ? AppColors.border
                : AppColors.primaryLight.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _color, size: 20),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.timeAgo,
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight),
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

            // Delete icon button
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFC81E1E)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    switch (item.type) {
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

  Color get _color {
    switch (item.type) {
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
