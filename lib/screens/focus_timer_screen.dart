import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../providers/settings_provider.dart';
import '../providers/focus_provider.dart';
import '../services/notification_service.dart';
import 'settings_view_screen.dart';
import 'package:provider/provider.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  final GlobalKey _timerKey = GlobalKey();
  final GlobalKey _modesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>();
      if (!settings.focusGuideSeen) {
        ShowCaseWidget.of(context).startShowCase([_timerKey, _modesKey]);
        settings.setGuideSeen('focusGuideSeen');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final focusProvider = context.watch<FocusProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
        actions: [
          IconButton(
            tooltip: 'Timer Settings',
            icon: const Icon(Icons.more_time_outlined),
            onPressed: () => _showSettingsDialog(context, focusProvider),
          ),
          IconButton(
            tooltip: 'App Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsViewScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Showcase(
              key: _modesKey,
              description: 'Take breaks using these buttons',
              tooltipBackgroundColor: const Color(0xFF004D40),
              textColor: Colors.white,
              child: _buildModeSelector(context, focusProvider),
            ),
            const SizedBox(height: 50),
            Showcase(
              key: _timerKey,
              description: 'Use this timer to focus on work',
              tooltipBackgroundColor: const Color(0xFF004D40),
              textColor: Colors.white,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: focusProvider.isActive 
                          ? (focusProvider.currentTime / _getMaxTime(focusProvider, focusProvider.mode)) 
                          : 1.0,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                      color: _getModeColor(focusProvider.mode),
                      backgroundColor: _getModeColor(focusProvider.mode).withOpacity(0.1),
                    ),
                  ),
                  Text(
                    focusProvider.formattedTime,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: focusProvider.isActive 
                    ? focusProvider.stopTimer 
                    : focusProvider.startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: focusProvider.isActive ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: Icon(focusProvider.isActive ? Icons.pause : Icons.play_arrow, size: 36),
                ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: focusProvider.resetTimer,
                  icon: const Icon(Icons.refresh, size: 36),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              'Total Focused Today: ${focusProvider.totalFocusToday} min',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector(BuildContext context, FocusProvider provider) {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(20),
      selectedColor: Colors.white,
      fillColor: _getModeColor(provider.mode),
      constraints: const BoxConstraints(minWidth: 100, minHeight: 40),
      onPressed: (index) {
        provider.switchMode(FocusMode.values[index]);
      },
      isSelected: FocusMode.values.map((m) => m == provider.mode).toList(),
      children: const [
        Text('Focus'),
        Text('Short Break'),
        Text('Long Break'),
      ],
    );
  }

  Color _getModeColor(FocusMode mode) {
    switch (mode) {
      case FocusMode.focus: return Colors.indigo;
      case FocusMode.shortBreak: return Colors.green;
      case FocusMode.longBreak: return Colors.blue;
    }
  }

  int _getMaxTime(FocusProvider provider, FocusMode mode) {
    switch (mode) {
      case FocusMode.focus: return provider.focusDuration;
      case FocusMode.shortBreak: return provider.shortBreakDuration;
      case FocusMode.longBreak: return provider.longBreakDuration;
    }
  }

  void _showSettingsDialog(BuildContext context, FocusProvider provider) {
    int focus = provider.focusDuration ~/ 60;
    int short = provider.shortBreakDuration ~/ 60;
    int long = provider.longBreakDuration ~/ 60;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timer Settings (min)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDurationField('Focus', (val) => focus = val, initial: focus),
            _buildDurationField('Short Break', (val) => short = val, initial: short),
            _buildDurationField('Long Break', (val) => long = val, initial: long),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              provider.updateDurations(focus: focus, short: short, long: long);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationField(String label, Function(int) onChanged, {required int initial}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initial.toString(),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: TextInputType.number,
        onChanged: (val) => onChanged(int.tryParse(val) ?? initial),
      ),
    );
  }
}
