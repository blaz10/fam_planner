import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fam_planner/models/base_model.dart';

part 'household_member.g.dart';

@HiveType(typeId: 1)
class HouseholdMember extends HiveObject implements BaseModel<HouseholdMember> {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? email;
  
  @HiveField(3)
  final String? phone;
  
  @HiveField(4)
  final int colorValue;
  
  HouseholdMember({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    Color? color,
  }) : colorValue = color?.value ?? Colors.blue.value;
  
  Color get color => Color(colorValue);
  
  @override
  int get typeId => 1;
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'color': colorValue,
    };
  }
  
  @override
  HouseholdMember fromJson(Map<String, dynamic> json) {
    return HouseholdMember(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      color: Color(json['color'] ?? Colors.blue.value),
    );
  }
  
  @override
  Map<String, dynamic> toHive() => toJson();
  
  @override
  HouseholdMember fromHive(Map<String, dynamic> json) => fromJson(json);
  
  HouseholdMember copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    Color? color,
  }) {
    return HouseholdMember(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      color: color ?? this.color,
    );
  }
}

// Generate Hive adapter
// Run: flutter pub run build_runner build --delete-conflicting-outputs
