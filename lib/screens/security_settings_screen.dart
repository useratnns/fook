import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final security = context.watch<SecurityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Lock'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader('Access Control'),
          SwitchListTile(
            title: const Text('App Lock'),
            subtitle: const Text('Require PIN or Biometrics to open the app'),
            value: security.isAppLockEnabled,
            onChanged: (bool value) async {
              if (value) {
                _showSetPinDialog(context, security);
              } else {
                await security.toggleAppLock(false);
              }
            },
            secondary: const Icon(Icons.lock_outline, color: Colors.indigo),
          ),
          
          if (security.isAppLockEnabled) ...[
            const Divider(),
            _buildSectionHeader('Authentication Options'),
            ListTile(
              title: const Text('Change PIN'),
              subtitle: const Text('Update your 4-digit security PIN'),
              leading: const Icon(Icons.password, color: Colors.indigo),
              onTap: () => _showSetPinDialog(context, security, isUpdate: true),
              trailing: const Icon(Icons.chevron_right),
            ),
            SwitchListTile(
              title: const Text('Fingerprint / Face ID'),
              subtitle: const Text('Enable device biometrics for quick unlock'),
              value: security.isBiometricEnabled,
              onChanged: (bool value) => security.toggleBiometric(value),
              secondary: const Icon(Icons.fingerprint, color: Colors.indigo),
            ),
            const Divider(),
            _buildSectionHeader('Auto Lock Policy'),
            ListTile(
              title: const Text('Auto Lock Delay'),
              subtitle: Text(_getAutoLockText(security.autoLockMinutes)),
              leading: const Icon(Icons.timer_outlined, color: Colors.indigo),
              onTap: () => _showAutoLockPicker(context, security),
              trailing: const Icon(Icons.edit_outlined, size: 20),
            ),
          ],
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Your security data is stored locally and encrypted on your device.',
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

  void _showSetPinDialog(BuildContext context, SecurityProvider security, {bool isUpdate = false}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isUpdate ? 'Update PIN' : 'Set 4-Digit PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              style: const TextStyle(fontSize: 24, letterSpacing: 10),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '****',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 8),
            const Text('Enter exact 4 digits', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (controller.text.length == 4) {
                await security.updatePin(controller.text);
                if (!isUpdate) await security.toggleAppLock(true);
                Navigator.pop(context);
              }
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  void _showAutoLockPicker(BuildContext context, SecurityProvider security) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Auto Lock Delay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Immediately'),
              leading: const Icon(Icons.bolt, color: Colors.orange),
              onTap: () { security.setAutoLockTime(0); Navigator.pop(context); },
            ),
            ListTile(
              title: const Text('1 Minute'),
              leading: const Icon(Icons.timer_outlined),
              onTap: () { security.setAutoLockTime(1); Navigator.pop(context); },
            ),
            ListTile(
              title: const Text('5 Minutes'),
              leading: const Icon(Icons.timer_outlined),
              onTap: () { security.setAutoLockTime(5); Navigator.pop(context); },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _getAutoLockText(int minutes) {
    if (minutes == 0) return 'Lock immediately upon closing';
    return 'Lock after $minutes minutes in background';
  }
}
