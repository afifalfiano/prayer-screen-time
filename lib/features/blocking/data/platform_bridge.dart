import 'dart:io';
import 'package:flutter/services.dart';

class AppInfo {
  final String packageName;
  final String appName;

  AppInfo({required this.packageName, required this.appName});
}

class PlatformBridge {
  static const _androidChannel =
      MethodChannel('com.prayerscreentime.appblocker');
  static const _iosChannel =
      MethodChannel('com.prayerscreentime.screentime');

  MethodChannel get _channel =>
      Platform.isIOS ? _iosChannel : _androidChannel;

  Future<List<AppInfo>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod<List>('getInstalledApps');
      if (result == null) return [];
      return result
          .cast<Map>()
          .map((app) => AppInfo(
                packageName: app['packageName'] as String,
                appName: app['appName'] as String,
              ))
          .toList();
    } on PlatformException {
      return [];
    }
  }

  Future<bool> startBlocking(List<String> packageNames) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'startBlocking',
        {'packages': packageNames},
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> stopBlocking() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopBlocking');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isAccessibilityEnabled() async {
    if (!Platform.isAndroid) return false;
    try {
      final result =
          await _androidChannel.invokeMethod<bool>('isAccessibilityEnabled');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> requestScreenTimeAuthorization() async {
    if (!Platform.isIOS) return false;
    try {
      final result =
          await _iosChannel.invokeMethod<bool>('requestAuthorization');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
