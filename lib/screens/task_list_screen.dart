import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fam_planner/models/task.dart';
import 'package:fam_planner/services/task_service.dart';
import 'package:fam_planner/screens/task_form_screen.dart';
import 'package:fam_planner/widgets/task_item.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  int _selectedPriority = -1; // -1: All, 0: Low, 1: Medium, 2: High
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Task> _getFilteredTasks(List<Task> tasks) {
    // This method will be called whenever the widget rebuilds, which happens when _selectedCategory, _selectedPriority, or _showCompleted changes
    return tasks.where((task) {
      // Filter by search query
      if (_searchQuery.isNotEmpty &&
          !task.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          (task.description == null ||
              !task.description!.toLowerCase().contains(_searchQuery.toLowerCase()))) {
        return false;
      }

      // Filter by category
      if (_selectedCategory != 'All' && task.category != _selectedCategory) {
        return false;
      }

      // Filter by priority
      if (_selectedPriority != -1 && task.priority != _selectedPriority) {
        return false;
      }

      // Filter by completion status
      if (!_showCompleted && task.isDone) {
        return false;
      }

      // Filter by selected day
      if (_selectedDay != null) {
        return task.dueDate.year == _selectedDay!.year &&
            task.dueDate.month == _selectedDay!.month &&
            task.dueDate.day == _selectedDay!.day;
      }

      return true;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will be called when the dependencies change, including when TaskService notifies listeners
    
    // Force a rebuild when dependencies change to ensure the task list is updated
    if (mounted) {
      setState(() {
        // Trigger a rebuild
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TaskFormScreen(),
                ),
              );
              
              if (result == true) {
                // The TaskService will notify listeners automatically
                // No need to call setState here
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'categories') {
                _showCategoryDialog(context);
              } else if (value == 'filter') {
                _showFilterDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'categories',
                child: Text('Categories'),
              ),
              const PopupMenuItem(
                value: 'filter',
                child: Text('Filter'),
              ),
            ],
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
                  child: _buildTaskList(),
                ),
              ],
            )
          : Column(
              children: [
                // Calendar in portrait mode
                _buildCalendar(),
                // Task list in portrait mode
                Expanded(
                  child: _buildTaskList(),
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
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          daysOfWeekHeight: 40.0,
          rowHeight: 48.0,
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
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
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) {
            // This would be replaced with actual task counts for the day
            return [];
          },
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Consumer<TaskService>(
      builder: (context, taskService, _) {
        // This will be rebuilt whenever taskService notifies listeners or when local state changes
        final tasks = _getFilteredTasks(taskService.getAll());
        
        if (tasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks found',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (!isLandscape) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add a new task',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        
        return ListView.builder(
          shrinkWrap: isLandscape ? false : true,
          physics: isLandscape ? const AlwaysScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: isLandscape ? 16.0 : 80.0, // Space for FAB in portrait
            left: isLandscape ? 8.0 : 8.0,
            right: isLandscape ? 8.0 : 8.0,
            top: 8.0,
          ),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            // Wrap TaskItem with Dismissible for swipe-to-delete
            return Dismissible(
              key: Key(task.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              confirmDismiss: (direction) async {
                // Show a confirmation dialog before deleting
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: const Text('Are you sure you want to delete this task?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );
              },
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
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TaskItem(
                  task: task,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskFormScreen(task: task),
                      ),
                    );
                    
                    if (result == true) {
                      // The TaskService will notify listeners automatically
                      // No need to call setState here
                    }
                  },
                  onComplete: (bool? value) async {
                    if (value != null) {
                      await taskService.toggleTaskCompletion(task.id);
                      // No need to call setState here as TaskService will notify listeners
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCategoryDialog(BuildContext context) {
    final taskService = Provider.of<TaskService>(context, listen: false);
    final categories = taskService.getCategories();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Categories'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'All';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final taskService = Provider.of<TaskService>(context, listen: false);
    
    // Create local copies of the current filter values
    String? selectedCategory = _selectedCategory == 'All' ? null : _selectedCategory;
    int? selectedPriority = _selectedPriority == -1 ? null : _selectedPriority;
    bool showCompleted = _showCompleted;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Filter Tasks'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...taskService.getCategories().map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                      ],
                      onChanged: (String? value) {
                        setDialogState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      isExpanded: true,
                      value: selectedPriority,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('All Priorities'),
                        ),
                        DropdownMenuItem(
                          value: 0,
                          child: Text('Low'),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('High'),
                        ),
                      ],
                      onChanged: (int? value) {
                        setDialogState(() {
                          selectedPriority = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: showCompleted,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              showCompleted = value ?? false;
                            });
                          },
                        ),
                        const Text('Show completed tasks'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      selectedCategory = null;
                      selectedPriority = null;
                      showCompleted = true;
                    });
                  },
                  child: const Text('Reset'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Update the parent widget's state
                    setState(() {
                      _selectedCategory = selectedCategory ?? 'All';
                      _selectedPriority = selectedPriority ?? -1;
                      _showCompleted = showCompleted;
                      
                      // Debug output
                      print('Applied filters:');
                      print('  - Category: ${_selectedCategory}');
                      print('  - Priority: ${_selectedPriority}');
                      print('  - Show completed: $_showCompleted');
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
