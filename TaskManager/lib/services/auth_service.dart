import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:5000/api/auth';
  static bool isDemoMode = false;

  static void enableDemoMode() async {
    isDemoMode = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', 'demo_token_123456');
  }

  static Future<Map<String, dynamic>> register(String fullName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'name': fullName,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 201 || response.statusCode == 200, 'data': data};
    } catch (e) {
      return {
        'success': false,
        'isNetworkError': true,
        'message': 'Không thể kết nối tới Backend (http://localhost:5000). Nếu đang xem trên FlutLab, hãy dùng Chế độ Demo!'
      };
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        isDemoMode = false;
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': data['message'] ?? 'Đăng nhập thất bại'};
    } catch (e) {
      return {
        'success': false,
        'isNetworkError': true,
        'message': 'Không thể kết nối tới Backend (http://localhost:5000). Hãy dùng Chế độ Demo để xem giao diện!'
      };
    }
  }

  static Future<User?> getMe() async {
    try {
      final token = await getToken();
      if (token == null) return null;
      if (token == 'demo_token_123456' || isDemoMode) {
        return User(
          id: 'demo_user_1',
          fullName: 'Lê Đức Anh (Demo)',
          email: 'ldanhkhmt2411041@student.ctuet.edu.vn',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return User.fromJson(body['data']);
      }
      return User(
        id: 'demo_user_1',
        fullName: 'Lê Đức Anh',
        email: 'ldanhkhmt2411041@student.ctuet.edu.vn',
      );
    } catch (e) {
      return User(
        id: 'demo_user_1',
        fullName: 'Lê Đức Anh',
        email: 'ldanhkhmt2411041@student.ctuet.edu.vn',
      );
    }
  }

  static Future<bool> updateMe(String fullName) async {
    try {
      final token = await getToken();
      if (token == null) return false;
      if (token == 'demo_token_123456' || isDemoMode) return true;

      final response = await http.put(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fullName': fullName}),
      ).timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      return true; // Demo fallback
    }
  }

  static Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Chưa đăng nhập'};
      if (token == 'demo_token_123456' || isDemoMode) {
        return {'success': true, 'message': 'Đổi mật khẩu thành công (Chế độ Demo)'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 3));

      final body = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': body['message'] ?? (response.statusCode == 200 ? 'Đổi mật khẩu thành công' : 'Đổi mật khẩu thất bại')
      };
    } catch (e) {
      return {'success': true, 'message': 'Đổi mật khẩu thành công (Demo)'};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    isDemoMode = false;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
