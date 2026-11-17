import 'package:flutter/material.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../services/task_service.dart';
import '../tasks/task_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final list = await NotificationService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    final success = await NotificationService.markAllAsRead();
    if (success && mounted) {
      _loadNotifications();
    }
  }

  Future<void> _handleTapNotification(AppNotification notif) async {
    if (!notif.isRead) {
      await NotificationService.markAsRead(notif.id);
    }

    if (notif.taskId != null && notif.taskId!.isNotEmpty && mounted) {
      final task = await TaskService.getTaskById(notif.taskId!);
      if (task != null && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
        );
      }
    }
    _loadNotifications();
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'assignment':
        return Icons.assignment_ind;
      case 'sharing':
        return Icons.share;
      case 'status_change':
        return Icons.check_circle_outline;
      case 'deadline_reminder':
        return Icons.alarm;
      case 'update':
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'assignment':
        return Colors.blue;
      case 'sharing':
        return Colors.purple;
      case 'status_change':
        return Colors.green;
      case 'deadline_reminder':
        return Colors.red;
      case 'update':
      default:
        return Colors.amber.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Báo'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: _markAllRead,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Bạn không có thông báo nào', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      final icon = _getTypeIcon(item.type);
                      final color = _getTypeColor(item.type);

                      return Container(
                        color: item.isRead ? Colors.transparent : Colors.blue.withOpacity(0.06),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(icon, color: color),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(item.message),
                              if (item.createdAt != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.createdAt.toString().split('.')[0],
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ],
                          ),
                          trailing: !item.isRead
                              ? Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                          onTap: () => _handleTapNotification(item),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
