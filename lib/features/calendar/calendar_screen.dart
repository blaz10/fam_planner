import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../services/task_service.dart';
import '../../../screens/task_form_screen.dart';

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
    
    // Navigate to the TaskFormScreen with just the selected date
    // This will make it create a new task with this date pre-filled
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(
          initialDate: selectedDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
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
      body: isLandscape 
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar takes 40% of the screen width in landscape
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: SingleChildScrollView(
                    child: _buildCalendar(),
                  ),
                ),
                // Vertical divider
                const VerticalDivider(width: 1, thickness: 1),
                // Task list takes the remaining width
                Expanded(
                  child: _buildEventList(),
                ),
              ],
            )
          : Column(
              children: [
                // Calendar in portrait mode
                _buildCalendar(),
                // Task list in portrait mode
                Expanded(
                  child: _buildEventList(),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendar() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Card(
      margin: isLandscape 
          ? const EdgeInsets.all(8.0)
          : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: isLandscape 
            ? const EdgeInsets.all(8.0)
            : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Consumer<TaskService>(
          builder: (context, taskService, _) {
            return TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              daysOfWeekHeight: 40.0,
              rowHeight: 48.0,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                leftChevronIcon: const Icon(Icons.chevron_left, size: 28.0),
                rightChevronIcon: const Icon(Icons.chevron_right, size: 28.0),
                headerMargin: const EdgeInsets.only(bottom: 8.0),
                formatButtonDecoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              calendarStyle: CalendarStyle(
                // Today's date style
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                // Selected date style
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                // Event marker style
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                // Cell styling
                cellMargin: const EdgeInsets.all(4.0),
                cellPadding: const EdgeInsets.all(8.0),
                defaultTextStyle: const TextStyle(fontSize: 16.0),
                todayTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black87
                      : Colors.black87,
                ),
                selectedTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                weekendTextStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
                ),
                markersAutoAligned: true,
                markerSize: 6.0,
                markersMaxCount: 1,
              ),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                return taskService.getTasksForDay(day).isNotEmpty ? [1] : [];
              },
            );
          },
        ),
      ),
    );
  }

  // Build the list of tasks for the selected day
  Widget _buildEventList() {
    return Consumer<TaskService>(
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
    );
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
