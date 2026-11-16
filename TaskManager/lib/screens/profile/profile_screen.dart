import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/statistics_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;

  Map<String, int> _taskStats = {'total': 0, 'todo': 0, 'inProgress': 0, 'completed': 0};
  Map<String, int> _assignmentStats = {'assigned': 0, 'primary': 0, 'created': 0, 'shared': 0};
  Map<String, int> _deadlineStats = {'overdue': 0, 'upcoming': 0, 'completed': 0};

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final user = await AuthService.getMe();
    final taskStats = await StatisticsService.getTaskStats();
    final assignmentStats = await StatisticsService.getAssignmentStats();
    final deadlineStats = await StatisticsService.getDeadlineStats();

    if (mounted) {
      setState(() {
        _user = user;
        _taskStats = taskStats;
        _assignmentStats = assignmentStats;
        _deadlineStats = deadlineStats;
        _isLoading = false;
      });
    }
  }

  void _showEditProfileDialog() {
    final controller = TextEditingController(text: _user?.fullName ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cap Nhat Ho So'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Ho va ten',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huy')),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final success = await AuthService.updateMe(newName);
                if (success && mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cap nhat thong tin thanh cong!')),
                  );
                  _loadAllData();
                }
              }
            },
            child: const Text('Luu'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Doi Mat Khau'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mat khau hien tai',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mat khau moi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Xac nhan mat khau moi',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huy')),
          ElevatedButton(
            onPressed: () async {
              final cur = currentPassController.text;
              final next = newPassController.text;
              final conf = confirmPassController.text;

              if (cur.isEmpty || next.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui long dien day du thong tin')),
                );
                return;
              }
              if (next != conf) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mat khau xac nhan khong khop')),
                );
                return;
              }

              final result = await AuthService.changePassword(cur, next);
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
              }
            },
            child: const Text('Doi mat khau'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ca Nhan & Thong Ke'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAllData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Card
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.blue.shade700,
                              child: Text(
                                _user?.fullName.isNotEmpty == true ? _user!.fullName[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _user?.fullName ?? 'Nguoi dung',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _user?.email ?? '',
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _showEditProfileDialog();
                                } else if (val == 'password') {
                                  _showChangePasswordDialog();
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'edit', child: Text('Cap nhat ho so')),
                                PopupMenuItem(value: 'password', child: Text('Doi mat khau')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SECTION 1: Status Statistics
                    const Text(
                      'Thong ke theo trang thai cong viec',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatCard('Chua lam', '${_taskStats['todo']}', Colors.blue, Icons.list_alt),
                        _buildStatCard('Dang lam', '${_taskStats['inProgress']}', Colors.orange, Icons.run_circle_outlined),
                        _buildStatCard('Da xong', '${_taskStats['completed']}', Colors.green, Icons.check_circle_outline),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // SECTION 2: Assignment Statistics
                    const Text(
                      'Thong ke cong viec theo vai tro',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatCard('Duoc giao', '${_assignmentStats['assigned']}', Colors.indigo, Icons.assignment_turned_in),
                        _buildStatCard('Phu trach chinh', '${_assignmentStats['primary']}', Colors.amber.shade800, Icons.star_border),
                        _buildStatCard('Cua toi tao', '${_assignmentStats['created']}', Colors.teal, Icons.create_new_folder_outlined),
                        _buildStatCard('Duoc chia se', '${_assignmentStats['shared']}', Colors.purple, Icons.share),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // SECTION 3: Deadlines Statistics
                    const Text(
                      'Theo doi han hoan thanh',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatCard('Sap den han (<48h)', '${_deadlineStats['upcoming']}', Colors.amber.shade900, Icons.timer),
                        _buildStatCard('Qua han', '${_deadlineStats['overdue']}', Colors.red.shade700, Icons.warning_amber_rounded),
                        _buildStatCard('Da hoan tat', '${_deadlineStats['completed']}', Colors.green.shade700, Icons.task_alt),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text('Dang Xuat Khoi He Thong', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Xac nhan dang xuat'),
                              content: const Text('Ban co chac chan muon dang xuat khong?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huy')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Dang xuat', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await AuthService.logout();
                            if (mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
