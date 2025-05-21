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
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Calendar
          Card(
            margin: const EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
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
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                // This would be replaced with actual task counts for the day
                return [];
              },
            ),
          ),
          
          // Task list header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDay == null
                      ? 'All Tasks'
                      : 'Tasks for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _showCompleted ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _showCompleted = !_showCompleted;
                        });
                      },
                      tooltip: _showCompleted ? 'Hide completed' : 'Show completed',
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () => _showFilterDialog(context),
                      tooltip: 'Filter',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Task list
          Expanded(
            child: Consumer<TaskService>(
              builder: (context, taskService, _) {
                final tasks = _getFilteredTasks(taskService.getAll());
                
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No tasks found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        if (_searchQuery.isNotEmpty ||
                            _selectedCategory != 'All' ||
                            _selectedPriority != -1 ||
                            !_showCompleted)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _selectedCategory = 'All';
                                _selectedPriority = -1;
                                _showCompleted = true;
                                _searchController.clear();
                              });
                            },
                            child: const Text('Clear filters'),
                          ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskItem(
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
    String? selectedCategory = _selectedCategory == 'All' ? null : _selectedCategory;
    int? selectedPriority = _selectedPriority == -1 ? null : _selectedPriority;
    bool showCompleted = _showCompleted;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
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
                      onChanged: (value) {
                        setState(() {
                          selectedPriority = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: showCompleted,
                          onChanged: (value) {
                            setState(() {
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
                    setState(() {
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
                    setState(() {
                      _selectedCategory = selectedCategory ?? 'All';
                      _selectedPriority = selectedPriority ?? -1;
                      _showCompleted = showCompleted;
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
