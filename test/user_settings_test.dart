import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_screen_time/core/database/collections/user_settings.dart';
import 'package:prayer_screen_time/core/database/collections/blocked_app.dart';

void main() {
  group('UserSettings', () {
    test('serialization roundtrip', () {
      final settings = UserSettings(
        latitude: 21.4225,
        longitude: 39.8262,
        timezone: 'AST',
        calculationMethodIndex: 3,
        blockDurationBefore: 10,
        blockDurationAfter: 15,
        notificationsEnabled: false,
      );

      final encoded = settings.encode();
      final decoded = UserSettings.decode(encoded);

      expect(decoded.latitude, settings.latitude);
      expect(decoded.longitude, settings.longitude);
      expect(decoded.timezone, settings.timezone);
      expect(decoded.calculationMethodIndex, settings.calculationMethodIndex);
      expect(decoded.blockDurationBefore, settings.blockDurationBefore);
      expect(decoded.blockDurationAfter, settings.blockDurationAfter);
      expect(decoded.notificationsEnabled, settings.notificationsEnabled);
    });

    test('default values', () {
      final settings = UserSettings();
      expect(settings.latitude, 0);
      expect(settings.longitude, 0);
      expect(settings.calculationMethodIndex, 0);
      expect(settings.blockDurationBefore, 5);
      expect(settings.blockDurationAfter, 10);
      expect(settings.notificationsEnabled, true);
    });

    test('copyWith creates modified copy', () {
      final original = UserSettings(latitude: 10, longitude: 20);
      final copy = original.copyWith(latitude: 30);

      expect(copy.latitude, 30);
      expect(copy.longitude, 20); // unchanged
    });
  });

  group('BlockedApp', () {
    test('list serialization roundtrip', () {
      final apps = [
        BlockedApp(packageName: 'com.instagram', appName: 'Instagram'),
        BlockedApp(packageName: 'com.tiktok', appName: 'TikTok', isBlocked: false),
      ];

      final encoded = BlockedApp.encodeList(apps);
      final decoded = BlockedApp.decodeList(encoded);

      expect(decoded.length, 2);
      expect(decoded[0].packageName, 'com.instagram');
      expect(decoded[0].isBlocked, true);
      expect(decoded[1].appName, 'TikTok');
      expect(decoded[1].isBlocked, false);
    });

    test('empty list roundtrip', () {
      final encoded = BlockedApp.encodeList([]);
      final decoded = BlockedApp.decodeList(encoded);
      expect(decoded, isEmpty);
    });
  });
}
