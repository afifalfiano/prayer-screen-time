import 'package:adhan/adhan.dart';
import '../../../core/constants/prayer_method.dart';

class PrayerTimesResult {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  PrayerTimesResult({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  List<MapEntry<String, DateTime>> get asList => [
        MapEntry('Fajr', fajr),
        MapEntry('Sunrise', sunrise),
        MapEntry('Dhuhr', dhuhr),
        MapEntry('Asr', asr),
        MapEntry('Maghrib', maghrib),
        MapEntry('Isha', isha),
      ];
}

class PrayerRepository {
  PrayerTimesResult calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
    required PrayerMethod method,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = method.parameters;
    final dateComponents = DateComponents.from(date);
    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    return PrayerTimesResult(
      fajr: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr,
      asr: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isha: prayerTimes.isha,
    );
  }

  /// Returns the next prayer name and time from now.
  MapEntry<String, DateTime>? nextPrayer({
    required PrayerTimesResult times,
  }) {
    final now = DateTime.now();
    for (final entry in times.asList) {
      if (entry.value.isAfter(now)) {
        return entry;
      }
    }
    return null; // all prayers passed for today
  }
}
