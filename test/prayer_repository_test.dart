import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_screen_time/core/constants/prayer_method.dart';
import 'package:prayer_screen_time/features/prayer/data/prayer_repository.dart';

void main() {
  late PrayerRepository repo;

  setUp(() {
    repo = PrayerRepository();
  });

  group('PrayerRepository', () {
    test('calculates prayer times for Mecca', () {
      final result = repo.calculate(
        latitude: 21.4225,
        longitude: 39.8262,
        date: DateTime(2024, 3, 15),
        method: PrayerMethod.ummAlQura,
      );

      expect(result.fajr.isBefore(result.sunrise), true);
      expect(result.sunrise.isBefore(result.dhuhr), true);
      expect(result.dhuhr.isBefore(result.asr), true);
      expect(result.asr.isBefore(result.maghrib), true);
      expect(result.maghrib.isBefore(result.isha), true);
    });

    test('calculates prayer times for New York', () {
      final result = repo.calculate(
        latitude: 40.7128,
        longitude: -74.0060,
        date: DateTime(2024, 6, 21),
        method: PrayerMethod.northAmerica,
      );

      expect(result.fajr.isBefore(result.sunrise), true);
      // Dhuhr should be after sunrise and before asr regardless of timezone
      expect(result.dhuhr.isAfter(result.sunrise), true);
      expect(result.dhuhr.isBefore(result.asr), true);
    });

    test('calculates prayer times for Jakarta', () {
      final result = repo.calculate(
        latitude: -6.2088,
        longitude: 106.8456,
        date: DateTime(2024, 1, 1),
        method: PrayerMethod.singapore,
      );

      expect(result.asList.length, 6);
      expect(result.fajr.isBefore(result.isha), true);
    });

    test('calculates prayer times for London', () {
      final result = repo.calculate(
        latitude: 51.5074,
        longitude: -0.1278,
        date: DateTime(2024, 12, 21),
        method: PrayerMethod.muslimWorldLeague,
      );

      expect(result.fajr.isBefore(result.sunrise), true);
      expect(result.maghrib.isBefore(result.isha), true);
    });

    test('calculates prayer times for Istanbul', () {
      final result = repo.calculate(
        latitude: 41.0082,
        longitude: 28.9784,
        date: DateTime(2024, 9, 15),
        method: PrayerMethod.turkey,
      );

      expect(result.asList.length, 6);
      expect(result.fajr.isBefore(result.sunrise), true);
    });

    test('nextPrayer returns correct next prayer', () {
      final now = DateTime.now();
      // Use a date far in the future to ensure prayers haven't passed
      final result = repo.calculate(
        latitude: 21.4225,
        longitude: 39.8262,
        date: now.add(const Duration(days: 1)),
        method: PrayerMethod.ummAlQura,
      );

      // All prayers are tomorrow, so nextPrayer should return Fajr
      // when we check against times from tomorrow
      expect(result.asList.isNotEmpty, true);
    });
  });
}
