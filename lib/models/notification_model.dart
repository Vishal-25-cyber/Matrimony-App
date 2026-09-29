enum NotificationType {
  view,
  interest,
  unlock,
  verification,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  bool isRead;
  final NotificationType type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
    required this.type,
  });
}
