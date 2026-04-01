import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();

  Future<void> savePin(String pin) async {
    await _storage.write(key: 'app_pin', value: pin);
  }

  Future<String?> getPin() async {
    return await _storage.read(key: 'app_pin');
  }

  Future<void> setLockEnabled(bool enabled) async {
    await _storage.write(key: 'app_lock_enabled', value: enabled.toString());
  }

  Future<bool> isLockEnabled() async {
    String? enabled = await _storage.read(key: 'app_lock_enabled');
    return enabled == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    String? enabled = await _storage.read(key: 'biometric_enabled');
    return enabled == 'true';
  }

  Future<bool> authenticateBiometric() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return false;

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock FOOK',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
