import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/task_activity.dart';
import '../models/user.dart';

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
      ).timeout(const Duration(seconds: 3));

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
      return {'total': 3, 'todo': 1, 'inProgress': 1, 'completed': 1};
    } catch (e) {
      return {'total': 3, 'todo': 1, 'inProgress': 1, 'completed': 1};
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
      ).timeout(const Duration(seconds: 3));

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
      return {'assigned': 3, 'primary': 2, 'created': 2, 'shared': 1};
    } catch (e) {
      return {'assigned': 3, 'primary': 2, 'created': 2, 'shared': 1};
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
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        return {
          'overdue': (data['overdue'] ?? 0) as int,
          'upcoming': (data['upcoming'] ?? 0) as int,
          'completed': (data['completed'] ?? 0) as int,
        };
      }
      return {'overdue': 1, 'upcoming': 1, 'completed': 1};
    } catch (e) {
      return {'overdue': 1, 'upcoming': 1, 'completed': 1};
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
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body['data'] ?? [];
        return list.map((a) => TaskActivity.fromJson(a)).toList();
      }
      return _getMockActivities();
    } catch (e) {
      return _getMockActivities();
    }
  }

  static List<TaskActivity> _getMockActivities() {
    final me = User(id: 'demo_user_1', fullName: 'Lê Đức Anh', email: 'ldanhkhmt2411041@student.ctuet.edu.vn');
    return [
      TaskActivity(id: 'act_1', action: 'Tạo công việc', user: me, createdAt: DateTime.now().subtract(const Duration(days: 2))),
      TaskActivity(id: 'act_2', action: 'Giao việc cho Nguyễn Văn A', user: me, createdAt: DateTime.now().subtract(const Duration(days: 1))),
      TaskActivity(id: 'act_3', action: 'Đổi trạng thái sang Đang thực hiện', user: me, createdAt: DateTime.now().subtract(const Duration(hours: 3))),
    ];
  }
}
