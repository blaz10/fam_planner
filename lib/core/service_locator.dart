import 'package:fam_planner/models/calendar_event.dart';
import 'package:fam_planner/models/household_member.dart';
import 'package:fam_planner/models/shopping_item.dart';
import 'package:fam_planner/models/task.dart';
import 'package:fam_planner/services/database_service.dart';
import 'package:fam_planner/services/task_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  try {
    // Register adapters
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

    // Initialize and register the DatabaseService
    final databaseService = DatabaseService();
    await databaseService.init();
    locator.registerSingleton<DatabaseService>(databaseService);

    // Register services
    locator.registerSingleton<TaskService>(TaskService());

    // Register other services here as needed
  } catch (e) {
    print('Error in setupLocator: $e');
    rethrow;
  }
}
