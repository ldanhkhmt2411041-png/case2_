import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/notification.dart';

class NotificationService {
  static const String baseUrl = 'http://localhost:5000/api/notifications';

  static final List<NotificationItem> _mockNotifications = [
    NotificationItem(
      id: 'notif_1',
      title: 'Công việc mới được giao',
      message: 'Bạn được giao làm người phụ trách chính cho: Thiết kế giao diện Flutter',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationItem(
      id: 'notif_2',
      title: 'Chia sẻ công việc',
      message: 'Nguyễn Văn A đã chia sẻ quyền chỉnh sửa cho: Kiểm thử gửi Email',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static Future<List<NotificationItem>> getNotifications() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body['data'] ?? [];
        return list.map((item) => NotificationItem.fromJson(item)).toList();
      }
      return _mockNotifications;
    } catch (e) {
      return _mockNotifications;
    }
  }

  static Future<int> getUnreadCount() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/unread-count'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['count'] ?? 0;
      }
      return 1;
    } catch (e) {
      return 1;
    }
  }

  static Future<bool> markAsRead(String id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/read'),
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

  static Future<bool> markAllAsRead() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/read-all'),
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
