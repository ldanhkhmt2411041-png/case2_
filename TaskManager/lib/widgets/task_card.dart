import 'package:flutter/material.dart';
import '../models/task.dart';
import 'priority_badge.dart';
import 'status_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onStatusToggle;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == 'completed';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onTap,
        leading: IconButton(
          icon: Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? Colors.green : Colors.grey,
          ),
          onPressed: onStatusToggle,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                StatusBadge(status: task.status),
                PriorityBadge(priority: task.priority),
                if (task.dueDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event, size: 13, color: Colors.grey.shade600),
                        const SizedBox(width: 2),
                        Text(
                          task.dueDate.toString().split(' ')[0],
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
