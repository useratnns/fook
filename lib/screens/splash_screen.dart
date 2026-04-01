import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main_screen.dart';
import '../services/notification_service.dart';
import '../services/alarm_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final startTime = DateTime.now();

    try {
      // Run permissions and service initialization in parallel
      await Future.wait([
        _requestPermissions(),
        NotificationService().init(),
        AlarmService().init(),
        // Minimum visual delay (2 seconds)
        Future.delayed(const Duration(seconds: 2)),
      ]);
    } catch (e) {
      debugPrint('Error during initialization: $e');
      // If error occurs, still try to proceed after a safety delay
      await Future.delayed(const Duration(seconds: 1));
    }
    
    // Check if we need to wait a bit more to respect the minimum duration
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed.inSeconds < 2) {
      await Future.delayed(Duration(milliseconds: 2000 - elapsed.inMilliseconds));
    }
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  Future<void> _requestPermissions() async {
    // Request critical permissions in parallel (most effective on Android)
    await Future.wait([
      _requestNotificationPermission(),
      _requestAlarmPermission(),
      _requestBatteryPermission(),
    ]);
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _requestAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> _requestBatteryPermission() async {
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D47A1), // Deep Blue
              const Color(0xFF004D40), // Dark Teal
              const Color(0xFF311B92), // Deep Purple
            ],
            stops: const [0.1, 0.5, 0.9],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOutSine,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          height: 140,
                          width: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'FOOK',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Framework Of Organized Knowledge',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 80),
              Container(
                width: 200,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
