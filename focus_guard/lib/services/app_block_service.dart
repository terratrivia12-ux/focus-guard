import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppInfo {
  final String packageName;
  final String appName;
  bool isBlocked;

  AppInfo({
    required this.packageName,
    required this.appName,
    this.isBlocked = false,
  });

  Map<String, dynamic> toJson() => {
    'packageName': packageName,
    'appName': appName,
    'isBlocked': isBlocked,
  };

  factory AppInfo.fromJson(Map<String, dynamic> json) => AppInfo(
    packageName: json['packageName'],
    appName: json['appName'],
    isBlocked: json['isBlocked'] ?? false,
  );
}

class BlockSession {
  final DateTime startTime;
  final int durationMinutes;
  final List<String> blockedPackages;

  BlockSession({
    required this.startTime,
    required this.durationMinutes,
    required this.blockedPackages,
  });
}

class AppBlockService extends ChangeNotifier {
  static const platform = MethodChannel('com.focusguard/app_blocker');

  List<AppInfo> _installedApps = [];
  List<AppInfo> get installedApps => _installedApps;

  List<String> _blockedPackages = [];
  List<String> get blockedPackages => _blockedPackages;

  bool _isBlockingActive = false;
  bool get isBlockingActive => _isBlockingActive;

  DateTime? _blockEndTime;
  DateTime? get blockEndTime => _blockEndTime;

  int get remainingBlockMinutes {
    if (_blockEndTime == null) return 0;
    final diff = _blockEndTime!.difference(DateTime.now());
    return diff.inMinutes.clamp(0, 9999);
  }

  // Predefined popular apps to show at top
  static const List<Map<String, String>> popularApps = [
    {'name': 'Instagram', 'package': 'com.instagram.android'},
    {'name': 'YouTube', 'package': 'com.google.android.youtube'},
    {'name': 'TikTok', 'package': 'com.zhiliaoapp.musically'},
    {'name': 'Facebook', 'package': 'com.facebook.katana'},
    {'name': 'Twitter / X', 'package': 'com.twitter.android'},
    {'name': 'Snapchat', 'package': 'com.snapchat.android'},
    {'name': 'WhatsApp', 'package': 'com.whatsapp'},
    {'name': 'Reddit', 'package': 'com.reddit.frontpage'},
    {'name': 'Netflix', 'package': 'com.netflix.mediaclient'},
    {'name': 'Spotify', 'package': 'com.spotify.music'},
    {'name': 'Discord', 'package': 'com.discord'},
    {'name': 'Telegram', 'package': 'org.telegram.messenger'},
    {'name': 'LinkedIn', 'package': 'com.linkedin.android'},
    {'name': 'Pinterest', 'package': 'com.pinterest'},
    {'name': 'Amazon', 'package': 'com.amazon.mShop.android.shopping'},
    {'name': 'Chrome', 'package': 'com.android.chrome'},
  ];

  AppBlockService() {
    _loadBlockedApps();
    _loadPopularApps();
  }

  void _loadPopularApps() {
    _installedApps = popularApps.map((a) => AppInfo(
      packageName: a['package']!,
      appName: a['name']!,
      isBlocked: _blockedPackages.contains(a['package']),
    )).toList();
    notifyListeners();
  }

  Future<void> loadInstalledApps() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getInstalledApps');
      final List<AppInfo> apps = result.map((app) => AppInfo(
        packageName: app['packageName'] as String,
        appName: app['appName'] as String,
        isBlocked: _blockedPackages.contains(app['packageName']),
      )).toList();
      apps.sort((a, b) => a.appName.compareTo(b.appName));
      _installedApps = apps;
      notifyListeners();
    } catch (e) {
      // Fallback to popular apps list if native call fails
      _loadPopularApps();
    }
  }

  void toggleAppBlock(String packageName) {
    if (_blockedPackages.contains(packageName)) {
      _blockedPackages.remove(packageName);
    } else {
      _blockedPackages.add(packageName);
    }
    for (var app in _installedApps) {
      if (app.packageName == packageName) {
        app.isBlocked = _blockedPackages.contains(packageName);
      }
    }
    _saveBlockedApps();
    notifyListeners();
  }

  Future<void> startBlocking(int durationMinutes) async {
    _isBlockingActive = true;
    _blockEndTime = DateTime.now().add(Duration(minutes: durationMinutes));
    try {
      await platform.invokeMethod('startBlocking', {
        'packages': _blockedPackages,
        'durationMinutes': durationMinutes,
      });
    } catch (e) {
      // Native blocking requires accessibility service; guide user
      debugPrint('Native blocking unavailable: $e');
    }
    _saveBlockState();
    notifyListeners();
  }

  Future<void> stopBlocking() async {
    _isBlockingActive = false;
    _blockEndTime = null;
    try {
      await platform.invokeMethod('stopBlocking');
    } catch (e) {
      debugPrint('Stop blocking error: $e');
    }
    _saveBlockState();
    notifyListeners();
  }

  Future<void> _loadBlockedApps() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('blocked_packages') ?? [];
    _blockedPackages = stored;
    final blockActive = prefs.getBool('block_active') ?? false;
    final blockEndMs = prefs.getInt('block_end_time');
    if (blockActive && blockEndMs != null) {
      final endTime = DateTime.fromMillisecondsSinceEpoch(blockEndMs);
      if (endTime.isAfter(DateTime.now())) {
        _isBlockingActive = true;
        _blockEndTime = endTime;
      }
    }
    _loadPopularApps();
  }

  Future<void> _saveBlockedApps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('blocked_packages', _blockedPackages);
  }

  Future<void> _saveBlockState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('block_active', _isBlockingActive);
    if (_blockEndTime != null) {
      await prefs.setInt('block_end_time', _blockEndTime!.millisecondsSinceEpoch);
    }
  }

  int get blockedCount => _blockedPackages.length;
}
