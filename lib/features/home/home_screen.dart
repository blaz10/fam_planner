import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../core/utils/app_localizations.dart';

// Import screen widgets
import '../tasks/tasks_screen.dart';
import '../calendar/calendar_screen.dart';
import '../shopping/shopping_screen.dart';
import '../profile/profile_screen.dart';

// Helper function for debug logging
void _log(String message) {
  if (kDebugMode) {
    debugPrint('HomeScreen: $message');
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  // Import the actual screen widgets
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens in initState to ensure context is available
    _screens = [
      const TasksScreen(),
      const CalendarScreen(),
      const ShoppingScreen(),
      const ProfileScreen(),
    ];
    _log('HomeScreen initialized with ${_screens.length} screens');
  }



  // Handle tab changes
  void _onTabTapped(int index) {
    _log('Tab tapped: $index');
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _log('Building HomeScreen with index: $_currentIndex');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Fam Planner - ${_getScreenName(_currentIndex)}'),
        actions: const [
          // Theme toggle has been moved to the profile screen
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
  
  String _getScreenName(int index) {
    switch (index) {
      case 0: return 'Tasks';
      case 1: return 'Calendar';
      case 2: return 'Shopping';
      case 3: return 'Profile';
      default: return 'Unknown';
    }
  }

  Widget _buildBottomNavBar() {
    print('Building BottomNavigationBar with index: $_currentIndex');
    
    final items = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.task_outlined),
        activeIcon: const Icon(Icons.task),
        label: 'Tasks', // Using hardcoded text for debugging
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.calendar_today_outlined),
        activeIcon: const Icon(Icons.calendar_today),
        label: 'Calendar',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.shopping_cart_outlined),
        activeIcon: const Icon(Icons.shopping_cart),
        label: 'Shopping',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline),
        activeIcon: const Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    print('BottomNavigationBar items: ${items.map((e) => e.label).toList()}');
    
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        print('BottomNavigationBar onTap: $index');
        _onTabTapped(index);
      },
      type: BottomNavigationBarType.fixed,
      items: items,
    );
  }

  Widget? _buildFloatingActionButton() {
    _log('Building FAB for index: $_currentIndex');
    
    final theme = Theme.of(context);
    
    switch (_currentIndex) {
      case 0: // Tasks
        return FloatingActionButton(
          backgroundColor: theme.colorScheme.primary,
          onPressed: _onAddTask,
          child: const Icon(Icons.add),
        );
      case 1: // Calendar
        return FloatingActionButton(
          backgroundColor: theme.colorScheme.tertiary,
          onPressed: _onAddEvent,
          child: const Icon(Icons.add),
        );
      case 2: // Shopping
        return FloatingActionButton(
          backgroundColor: theme.colorScheme.secondary,
          onPressed: _onAddShoppingItem,
          child: const Icon(Icons.add_shopping_cart),
        );
      default:
        return null;
    }
  }

  void _onAddTask() {
    _log('Add Task button pressed');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.translate('add_task')),
          ),
          body: const Center(
            child: Text('Add New Task'),
          ),
        ),
      ),
    );
  }

  void _onAddShoppingItem() {
    _log('Add Shopping Item button pressed');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.translate('add_shopping_item')),
          ),
          body: const Center(
            child: Text('Add New Shopping Item'),
          ),
        ),
      ),
    );
  }

  void _onAddEvent() {
    _log('Add Event button pressed');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.translate('add_event')),
          ),
          body: const Center(
            child: Text('Add New Event'),
          ),
        ),
      ),
    );
  }
}
