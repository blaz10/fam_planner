import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../models/task.dart';
import '../../../screens/task_form_screen.dart';
import '../../../services/task_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _addNewTask() {
    // Navigate to the task form with the selected date pre-filled
    final selectedDate = _selectedDay ?? DateTime.now();

    // Create a new task with minimal required fields
    final newTask = Task(
      id: const Uuid().v4(),
      title: '',
      description: null,
      room: 'General',
      dueDate: selectedDate,
      priority: 1, // Medium priority by default
      category: 'General',
      notifyBefore: true,
      notificationInterval: const Duration(hours: 1),
    );

    // Navigate to the form without the task parameter to ensure it's treated as a new task
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: newTask),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewTask,
            tooltip: 'Add Task',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar view will go here
          _buildCalendar(),
          const SizedBox(height: 8.0),
          _buildEventList(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Consumer<TaskService>(
        builder: (context, taskService, _) {
          return TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              markersAutoAligned: true,
              markerSize: 6.0,
              markersMaxCount: 1,
            ),
            // Add event markers for days with tasks
            eventLoader: (day) {
              return taskService.getTasksForDay(day).isNotEmpty ? [1] : [];
            },
          );
        },
      ),
    );
  }

  // Build the list of tasks for the selected day
  Widget _buildEventList() {
    return Expanded(
      child: Consumer<TaskService>(
        builder: (context, taskService, _) {
          if (_selectedDay == null) return const SizedBox.shrink();

          final tasks = taskService.getTasksForDay(_selectedDay!);

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 48,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks for ${DateFormat('EEEE, MMM d').format(_selectedDay!)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Dismissible(
                key: Key(task.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  // Remove the task when dismissed
                  taskService.deleteTask(task.id);

                  // Show a snackbar to undo the deletion
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Task "${task.title}" deleted'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          taskService.addTask(task);
                        },
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 8.0,
                  ),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description?.isNotEmpty ?? false)
                          Text(task.description!),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('h:mm a').format(task.dueDate),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (value) {
                        taskService.toggleTaskCompletion(task.id);
                      },
                    ),
                    onTap: () {
                      // Navigate to task form for editing
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskFormScreen(task: task),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
