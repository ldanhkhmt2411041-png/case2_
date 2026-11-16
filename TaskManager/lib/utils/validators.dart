class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email là bắt buộc';
    final regex = RegExp(r'^[\w\-.]+@[\w\-]+\.\w+$');
    if (!regex.hasMatch(value.trim())) return 'Email không hợp lệ';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Mật khẩu là bắt buộc';
    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }

  static String? required(String? value, [String field = 'Trường này']) {
    if (value == null || value.trim().isEmpty) return '$field là bắt buộc';
    return null;
  }
}
