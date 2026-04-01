import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';
import 'create_task_screen.dart';
import '../models/task_model.dart';

import 'package:showcaseview/showcaseview.dart';
import '../providers/settings_provider.dart';
import 'settings_view_screen.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  State<TaskManagerScreen> createState() => TaskManagerScreenState();
}

class TaskManagerScreenState extends State<TaskManagerScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Overdue', 'Today', 'Tomorrow', 'Future', 'Completed'];
  
  final GlobalKey _createTaskKey = GlobalKey();
  final GlobalKey _taskCircleKey = GlobalKey();
  final GlobalKey _taskListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void startGuide() {
    if (!mounted) return;
    final settings = context.read<SettingsProvider>();
    ShowCaseWidget.of(context).startShowCase([_createTaskKey, _taskCircleKey, _taskListKey]);
    settings.setGuideSeen('tasksGuideSeen');
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final filteredTasks = _getFilteredTasks(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsViewScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = filter);
                    },
                    selectedColor: Colors.indigo,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ).animate(); // Simplified animation notation
              }).toList(),
            ),
          ),
        ),
      ),
      body: filteredTasks.isEmpty
          ? Showcase(
              key: _taskListKey,
              description: 'All your tasks appear here',
              tooltipBackgroundColor: const Color(0xFF004D40),
              textColor: Colors.white,
              child: const Center(child: Text('No tasks found for this filter.')),
            )
          : Showcase(
              key: _taskListKey,
              description: 'All your tasks appear here',
              tooltipBackgroundColor: const Color(0xFF004D40),
              textColor: Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  // Highlight the first task's circle as a guide
                  return TaskItem(
                    task: task,
                    onToggle: () => taskProvider.updateTask(task.copyWith(isCompleted: !task.isCompleted)),
                    onTap: () => _openCreateTask(context, task),
                    showcaseKey: index == 0 ? _taskCircleKey : null,
                  );
                },
              ),
            ),
      floatingActionButton: Showcase(
        key: _createTaskKey,
        description: 'Create new task here',
        tooltipBackgroundColor: const Color(0xFF004D40),
        textColor: Colors.white,
        child: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
          ),
          backgroundColor: Colors.indigo,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _openCreateTask(BuildContext context, Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CreateTaskScreen(task: task)),
    );
  }

  List _getFilteredTasks(TaskProvider provider) {
    switch (_selectedFilter) {
      case 'Overdue': return provider.overdueTasks;
      case 'Today': return provider.todayTasks;
      case 'Tomorrow': return provider.tomorrowTasks;
      case 'Future': return provider.futureTasks;
      case 'Completed': return provider.completedTasks;
      default: return provider.tasks;
    }
  }
}

extension on Widget {
  Widget animate() => this; // Placeholder for future animation logic if desired
}
