import 'dart:convert';

class UserSettings {
  double latitude;
  double longitude;
  String timezone;
  int calculationMethodIndex;
  int blockDurationBefore;
  int blockDurationAfter;
  bool notificationsEnabled;

  UserSettings({
    this.latitude = 0,
    this.longitude = 0,
    this.timezone = '',
    this.calculationMethodIndex = 0,
    this.blockDurationBefore = 5,
    this.blockDurationAfter = 10,
    this.notificationsEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'timezone': timezone,
        'calculationMethodIndex': calculationMethodIndex,
        'blockDurationBefore': blockDurationBefore,
        'blockDurationAfter': blockDurationAfter,
        'notificationsEnabled': notificationsEnabled,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        timezone: json['timezone'] as String? ?? '',
        calculationMethodIndex: json['calculationMethodIndex'] as int? ?? 0,
        blockDurationBefore: json['blockDurationBefore'] as int? ?? 5,
        blockDurationAfter: json['blockDurationAfter'] as int? ?? 10,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      );

  String encode() => jsonEncode(toJson());

  factory UserSettings.decode(String source) =>
      UserSettings.fromJson(jsonDecode(source) as Map<String, dynamic>);

  UserSettings copyWith({
    double? latitude,
    double? longitude,
    String? timezone,
    int? calculationMethodIndex,
    int? blockDurationBefore,
    int? blockDurationAfter,
    bool? notificationsEnabled,
  }) =>
      UserSettings(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        timezone: timezone ?? this.timezone,
        calculationMethodIndex:
            calculationMethodIndex ?? this.calculationMethodIndex,
        blockDurationBefore: blockDurationBefore ?? this.blockDurationBefore,
        blockDurationAfter: blockDurationAfter ?? this.blockDurationAfter,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );
}
