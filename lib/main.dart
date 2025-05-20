import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/app_localizations.dart';
import 'core/service_locator.dart';
import 'features/home/home_screen.dart';

void main() async {
  print('=== APP STARTING ===');
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    debugPrint('Initializing Hive and service locator...');
  }
  
  try {
    await Hive.initFlutter();
    await setupLocator();
    if (kDebugMode) {
      debugPrint('Hive and service locator initialized successfully');
    }
    
    print('Initialization complete, running app...');
    
    // Get saved theme mode
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    
    print('Initialization complete, running app...');
    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(isDarkMode: isDarkMode),
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    // Handle any initialization errors
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

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode;
  
  ThemeProvider({required bool isDarkMode}) : _isDarkMode = isDarkMode;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        print('Building app with theme mode: ${themeProvider.themeMode}');
        return MaterialApp(
          title: 'Fam Planner',
          debugShowCheckedModeBanner: true, // Show debug banner to verify updates
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
            // Check if the current device locale is supported
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            // If not supported, use the first one (Slovenian) as default
            return supportedLocales.first;
          },
          home: const HomeScreen(),
        );
      },
    );
  }
}

