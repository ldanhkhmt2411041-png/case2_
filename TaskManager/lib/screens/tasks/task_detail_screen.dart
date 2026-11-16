import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/task_activity.dart';
import '../../services/statistics_service.dart';
import '../../services/task_service.dart';
import '../assignment/assign_task_screen.dart';
import '../sharing/task_sharing_screen.dart';
import 'task_edit_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _currentTask;
  bool _isLoading = true;
  List<TaskActivity> _activities = [];

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _refreshTask();
  }

  Future<void> _refreshTask() async {
    setState(() => _isLoading = true);
    final task = await TaskService.getTaskById(_currentTask.id);
    final activities = await StatisticsService.getTaskActivities(_currentTask.id);
    if (mounted) {
      setState(() {
        if (task != null) {
          _currentTask = task;
        }
        _activities = activities;
        _isLoading = false;
      });
    }
  }

  void _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xac nhan xoa'),
        content: const Text('Ban co chac chan muon xoa cong viec nay khong?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xoa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await TaskService.deleteTask(_currentTask.id);
      if (mounted && success) {
        Navigator.pop(context, true);
      }
    }
  }

  void _toggleStatus() async {
    String nextStatus = 'todo';
    if (_currentTask.status == 'todo') {
      nextStatus = 'in_progress';
    } else if (_currentTask.status == 'in_progress') {
      nextStatus = 'completed';
    } else {
      nextStatus = 'todo';
    }

    final success = await TaskService.updateTaskStatus(_currentTask.id, nextStatus);
    if (success && mounted) {
      _refreshTask();
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'in_progress':
        return 'Dang thuc hien';
      case 'completed':
        return 'Da hoan thanh';
      case 'todo':
      default:
        return 'Chua thuc hien';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'todo':
      default:
        return Colors.blue;
    }
  }

  String _formatPriority(String priority) {
    switch (priority) {
      case 'high':
        return 'Cao';
      case 'medium':
        return 'Trung binh';
      case 'low':
      default:
        return 'Thap';
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.amber.shade800;
      case 'low':
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _currentTask.canEdit;
    final isCreator = _currentTask.isCreator;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiet Cong Viec'),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Chinh sua',
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskEditScreen(task: _currentTask)),
                );
                if (updated == true && mounted) {
                  _refreshTask();
                }
              },
            ),
          if (isCreator)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Xoa cong viec',
              onPressed: _handleDelete,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshTask,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Card
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentTask.title,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const Divider(height: 24),
                            const Text('Mo ta:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 6),
                            Text(
                              _currentTask.description.isEmpty ? 'Khong co mo ta' : _currentTask.description,
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text('Trang thai: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                Chip(
                                  label: Text(
                                    _formatStatus(_currentTask.status),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: _getStatusColor(_currentTask.status),
                                ),
                                if (canEdit) ...[
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    icon: const Icon(Icons.sync, size: 16),
                                    label: const Text('Doi trang thai'),
                                    onPressed: _toggleStatus,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('Muc do uu tien: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                Chip(
                                  label: Text(
                                    _formatPriority(_currentTask.priority),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: _getPriorityColor(_currentTask.priority),
                                ),
                              ],
                            ),
                            if (_currentTask.startDate != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text('Ngay bat dau: ${_currentTask.startDate.toString().split(' ')[0]}'),
                                ],
                              ),
                            ],
                            if (_currentTask.dueDate != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.event, size: 16, color: Colors.red),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Han hoan thanh: ${_currentTask.dueDate.toString().split(' ')[0]}',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                            if (_currentTask.createdBy != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: Colors.blueGrey),
                                  const SizedBox(width: 6),
                                  Text('Nguoi tao: ${_currentTask.createdBy!.fullName} (${_currentTask.createdBy!.email})'),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Actions for Assignment & Sharing
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.assignment_ind),
                            label: const Text('Giao viec'),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AssignTaskScreen(task: _currentTask)),
                              );
                              _refreshTask();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.indigo.shade600,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.share),
                            label: const Text('Chia se'),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TaskSharingScreen(task: _currentTask)),
                              );
                              _refreshTask();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // People involved
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nguoi phu trach:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            if (_currentTask.primaryAssignee != null)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.amber,
                                  child: Icon(Icons.star, color: Colors.white),
                                ),
                                title: Text('${_currentTask.primaryAssignee!.fullName} (Phu trach chinh)'),
                                subtitle: Text(_currentTask.primaryAssignee!.email),
                              ),
                            if (_currentTask.assignees.isNotEmpty) ...[
                              const Divider(),
                              const Text('Tat ca nguoi duoc giao:', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              ..._currentTask.assignees.map((user) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?'),
                                ),
                                title: Text(user.fullName),
                                subtitle: Text(user.email),
                              )),
                            ] else if (_currentTask.primaryAssignee == null) ...[
                              const Text('Chua giao cho ai', style: TextStyle(color: Colors.grey)),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SECTION 4: Activity History (Lịch sử hoạt động)
                    Card(
                      elevation: 1,
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        leading: const Icon(Icons.history, color: Colors.blueGrey),
                        title: Text(
                          'Lich su hoat dong (${_activities.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          if (_activities.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Chua co lich su hoat dong nao', style: TextStyle(color: Colors.grey)),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _activities.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final act = _activities[index];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.check_circle_outline, size: 18, color: Colors.teal),
                                  title: Text(act.action, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    'Boi: ${act.user?.fullName ?? "He thong"}'
                                    '${act.createdAt != null ? " • ${act.createdAt.toString().split('.')[0]}" : ""}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
