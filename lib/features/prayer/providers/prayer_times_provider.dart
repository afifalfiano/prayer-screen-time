import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/prayer_method.dart';
import '../../../core/location/location_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/prayer_repository.dart';

final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return PrayerRepository();
});

final prayerTimesProvider = FutureProvider<PrayerTimesResult>((ref) async {
  final settings = ref.watch(settingsProvider);
  final repo = ref.watch(prayerRepositoryProvider);

  double lat = settings.latitude;
  double lng = settings.longitude;

  // Try to get a fresh GPS fix only if permission is already granted.
  // Never trigger the permission dialog automatically.
  if (lat == 0 && lng == 0) {
    try {
      final position = await ref.watch(currentLocationProvider.future);
      lat = position.latitude;
      lng = position.longitude;
      // Persist so next launch skips GPS
      await ref.read(settingsProvider.notifier).updateLocation(lat, lng);
    } catch (_) {
      // Permission not granted or GPS unavailable — nothing to do
    }
  }

  if (lat == 0 && lng == 0) {
    throw Exception(
        'Location not available. Please grant location permission in Settings.');
  }

  return repo.calculate(
    latitude: lat,
    longitude: lng,
    date: DateTime.now(),
    method: PrayerMethod.values[settings.calculationMethodIndex],
  );
});
