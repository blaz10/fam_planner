import 'package:flutter/material.dart';
import 'package:fam_planner/screens/task_list_screen.dart';
import 'package:fam_planner/features/calendar/calendar_screen.dart';
import 'package:fam_planner/features/shopping/shopping_list_screen.dart';
import 'package:fam_planner/features/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;
  
  const MainScreen({
    Key? key,
    this.onLanguageChanged,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const TaskListScreen(),
      const CalendarScreen(),
      const ShoppingListScreen(),
      ProfileScreen(
        onLanguageChanged: widget.onLanguageChanged,
      ),
    ];
  }

  static const List<BottomNavigationBarItem> _bottomNavBarItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.task_alt),
      label: 'Tasks',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      label: 'Calendar',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart),
      label: 'Shopping',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
