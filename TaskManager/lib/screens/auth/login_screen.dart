import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../tasks/task_list_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TaskListScreen()),
      );
    } else {
      if (result['isNetworkError'] == true) {
        _showDemoModeDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Đăng nhập thất bại')),
        );
      }
    }
  }

  void _enterDemoMode() {
    AuthService.enableDemoMode();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TaskListScreen()),
    );
  }

  void _showDemoModeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Chưa kết nối Backend'),
          ],
        ),
        content: const Text(
          'Không tìm thấy máy chủ API tại http://localhost:5000 (do bạn đang xem trên FlutLab hoặc chưa bật file 1_Chay_Backend.bat).\n\n'
          '👉 Bạn có muốn vào thẳng CHẾ ĐỘ DEMO để trải nghiệm toàn bộ 10 màn hình của ứng dụng không?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Vào xem Demo ngay'),
            onPressed: () {
              Navigator.pop(ctx);
              _enterDemoMode();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng Nhập Task Manager')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.task_alt, size: 80, color: Colors.blue),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'CASE STUDY 2: QUẢN LÝ CÔNG VIỆC',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Đăng Nhập'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Chưa có tài khoản? Đăng ký ngay'),
                ),
                const Divider(height: 32),
                // Nut Demo Mode danh cho FlutLab
                OutlinedButton.icon(
                  icon: const Icon(Icons.visibility, color: Colors.teal),
                  label: const Text(
                    'Xem thử toàn bộ 10 màn hình (Chế độ Demo / FlutLab)',
                    style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.teal),
                  ),
                  onPressed: _enterDemoMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
