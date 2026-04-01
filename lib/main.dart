import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'providers/task_provider.dart';
import 'providers/focus_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/security_provider.dart';
import 'providers/note_provider.dart';
import 'screens/lock_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'services/alarm_service.dart';
import 'package:showcaseview/showcaseview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services separately (handled in SplashScreen for better UX)
  NotificationService().init();
  AlarmService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
        ChangeNotifierProvider(create: (_) => FocusProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()..loadNotes()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
      ],
      child: AppLifecycleObserver(
        child: ShowCaseWidget(
          onStart: (index, key) {},
          onComplete: (index, key) {},
          autoPlay: false,
          blurValue: 1,
          enableAutoScroll: true,
          builder: (context) => const FookApp(),
        ),
      ),
    ),
  );
}

class AppLifecycleObserver extends StatefulWidget {
  final Widget child;
  const AppLifecycleObserver({super.key, required this.child});

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final security = context.read<SecurityProvider>();
    if (state == AppLifecycleState.paused) {
      security.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      security.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class FookApp extends StatelessWidget {
  const FookApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final security = context.watch<SecurityProvider>();
    
    return MaterialApp(
      title: 'FOOK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: security.isLocked 
          ? const LockScreen() 
          : (!settings.onboardingSeen ? const OnboardingScreen() : const SplashScreen()),
    );
  }
}
