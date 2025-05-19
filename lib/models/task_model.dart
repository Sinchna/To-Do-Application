import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class TaskModel {
  final String id;
  final String title;
  final bool isDone;
  final DateTime? startDate;
  final DateTime? endDate;

  TaskModel({
    required this.id,
    required this.title,
    required this.isDone,
    this.startDate,
    this.endDate,
  });

  factory TaskModel.fromParse(ParseObject obj) {
    return TaskModel(
      id: obj.objectId ?? '',
      title: obj.get<String>('title') ?? '',
      isDone: obj.get<bool>('isDone') ?? false,
      startDate: obj.get<DateTime>('startDate'),
      endDate: obj.get<DateTime>('endDate'),
    );
  }

  ParseObject toParseObject() {
    final task = ParseObject('Task')
      ..set('title', title)
      ..set('isDone', isDone);

    if (startDate != null) {
      task.set('startDate', startDate);
    }
    if (endDate != null) {
      task.set('endDate', endDate);
    }

    // Don't assign objectId here; handled in service
    return task;
  }
}
