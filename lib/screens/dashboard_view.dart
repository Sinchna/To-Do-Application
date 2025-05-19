// lib/screens/dashboard_view.dart

import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../services/user_service.dart';
import 'login_view.dart';
import 'profile_view.dart';
import 'task_editor_view.dart';
import '../widgets/task_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  List<TaskModel> tasks = [];
  List<TaskModel> filteredTasks = [];
  bool _isLoading = true;
  String? _username;
  String? _profilePicUrl;
  final TextEditingController _searchController = TextEditingController();

  // In-app notifications
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadTasks();
  }

  Future<void> _loadUserInfo() async {
    final profile = await UserService.getProfile();
    if (!mounted) return;
    setState(() {
      _username = profile?['username'] ?? 'User';
      _profilePicUrl = profile?['profilePic'];
    });
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    tasks = await TaskService.getTasks();
    _applyFilter(_searchController.text);
    setState(() => _isLoading = false);
  }

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    filteredTasks = q.isEmpty
        ? List.from(tasks)
        : tasks.where((t) => t.title.toLowerCase().contains(q)).toList();
  }

  Future<void> _logout() async {
    await UserService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  Future<void> _openEditor([TaskModel? task]) async {
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => TaskEditorView(task: task)),
    );
    if (result != null && result.isNotEmpty) {
      final action = task == null ? 'added' : 'updated';
      _addNotification("Todo '$result' $action");
    }
    await _loadTasks();
  }

  Future<void> _deleteTaskWithNotification(TaskModel task) async {
    await TaskService.deleteTask(task.id);
    _addNotification("Todo '${task.title}' deleted");
    await _loadTasks();
  }

  void _addNotification(String message) {
    setState(() => notifications.insert(0, message));
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: notifications.isEmpty
              ? const Text('🎉 No notifications')
              : ListView(
                  shrinkWrap: true,
                  children: notifications
                      .map((msg) => ListTile(title: Text(msg)))
                      .toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileView()),
            );
            await _loadUserInfo();
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: (_profilePicUrl != null && _profilePicUrl!.isNotEmpty)
                    ? NetworkImage(_profilePicUrl!)
                    : null,
                child: (_profilePicUrl == null || _profilePicUrl!.isEmpty)
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                "Hi, ${_username}",
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
        actions: [
          // Notifications bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, size: 28),
                onPressed: _showNotifications,
                tooltip: 'Notifications',
              ),
              if (notifications.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${notifications.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                  onChanged: (val) => setState(() => _applyFilter(val)),
                ),
              ),

              // "Your ToDos" header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your ToDos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredTasks.isEmpty
              ? const Center(child: Text('No tasks found.'))
              : RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final t = filteredTasks[index];
                      return TaskCard(
                        task: t,
                        onToggle: () async {
                          final updated = TaskModel(
                            id: t.id,
                            title: t.title,
                            isDone: !t.isDone,
                            startDate: t.startDate,
                            endDate: t.endDate,
                          );
                          await TaskService.updateTask(updated);
                          _addNotification("Todo '${t.title}' marked ${updated.isDone ? 'done' : 'not done'}");
                          await _loadTasks();
                        },
                        onEdit: () => _openEditor(t),
                        onDelete: () => _deleteTaskWithNotification(t),
                      );
                    },
                  ),
                ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
