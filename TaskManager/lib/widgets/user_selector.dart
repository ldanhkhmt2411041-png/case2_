import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserSelectorDialog extends StatefulWidget {
  final String title;
  final Function(User) onSelect;

  const UserSelectorDialog({
    super.key,
    required this.title,
    required this.onSelect,
  });

  @override
  State<UserSelectorDialog> createState() => _UserSelectorDialogState();
}

class _UserSelectorDialogState extends State<UserSelectorDialog> {
  final TextEditingController _controller = TextEditingController();
  List<User> _users = [];
  bool _isLoading = false;

  void _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _users = []);
      return;
    }
    setState(() => _isLoading = true);
    final results = await UserService.searchUsers(query.trim());
    if (mounted) {
      setState(() {
        _users = results;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Nhap email hoac ten nguoi dung...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: _search,
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final u = _users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : '?'),
                      ),
                      title: Text(u.fullName),
                      subtitle: Text(u.email),
                      onTap: () {
                        widget.onSelect(u);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Dong'),
        ),
      ],
    );
  }
}
