import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PomodoroState { idle, focusing, shortBreak, longBreak }

class PomodoroService extends ChangeNotifier {
  // Settings
  int focusDuration = 25; // minutes
  int shortBreakDuration = 5;
  int longBreakDuration = 15;
  int sessionsBeforeLongBreak = 4;
  bool autoStartNext = true;

  // State
  PomodoroState _state = PomodoroState.idle;
  int _secondsRemaining = 0;
  int _completedSessions = 0;
  int _totalFocusMinutes = 0;
  Timer? _timer;
  bool _isPaused = false;

  PomodoroState get state => _state;
  int get secondsRemaining => _secondsRemaining;
  int get completedSessions => _completedSessions;
  int get totalFocusMinutes => _totalFocusMinutes;
  bool get isPaused => _isPaused;
  bool get isRunning => _timer != null && _timer!.isActive;

  double get progress {
    int total = _totalSecondsForState(_state);
    if (total == 0) return 0;
    return 1 - (_secondsRemaining / total);
  }

  String get timeDisplay {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get stateLabel {
    switch (_state) {
      case PomodoroState.focusing:
        return 'FOCUS';
      case PomodoroState.shortBreak:
        return 'SHORT BREAK';
      case PomodoroState.longBreak:
        return 'LONG BREAK';
      default:
        return 'READY';
    }
  }

  Color get stateColor {
    switch (_state) {
      case PomodoroState.focusing:
        return const Color(0xFFFF6B35);
      case PomodoroState.shortBreak:
        return const Color(0xFF00D4FF);
      case PomodoroState.longBreak:
        return const Color(0xFF7B61FF);
      default:
        return const Color(0xFF555577);
    }
  }

  PomodoroService() {
    _loadSettings();
    _secondsRemaining = focusDuration * 60;
  }

  int _totalSecondsForState(PomodoroState s) {
    switch (s) {
      case PomodoroState.focusing:
        return focusDuration * 60;
      case PomodoroState.shortBreak:
        return shortBreakDuration * 60;
      case PomodoroState.longBreak:
        return longBreakDuration * 60;
      default:
        return focusDuration * 60;
    }
  }

  void start() {
    if (_state == PomodoroState.idle) {
      _state = PomodoroState.focusing;
      _secondsRemaining = focusDuration * 60;
    }
    _isPaused = false;
    _startTimer();
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _isPaused = true;
    notifyListeners();
  }

  void resume() {
    _isPaused = false;
    _startTimer();
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _state = PomodoroState.idle;
    _secondsRemaining = focusDuration * 60;
    _isPaused = false;
    notifyListeners();
  }

  void skip() {
    _timer?.cancel();
    _onSessionComplete();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        if (_state == PomodoroState.focusing) {
          _totalFocusMinutes = _totalFocusMinutes; // updated on complete
        }
        notifyListeners();
      } else {
        _timer?.cancel();
        _onSessionComplete();
      }
    });
  }

  void _onSessionComplete() {
    if (_state == PomodoroState.focusing) {
      _completedSessions++;
      _totalFocusMinutes += focusDuration;
      bool isLongBreak = _completedSessions % sessionsBeforeLongBreak == 0;
      _state = isLongBreak ? PomodoroState.longBreak : PomodoroState.shortBreak;
      _secondsRemaining = _totalSecondsForState(_state);
    } else {
      _state = PomodoroState.focusing;
      _secondsRemaining = focusDuration * 60;
    }
    _saveSettings();
    notifyListeners();
    if (autoStartNext) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _isPaused = false;
        _startTimer();
        notifyListeners();
      });
    } else {
      _isPaused = true;
    }
  }

  void updateSettings({
    int? focus,
    int? shortBreak,
    int? longBreak,
    int? sessionsBeforeLong,
    bool? autoStart,
  }) {
    if (focus != null) focusDuration = focus;
    if (shortBreak != null) shortBreakDuration = shortBreak;
    if (longBreak != null) longBreakDuration = longBreak;
    if (sessionsBeforeLong != null) sessionsBeforeLongBreak = sessionsBeforeLong;
    if (autoStart != null) autoStartNext = autoStart;
    if (_state == PomodoroState.idle) {
      _secondsRemaining = focusDuration * 60;
    }
    _saveSettings();
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    focusDuration = prefs.getInt('focus_duration') ?? 25;
    shortBreakDuration = prefs.getInt('short_break') ?? 5;
    longBreakDuration = prefs.getInt('long_break') ?? 15;
    sessionsBeforeLongBreak = prefs.getInt('sessions_before_long') ?? 4;
    autoStartNext = prefs.getBool('auto_start') ?? true;
    _completedSessions = prefs.getInt('completed_sessions') ?? 0;
    _totalFocusMinutes = prefs.getInt('total_focus_minutes') ?? 0;
    _secondsRemaining = focusDuration * 60;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('focus_duration', focusDuration);
    await prefs.setInt('short_break', shortBreakDuration);
    await prefs.setInt('long_break', longBreakDuration);
    await prefs.setInt('sessions_before_long', sessionsBeforeLongBreak);
    await prefs.setBool('auto_start', autoStartNext);
    await prefs.setInt('completed_sessions', _completedSessions);
    await prefs.setInt('total_focus_minutes', _totalFocusMinutes);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
