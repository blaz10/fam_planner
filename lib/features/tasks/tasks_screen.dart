import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_localizations.dart';
import '../../../models/task.dart';
import '../../../services/task_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('tasks')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.translate('upcoming')),
            Tab(text: AppLocalizations.of(context)!.translate('completed')),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // This will trigger a rebuild of the Consumer
              setState(() {});
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(false),
          _buildTaskList(true),
        ],
      ),
    );
  }
  
  Widget _buildTaskList(bool showCompleted) {
    return Consumer<TaskService>(
      builder: (context, taskService, _) {
        // Add debug log
        print('Building task list with showCompleted: $showCompleted');
        
        final tasks = taskService.getAll();
        print('Total tasks: ${tasks.length}');
        
        final filteredTasks = tasks.where((task) => task.isDone == showCompleted).toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
        
        print('Filtered tasks: ${filteredTasks.length}');
        
        if (filteredTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.translate('no_tasks'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (tasks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${tasks.where((t) => t.isDone).length} completed tasks hidden',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            // Force a refresh by calling setState which will trigger a rebuild
            if (mounted) {
              setState(() {});
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return _buildTaskTile(task);
            },
          ),
        );
      },
    );
  }
  
  Widget _buildTaskTile(Task task) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: Checkbox(
          value: task.isDone,
          onChanged: (value) => _toggleTaskStatus(task, value ?? false),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(task.room),
        trailing: _buildPriorityChip(task.priority),
        onTap: () => _showTaskDetails(task),
      ),
    );
  }
  
  Widget _buildPriorityChip(int priority) {
    final priorityText = priority == 0 
        ? AppLocalizations.of(context)!.translate('low')
        : priority == 2 
            ? AppLocalizations.of(context)!.translate('high')
            : AppLocalizations.of(context)!.translate('medium');
            
    final color = priority == 0 
        ? Colors.green
        : priority == 2 
            ? Colors.red
            : Colors.orange;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        priorityText,
        style: TextStyle(color: color, fontSize: 12.0),
      ),
    );
  }
  
  void _toggleTaskStatus(Task task, bool isDone) {
    final taskService = Provider.of<TaskService>(context, listen: false);
    final updatedTask = task.copyWith(isDone: isDone);
    taskService.updateTask(updatedTask);
    // No need to call setState here as TaskService will notify listeners
  }
  
  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.category.isNotEmpty)
              Text('${AppLocalizations.of(context)!.translate('category')}: ${task.category}'),
            if (task.description?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(task.description!),
              ),
            const SizedBox(height: 16.0),
            Text(
              '${AppLocalizations.of(context)!.translate('due_date')}: ${_formatDate(task.dueDate)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.translate('close')),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
