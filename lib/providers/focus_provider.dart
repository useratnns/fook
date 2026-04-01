import 'dart:async';
import 'package:flutter/material.dart';

enum FocusMode { focus, shortBreak, longBreak }

class FocusProvider with ChangeNotifier {
  int _focusDuration = 45 * 60; // seconds
  int _shortBreakDuration = 5 * 60;
  int _longBreakDuration = 15 * 60;
  
  int _currentTime = 45 * 60;
  Timer? _timer;
  FocusMode _mode = FocusMode.focus;
  bool _isActive = false;
  int _totalFocusToday = 0; // minutes
  
  int get focusDuration => _focusDuration;
  int get shortBreakDuration => _shortBreakDuration;
  int get longBreakDuration => _longBreakDuration;

  int get currentTime => _currentTime;
  FocusMode get mode => _mode;
  bool get isActive => _isActive;
  int get totalFocusToday => _totalFocusToday;

  void startTimer() {
    if (_isActive) return;
    _isActive = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTime > 0) {
        _currentTime--;
        notifyListeners();
      } else {
        stopTimer();
        if (_mode == FocusMode.focus) {
          _totalFocusToday += (_focusDuration ~/ 60);
        }
        // Notification logic will be triggered from the UI or service
      }
    });
    notifyListeners();
  }

  void stopTimer() {
    _isActive = false;
    _timer?.cancel();
    notifyListeners();
  }

  void resetTimer() {
    stopTimer();
    _setInitialTime();
    notifyListeners();
  }

  void switchMode(FocusMode mode) {
    _mode = mode;
    resetTimer();
  }

  void _setInitialTime() {
    switch (_mode) {
      case FocusMode.focus:
        _currentTime = _focusDuration;
        break;
      case FocusMode.shortBreak:
        _currentTime = _shortBreakDuration;
        break;
      case FocusMode.longBreak:
        _currentTime = _longBreakDuration;
        break;
    }
  }

  void updateDurations({int? focus, int? short, int? long}) {
    if (focus != null) _focusDuration = focus * 60;
    if (short != null) _shortBreakDuration = short * 60;
    if (long != null) _longBreakDuration = long * 60;
    resetTimer();
  }

  String get formattedTime {
    int minutes = _currentTime ~/ 60;
    int seconds = _currentTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
