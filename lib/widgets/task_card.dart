import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';

/// A card widget displaying a single task with start/end dates,
/// a completion checkbox, and edit/delete buttons.
class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle; // Toggle completion
  final VoidCallback onEdit;   // Edit task
  final VoidCallback onDelete; // Delete task

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = task.startDate != null
        ? _dateFormat.format(task.startDate!)
        : 'N/A';
    final endDate = task.endDate != null
        ? _dateFormat.format(task.endDate!)
        : 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Checkbox(
          value: task.isDone,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            decoration: task.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Start: $startDate'),
            const SizedBox(height: 4),
            Text('End:   $endDate'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: 'Edit Task',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete Task',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
