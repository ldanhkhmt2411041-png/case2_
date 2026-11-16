import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';

class AssignTaskScreen extends StatefulWidget {
  final Task task;

  const AssignTaskScreen({super.key, required this.task});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  bool _isLoading = false;
  List<User> _assignees = [];
  User? _primaryAssignee;

  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadAssignees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignees() async {
    setState(() => _isLoading = true);
    final data = await TaskService.getAssignees(widget.task.id);
    if (mounted) {
      setState(() {
        _assignees = List<User>.from(data['assignees'] ?? []);
        _primaryAssignee = data['primaryAssignee'];
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

  Future<void> _addAssignee(User user) async {
    if (_assignees.any((u) => u.id == user.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nguoi dung nay da duoc giao viec')),
      );
      return;
    }

    final success = await TaskService.addAssignees(
      widget.task.id,
      [user.id],
      primaryAssigneeId: _primaryAssignee == null ? user.id : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Da giao viec cho ${user.fullName}')),
      );
      _searchController.clear();
      setState(() => _searchResults = []);
      _loadAssignees();
    }
  }

  Future<void> _setPrimaryAssignee(User user) async {
    final success = await TaskService.updatePrimaryAssignee(widget.task.id, user.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Da chon ${user.fullName} la nguoi phu trach chinh')),
      );
      _loadAssignees();
    }
  }

  Future<void> _removeAssignee(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xac nhan'),
        content: Text('Huy giao viec cho ${user.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Dong y', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await TaskService.removeAssignee(widget.task.id, user.id);
      if (success && mounted) {
        _loadAssignees();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao Cong Viec'),
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
                    'Tim kiem nguoi dung de giao viec:',
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
                          final isAlready = _assignees.any((u) => u.id == user.id);
                          return ListTile(
                            leading: CircleAvatar(child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?')),
                            title: Text(user.fullName),
                            subtitle: Text(user.email),
                            trailing: isAlready
                                ? const Chip(label: Text('Da giao', style: TextStyle(fontSize: 12)))
                                : ElevatedButton.icon(
                                    icon: const Icon(Icons.person_add, size: 16),
                                    label: const Text('Giao'),
                                    onPressed: () => _addAssignee(user),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Danh sach nguoi duoc giao viec:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_assignees.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Chua co ai duoc giao viec', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _assignees.length,
                      itemBuilder: (context, index) {
                        final user = _assignees[index];
                        final isPrimary = _primaryAssignee != null && _primaryAssignee!.id == user.id;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isPrimary ? Colors.amber.shade700 : Colors.blue.shade300,
                              foregroundColor: Colors.white,
                              child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?'),
                            ),
                            title: Row(
                              children: [
                                Expanded(child: Text(user.fullName)),
                                if (isPrimary)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.amber.shade700),
                                    ),
                                    child: const Text('Phu trach chinh', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown)),
                                  ),
                              ],
                            ),
                            subtitle: Text(user.email),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'primary') {
                                  _setPrimaryAssignee(user);
                                } else if (value == 'remove') {
                                  _removeAssignee(user);
                                }
                              },
                              itemBuilder: (context) => [
                                if (!isPrimary)
                                  const PopupMenuItem(
                                    value: 'primary',
                                    child: Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.amber, size: 20),
                                        SizedBox(width: 8),
                                        Text('Dat lam phu trach chinh'),
                                      ],
                                    ),
                                  ),
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person_remove, color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Text('Huy giao viec', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
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
