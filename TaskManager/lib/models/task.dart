import 'user.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final DateTime? startDate;
  final DateTime? dueDate;
  final User? createdBy;
  final List<User> assignees;
  final User? primaryAssignee;
  final String? permission; // 'creator', 'assignee', 'editor', 'viewer'

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.startDate,
    this.dueDate,
    this.createdBy,
    this.assignees = const [],
    this.primaryAssignee,
    this.permission,
  });

  bool get isCreator => permission == 'creator';
  bool get canEdit => permission == 'creator' || permission == 'editor' || permission == 'assignee';
  bool get isViewer => permission == 'viewer';

  factory Task.fromJson(Map<String, dynamic> json, {String? userPermission}) {
    User? creator;
    if (json['createdBy'] != null) {
      if (json['createdBy'] is Map<String, dynamic>) {
        creator = User.fromJson(json['createdBy']);
      } else if (json['createdBy'] is String) {
        creator = User(id: json['createdBy'], fullName: '', email: '');
      }
    }

    List<User> parsedAssignees = [];
    if (json['assigneeIds'] != null && json['assigneeIds'] is List) {
      for (var item in json['assigneeIds']) {
        if (item is Map<String, dynamic>) {
          parsedAssignees.add(User.fromJson(item));
        } else if (item is String) {
          parsedAssignees.add(User(id: item, fullName: '', email: ''));
        }
      }
    }

    User? primary;
    if (json['primaryAssigneeId'] != null) {
      if (json['primaryAssigneeId'] is Map<String, dynamic>) {
        primary = User.fromJson(json['primaryAssigneeId']);
      } else if (json['primaryAssigneeId'] is String) {
        primary = User(id: json['primaryAssigneeId'], fullName: '', email: '');
      }
    }

    return Task(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'todo',
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      createdBy: creator,
      assignees: parsedAssignees,
      primaryAssignee: primary,
      permission: userPermission ?? json['permission'],
    );
  }
}
