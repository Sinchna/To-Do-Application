import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../models/task_model.dart';

class TaskService {
  static Future<List<TaskModel>> getTasks() async {
    final query = QueryBuilder(ParseObject('Task'));
    final response = await query.query();
    if (response.success && response.results != null) {
      return (response.results as List<ParseObject>)
          .map((e) => TaskModel.fromParse(e))
          .toList();
    }
    return [];
  }

  static Future<void> addTask(TaskModel task) async {
    final obj = task.toParseObject();
    // Make sure it's a new object without objectId
    obj.objectId = null;
    await obj.save();
  }

  static Future<void> updateTask(TaskModel task) async {
    if (task.id.isEmpty) {
      throw Exception('Task ID is required for update');
    }
    final obj = task.toParseObject();
    obj.objectId = task.id; // Set existing ID for update
    await obj.save();
  }

  static Future<void> deleteTask(String id) async {
    final obj = ParseObject('Task')..objectId = id;
    await obj.delete();
  }
}
