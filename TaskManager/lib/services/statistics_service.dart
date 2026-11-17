import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/task_activity.dart';

class StatisticsService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<Map<String, int>> getTaskStats() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        return {
          'total': (data['total'] ?? 0) as int,
          'todo': (data['todo'] ?? 0) as int,
          'inProgress': (data['inProgress'] ?? 0) as int,
          'completed': (data['completed'] ?? 0) as int,
        };
      }
      return {'total': 0, 'todo': 0, 'inProgress': 0, 'completed': 0};
    } catch (e) {
      return {'total': 0, 'todo': 0, 'inProgress': 0, 'completed': 0};
    }
  }

  static Future<Map<String, int>> getAssignmentStats() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/assignments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        return {
          'assigned': (data['assigned'] ?? 0) as int,
          'primary': (data['primary'] ?? 0) as int,
          'created': (data['created'] ?? 0) as int,
          'shared': (data['shared'] ?? 0) as int,
        };
      }
      return {'assigned': 0, 'primary': 0, 'created': 0, 'shared': 0};
    } catch (e) {
      return {'assigned': 0, 'primary': 0, 'created': 0, 'shared': 0};
    }
  }

  static Future<Map<String, int>> getDeadlineStats() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/deadlines'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        return {
          'overdue': (data['overdue'] ?? 0) as int,
          'upcoming': (data['upcoming'] ?? 0) as int,
          'completed': (data['completed'] ?? 0) as int,
        };
      }
      return {'overdue': 0, 'upcoming': 0, 'completed': 0};
    } catch (e) {
      return {'overdue': 0, 'upcoming': 0, 'completed': 0};
    }
  }

  static Future<List<TaskActivity>> getTaskActivities(String taskId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/$taskId/activities'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body['data'] ?? [];
        return list.map((a) => TaskActivity.fromJson(a)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
