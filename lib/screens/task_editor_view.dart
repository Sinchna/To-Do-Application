import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskEditorView extends StatefulWidget {
  final TaskModel? task;
  const TaskEditorView({super.key, this.task});

  @override
  State<TaskEditorView> createState() => _TaskEditorViewState();
}

class _TaskEditorViewState extends State<TaskEditorView> {
  final TextEditingController _titleController = TextEditingController();
  bool isDone = false;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      isDone = widget.task!.isDone;
      _startDate = widget.task!.startDate;
      _endDate = widget.task!.endDate;
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (newDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = newDate;
        } else {
          _endDate = newDate;
        }
      });
    }
  }

  void saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final isNew = widget.task == null;

    final task = TaskModel(
      id: isNew ? '' : widget.task!.id,
      title: title,
      isDone: isDone,
      startDate: _startDate,
      endDate: _endDate,
    );

    try {
      if (isNew) {
        await TaskService.addTask(task);
      } else {
        await TaskService.updateTask(task);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save task: $e')),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add/Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Completed'),
              value: isDone,
              onChanged: (v) => setState(() => isDone = v ?? false),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(context, true),
                    child: Text('Start Date: ${_formatDate(_startDate)}'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(context, false),
                    child: Text('End Date: ${_formatDate(_endDate)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: saveTask, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
