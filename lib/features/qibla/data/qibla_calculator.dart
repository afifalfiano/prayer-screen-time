import 'dart:math';

class QiblaCalculator {
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  /// Returns the Qibla bearing in degrees from true north.
  static double bearing(double latitude, double longitude) {
    final lat1 = _toRadians(latitude);
    final lng1 = _toRadians(longitude);
    final lat2 = _toRadians(_kaabaLat);
    final lng2 = _toRadians(_kaabaLng);

    final dLng = lng2 - lng1;
    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    final bearing = atan2(y, x);

    return (_toDegrees(bearing) + 360) % 360;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
  static double _toDegrees(double radians) => radians * 180 / pi;
}
