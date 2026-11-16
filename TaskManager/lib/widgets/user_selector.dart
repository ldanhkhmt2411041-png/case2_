import 'package:flutter/material.dart';
import '../models/user.dart';

class UserSelector extends StatelessWidget {
  final List<User> users;
  final User? selectedUser;
  final ValueChanged<User?> onSelected;
  final String label;

  const UserSelector({
    super.key,
    required this.users,
    this.selectedUser,
    required this.onSelected,
    this.label = 'Chọn người dùng',
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<User>(
      value: selectedUser,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: users.map((u) {
        return DropdownMenuItem<User>(
          value: u,
          child: Text('${u.fullName} (${u.email})'),
        );
      }).toList(),
      onChanged: onSelected,
    );
  }
}
