import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/prayer_method.dart';
import '../../../core/location/location_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/prayer_repository.dart';

final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return PrayerRepository();
});

final prayerTimesProvider = FutureProvider<PrayerTimesResult>((ref) async {
  final position = await ref.watch(currentLocationProvider.future);
  final settings = ref.watch(settingsProvider);
  final repo = ref.watch(prayerRepositoryProvider);

  return repo.calculate(
    latitude: position.latitude,
    longitude: position.longitude,
    date: DateTime.now(),
    method: PrayerMethod.values[settings.calculationMethodIndex],
  );
});
