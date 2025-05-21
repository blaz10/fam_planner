import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';
import 'package:fam_planner/models/base_model.dart';
import 'package:fam_planner/models/recurrence_rule.dart';

part 'task.g.dart';

// Register the DurationAdapter
@HiveType(typeId: 100)
class HiveDuration extends HiveObject {
  @HiveField(0)
  final int microseconds;

  HiveDuration(this.microseconds);

  Duration toDuration() => Duration(microseconds: microseconds);
  
  factory HiveDuration.fromDuration(Duration duration) => HiveDuration(duration.inMicroseconds);
}

@HiveType(typeId: 2)
@JsonSerializable(explicitToJson: true)
class Task implements BaseModel<Task> {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final String room;
  
  @HiveField(4)
  final String? assignedTo; // ID of assigned household member
  
  @HiveField(5)
  final DateTime dueDate;
  
  @HiveField(6)
  final bool isDone;
  
  @HiveField(7)
  final int priority; // 0: Low, 1: Medium, 2: High
  
  @HiveField(8)
  final DateTime createdAt;
  
  @HiveField(9)
  final DateTime updatedAt;
  
  // New fields
  @HiveField(10)
  final String category;
  
  @HiveField(11, defaultValue: null)
  final RecurrenceRule? recurrenceRule;
  
  @HiveField(12, defaultValue: const [])
  final List<String> attachmentPaths;
  
  @HiveField(13, defaultValue: true)
  final bool notifyBefore;
  
  @HiveField(14, defaultValue: null)
  @JsonKey(includeIfNull: false)
  int? notificationIntervalMicros;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.room,
    this.assignedTo,
    required this.dueDate,
    this.isDone = false,
    this.priority = 1, // Default to Medium
    DateTime? createdAt,
    DateTime? updatedAt,
    this.category = 'General',
    this.recurrenceRule,
    List<String>? attachmentPaths,
    this.notifyBefore = true,
    Duration? notificationInterval,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        attachmentPaths = attachmentPaths ?? [],
        notificationIntervalMicros = notificationInterval?.inMicroseconds;
  
  @override
  static int get typeId => 2;
  
  static const int hiveTypeId = 2;
  
  /// Registers the Hive adapter for the Task model
  static void registerHiveAdapter() {
    if (!Hive.isAdapterRegistered(hiveTypeId)) {
      Hive.registerAdapter(TaskAdapter());
    }
  }
  
  @override
  Map<String, dynamic> toHive() => toJson();
  
  @override
  Task fromHive(Map<String, dynamic> json) => Task.fromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$TaskToJson(this);
  
  @override
  Task fromJson(Map<String, dynamic> json) => Task.fromJson(json);
  
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  
  // Helper methods
  /// Gets the notification interval as a Duration, or null if not set
  Duration? get notificationInterval => 
      notificationIntervalMicros != null 
          ? Duration(microseconds: notificationIntervalMicros!) 
          : null;
          
  /// Sets the notification interval from a Duration
  set notificationInterval(Duration? duration) {
    notificationIntervalMicros = duration?.inMicroseconds;
  }
  
  /// Returns true if the task is overdue
  bool get isOverdue => !isDone && dueDate.isBefore(DateTime.now());
  
  bool isDueOn(DateTime date) {
    return dueDate.year == date.year &&
        dueDate.month == date.month &&
        dueDate.day == date.day;
  }
  
  bool get isRecurring => recurrenceRule != null;
  
  // Get the next occurrence after a given date
  DateTime? getNextOccurrence(DateTime afterDate) {
    if (recurrenceRule == null) return null;
    
    DateTime next = dueDate;
    while (!next.isAfter(afterDate)) {
      next = recurrenceRule!.getNextOccurrence(next);
    }
    return next;
  }
  
  // Generate all occurrences between two dates
  List<DateTime> getOccurrencesBetween(DateTime start, DateTime end) {
    if (recurrenceRule == null) {
      return dueDate.isAfter(start) && dueDate.isBefore(end) ? [dueDate] : [];
    }
    
    List<DateTime> occurrences = [];
    DateTime current = dueDate;
    
    // Skip past dates before start
    while (current.isBefore(start)) {
      current = recurrenceRule!.getNextOccurrence(current);
    }
    
    // Add occurrences until we pass the end date
    while (current.isBefore(end)) {
      occurrences.add(current);
      current = recurrenceRule!.getNextOccurrence(current);
    }
    
    return occurrences;
  }
  
  // Create a copy of this task for the next occurrence
  Task createNextOccurrence() {
    if (recurrenceRule == null) return this;
    
    final nextDate = getNextOccurrence(dueDate);
    if (nextDate == null) return this;
    
    return copyWith(
      id: '${id}_${nextDate.millisecondsSinceEpoch}',
      dueDate: nextDate,
      isDone: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? room,
    String? assignedTo,
    DateTime? dueDate,
    bool? isDone,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    RecurrenceRule? recurrenceRule,
    List<String>? attachmentPaths,
    bool? notifyBefore,
    Duration? notificationInterval,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      room: room ?? this.room,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      attachmentPaths: attachmentPaths ?? List.from(this.attachmentPaths),
      notifyBefore: notifyBefore ?? this.notifyBefore,
      notificationInterval: notificationInterval ?? this.notificationInterval,
    );
  }
  
  // Helper methods
  String get priorityText {
    switch (priority) {
      case 0:
        return 'Low';
      case 2:
        return 'High';
      case 1:
      default:
        return 'Medium';
    }
  }
  
  Color get priorityColor {
    switch (priority) {
      case 0:
        return Colors.green;
      case 2:
        return Colors.red;
      case 1:
      default:
        return Colors.orange;
    }
  }
}
