import 'package:flutter/material.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find answers to common questions and learn how to master FOOK.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _buildFaqItem(
            'How to create a task?',
            'Tap the "+" button on the Dashboard or go to the Tasks screen and tap "Create Task". Fill in the title, category, priority, and time to set an alarm.',
            Icons.add_task,
          ),
          _buildFaqItem(
            'How reminders work?',
            'When you set a time for a task, the app schedules an exact alarm. Even if the app is closed, you will receive a high-priority notification with sound and vibration at the scheduled time.',
            Icons.notifications_active_outlined,
          ),
          _buildFaqItem(
            'How focus timer works?',
            'Select the "Focus" tab, set your desired focus duration, and tap "Start". The app will help you stay away from distractions. You can take short or long breaks using the provided buttons.',
            Icons.timer_outlined,
          ),
          _buildFaqItem(
            'How streak works?',
            'Complete all your daily tasks to maintain your productivity streak. Your streak increases every day you complete your scheduled work.',
            Icons.local_fire_department_outlined,
          ),
          _buildFaqItem(
            'How to create a note?',
            'Go to the "Notes" tab and tap the "+" button. You can write your ideas, assign a color to the note, and save it for later.',
            Icons.note_add_outlined,
          ),
          _buildFaqItem(
            'How to search notes?',
            'Use the search bar at the top of the Notes screen to quickly find any note by its title or content.',
            Icons.search,
          ),
          _buildFaqItem(
            'How to enable security lock?',
            'Go to Settings > Security Lock and toggle "App Lock". You can then set a PIN or enable biometric (Fingerprint/Face) authentication for privacy.',
            Icons.security_outlined,
          ),
          _buildFaqItem(
            'How to reset data?',
            'Go to Settings > General Settings > Reset App Data. Warning: This will permanently delete all your tasks, notes, and progress.',
            Icons.delete_forever_outlined,
          ),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              'Still have questions?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Contact the developer from the About Developer screen.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer, IconData icon) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.indigo, size: 24),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        iconColor: Colors.indigo,
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Text(
            answer,
            style: const TextStyle(height: 1.5, color: Colors.black87, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
