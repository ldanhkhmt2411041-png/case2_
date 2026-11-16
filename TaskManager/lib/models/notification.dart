class AppNotification {
  final String id;
  final String userId;
  final String? taskId;
  final String? taskTitle;
  final String type; // 'assignment', 'sharing', 'update', 'status_change', 'deadline_reminder'
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    this.taskId,
    this.taskTitle,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    String? tid;
    String? tTitle;
    if (json['taskId'] != null) {
      if (json['taskId'] is Map) {
        tid = json['taskId']['_id'];
        tTitle = json['taskId']['title'];
      } else if (json['taskId'] is String) {
        tid = json['taskId'];
      }
    }

    return AppNotification(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      taskId: tid,
      taskTitle: tTitle,
      type: json['type'] ?? 'general',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
