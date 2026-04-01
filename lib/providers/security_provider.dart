import 'dart:async';
import 'package:flutter/material.dart';
import '../services/security_service.dart';

class SecurityProvider with ChangeNotifier {
  final _securityService = SecurityService();
  
  bool _isLocked = false;
  bool _isAppLockEnabled = false;
  bool _isBiometricEnabled = false;
  int _autoLockMinutes = 0; // 0 = Immediately
  DateTime? _lastPausedTime;

  bool get isLocked => _isLocked;
  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  int get autoLockMinutes => _autoLockMinutes;

  SecurityProvider() {
    _init();
  }

  Future<void> _init() async {
    _isAppLockEnabled = await _securityService.isLockEnabled();
    _isBiometricEnabled = await _securityService.isBiometricEnabled();
    // Load auto lock time from SharedPreferences or SecureStorage
    // For now, default to 0
    if (_isAppLockEnabled) {
      _isLocked = true;
    }
    notifyListeners();
  }

  void setLocked(bool locked) {
    _isLocked = locked;
    notifyListeners();
  }

  Future<void> toggleAppLock(bool value) async {
    _isAppLockEnabled = value;
    await _securityService.setLockEnabled(value);
    if (!value) {
      _isLocked = false;
    }
    notifyListeners();
  }

  Future<void> toggleBiometric(bool value) async {
    _isBiometricEnabled = value;
    await _securityService.setBiometricEnabled(value);
    notifyListeners();
  }

  void setAutoLockTime(int minutes) {
    _autoLockMinutes = minutes;
    notifyListeners();
  }

  Future<bool> verifyPin(String enteredPin) async {
    final savedPin = await _securityService.getPin();
    return savedPin == enteredPin;
  }

  Future<void> updatePin(String newPin) async {
    await _securityService.savePin(newPin);
  }

  Future<bool> authenticateBiometric() async {
    if (!_isBiometricEnabled) return false;
    final success = await _securityService.authenticateBiometric();
    if (success) {
      _isLocked = false;
      notifyListeners();
    }
    return success;
  }

  void onAppPaused() {
    if (_isAppLockEnabled) {
      _lastPausedTime = DateTime.now();
    }
  }

  void onAppResumed() {
    if (_isAppLockEnabled && _lastPausedTime != null) {
      final difference = DateTime.now().difference(_lastPausedTime!).inMinutes;
      if (difference >= _autoLockMinutes) {
        _isLocked = true;
        notifyListeners();
      }
    }
  }

  Future<void> resetSecurityData() async {
    await _securityService.clearAll();
    _isLocked = false;
    _isAppLockEnabled = false;
    _isBiometricEnabled = false;
    _autoLockMinutes = 0;
    notifyListeners();
  }
}
