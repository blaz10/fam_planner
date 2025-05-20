import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fam_planner/models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function()? onTap;
  final Function(bool?)? onComplete;

  const TaskItem({
    Key? key,
    required this.task,
    this.onTap,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isOverdue = !task.isDone && task.dueDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Checkbox
                  Checkbox(
                    value: task.isDone,
                    onChanged: onComplete,
                    activeColor: _getPriorityColor(task.priority),
                  ),
                  
                  // Task title and details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with priority indicator
                        Row(
                          children: [
                            // Priority indicator
                            if (task.priority > 0) ...[
                              Icon(
                                Icons.flag,
                                size: 16,
                                color: _getPriorityColor(task.priority),
                              ),
                              const SizedBox(width: 4),
                            ],
                            
                            // Title
                            Expanded(
                              child: Text(
                                task.title,
                                style: textTheme.titleMedium?.copyWith(
                                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                                  color: task.isDone ? Colors.grey : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            // Recurring indicator
                            if (task.isRecurring) ...[
                              const Icon(Icons.repeat, size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                            ],
                            
                            // Notification indicator
                            if (task.notifyBefore) ...[
                              const Icon(Icons.notifications_none, size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                            ],
                          ],
                        ),
                        
                        // Description
                        if (task.description?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            style: textTheme.bodySmall?.copyWith(
                              decoration: task.isDone ? TextDecoration.lineThrough : null,
                              color: task.isDone ? Colors.grey : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        
                        // Details row
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Due date
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: isOverdue ? Colors.red : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM d, y • h:mm a').format(task.dueDate),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: isOverdue ? Colors.red : Colors.grey,
                                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            
                            const Spacer(),
                            
                            // Category
                            if (task.category.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  task.category,
                                  style: textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Room/Location
              if (task.room.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.room, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      task.room,
                      style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.blue; // Low priority
      case 1:
        return Colors.orange; // Medium priority
      case 2:
        return Colors.red; // High priority
      default:
        return Colors.grey;
    }
  }
}
