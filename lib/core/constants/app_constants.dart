import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Fam Planner';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String themeModeKey = 'theme_mode';
  static const String localeKey = 'locale';
  
  // Hive Box Names
  static const String tasksBox = 'tasks_box';
  static const String membersBox = 'members_box';
  static const String shoppingBox = 'shopping_box';
  static const String eventsBox = 'events_box';
  
  // Profile Colors
  static const List<Color> profileColors = [
    Color(0xFF2196F3), // blue
    Color(0xFFF44336), // red
    Color(0xFF4CAF50), // green
    Color(0xFFFF9800), // orange
    Color(0xFF9C27B0), // purple
    Color(0xFF009688), // teal
    Color(0xFFE91E63), // pink
    Color(0xFF3F51B5), // indigo
  ];
  
  // Default Values
  static const List<String> defaultRooms = [
    'Kuhinja',
    'Dnevni prostor',
    'Spalnica',
    'Kopalnica',
    'Hodnik',
    'Klet',
    'Vrt',
  ];
  
  // Localization
  static const String defaultLocale = 'sl';
  static const List<String> supportedLocales = ['sl', 'en'];
}
