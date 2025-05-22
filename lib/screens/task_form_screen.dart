import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:fam_planner/models/task.dart';
import 'package:fam_planner/models/recurrence_rule.dart';
import 'package:fam_planner/services/task_service.dart';
import 'package:fam_planner/widgets/recurrence_rule_picker.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final DateTime? initialDate;

  const TaskFormScreen({
    Key? key,
    this.task,
    this.initialDate,
  }) : super(key: key);

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TaskService _taskService;
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _roomController = TextEditingController();
  
  // Form values
  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = TimeOfDay.now();
  int _priority = 1; // 0: Low, 1: Medium, 2: High
  String _category = 'General';
  RecurrenceRule? _recurrenceRule;
  bool _notifyBefore = true;
  Duration _notificationInterval = const Duration(hours: 1);
  
  // Available categories (you can load these from a service)
  final List<String> _categories = [
    'General',
    'Shopping',
    'Work',
    'Personal',
    'Health',
    'Family',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _taskService = Provider.of<TaskService>(context, listen: false);
    
    // Initialize form with task data if editing, or with initial date if provided
    if (widget.task != null) {
      final task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _roomController.text = task.room;
      _dueDate = task.dueDate;
      _dueTime = TimeOfDay.fromDateTime(task.dueDate);
      _priority = task.priority;
      _category = task.category;
      _recurrenceRule = task.recurrenceRule;
      _notifyBefore = task.notifyBefore;
      _notificationInterval = task.notificationInterval ?? const Duration(hours: 1);
    } else if (widget.initialDate != null) {
      // Set initial date if provided for new tasks
      _dueDate = widget.initialDate!;
      _dueTime = TimeOfDay.fromDateTime(widget.initialDate!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    // Combine date and time
    final dueDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    final task = Task(
      id: widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      room: _roomController.text,
      dueDate: dueDateTime,
      priority: _priority,
      category: _category,
      recurrenceRule: _recurrenceRule,
      notifyBefore: _notifyBefore,
      notificationInterval: _notifyBefore ? _notificationInterval : null,
    );

    // Save the task
    if (widget.task != null) {
      _taskService.updateTask(task);
    } else {
      _taskService.addTask(task);
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Room
            TextFormField(
              controller: _roomController,
              decoration: const InputDecoration(
                labelText: 'Room/Location',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a room or location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Due Date and Time
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: _dueTime.format(context),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Priority
            const Text('Priority:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: const Text('Low'),
                  selected: _priority == 0,
                  onSelected: (_) => setState(() => _priority = 0),
                ),
                ChoiceChip(
                  label: const Text('Medium'),
                  selected: _priority == 1,
                  onSelected: (_) => setState(() => _priority = 1),
                ),
                ChoiceChip(
                  label: const Text('High'),
                  selected: _priority == 2,
                  onSelected: (_) => setState(() => _priority = 2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Category
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Recurrence
            const Text('Recurrence', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Repeat'),
              subtitle: Text(_recurrenceRule?.frequency.displayName ?? 'Never'),
              value: _recurrenceRule != null,
              onChanged: (value) {
                setState(() {
                  if (value) {
                    _recurrenceRule = RecurrenceRule(
                      frequency: RecurrenceFrequency.daily,
                      interval: 1,
                    );
                  } else {
                    _recurrenceRule = null;
                  }
                });
              },
            ),
            if (_recurrenceRule != null) ...[
              const SizedBox(height: 8),
              RecurrenceRulePicker(
                initialRule: _recurrenceRule,
                onChanged: (rule) {
                  setState(() {
                    _recurrenceRule = rule;
                  });
                },
              ),
            ],
            const SizedBox(height: 16),
            
            // Notifications
            const Text('Notifications', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Notify before due'),
              value: _notifyBefore,
              onChanged: (value) {
                setState(() {
                  _notifyBefore = value;
                });
              },
            ),
            if (_notifyBefore) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<Duration>(
                value: _notificationInterval,
                decoration: const InputDecoration(
                  labelText: 'Notification time before',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: Duration(minutes: 5),
                    child: Text('5 minutes before'),
                  ),
                  DropdownMenuItem(
                    value: Duration(minutes: 15),
                    child: Text('15 minutes before'),
                  ),
                  DropdownMenuItem(
                    value: Duration(minutes: 30),
                    child: Text('30 minutes before'),
                  ),
                  DropdownMenuItem(
                    value: Duration(hours: 1),
                    child: Text('1 hour before'),
                  ),
                  DropdownMenuItem(
                    value: Duration(hours: 2),
                    child: Text('2 hours before'),
                  ),
                  DropdownMenuItem(
                    value: Duration(days: 1),
                    child: Text('1 day before'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _notificationInterval = value;
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 24),
            
            // Save Button
            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.task == null ? 'Add Task' : 'Update Task',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
