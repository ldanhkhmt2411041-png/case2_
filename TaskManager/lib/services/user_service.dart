import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/user.dart';

class UserService {
  static const String baseUrl = 'http://localhost:5000/api/users';

  static Future<List<User>> searchUsers(String query) async {
    try {
      final token = await AuthService.getToken();
      final uri = Uri.parse('$baseUrl/search').replace(queryParameters: {'q': query});
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body['data'] ?? [];
        return list.map((u) => User.fromJson(u)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<User?> getUserById(String id) async {
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
        return User.fromJson(body['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
