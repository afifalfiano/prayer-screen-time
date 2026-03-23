import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/prayer_method.dart';
import '../../prayer/data/prayer_repository.dart';
import '../../settings/data/settings_repository.dart';
import '../data/notification_service.dart';

const _taskRecalculate = 'com.prayerscreentime.recalculate';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      await NotificationService.init();
      final settingsRepo = SettingsRepository();
      final settings = settingsRepo.getSettings();
      final prayerRepo = PrayerRepository();

      double lat = settings.latitude;
      double lng = settings.longitude;

      // Try to get fresh location
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        lat = position.latitude;
        lng = position.longitude;
        await settingsRepo.updateLocation(lat, lng);
      } catch (_) {
        // Use cached location
      }

      if (lat == 0 && lng == 0) return true;

      final times = prayerRepo.calculate(
        latitude: lat,
        longitude: lng,
        date: DateTime.now(),
        method: PrayerMethod.values[settings.calculationMethodIndex],
      );

      if (settings.notificationsEnabled) {
        await NotificationService.rescheduleAll(times);
      }

      return true;
    } catch (_) {
      return false;
    }
  });
}

class BackgroundWorker {
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  static Future<void> registerDailyTask() async {
    // workmanager periodic tasks only supported on Android
    if (!Platform.isAndroid) return;
    await Workmanager().registerPeriodicTask(
      _taskRecalculate,
      _taskRecalculate,
      frequency: const Duration(hours: 12),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}
