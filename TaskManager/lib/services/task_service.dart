import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/task.dart';
import '../models/user.dart';

class TaskService {
  static const String baseUrl = 'http://localhost:5000/api/tasks';

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
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List tasksJson = body['data'] ?? [];
        return tasksJson.map((t) => Task.fromJson(t)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
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
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final taskData = body['data'];
        final permission = body['permission'];
        return Task.fromJson(taskData, userPermission: permission);
      }
      return null;
    } catch (e) {
      return null;
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
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
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
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
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
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
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
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
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
      );
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
      return {'primaryAssignee': null, 'assignees': <User>[]};
    } catch (e) {
      return {'primaryAssignee': null, 'assignees': <User>[]};
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
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
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
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
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
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
