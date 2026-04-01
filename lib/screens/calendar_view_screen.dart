import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';
import 'package:intl/intl.dart';
import 'package:showcaseview/showcaseview.dart';
import '../providers/settings_provider.dart';
import 'settings_view_screen.dart';
import 'create_task_screen.dart';
import '../models/task_model.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final GlobalKey _calendarKey = GlobalKey();
  final GlobalKey _dayTasksKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>();
      if (!settings.calendarGuideSeen) {
        ShowCaseWidget.of(context).startShowCase([_calendarKey, _dayTasksKey]);
        settings.setGuideSeen('calendarGuideSeen');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final dayTasks = _getTasksForDay(taskProvider.tasks, _selectedDay!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar View'),
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
      ),
      body: Column(
        children: [
          Showcase(
            key: _calendarKey,
            description: 'Tap a date to see tasks',
            tooltipBackgroundColor: const Color(0xFF004D40),
            textColor: Colors.white,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
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
              eventLoader: (day) => _getTasksForDay(taskProvider.tasks, day),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.indigo,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: Showcase(
              key: _dayTasksKey,
              description: 'Tasks for selected date appear here',
              tooltipBackgroundColor: const Color(0xFF004D40),
              textColor: Colors.white,
              child: dayTasks.isEmpty
                  ? const Center(child: Text('No tasks for this day.'))
                  : ListView.builder(
                      itemCount: dayTasks.length,
                      itemBuilder: (context, index) {
                        final task = dayTasks[index];
                        return TaskItem(
                          task: task,
                          onToggle: () => taskProvider.updateTask(task.copyWith(isCompleted: !task.isCompleted)),
                          onTap: () => _openCreateTask(context, task),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCreateTask(BuildContext context, Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CreateTaskScreen(task: task)),
    );
  }

  List _getTasksForDay(List tasks, DateTime day) {
    return tasks.where((task) => isSameDay(task.date, day)).toList();
  }
}
