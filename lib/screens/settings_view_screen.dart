import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'general_settings_screen.dart';
import 'security_settings_screen.dart';
import 'help_faq_screen.dart';
import 'developer_info_screen.dart';
import 'package:showcaseview/showcaseview.dart';

class SettingsViewScreen extends StatefulWidget {
  const SettingsViewScreen({super.key});

  @override
  State<SettingsViewScreen> createState() => _SettingsViewScreenState();
}

class _SettingsViewScreenState extends State<SettingsViewScreen> {
  final GlobalKey _generalKey = GlobalKey();
  final GlobalKey _securityKey = GlobalKey();
  final GlobalKey _helpKey = GlobalKey();
  final GlobalKey _devKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>();
      if (!settings.settingsGuideSeen) {
        ShowCaseWidget.of(context).startShowCase([_generalKey, _securityKey, _helpKey, _devKey]);
        settings.setGuideSeen('settingsGuideSeen');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),
          _buildCategoryTile(
            context,
            key: _generalKey,
            title: 'General Settings',
            subtitle: 'Theme, Notifications, & Reset',
            icon: Icons.settings_outlined,
            color: Colors.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GeneralSettingsScreen())),
          ),
          const SizedBox(height: 16),
          _buildCategoryTile(
            context,
            key: _securityKey,
            title: 'Security Lock',
            subtitle: 'PIN & Biometric security',
            icon: Icons.shield_outlined,
            color: Colors.green,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsScreen())),
          ),
          const SizedBox(height: 16),
          _buildCategoryTile(
            context,
            key: _helpKey,
            title: 'Help & FAQ',
            subtitle: 'Usage guides & help center',
            icon: Icons.help_outline_rounded,
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpFaqScreen())),
          ),
          const SizedBox(height: 16),
          _buildCategoryTile(
            context,
            key: _devKey,
            title: 'About Developer',
            subtitle: 'Profile, App Version, & Socials',
            icon: Icons.person_outline_rounded,
            color: Colors.indigo,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeveloperInfoScreen())),
          ),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              'FOOK v1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Your Offline Productivity Companion',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context, {
    required GlobalKey key,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Showcase(
      key: key,
      description: 'Open $title',
      tooltipBackgroundColor: const Color(0xFF004D40),
      textColor: Colors.white,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }
}
