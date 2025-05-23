import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/app_localizations.dart';
import 'core/service_locator.dart';
import 'models/task.dart';
import 'models/recurrence_rule.dart';
import 'screens/main_screen.dart';
import 'services/task_service.dart';
import 'services/shopping_service.dart';

final getIt = GetIt.instance;

void main() async {
  print('=== APP STARTING ===');
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    debugPrint('Initializing Hive and service locator...');
  }

  try {
    print('Initializing Hive and service locator...');

    // Initialize Hive with different paths for web and non-web
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);
    }

    // Register Hive adapters
    Task.registerHiveAdapter();
    Hive.registerAdapter(RecurrenceRuleAdapter());
    Hive.registerAdapter(RecurrenceFrequencyAdapter());

    // Open the settings box
    await Hive.openBox('settings');

    // Initialize service locator which will set up all services
    await setupLocator();

    // Get instances of services
    final shoppingService = locator<ShoppingService>();
    final taskService = locator<TaskService>();
    
    // Initialize services
    await shoppingService.init();
    await taskService.initialize();

    // Initialize theme
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final themeProvider = ThemeProvider(isDarkMode: isDarkMode);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider.value(value: shoppingService),
          ChangeNotifierProvider.value(value: taskService),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('Error during initialization: $e');
    print('Stack trace: $stackTrace');

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to initialize app',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $e',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Fam Planner',
          debugShowCheckedModeBanner: true,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('sl', ''), // Slovenian
            Locale('en', ''), // English
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          home: const MainScreen(),
        );
      },
    );
  }
}
