import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../providers/note_provider.dart';
import '../providers/security_provider.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('General Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between Light and Dark themes'),
            value: settings.isDarkMode,
            onChanged: (bool value) => settings.toggleTheme(),
            secondary: Icon(
              settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.indigo,
            ),
          ),
          const Divider(),
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('App Notifications'),
            subtitle: const Text('Enable or disable all task reminders'),
            value: settings.notificationsEnabled,
            onChanged: (bool value) => settings.toggleNotifications(),
            secondary: const Icon(Icons.notifications_none, color: Colors.indigo),
          ),
          const Divider(),
          _buildSectionHeader('Help & Data Management'),
          ListTile(
            title: const Text('Show Help Again'),
            subtitle: const Text('Reset onboarding and interactive guides'),
            leading: const Icon(Icons.refresh, color: Colors.indigo),
            onTap: () async {
              await settings.resetHelp();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Guides have been reset. They will show again on your next visit.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Reset App Data'),
            subtitle: const Text(
              'Clear all tasks, notes, and progress permanently',
              style: TextStyle(color: Colors.redAccent),
            ),
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent),
            onTap: () => _confirmReset(context),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Note: Resetting data is an unrecoverable action. Please be careful.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Critical Warning'),
          ],
        ),
        content: const Text(
          'This will permanently delete ALL your tasks, notes, and settings. You cannot undo this.\n\nAre you absolutely sure?',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () async {
              final settings = context.read<SettingsProvider>();
              final security = context.read<SecurityProvider>();
              final tasks = context.read<TaskProvider>();
              final notes = context.read<NoteProvider>();

              await settings.resetData();
              await security.resetSecurityData();
              await tasks.clearAllTasks();
              await notes.clearAllNotes();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All app data has been cleared permanently.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('RESET EVERYTHING'),
          ),
        ],
      ),
    );
  }
}
