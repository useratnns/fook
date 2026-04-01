import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';
import '../data/quotes.dart';
import '../models/task_model.dart';
import 'task_manager_screen.dart'; // To navigate to Task List if needed
import 'settings_view_screen.dart';
import 'note_list_screen.dart'; // To be created

import 'package:showcaseview/showcaseview.dart';
import '../providers/settings_provider.dart';
import 'create_task_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey _addTaskKey = GlobalKey();
  final GlobalKey _overdueKey = GlobalKey();
  final GlobalKey _tomorrowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void startGuide() {
    if (!mounted) return;
    final settings = context.read<SettingsProvider>();
    ShowCaseWidget.of(context).startShowCase([_addTaskKey, _overdueKey, _tomorrowKey]);
    settings.setGuideSeen('dashboardGuideSeen');
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final quote = getRandomQuote();
    final overdue = taskProvider.overdueTasks;
    final today = taskProvider.todayTasks;
    final tomorrow = taskProvider.tomorrowTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FOOK Dashboard'),
        actions: [
          _buildStreakAction(context, taskProvider.streak),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsViewScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Showcase(
        key: _addTaskKey,
        description: 'Tap here to create a new task',
        tooltipBackgroundColor: const Color(0xFF004D40),
        textColor: Colors.white,
        child: FloatingActionButton.extended(
          onPressed: () => _openCreateTask(context),
          label: const Text('Add Task'),
          icon: const Icon(Icons.add),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuoteHeader(context, quote),
            const SizedBox(height: 16),
            if (overdue.isNotEmpty) ...[
              Showcase(
                key: _overdueKey,
                description: 'These are your pending tasks',
                tooltipBackgroundColor: const Color(0xFF004D40),
                textColor: Colors.white,
                child: _buildSectionHeader('Previous Tasks (Overdue)'),
              ),
              ...overdue.map((task) => TaskItem(
                task: task,
                onToggle: () => taskProvider.updateTask(task.copyWith(isCompleted: true)),
                onTap: () => _openCreateTask(context, task: task),
              )).toList(),
              const SizedBox(height: 16),
            ] else 
              // Invisible showcase anchor if no overdue tasks
              Showcase(
                key: _overdueKey,
                description: 'These are your pending tasks',
                tooltipBackgroundColor: const Color(0xFF004D40),
                textColor: Colors.white,
                child: const SizedBox.shrink(),
              ),
            _buildSectionHeader('Today\'s Tasks'),
            if (today.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('You have no tasks for today! Enjoy!'),
              ))
            else
              ...today.map((task) => TaskItem(
                task: task,
                onToggle: () => taskProvider.updateTask(task.copyWith(isCompleted: !task.isCompleted)),
                onTap: () => _openCreateTask(context, task: task),
              )).toList(),
            const SizedBox(height: 16),
            Showcase(
              key: _tomorrowKey,
              description: 'These are your upcoming tasks',
              tooltipBackgroundColor: const Color(0xFF004D40),
              textColor: Colors.white,
              child: _buildSectionHeader('Tomorrow\'s Tasks'),
            ),
            if (tomorrow.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('No tasks for tomorrow.'),
              ))
            else
              ...tomorrow.map((task) => TaskItem(
                task: task,
                onToggle: () => taskProvider.updateTask(task.copyWith(isCompleted: !task.isCompleted)),
                onTap: () => _openCreateTask(context, task: task),
              )).toList(),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildStreakAction(BuildContext context, int streak) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteHeader(BuildContext context, Quote quote) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[800]!, Colors.indigo[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: Colors.white54, size: 24),
          const SizedBox(height: 4),
          Text(
            quote.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "- ${quote.author}",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _openCreateTask(BuildContext context, {Task? task}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CreateTaskScreen(task: task)),
    );
  }
}
