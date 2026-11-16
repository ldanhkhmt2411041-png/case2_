import 'user.dart';

class TaskActivity {
  final String id;
  final String taskId;
  final User? user;
  final String action;
  final Map<String, dynamic> details;
  final DateTime? createdAt;

  TaskActivity({
    required this.id,
    required this.taskId,
    this.user,
    required this.action,
    this.details = const {},
    this.createdAt,
  });

  factory TaskActivity.fromJson(Map<String, dynamic> json) {
    User? u;
    if (json['userId'] != null) {
      if (json['userId'] is Map<String, dynamic>) {
        u = User.fromJson(json['userId']);
      } else if (json['userId'] is String) {
        u = User(id: json['userId'], fullName: '', email: '');
      }
    }

    return TaskActivity(
      id: json['_id'] ?? '',
      taskId: json['taskId'] ?? '',
      user: u,
      action: json['action'] ?? '',
      details: json['details'] is Map ? Map<String, dynamic>.from(json['details']) : {},
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
