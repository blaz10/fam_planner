import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fam_planner/models/base_model.dart';

part 'task.g.dart';

@HiveType(typeId: 2)
class Task extends HiveObject implements BaseModel<Task> {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final String room;
  
  @HiveField(4)
  final String? assignedTo;
  
  @HiveField(5)
  final DateTime dueDate;
  
  @HiveField(6)
  final bool isRecurring;
  
  @HiveField(7)
  final bool isDone;
  
  @HiveField(8)
  final int priority; // 0: Low, 1: Medium, 2: High
  
  @HiveField(9)
  final String? recurrenceRule; // For recurring tasks
  
  Task({
    required this.id,
    required this.title,
    this.description,
    required this.room,
    this.assignedTo,
    required this.dueDate,
    this.isRecurring = false,
    this.isDone = false,
    this.priority = 1,
    this.recurrenceRule,
  });
  
  @override
  int get typeId => 2;
  
  @override
  Map<String, dynamic> toHive() => toJson();
  
  @override
  Task fromHive(Map<String, dynamic> json) => fromJson(json);
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'room': room,
      'assignedTo': assignedTo,
      'dueDate': dueDate.toIso8601String(),
      'isRecurring': isRecurring,
      'isDone': isDone,
      'priority': priority,
      'recurrenceRule': recurrenceRule,
    };
  }
  
  @override
  Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      room: json['room'],
      assignedTo: json['assignedTo'],
      dueDate: DateTime.parse(json['dueDate']),
      isRecurring: json['isRecurring'] ?? false,
      isDone: json['isDone'] ?? false,
      priority: json['priority'] ?? 1,
      recurrenceRule: json['recurrenceRule'],
    );
  }
  
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? room,
    String? assignedTo,
    DateTime? dueDate,
    bool? isRecurring,
    bool? isDone,
    int? priority,
    String? recurrenceRule,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      room: room ?? this.room,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      isRecurring: isRecurring ?? this.isRecurring,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
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
