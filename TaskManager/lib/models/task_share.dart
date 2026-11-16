import 'user.dart';

class TaskShare {
  final String id;
  final String taskId;
  final User? user;
  final String permission; // 'viewer' or 'editor'
  final User? sharedBy;
  final DateTime? createdAt;

  TaskShare({
    required this.id,
    required this.taskId,
    this.user,
    required this.permission,
    this.sharedBy,
    this.createdAt,
  });

  factory TaskShare.fromJson(Map<String, dynamic> json) {
    return TaskShare(
      id: json['_id'] ?? '',
      taskId: json['taskId'] is Map ? (json['taskId']['_id'] ?? '') : (json['taskId'] ?? ''),
      user: json['userId'] != null && json['userId'] is Map
          ? User.fromJson(json['userId'])
          : null,
      permission: json['permission'] ?? 'viewer',
      sharedBy: json['sharedBy'] != null && json['sharedBy'] is Map
          ? User.fromJson(json['sharedBy'])
          : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
