import 'package:flutter/material.dart';

import '../../../core/utils/app_localizations.dart';
import '../../../models/task.dart';
import '../../../services/database_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();
  
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
    return FutureBuilder<List<Task>>(
      future: _databaseService.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final tasks = snapshot.data ?? [];
        final filteredTasks = tasks.where((task) => task.isDone == showCompleted).toList();
        
        if (filteredTasks.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.translate('no_tasks'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return _buildTaskTile(task);
          },
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
  
  void _toggleTaskStatus(Task task, bool isDone) async {
    final updatedTask = task.copyWith(isDone: isDone);
    await _databaseService.updateTask(updatedTask);
    setState(() {});
  }
  
  void _showTaskDetails(Task task) {
    // TODO: Show task details in a dialog or new screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppLocalizations.of(context)!.translate('room')}: ${task.room}'),
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
