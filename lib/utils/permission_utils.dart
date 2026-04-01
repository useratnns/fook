import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionUtils {
  static Future<bool> requestAlarmPermissions(BuildContext context) async {
    // Request notification permission for Android 13+
    final status = await Permission.notification.request();
    if (status.isDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications are required for alarms.')),
        );
      }
      return false;
    }

    // Request exact alarm permission for Android 13+
    // Note: On Android 13+, SCHEDULE_EXACT_ALARM is required.
    // On Android 14+, the app might need to be explicitly granted permission by the user.
    if (await Permission.scheduleExactAlarm.request().isDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exact alarm permission is required for reliable reminders.')),
        );
      }
      return false;
    }

    return true;
  }
}
