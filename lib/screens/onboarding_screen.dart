import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<ContentConfig> listContentConfig = [];

  @override
  void initState() {
    super.initState();

    final Color midnightTeal = const Color(0xFF004D40);

    listContentConfig.add(
      ContentConfig(
        title: "Welcome to FOOK",
        description: "Organize your tasks and plan your day effectively with the Framework Of Organized Knowledge.",
        centerWidget: Image.asset('assets/images/app_icon.png', height: 200, width: 200),
        backgroundColor: midnightTeal,
        styleTitle: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
        styleDescription: const TextStyle(color: Colors.white70, fontSize: 18),
      ),
    );

    listContentConfig.add(
      ContentConfig(
        title: "Tasks & Reminders",
        description: "Create tasks, set exact reminders, and never miss your important work.",
        centerWidget: const Icon(Icons.checklist_rtl_rounded, size: 200, color: Colors.white),
        backgroundColor: midnightTeal,
        styleTitle: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
        styleDescription: const TextStyle(color: Colors.white70, fontSize: 18),
      ),
    );

    listContentConfig.add(
      ContentConfig(
        title: "Notes / Notepad",
        description: "Write down quick notes, ideas, and keep all your important information in one place.",
        centerWidget: const Icon(Icons.note_alt_rounded, size: 200, color: Colors.white),
        backgroundColor: midnightTeal,
        styleTitle: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
        styleDescription: const TextStyle(color: Colors.white70, fontSize: 18),
      ),
    );

    listContentConfig.add(
      ContentConfig(
        title: "Focus & Productivity",
        description: "Use the focus timer to stay away from distractions and build your productivity streak.",
        centerWidget: const Icon(Icons.timer_rounded, size: 200, color: Colors.white),
        backgroundColor: midnightTeal,
        styleTitle: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
        styleDescription: const TextStyle(color: Colors.white70, fontSize: 18),
      ),
    );

    listContentConfig.add(
      ContentConfig(
        title: "Security",
        description: "Protect your privacy by locking the app with a PIN or Fingerprint.",
        centerWidget: const Icon(Icons.fingerprint_rounded, size: 200, color: Colors.white),
        backgroundColor: midnightTeal,
        styleTitle: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
        styleDescription: const TextStyle(color: Colors.white70, fontSize: 18),
      ),
    );
  }

  void onDonePress() async {
    await context.read<SettingsProvider>().setOnboardingSeen();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      key: UniqueKey(),
      listContentConfig: listContentConfig,
      onDonePress: onDonePress,
      onSkipPress: onDonePress,
      renderSkipBtn: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: const Text("Skip", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      renderNextBtn: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      renderDoneBtn: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          "Get Started",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.visible,
          softWrap: false,
        ),
      ),
      indicatorConfig: const IndicatorConfig(
        colorIndicator: Colors.white24,
        colorActiveIndicator: Colors.white,
      ),
    );
  }
}
