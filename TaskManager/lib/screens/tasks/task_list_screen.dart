import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import 'task_create_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _selectedStatus = '';
  String _selectedPriority = '';
  String _selectedScope = ''; // '', 'created', 'assigned', 'shared'
  String _searchQuery = '';
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await TaskService.getTasks(
      status: _selectedStatus.isEmpty ? null : _selectedStatus,
      priority: _selectedPriority.isEmpty ? null : _selectedPriority,
      q: _searchQuery.isEmpty ? null : _searchQuery,
      scope: _selectedScope.isEmpty ? null : _selectedScope,
      sortBy: _sortBy,
      order: _sortOrder,
    );
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  void _toggleStatus(Task task) async {
    String nextStatus = 'todo';
    if (task.status == 'todo') {
      nextStatus = 'in_progress';
    } else if (task.status == 'in_progress') {
      nextStatus = 'completed';
    } else {
      nextStatus = 'todo';
    }

    final success = await TaskService.updateTaskStatus(task.id, nextStatus);
    if (success && mounted) {
      _loadTasks();
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.grey;
    }
  }

  String _formatPriority(String priority) {
    switch (priority) {
      case 'high':
        return 'Cao';
      case 'medium':
        return 'TB';
      case 'low':
      default:
        return 'Thap';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quan Ly Cong Viec'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tim kiem cong viec...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _loadTasks();
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (value) {
                setState(() => _searchQuery = value);
                _loadTasks();
              },
            ),
          ),

          // Scope Filter Tabs (Tất cả, Của tôi, Được giao, Được chia sẻ)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tat ca'),
                  selected: _selectedScope == '',
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedScope = '');
                      _loadTasks();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Cua toi'),
                  selected: _selectedScope == 'created',
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedScope = 'created');
                      _loadTasks();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Duoc giao'),
                  selected: _selectedScope == 'assigned',
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedScope = 'assigned');
                      _loadTasks();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Duoc chia se'),
                  selected: _selectedScope == 'shared',
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedScope = 'shared');
                      _loadTasks();
                    }
                  },
                ),
              ],
            ),
          ),

          // Filter by status & priority & sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Trang thai: Tat ca')),
                      DropdownMenuItem(value: 'todo', child: Text('Chua lam')),
                      DropdownMenuItem(value: 'in_progress', child: Text('Dang lam')),
                      DropdownMenuItem(value: 'completed', child: Text('Da xong')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedStatus = val);
                        _loadTasks();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Uu tien: Tat ca')),
                      DropdownMenuItem(value: 'low', child: Text('Thap')),
                      DropdownMenuItem(value: 'medium', child: Text('Trung binh')),
                      DropdownMenuItem(value: 'high', child: Text('Cao')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedPriority = val);
                        _loadTasks();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Tasks List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? const Center(child: Text('Khong co cong viec nao'))
                    : RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            final isDone = task.status == 'completed';

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: ListTile(
                                leading: IconButton(
                                  icon: Icon(
                                    isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: isDone ? Colors.green : Colors.grey,
                                  ),
                                  onPressed: () => _toggleStatus(task),
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
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getPriorityColor(task.priority).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: _getPriorityColor(task.priority), width: 0.8),
                                          ),
                                          child: Text(
                                            _formatPriority(task.priority),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _getPriorityColor(task.priority),
                                            ),
                                          ),
                                        ),
                                        if (task.dueDate != null) ...[
                                          const SizedBox(width: 8),
                                          Icon(Icons.event, size: 13, color: Colors.grey.shade600),
                                          const SizedBox(width: 2),
                                          Text(
                                            task.dueDate.toString().split(' ')[0],
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                          ),
                                        ],
                                        if (task.primaryAssignee != null) ...[
                                          const SizedBox(width: 8),
                                          Icon(Icons.person, size: 13, color: Colors.blue.shade700),
                                          const SizedBox(width: 2),
                                          Text(
                                            task.primaryAssignee!.fullName,
                                            style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaskDetailScreen(task: task),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadTasks();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskCreateScreen()),
          );
          if (created == true) _loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
