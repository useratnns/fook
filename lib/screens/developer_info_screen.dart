import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperInfoScreen extends StatelessWidget {
  const DeveloperInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Developer'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            // 1. Photo
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.indigo, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 55, color: Colors.indigo),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. Heading
            const Text(
              'Developer Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 8),

            // 3. About Section
            Column(
              children: [
                const Text(
                  'Let\'s Build Something.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.indigo),
                ),
                const SizedBox(height: 8),
                Text(
                  'Passionate Flutter developer with experience in high-performance application engineering and user-centric UI design.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 4. Contact Developer Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _launchURL('mailto:developer@example.com', 'Email'),
                icon: const Icon(Icons.email_outlined),
                label: const Text('Contact Developer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 5. Account Links (2 - 3 - 2 Grid)
            _buildSocialGrid(),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 30),

            // 6. About App Section
            _buildAboutAppSection(),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialGrid() {
    return Column(
      children: [
        // Row 1: Email & WhatsApp (2)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconTile(Icons.alternate_email, 'Email', 'mailto:developer@example.com', Colors.redAccent),
            _buildIconTile(Icons.chat_bubble_outline, 'WhatsApp', 'https://wa.me/yournumber', const Color(0xFF25D366)),
          ],
        ),
        const SizedBox(height: 20),
        
        // Row 2: GitHub, Instagram, & LinkedIn (3)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconTile(Icons.code, 'GitHub', 'https://github.com/yourusername', Colors.black87),
            _buildIconTile(Icons.camera_alt_outlined, 'Instagram', 'https://instagram.com/yourusername', const Color(0xFFE4405F)),
            _buildIconTile(Icons.link, 'LinkedIn', 'https://linkedin.com/in/yourprofile', const Color(0xFF0077B5)),
          ],
        ),
        const SizedBox(height: 20),
        
        // Row 3: Facebook & Website (2)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconTile(Icons.facebook_outlined, 'Facebook', 'https://facebook.com/yourprofile', const Color(0xFF1877F2)),
            _buildIconTile(Icons.language, 'Website', 'http://www.yourportfolio.com', Colors.indigo),
          ],
        ),
      ],
    );
  }

  Widget _buildIconTile(IconData icon, String label, String url, Color color) {
    return Expanded(
      child: Center(
        child: Tooltip(
          message: label,
          child: Column(
            children: [
              InkWell(
                onTap: () => _launchURL(url, label),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutAppSection() {
    return Column(
      children: [
        const Icon(Icons.bolt, color: Colors.indigo, size: 40),
        const SizedBox(height: 12),
        const Text(
          'FOOK',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 3),
        ),
        const Text(
          'Version 1.0.0',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        const Text(
          'A professional framework of organized knowledge.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black54),
        ),
        const SizedBox(height: 24),
        const Text(
            '© 2026 Open Source. All Rights Reserved.',
            style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Future<void> _launchURL(String urlString, String label) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      debugPrint('Launch Error: $e');
    }
  }
}
