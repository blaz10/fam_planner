import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recurrence_rule.g.dart';

@JsonSerializable()

@HiveType(typeId: 10)
class RecurrenceRule {
  @HiveField(0)
  final RecurrenceFrequency frequency;
  
  @HiveField(1)
  final int interval;
  
  @HiveField(2)
  final int? count; // Optional: number of occurrences
  
  @HiveField(3)
  final DateTime? until; // Optional: end date
  
  @HiveField(4)
  final List<int>? byWeekDays; // 1-7, where 1 is Monday and 7 is Sunday
  
  @HiveField(5)
  final List<int>? byMonthDays; // 1-31
  
  @HiveField(6)
  final List<int>? byMonths; // 1-12
  
  RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.count,
    this.until,
    this.byWeekDays,
    this.byMonthDays,
    this.byMonths,
  }) : assert(count == null || until == null, 
           'Cannot specify both count and until');
  
  // Get the next occurrence after a given date
  DateTime getNextOccurrence(DateTime afterDate) {
    DateTime next = afterDate;
    
    switch (frequency) {
      case RecurrenceFrequency.daily:
        next = next.add(Duration(days: interval));
        break;
        
      case RecurrenceFrequency.weekly:
        next = next.add(Duration(days: 7 * interval));
        break;
        
      case RecurrenceFrequency.monthly:
        next = DateTime(next.year, next.month + interval, next.day);
        break;
        
      case RecurrenceFrequency.yearly:
        next = DateTime(next.year + interval, next.month, next.day);
        break;
    }
    
    // Apply byWeekDays if specified
    if (byWeekDays != null && byWeekDays!.isNotEmpty) {
      next = _getNextWeekDay(next, byWeekDays!.toSet());
    }
    
    return next;
  }
  
  DateTime _getNextWeekDay(DateTime date, Set<int> weekDays) {
    DateTime next = date;
    int currentWeekDay = next.weekday;
    
    // Find the next matching weekday
    while (!weekDays.contains(currentWeekDay)) {
      next = next.add(const Duration(days: 1));
      currentWeekDay = next.weekday;
    }
    
    return next;
  }
  
  // Check if this rule would generate an occurrence on the given date
  bool matchesDate(DateTime date) {
    if (byMonths != null && !byMonths!.contains(date.month)) {
      return false;
    }
    
    if (byMonthDays != null && !byMonthDays!.contains(date.day)) {
      return false;
    }
    
    if (byWeekDays != null && !byWeekDays!.contains(date.weekday)) {
      return false;
    }
    
    return true;
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() => _$RecurrenceRuleToJson(this);
  
  // Create from JSON
  factory RecurrenceRule.fromJson(Map<String, dynamic> json) => 
      _$RecurrenceRuleFromJson(json);
}

@HiveType(typeId: 11)
enum RecurrenceFrequency {
  @HiveField(0)
  daily,
  
  @HiveField(1)
  weekly,
  
  @HiveField(2)
  monthly,
  
  @HiveField(3)
  yearly,
}

// Extension for RecurrenceFrequency
extension RecurrenceFrequencyExtension on RecurrenceFrequency {
  String get displayName {
    switch (this) {
      case RecurrenceFrequency.daily:
        return 'Daily';
      case RecurrenceFrequency.weekly:
        return 'Weekly';
      case RecurrenceFrequency.monthly:
        return 'Monthly';
      case RecurrenceFrequency.yearly:
        return 'Yearly';
    }
  }
  
  String get description {
    switch (this) {
      case RecurrenceFrequency.daily:
        return 'Repeat every day';
      case RecurrenceFrequency.weekly:
        return 'Repeat every week';
      case RecurrenceFrequency.monthly:
        return 'Repeat every month';
      case RecurrenceFrequency.yearly:
        return 'Repeat every year';
    }
  }
}
