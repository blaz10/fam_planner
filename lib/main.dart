import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
    
    // Get saved language or use device locale
    String? savedLanguage = prefs.getString('language');
    String languageCode = savedLanguage ?? await _getDeviceLocale();
    
    final themeProvider = ThemeProvider(
      isDarkMode: isDarkMode,
      languageCode: languageCode,
    );

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
    debugPrint('Error during initialization: $e');
    debugPrint('Stack trace: $stackTrace');

    // Ensure Flutter binding is initialized
    WidgetsFlutterBinding.ensureInitialized();

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Initialization Error'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Failed to initialize the app',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Error Details:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            e.toString(),
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Try to restart the app
                      runApp(const MyApp());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? languageCode = prefs.getString('language');
      
      // If no language is saved, use device locale or default to 'en'
      if (languageCode == null || languageCode.isEmpty) {
        languageCode = await _getDeviceLocale();
        // Save the detected language code for future use
        await prefs.setString('language', languageCode);
        debugPrint('Saved new language preference: $languageCode');
      } else {
        debugPrint('Using saved language preference: $languageCode');
      }
      
      if (mounted) {
        setState(() {
          _locale = Locale(languageCode!);
          debugPrint('Locale set to: ${_locale?.languageCode}');
        });
      }
    } catch (e) {
      debugPrint('Error loading saved locale: $e');
      // Fallback to English if there's an error
      if (mounted) {
        setState(() {
          _locale = const Locale('en');
          debugPrint('Falling back to default locale: en');
        });
      }
    }
  }

  Future<void> _changeLanguage(Locale locale) async {
    try {
      debugPrint('Changing language to: ${locale.languageCode}');
      
      // Save the new language preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', locale.languageCode);
      
      // Update the app's locale
      if (mounted) {
        setState(() {
          _locale = locale;
        });
      }
      
      // Update theme provider
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.setLanguage(locale.languageCode);
      
      debugPrint('Language changed successfully to: ${locale.languageCode}');
    } catch (e) {
      debugPrint('Error changing language: $e');
      // Revert to previous locale if there's an error
      if (mounted) {
        setState(() {
          _locale = const Locale('en');
        });
      }
      rethrow; // Re-throw to allow UI to show error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Fam Planner',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: _locale,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('sl', 'SI'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            // Check if the current device locale is supported
            if (deviceLocale != null) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == deviceLocale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            // If not supported, use the first locale (Slovenian) as default
            return supportedLocales.first;
          },
          home: _locale == null 
              ? const Center(child: CircularProgressIndicator())
              : MainScreen(
                  onLanguageChanged: (locale) => _changeLanguage(locale),
                ),
        );
      },
    );
  }
}

// Helper function to get device locale
Future<String> _getDeviceLocale() async {
  try {
    String systemLocale;
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // For desktop platforms, we'll use the system locale if available
      systemLocale = WidgetsBinding.instance.window.locale.languageCode;
    } else {
      // For mobile platforms, use the device's preferred locale
      final locales = await WidgetsBinding.instance.window.locales;
      systemLocale = locales.isNotEmpty ? locales.first.languageCode : 'en';
    }
    
    debugPrint('Detected system locale: $systemLocale');
    
    // Check if the locale is supported (either 'sl' or 'en')
    if (systemLocale == 'sl' || systemLocale == 'en') {
      return systemLocale;
    }
    
    // If the language code is longer than 2 characters (e.g., 'en-US'), try just the first 2 chars
    if (systemLocale.length > 2) {
      final shortCode = systemLocale.substring(0, 2);
      if (shortCode == 'sl' || shortCode == 'en') {
        return shortCode;
      }
    }
    
    debugPrint('Unsupported locale: $systemLocale, defaulting to English');
    return 'en'; // Default to English
  } catch (e) {
    debugPrint('Error getting device locale: $e');
    return 'en'; // Default to English on error
  }
}
