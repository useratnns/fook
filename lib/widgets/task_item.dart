import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:showcaseview/showcaseview.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final GlobalKey? showcaseKey;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
    this.showcaseKey,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Showcase(
          key: showcaseKey ?? GlobalKey(),
          description: 'Tap circle to mark task complete',
          tooltipBackgroundColor: const Color(0xFF004D40),
          textColor: Colors.white,
          child: GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted ? Colors.green : Colors.grey,
                      width: 2,
                    ),
                    color: task.isCompleted ? Colors.green.withOpacity(0.2) : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 20, color: Colors.green)
                      : null,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(DateFormat('MMM dd').format(task.date), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(width: 12),
            Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(task.time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        trailing: _getPriorityIndicator(),
      ),
    );
  }

  Widget _getPriorityIndicator() {
    Color color;
    switch (task.priority) {
      case TaskPriority.low:
        color = Colors.blue;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        break;
      case TaskPriority.high:
        color = Colors.red;
        break;
    }
    return Container(
      width: 4,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
