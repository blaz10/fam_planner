// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 2;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      room: fields[3] as String,
      assignedTo: fields[4] as String?,
      dueDate: fields[5] as DateTime,
      isDone: fields[6] as bool,
      priority: fields[7] as int,
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
      category: fields[10] as String,
      recurrenceRule: fields[11] as RecurrenceRule?,
      attachmentPaths: (fields[12] as List?)?.cast<String>(),
      notifyBefore: fields[13] as bool,
      notificationInterval: fields[14] as Duration?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.room)
      ..writeByte(4)
      ..write(obj.assignedTo)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.isDone)
      ..writeByte(7)
      ..write(obj.priority)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.category)
      ..writeByte(11)
      ..write(obj.recurrenceRule)
      ..writeByte(12)
      ..write(obj.attachmentPaths)
      ..writeByte(13)
      ..write(obj.notifyBefore)
      ..writeByte(14)
      ..write(obj.notificationInterval);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      room: json['room'] as String,
      assignedTo: json['assignedTo'] as String?,
      dueDate: DateTime.parse(json['dueDate'] as String),
      isDone: json['isDone'] as bool? ?? false,
      priority: (json['priority'] as num?)?.toInt() ?? 1,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      category: json['category'] as String? ?? 'General',
      recurrenceRule: json['recurrenceRule'] == null
          ? null
          : RecurrenceRule.fromJson(
              json['recurrenceRule'] as Map<String, dynamic>),
      attachmentPaths: (json['attachmentPaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      notifyBefore: json['notifyBefore'] as bool? ?? true,
      notificationInterval: json['notificationInterval'] == null
          ? null
          : Duration(
              microseconds: (json['notificationInterval'] as num).toInt()),
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'room': instance.room,
      'assignedTo': instance.assignedTo,
      'dueDate': instance.dueDate.toIso8601String(),
      'isDone': instance.isDone,
      'priority': instance.priority,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'category': instance.category,
      'recurrenceRule': instance.recurrenceRule?.toJson(),
      'attachmentPaths': instance.attachmentPaths,
      'notifyBefore': instance.notifyBefore,
      'notificationInterval': instance.notificationInterval?.inMicroseconds,
    };
