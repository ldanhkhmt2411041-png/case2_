import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/task_share.dart';
import '../../models/user.dart';
import '../../services/task_share_service.dart';
import '../../services/user_service.dart';

class TaskSharingScreen extends StatefulWidget {
  final Task task;

  const TaskSharingScreen({super.key, required this.task});

  @override
  State<TaskSharingScreen> createState() => _TaskSharingScreenState();
}

class _TaskSharingScreenState extends State<TaskSharingScreen> {
  bool _isLoading = false;
  List<TaskShare> _shares = [];

  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isSearching = false;
  String _selectedPermission = 'viewer';

  @override
  void initState() {
    super.initState();
    _loadShares();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadShares() async {
    setState(() => _isLoading = true);
    final shares = await TaskShareService.getShares(widget.task.id);
    if (mounted) {
      setState(() {
        _shares = shares;
        _isLoading = false;
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await UserService.searchUsers(query.trim());
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  Future<void> _addShare(User user) async {
    if (_shares.any((s) => s.user != null && s.user!.id == user.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nguoi dung nay da duoc chia se cong viec')),
      );
      return;
    }

    final success = await TaskShareService.addShare(
      widget.task.id,
      user.id,
      _selectedPermission,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Da chia se cong viec voi ${user.fullName} (${_selectedPermission == 'editor' ? 'Chinh sua' : 'Chi xem'})')),
      );
      _searchController.clear();
      setState(() => _searchResults = []);
      _loadShares();
    }
  }

  Future<void> _updatePermission(TaskShare share, String newPermission) async {
    final success = await TaskShareService.updateSharePermission(
      widget.task.id,
      share.id,
      newPermission,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Da doi quyen thanh: ${newPermission == 'editor' ? 'Chinh sua' : 'Chi xem'}')),
      );
      _loadShares();
    }
  }

  Future<void> _revokeShare(TaskShare share) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thu hoi chia se'),
        content: Text('Thu hoi quyen truy cap cua ${share.user?.fullName ?? "nguoi dung"}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Thu hoi', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await TaskShareService.removeShare(widget.task.id, share.id);
      if (success && mounted) {
        _loadShares();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chia Se & Phan Quyen'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chia se cong viec voi nguoi khac:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Nhap email hoac ten...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onSubmitted: _searchUsers,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _searchUsers(_searchController.text),
                        child: const Text('Tim'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Quyen mac dinh khi chia se: '),
                      DropdownButton<String>(
                        value: _selectedPermission,
                        items: const [
                          DropdownMenuItem(value: 'viewer', child: Text('Chi xem (Viewer)')),
                          DropdownMenuItem(value: 'editor', child: Text('Chinh sua (Editor)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedPermission = val);
                        },
                      ),
                    ],
                  ),
                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (_searchResults.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          final isAlready = _shares.any((s) => s.user != null && s.user!.id == user.id);
                          return ListTile(
                            leading: CircleAvatar(child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?')),
                            title: Text(user.fullName),
                            subtitle: Text(user.email),
                            trailing: isAlready
                                ? const Chip(label: Text('Da chia se', style: TextStyle(fontSize: 12)))
                                : ElevatedButton.icon(
                                    icon: const Icon(Icons.share, size: 16),
                                    label: const Text('Chia se'),
                                    onPressed: () => _addShare(user),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Danh sach duoc chia se:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_shares.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Chua chia se voi ai', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _shares.length,
                      itemBuilder: (context, index) {
                        final share = _shares[index];
                        final user = share.user;
                        final isEditor = share.permission == 'editor';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isEditor ? Colors.teal.shade300 : Colors.indigo.shade300,
                              foregroundColor: Colors.white,
                              child: Text(user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : '?'),
                            ),
                            title: Text(user?.fullName ?? 'Nguoi dung'),
                            subtitle: Text(user?.email ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButton<String>(
                                  value: share.permission,
                                  underline: const SizedBox(),
                                  items: const [
                                    DropdownMenuItem(value: 'viewer', child: Text('Viewer', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold))),
                                    DropdownMenuItem(value: 'editor', child: Text('Editor', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
                                  ],
                                  onChanged: (newVal) {
                                    if (newVal != null && newVal != share.permission) {
                                      _updatePermission(share, newVal);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  tooltip: 'Thu hoi quyen',
                                  onPressed: () => _revokeShare(share),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
