import 'dart:convert';

class BlockedApp {
  final String packageName;
  final String appName;
  bool isBlocked;

  BlockedApp({
    required this.packageName,
    required this.appName,
    this.isBlocked = true,
  });

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'appName': appName,
        'isBlocked': isBlocked,
      };

  factory BlockedApp.fromJson(Map<String, dynamic> json) => BlockedApp(
        packageName: json['packageName'] as String,
        appName: json['appName'] as String,
        isBlocked: json['isBlocked'] as bool? ?? true,
      );

  static String encodeList(List<BlockedApp> apps) =>
      jsonEncode(apps.map((a) => a.toJson()).toList());

  static List<BlockedApp> decodeList(String source) =>
      (jsonDecode(source) as List)
          .map((e) => BlockedApp.fromJson(e as Map<String, dynamic>))
          .toList();
}
