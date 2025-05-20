import 'package:hive_flutter/hive_flutter.dart';
import 'package:fam_planner/models/household_member.dart';
import 'package:fam_planner/models/task.dart';
import 'package:fam_planner/models/shopping_item.dart';
import 'package:fam_planner/models/calendar_event.dart';
import 'package:fam_planner/core/constants/app_constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();
  
  // Register and initialize Hive adapters and boxes
  // Instance variable to track initialization
  bool _isInitialized = false;
  
  // Get a box by name
  Box<T> getBox<T>(String boxName) {
    if (!_isInitialized) {
      throw Exception('DatabaseService has not been initialized. Call init() first.');
    }
    
    if (!Hive.isBoxOpen(boxName)) {
      throw Exception('Box $boxName is not open. Make sure it was opened during initialization.');
    }
    
    return Hive.box<T>(boxName);
  }
  
  // Initialize the database
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(HouseholdMemberAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(TaskAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(ShoppingItemAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(CalendarEventAdapter());
      }
      
      // Open all boxes with error handling
      try {
        await Hive.openBox<HouseholdMember>(AppConstants.membersBox);
      } catch (e) {
        print('Error opening ${AppConstants.membersBox} box: $e');
        rethrow;
      }
      
      try {
        await Hive.openBox<Task>(AppConstants.tasksBox);
      } catch (e) {
        print('Error opening ${AppConstants.tasksBox} box: $e');
        rethrow;
      }
      
      try {
        await Hive.openBox<ShoppingItem>(AppConstants.shoppingBox);
      } catch (e) {
        print('Error opening ${AppConstants.shoppingBox} box: $e');
        rethrow;
      }
      
      try {
        await Hive.openBox<CalendarEvent>(AppConstants.eventsBox);
      } catch (e) {
        print('Error opening ${AppConstants.eventsBox} box: $e');
        rethrow;
      }
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing DatabaseService: $e');
      rethrow;
    }
  }
  
  // Generic CRUD operations
  Future<void> addItem<T>(String boxName, T item) async {
    final box = Hive.box<T>(boxName);
    await box.put((item as dynamic).id, item);
  }
  
  Future<T?> getItem<T>(String boxName, String id) async {
    final box = Hive.box<T>(boxName);
    return box.get(id);
  }
  
  Future<List<T>> getAllItems<T>(String boxName) async {
    final box = Hive.box<T>(boxName);
    return box.values.toList();
  }
  
  Future<void> updateItem<T>(String boxName, T item) async {
    final box = Hive.box<T>(boxName);
    await box.put((item as dynamic).id, item);
  }
  
  Future<void> deleteItem<T>(String boxName, String id) async {
    final box = Hive.box<T>(boxName);
    await box.delete(id);
  }
  
  // Household Members
  Future<void> saveHouseholdMember(HouseholdMember member) async {
    await updateItem(AppConstants.membersBox, member);
  }
  
  Future<void> addHouseholdMember(HouseholdMember member) async {
    await addItem(AppConstants.membersBox, member);
  }
  
  Future<List<HouseholdMember>> getHouseholdMembers() async {
    return await getAllItems<HouseholdMember>(AppConstants.membersBox);
  }
  
  Future<HouseholdMember?> getHouseholdMember(String id) async {
    return await getItem<HouseholdMember>(AppConstants.membersBox, id);
  }
  
  Future<void> deleteHouseholdMember(String id) async {
    await deleteItem<HouseholdMember>(AppConstants.membersBox, id);
  }
  
  // Tasks
  Future<void> addTask(Task task) async {
    await addItem(AppConstants.tasksBox, task);
  }
  
  Future<void> updateTask(Task task) async {
    await updateItem(AppConstants.tasksBox, task);
  }
  
  Future<List<Task>> getTasks() async {
    return await getAllItems<Task>(AppConstants.tasksBox);
  }
  
  Future<List<Task>> getTasksByDate(DateTime date) async {
    final tasks = await getTasks();
    return tasks.where((task) {
      return task.dueDate.year == date.year &&
             task.dueDate.month == date.month &&
             task.dueDate.day == date.day;
    }).toList();
  }
  
  // Shopping Items
  Future<void> addShoppingItem(ShoppingItem item) async {
    await addItem(AppConstants.shoppingBox, item);
  }
  
  Future<void> updateShoppingItem(ShoppingItem item) async {
    await updateItem(AppConstants.shoppingBox, item);
  }
  
  Future<void> deleteShoppingItem(String id) async {
    await deleteItem<ShoppingItem>(AppConstants.shoppingBox, id);
  }
  
  Future<List<ShoppingItem>> getShoppingItems({bool? isBought}) async {
    final items = await getAllItems<ShoppingItem>(AppConstants.shoppingBox);
    if (isBought != null) {
      return items.where((item) => item.isBought == isBought).toList();
    }
    return items;
  }
  
  // Calendar Events
  Future<void> addCalendarEvent(CalendarEvent event) async {
    await addItem(AppConstants.eventsBox, event);
  }
  
  // Get calendar events, optionally filtered by date
  Future<List<CalendarEvent>> getCalendarEvents([DateTime? date]) async {
    final events = await getAllItems<CalendarEvent>(AppConstants.eventsBox);
    if (date != null) {
      return events.where((event) => event.isOnDate(date)).toList();
    }
    return events;
  }

  // Get events for a specific day
  Future<List<CalendarEvent>> getEventsForDay(DateTime day) async {
    final allEvents = await getCalendarEvents();
    return allEvents.where((event) {
      return event.startTime.year == day.year &&
          event.startTime.month == day.month &&
          event.startTime.day == day.day;
    }).toList();
  }
  
  // Close all boxes
  Future<void> close() async {
    await Hive.close();
  }
}
