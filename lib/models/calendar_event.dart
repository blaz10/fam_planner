import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fam_planner/models/base_model.dart';

part 'calendar_event.g.dart';

@HiveType(typeId: 4)
class CalendarEvent extends HiveObject implements BaseModel<CalendarEvent> {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final DateTime startTime;
  
  @HiveField(4)
  final DateTime endTime;
  
  @HiveField(5)
  final String? location;
  
  @HiveField(6)
  final String? assignedTo;
  
  @HiveField(7)
  final bool isAllDay;
  
  @HiveField(8)
  final int colorValue;
  
  @HiveField(9)
  final bool isRecurring;
  
  @HiveField(10)
  final String? recurrenceRule;
  
  CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    this.assignedTo,
    this.isAllDay = false,
    Color? color,
    this.isRecurring = false,
    this.recurrenceRule,
  }) : colorValue = (color ?? Colors.blue).value;
  
  Color get color => Color(colorValue);
  
  @override
  int get typeId => 4;
  
  @override
  Map<String, dynamic> toHive() => toJson();
  
  @override
  CalendarEvent fromHive(Map<String, dynamic> json) => fromJson(json);
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'assignedTo': assignedTo,
      'isAllDay': isAllDay,
      'color': colorValue,
      'isRecurring': isRecurring,
      'recurrenceRule': recurrenceRule,
    };
  }
  
  @override
  CalendarEvent fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      location: json['location'],
      assignedTo: json['assignedTo'],
      isAllDay: json['isAllDay'] ?? false,
      color: Color(json['color'] ?? Colors.blue.value),
      isRecurring: json['isRecurring'] ?? false,
      recurrenceRule: json['recurrenceRule'],
    );
  }
  
  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? assignedTo,
    bool? isAllDay,
    Color? color,
    bool? isRecurring,
    String? recurrenceRule,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      assignedTo: assignedTo ?? this.assignedTo,
      isAllDay: isAllDay ?? this.isAllDay,
      color: color ?? this.color,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
    );
  }
  
  // Helper method to check if event is happening on a specific date
  bool isOnDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    
    return (start.isBefore(endTime) || start.isAtSameMomentAs(endTime)) &&
           end.isAfter(startTime);
  }
}
