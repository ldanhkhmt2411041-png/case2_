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
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa công việc này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
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
        return 'Đang thực hiện';
      case 'completed':
        return 'Đã hoàn thành';
      case 'todo':
      default:
        return 'Chưa thực hiện';
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
        return 'Trung bình';
      case 'low':
      default:
        return 'Thấp';
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
        title: const Text('Chi Tiết Công Việc'),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Chỉnh sửa',
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
              tooltip: 'Xóa công việc',
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                            const Text('Mô tả:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 6),
                            Text(
                              _currentTask.description.isEmpty ? 'Không có mô tả chi tiết' : _currentTask.description,
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text('Trạng thái: ', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                    label: const Text('Đổi trạng thái'),
                                    onPressed: _toggleStatus,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('Mức độ ưu tiên: ', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                  Text('Ngày bắt đầu: ${_currentTask.startDate.toString().split(' ')[0]}'),
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
                                    'Hạn hoàn thành: ${_currentTask.dueDate.toString().split(' ')[0]}',
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                            if (_currentTask.createdBy != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.create, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text('Người tạo: ${_currentTask.createdBy!.fullName} (${_currentTask.createdBy!.email})'),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Actions Row: Giao viec va Chia se
                    if (isCreator || canEdit)
                      Row(
                        children: [
                          if (isCreator)
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.person_add),
                                label: const Text('Giao việc'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AssignTaskScreen(task: _currentTask)),
                                  );
                                  _refreshTask();
                                },
                              ),
                            ),
                          if (isCreator && canEdit) const SizedBox(width: 12),
                          if (isCreator)
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.share),
                                label: const Text('Chia sẻ'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Người phụ trách:',
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
                                title: Text('${_currentTask.primaryAssignee!.fullName} (Phụ trách chính)'),
                                subtitle: Text(_currentTask.primaryAssignee!.email),
                              ),
                            if (_currentTask.assignees.isNotEmpty) ...[
                              const Divider(),
                              const Text('Tất cả người được giao:', style: TextStyle(fontWeight: FontWeight.w600)),
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
                              const Text('Chưa giao cho ai', style: TextStyle(color: Colors.grey)),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SECTION 4: Activity History (Lịch sử hoạt động)
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        leading: const Icon(Icons.history, color: Colors.blueGrey),
                        title: Text(
                          'Lịch sử hoạt động (${_activities.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          if (_activities.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Chưa có lịch sử hoạt động nào', style: TextStyle(color: Colors.grey)),
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
                                    'Bởi: ${act.user?.fullName ?? "Hệ thống"}'
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
