import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _error = '';

  @override
  void initState() {
    super.initState();
    // Auto-trigger biometric if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateBiometric();
    });
  }

  Future<void> _authenticateBiometric() async {
    final security = context.read<SecurityProvider>();
    if (security.isBiometricEnabled) {
      final success = await security.authenticateBiometric();
      if (success) {
        // Unlock handled by provider
      }
    }
  }

  void _onNumberPressed(String number) {
    if (_pinController.text.length < 4) {
      setState(() {
        _pinController.text += number;
        _error = '';
      });
      if (_pinController.text.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pinController.text.isNotEmpty) {
      setState(() {
        _pinController.text = _pinController.text.substring(0, _pinController.text.length - 1);
        _error = '';
      });
    }
  }

  Future<void> _verifyPin() async {
    final security = context.read<SecurityProvider>();
    final isValid = await security.verifyPin(_pinController.text);
    if (isValid) {
      security.setLocked(false);
    } else {
      setState(() {
        _error = 'Incorrect PIN. Please try again.';
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final security = context.watch<SecurityProvider>();
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Logo and Name
            const Hero(
              tag: 'app_logo',
              child: Icon(Icons.lock_person, size: 80, color: Colors.indigo),
            ),
            const SizedBox(height: 16),
            const Text(
              'FOOK',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
            ),
            const Text('Framework Of Organized Knowledge', style: TextStyle(color: Colors.grey)),
            const Spacer(),
            
            // PIN Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _pinController.text.length > index 
                        ? Colors.indigo 
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(_error, style: const TextStyle(color: Colors.red)),
            ],
            const Spacer(),
            
            // Number Pad
            _buildNumberPad(),
            
            const SizedBox(height: 24),
            // Biometric Option
            if (security.isBiometricEnabled)
              IconButton(
                icon: const Icon(Icons.fingerprint, size: 48, color: Colors.indigo),
                onPressed: _authenticateBiometric,
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        for (var row in [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((n) => _buildNumberButton(n.toString())).toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80), // Empty space
            _buildNumberButton('0'),
            SizedBox(
              width: 80,
              height: 80,
              child: IconButton(
                icon: const Icon(Icons.backspace_outlined),
                onPressed: _onBackspace,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String text) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => _onNumberPressed(text),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
