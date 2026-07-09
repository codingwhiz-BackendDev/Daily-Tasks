import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskStorageService {
  static const String _tasksKey = 'tasks';
  static TaskStorageService? _instance;
  static SharedPreferences? _preferences;

  TaskStorageService._();

  static Future<TaskStorageService> getInstance() async {
    if (_instance == null) {
      _instance = TaskStorageService._();
      _preferences = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  Future<List<Task>> getTasks() async {
    final String? tasksJson = _preferences?.getString(_tasksKey);
    if (tasksJson == null) return [];

    final List<dynamic> decoded = json.decode(tasksJson);
    return decoded.map((item) => Task.fromJson(item)).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final String encoded = json.encode(
      tasks.map((task) => task.toJson()).toList(),
    );
    await _preferences?.setString(_tasksKey, encoded);
  }

  Future<void> addTask(Task task) async {
    final tasks = await getTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  Future<void> updateTask(Task updatedTask) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await saveTasks(tasks);
  }

  Future<void> clearAllTasks() async {
    await _preferences?.remove(_tasksKey);
  }
}
