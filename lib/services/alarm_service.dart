import 'dart:developer' as developer;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'notification_service.dart';
import '../models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  static const int _alarmIdOffset = 1000;

  Future<void> init() async {
    await AndroidAlarmManager.initialize();
  }

  Future<void> scheduleTaskAlarm(Task task) async {
    if (task.id == null) return;
    
    final alarmTime = _getTaskDateTime(task);
    if (alarmTime.isBefore(DateTime.now())) {
      developer.log('Alarm time is in the past for task: ${task.title}');
      return;
    }

    final int alarmId = _alarmIdOffset + task.id!;
    
    await AndroidAlarmManager.oneShotAt(
      alarmTime,
      alarmId,
      onAlarmTrigger,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      params: {'taskJson': task.toJson()},
    );
    
    developer.log('Scheduled alarm for task: ${task.title} at $alarmTime');
  }

  Future<void> cancelTaskAlarm(int taskId) async {
    final int alarmId = _alarmIdOffset + taskId;
    await AndroidAlarmManager.cancel(alarmId);
    developer.log('Cancelled alarm for task ID: $taskId');
  }

  DateTime _getTaskDateTime(Task task) {
    final date = DateFormat('yyyy-MM-dd').format(task.date);
    final time = task.time;
    return DateTime.parse('$date $time:00');
  }

  @pragma('vm:entry-point')
  static Future<void> onAlarmTrigger(int id, Map<String, dynamic> params) async {
    developer.log('Alarm triggered for ID: $id');
    final String? taskJson = params['taskJson'];
    if (taskJson != null) {
      final task = Task.fromJson(taskJson);
      
      // Initialize notification service in this background isolate
      final notificationService = NotificationService();
      await notificationService.init();
      
      // Trigger vibration
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(
          pattern: [500, 1000, 500, 1000, 500, 1000],
          intensities: [0, 255, 0, 255, 0, 255],
        );
      }

      await notificationService.showAlarmNotification(task);
    }
  }
}
