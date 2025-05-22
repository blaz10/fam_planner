import 'package:fam_planner/core/constants/app_constants.dart';
import 'package:fam_planner/models/task.dart';
import 'package:fam_planner/services/database_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class TaskService extends ChangeNotifier {
  late final Box<Task> _box;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Get the box from DatabaseService
      _box = DatabaseService().getBox<Task>(AppConstants.tasksBox);
      _isInitialized = true;
      print('TaskService initialized successfully');
    } catch (e) {
      print('Error initializing TaskService: $e');
      rethrow;
    }
  }

  // CRUD Operations
  Future<void> addTask(Task task) async {
    if (!_isInitialized) await initialize();
    
    print('Adding task: ${task.title}');
    await _box.put(task.id, task);
    print('Task added successfully');
    
    // Notify listeners about the change
    notifyListeners();

    // Schedule notifications if needed
    if (task.notifyBefore && task.notificationInterval != null) {
      _scheduleNotification(task);
    }
  }

  Future<void> updateTask(Task task) async {
    if (!_isInitialized) await initialize();
    
    print('Updating task: ${task.id}');
    await _box.put(task.id, task);
    print('Task updated successfully');
    
    // Notify listeners about the change
    notifyListeners();

    // Reschedule notifications
    if (task.notifyBefore && task.notificationInterval != null) {
      _scheduleNotification(task);
    }
  }

  Future<void> deleteTask(String id) async {
    if (!_isInitialized) await initialize();
    
    print('Deleting task: $id');
    await _box.delete(id);
    print('Task deleted successfully');
    
    // Notify listeners about the change
    notifyListeners();
    
    // Cancel any pending notifications
    _cancelNotification(id);
  }

  Task? getTask(String id) => _box.get(id);

  List<Task> getAll() => _box.values.toList();

  // Get tasks by status
  List<Task> getTasksByStatus(bool isCompleted) {
    return _box.values.where((task) => task.isDone == isCompleted).toList();
  }

  // Get tasks by priority
  List<Task> getTasksByPriority(int priority) {
    return _box.values.where((task) => task.priority == priority).toList();
  }

  // Get tasks by category
  List<Task> getTasksByCategory(String category) {
    return _box.values.where((task) => task.category == category).toList();
  }

  // Get all unique categories
  List<String> getCategories() {
    return _box.values.map((task) => task.category).toSet().toList()..sort();
  }

  // Get upcoming tasks
  List<Task> getUpcomingTasks({int daysAhead = 7}) {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: daysAhead));

    return _box.values.where((task) {
        return !task.isDone &&
            task.dueDate.isAfter(now) &&
            task.dueDate.isBefore(endDate);
      }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get overdue tasks
  List<Task> getOverdueTasks() {
    final now = DateTime.now();
    return _box.values
        .where((task) => !task.isDone && task.dueDate.isBefore(now))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get tasks by date range
  List<Task> getTasksByDateRange(DateTime start, DateTime end) {
    return _box.values.where((task) {
        return task.dueDate.isAfter(start) && task.dueDate.isBefore(end);
      }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
  
  // Get tasks for a specific day
  List<Task> getTasksForDay(DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _box.values.where((task) {
      return !task.dueDate.isBefore(startOfDay) && 
             task.dueDate.isBefore(endOfDay);
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(String id) async {
    final task = _box.get(id);
    if (task != null) {
      await _box.put(id, task.copyWith(isDone: !task.isDone));
      notifyListeners();
    }
  }

  // Get tasks assigned to a specific user
  List<Task> getTasksAssignedTo(String userId) {
    return _box.values.where((task) => task.assignedTo == userId).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get recurring tasks
  List<Task> getRecurringTasks() {
    return _box.values.where((task) => task.isRecurring).toList();
  }

  // Generate recurring instances for a task
  List<Task> generateRecurringInstances(Task task, {int count = 10}) {
    if (!task.isRecurring) return [task];

    final instances = <Task>[];
    var currentDate = task.dueDate;

    for (var i = 0; i < count; i++) {
      instances.add(
        task.copyWith(id: '${task.id}_$i', dueDate: currentDate, isDone: false),
      );

      currentDate = task.recurrenceRule!.getNextOccurrence(currentDate);
    }

    return instances;
  }

  // Notification handling
  void _scheduleNotification(Task task) {
    if (!task.notifyBefore || task.notificationInterval == null) return;

    final notificationTime = task.dueDate.subtract(task.notificationInterval!);

    // TODO: Implement notification scheduling
    // This is a placeholder for the actual notification scheduling logic
    // You would typically use a package like flutter_local_notifications

    print(
      'Scheduling notification for task: ${task.title} at $notificationTime',
    );
  }

  void _cancelNotification(String taskId) {
    // TODO: Implement notification cancellation
    // This would cancel any pending notifications for the given task
    print('Cancelling notifications for task: $taskId');
  }

  
  // Clean up
  Future<void> close() async {
    await _box.close();
  }
}
