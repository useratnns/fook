import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/task_model.dart';
import 'package:intl/intl.dart';
import '../services/alarm_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  int _streak = 0;
  String _lastCompletedDate = "";

  List<Task> get tasks => _tasks;
  int get streak => _streak;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> loadTasks() async {
    _tasks = await _dbHelper.getTasks();
    await loadStreak();
    notifyListeners();
  }

  Future<void> loadStreak() async {
    final streakData = await _dbHelper.getStreak();
    if (streakData != null) {
      _streak = streakData['current_streak'];
      _lastCompletedDate = streakData['last_completed_date'];
      
      // Reset streak if more than 1 day passed since last completion
      final lastDate = DateTime.parse(_lastCompletedDate);
      final now = DateTime.now();
      final difference = now.difference(lastDate).inDays;
      if (difference > 1) {
        _streak = 0;
        await _dbHelper.updateStreak(DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1))), 0);
      }
    }
  }

  Future<void> addTask(Task task) async {
    final id = await _dbHelper.insertTask(task);
    final newTask = task.copyWith(id: id);
    _tasks.add(newTask);
    
    // Schedule alarm for the new task
    await AlarmService().scheduleTaskAlarm(newTask);
    
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    // If being marked as completed now, set completedAt
    Task updatedTask = task;
    final oldTask = _tasks.firstWhere((t) => t.id == task.id);
    if (task.isCompleted && !oldTask.isCompleted) {
      updatedTask = task.copyWith(completedAt: DateTime.now());
    } else if (!task.isCompleted && oldTask.isCompleted) {
       updatedTask = task.copyWith(completedAt: null);
    }

    await _dbHelper.updateTask(updatedTask);
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      
      // Update alarm: Cancel if completed, otherwise reschedule
      if (updatedTask.isCompleted) {
        await AlarmService().cancelTaskAlarm(updatedTask.id!);
      } else {
        await AlarmService().scheduleTaskAlarm(updatedTask);
      }

      // Update streak if task completed today and not already updated today
      if (updatedTask.isCompleted) {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        if (_lastCompletedDate != today) {
          _streak++;
          _lastCompletedDate = today;
          await _dbHelper.updateStreak(today, _streak);
        }
      }
      
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    
    // Cancel alarm for the deleted task
    await AlarmService().cancelTaskAlarm(id);
    
    notifyListeners();
  }

  // Filtering Logic
  List<Task> get overdueTasks {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    return _tasks.where((t) => 
      !t.isCompleted && 
      (t.date.isBefore(DateTime.parse(todayStr)) || 
       (DateFormat('yyyy-MM-dd').format(t.date) == todayStr && _isTimeOverdue(t.time)))
    ).toList();
  }

  List<Task> get todayTasks {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _tasks.where((t) => !t.isCompleted && DateFormat('yyyy-MM-dd').format(t.date) == todayStr).toList();
  }

  List<Task> get tomorrowTasks {
    final tomorrowStr = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));
    return _tasks.where((t) => !t.isCompleted && DateFormat('yyyy-MM-dd').format(t.date) == tomorrowStr).toList();
  }

  List<Task> get futureTasks {
    final tomorrowEnd = DateTime.now().add(const Duration(days: 1));
    return _tasks.where((t) => t.date.isAfter(tomorrowEnd)).toList();
  }

  List<Task> get completedTasks {
    return _tasks.where((t) => t.isCompleted).toList();
  }

  bool _isTimeOverdue(String time) {
    final now = DateTime.now();
    final timeParts = time.split(':');
    final taskHour = int.parse(timeParts[0]);
    final taskMinute = int.parse(timeParts[1]);
    
    if (now.hour > taskHour) return true;
    if (now.hour == taskHour && now.minute > taskMinute) return true;
    return false;
  }

  Future<void> clearAllTasks() async {
    await _dbHelper.clearAllTasks();
    _tasks = [];
    _streak = 0;
    _lastCompletedDate = "";
    notifyListeners();
  }
}
