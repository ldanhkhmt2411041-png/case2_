import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/task.dart';
import '../models/user.dart';

class TaskService {
  static const String baseUrl = 'http://localhost:5000/api/tasks';

  static final User _me = User(
    id: 'demo_user_1',
    fullName: 'Lê Đức Anh',
    email: 'ldanhkhmt2411041@student.ctuet.edu.vn',
  );

  static final User _partner = User(
    id: 'demo_user_2',
    fullName: 'Nguyễn Văn A',
    email: 'nguyenvana@gmail.com',
  );

  static List<Task> _mockTasks = [
    Task(
      id: 'task_demo_1',
      title: 'Thiết kế giao diện quản lý công việc Flutter',
      description: 'Hoàn thiện 10 màn hình chức năng theo tài liệu Case Study 2.',
      status: 'in_progress',
      priority: 'high',
      createdBy: _me,
      assignees: [_me, _partner],
      primaryAssignee: _me,
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      dueDate: DateTime.now().add(const Duration(days: 2)),
      userPermission: 'owner',
    ),
    Task(
      id: 'task_demo_2',
      title: 'Cấu hình cơ sở dữ liệu MongoDB Atlas Cloud',
      description: 'Kết nối Mongoose với MongoDB Atlas và mở quyền 0.0.0.0/0.',
      status: 'completed',
      priority: 'high',
      createdBy: _me,
      assignees: [_me],
      primaryAssignee: _me,
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      userPermission: 'owner',
    ),
    Task(
      id: 'task_demo_3',
      title: 'Kiểm thử gửi Email thông báo Nodemailer',
      description: 'Gửi email tự động khi giao việc và khi sắp đến hạn hoàn thành.',
      status: 'todo',
      priority: 'medium',
      createdBy: _partner,
      assignees: [_me],
      primaryAssignee: _me,
      startDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 5)),
      userPermission: 'editor',
    ),
  ];

  static Future<List<Task>> getTasks({
    String? status,
    String? priority,
    String? q,
    String? scope,
    String? sortBy,
    String? order,
  }) async {
    try {
      final token = await AuthService.getToken();
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (priority != null && priority.isNotEmpty) queryParams['priority'] = priority;
      if (q != null && q.isNotEmpty) queryParams['q'] = q;
      if (scope != null && scope.isNotEmpty) queryParams['scope'] = scope;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
      if (order != null && order.isNotEmpty) queryParams['order'] = order;

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List tasksJson = body['data'] ?? [];
        return tasksJson.map((t) => Task.fromJson(t)).toList();
      }
      return _filterMockTasks(status: status, priority: priority, q: q);
    } catch (e) {
      // Khi Backend offline (nhu tren FlutLab), tra ve du lieu mau de xem giao dien
      return _filterMockTasks(status: status, priority: priority, q: q);
    }
  }

  static List<Task> _filterMockTasks({String? status, String? priority, String? q}) {
    return _mockTasks.where((t) {
      if (status != null && status.isNotEmpty && t.status != status) return false;
      if (priority != null && priority.isNotEmpty && t.priority != priority) return false;
      if (q != null && q.isNotEmpty && !t.title.toLowerCase().contains(q.toLowerCase())) return false;
      return true;
    }).toList();
  }

  static Future<Task?> getTaskById(String id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final taskData = body['data'];
        final permission = body['permission'];
        return Task.fromJson(taskData, userPermission: permission);
      }
      return _mockTasks.firstWhere((t) => t.id == id, orElse: () => _mockTasks.first);
    } catch (e) {
      return _mockTasks.firstWhere((t) => t.id == id, orElse: () => _mockTasks.first);
    }
  }

  static Future<bool> createTask({
    required String title,
    required String description,
    required String priority,
    required String status,
    DateTime? startDate,
    DateTime? dueDate,
    List<String>? assigneeIds,
    String? primaryAssigneeId,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'priority': priority,
          'status': status,
          'startDate': startDate?.toIso8601String(),
          'dueDate': dueDate?.toIso8601String(),
          'assigneeIds': assigneeIds ?? [],
          'primaryAssigneeId': primaryAssigneeId,
        }),
      ).timeout(const Duration(seconds: 3));

      return response.statusCode == 201;
    } catch (e) {
      // Demo mode: them truc tiep vao mock list
      _mockTasks.insert(0, Task(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        priority: priority,
        status: status,
        createdBy: _me,
        assignees: [_me],
        primaryAssignee: _me,
        startDate: startDate,
        dueDate: dueDate,
        userPermission: 'owner',
      ));
      return true;
    }
  }

  static Future<bool> updateTask({
    required String id,
    required String title,
    required String description,
    required String priority,
    required String status,
    DateTime? startDate,
    DateTime? dueDate,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'priority': priority,
          'status': status,
          'startDate': startDate?.toIso8601String(),
          'dueDate': dueDate?.toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      return true;
    }
  }

  static Future<bool> updateTaskStatus(String id, String status) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      final idx = _mockTasks.indexWhere((t) => t.id == id);
      if (idx != -1) {
        final t = _mockTasks[idx];
        _mockTasks[idx] = Task(
          id: t.id,
          title: t.title,
          description: t.description,
          status: status,
          priority: t.priority,
          createdBy: t.createdBy,
          assignees: t.assignees,
          primaryAssignee: t.primaryAssignee,
          startDate: t.startDate,
          dueDate: t.dueDate,
          userPermission: t.userPermission,
        );
      }
      return true;
    }
  }

  static Future<bool> deleteTask(String id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      _mockTasks.removeWhere((t) => t.id == id);
      return true;
    }
  }

  // Giao viec APIs
  static Future<Map<String, dynamic>> getAssignees(String taskId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/$taskId/assignees'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final primary = body['primaryAssignee'] != null ? User.fromJson(body['primaryAssignee']) : null;
        final List list = body['assignees'] ?? [];
        final assignees = list.map((u) => User.fromJson(u)).toList();
        return {
          'primaryAssignee': primary,
          'assignees': assignees,
        };
      }
      return {'primaryAssignee': _me, 'assignees': [_me, _partner]};
    } catch (e) {
      return {'primaryAssignee': _me, 'assignees': [_me, _partner]};
    }
  }

  static Future<bool> addAssignees(String taskId, List<String> userIds, {String? primaryAssigneeId}) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/$taskId/assignees'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userIds': userIds,
          'primaryAssigneeId': primaryAssigneeId,
        }),
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return true;
    }
  }

  static Future<bool> updatePrimaryAssignee(String taskId, String userId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/$taskId/assignees/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return true;
    }
  }

  static Future<bool> removeAssignee(String taskId, String userId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$taskId/assignees/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return true;
    }
  }
}
