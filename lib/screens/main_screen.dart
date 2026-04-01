import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'task_manager_screen.dart';
import 'calendar_view_screen.dart';
import 'focus_timer_screen.dart';
import 'note_list_screen.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey _navKey = GlobalKey();
  
  // Keys for child screens to coordinate guides
  final GlobalKey<DashboardScreenState> _dashKey = GlobalKey();
  final GlobalKey<TaskManagerScreenState> _tasksKey = GlobalKey();
  final GlobalKey<NoteListScreenState> _notesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialGuides();
    });
  }

  void _startInitialGuides() {
    final settings = context.read<SettingsProvider>();
    
    // 1. Start Navigation Guide if not seen
    if (!settings.dashboardGuideSeen) { // Using dashboard flag as 'main app guide' flag for now
       ShowCaseWidget.of(context).startShowCase([_navKey]);
    } 
    // 2. If nav guide seen but dash guide not, start dash guide
    else if (!settings.dashboardGuideSeen) {
       _dashKey.currentState?.startGuide();
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Trigger guide for the new tab after a brief delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final settings = context.read<SettingsProvider>();
      
      if (index == 0 && !settings.dashboardGuideSeen) {
        _dashKey.currentState?.startGuide();
      } else if (index == 1 && !settings.tasksGuideSeen) {
        _tasksKey.currentState?.startGuide();
      } else if (index == 4 && !settings.notesGuideSeen) {
        _notesKey.currentState?.startGuide();
      }
    });
  }

  late final List<Widget> _screens = [
    DashboardScreen(key: _dashKey),
    TaskManagerScreen(key: _tasksKey),
    const CalendarViewScreen(),
    const FocusTimerScreen(),
    NoteListScreen(key: _notesKey),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Showcase(
        key: _navKey,
        description: 'Use this to navigate the app',
        tooltipBackgroundColor: const Color(0xFF004D40),
        textColor: Colors.white,
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onTabChanged,
          indicatorColor: Colors.indigo.withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dash',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Plan',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer),
              label: 'Focus',
            ),
            NavigationDestination(
              icon: Icon(Icons.note_alt_outlined),
              selectedIcon: Icon(Icons.note_alt),
              label: 'Notes',
            ),
          ],
        ),
      ),
    );
  }
}
