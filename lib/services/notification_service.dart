import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task_model.dart';
import '../database/db_helper.dart';
import 'package:intl/intl.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle background actions here
  NotificationService()._handleNotificationAction(
    notificationResponse.id ?? 0,
    notificationResponse.actionId ?? '',
    notificationResponse.payload ?? '',
  );
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationAction(response.id ?? 0, response.actionId ?? '', response.payload ?? '');
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> scheduleTaskReminder(Task task) async {
    final taskTime = _getTaskDateTime(task);
    if (taskTime.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id ?? 0,
      'Task Reminder: ${task.title}',
      'It\'s time for your ${task.category} task!',
      tz.TZDateTime.from(taskTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for scheduled tasks',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          fullScreenIntent: true,
          audioAttributesUsage: AudioAttributesUsage.notification,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'complete',
              'Complete',
              showsUserInterface: false,
            ),
            const AndroidNotificationAction(
              'snooze',
              'Snooze (10m)',
              showsUserInterface: false,
            ),
            const AndroidNotificationAction(
              'open',
              'Open App',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.toJson(),
    );
  }

  Future<void> showAlarmNotification(Task task) async {
    await flutterLocalNotificationsPlugin.show(
      task.id ?? 0,
      'Task Alarm: ${task.title}',
      'High Priority: It\'s time for your ${task.category} task!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'task_alarms',
          'Task Alarms',
          channelDescription: 'High priority alarms for tasks',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
          enableLights: true,
          color: Color(0xFFFF0000),
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'complete',
              'Complete',
              showsUserInterface: false,
            ),
            const AndroidNotificationAction(
              'snooze',
              'Snooze (10m)',
              showsUserInterface: false,
            ),
            const AndroidNotificationAction(
              'open',
              'Open App',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
      payload: task.toJson(),
    );
  }

  Future<void> showImmediateNotification(String title, String body) async {
    await flutterLocalNotificationsPlugin.show(
      999,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'focus_timer',
          'Focus Timer',
          channelDescription: 'Notifications for focus timer sessions',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> _handleNotificationAction(int id, String actionId, String payload) async {
    if (actionId == 'complete') {
      if (payload.isNotEmpty) {
        final task = Task.fromJson(payload);
        final dbHelper = DatabaseHelper();
        await dbHelper.updateTask(task.copyWith(
          isCompleted: true, 
          completedAt: DateTime.now()
        ));
        await cancelNotification(id);
      }
    } else if (actionId == 'snooze') {
      if (payload.isNotEmpty) {
        final task = Task.fromJson(payload);
        final snoozeTime = DateTime.now().add(const Duration(minutes: 10));
        
        // Use zonedSchedule for snooze to ensure it triggers accurately
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          'Snoozed: ${task.title}',
          'It\'s time for your ${task.category} task (10m later)!',
          tz.TZDateTime.from(snoozeTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'task_alarms',
              'Task Alarms',
              importance: Importance.max,
              priority: Priority.high,
              category: AndroidNotificationCategory.alarm,
              fullScreenIntent: true,
              audioAttributesUsage: AudioAttributesUsage.alarm,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      }
    }
  }

  DateTime _getTaskDateTime(Task task) {
    final date = DateFormat('yyyy-MM-dd').format(task.date);
    final time = task.time;
    return DateTime.parse('$date $time:00');
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
