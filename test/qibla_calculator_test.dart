import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_screen_time/features/qibla/data/qibla_calculator.dart';

void main() {
  group('QiblaCalculator', () {
    test('Qibla from New York is roughly northeast (~58°)', () {
      final bearing = QiblaCalculator.bearing(40.7128, -74.0060);
      expect(bearing, closeTo(58.5, 2.0));
    });

    test('Qibla from Jakarta is roughly northwest (~295°)', () {
      final bearing = QiblaCalculator.bearing(-6.2088, 106.8456);
      expect(bearing, closeTo(295.0, 3.0));
    });

    test('Qibla from London is roughly southeast (~119°)', () {
      final bearing = QiblaCalculator.bearing(51.5074, -0.1278);
      expect(bearing, closeTo(119.0, 2.0));
    });

    test('Qibla from Tokyo is roughly west-northwest (~293°)', () {
      final bearing = QiblaCalculator.bearing(35.6762, 139.6503);
      expect(bearing, closeTo(293.0, 3.0));
    });

    test('Qibla from Mecca itself is 0 or 360 (at the Kaaba)', () {
      // At the Kaaba, bearing is undefined but should not crash
      final bearing = QiblaCalculator.bearing(21.4225, 39.8262);
      expect(bearing, isA<double>());
      expect(bearing.isNaN, false);
    });

    test('bearing is always between 0 and 360', () {
      final testPoints = [
        [0.0, 0.0],
        [90.0, 0.0],
        [-90.0, 0.0],
        [0.0, 180.0],
        [0.0, -180.0],
        [-33.8688, 151.2093], // Sydney
      ];

      for (final point in testPoints) {
        final bearing = QiblaCalculator.bearing(point[0], point[1]);
        expect(bearing, greaterThanOrEqualTo(0));
        expect(bearing, lessThan(360));
      }
    });
  });
}
