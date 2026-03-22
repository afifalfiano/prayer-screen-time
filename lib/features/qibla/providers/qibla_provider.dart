import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/location/location_provider.dart';
import '../data/qibla_calculator.dart';

class QiblaState {
  final double qiblaBearing; // degrees from true north
  final double? compassHeading; // device heading from true north

  QiblaState({required this.qiblaBearing, this.compassHeading});

  /// Rotation angle for the compass needle to point to Qibla.
  double? get qiblaDirection {
    if (compassHeading == null) return null;
    return qiblaBearing - compassHeading!;
  }
}

final qiblaBearingProvider = FutureProvider<double>((ref) async {
  final position = await ref.watch(currentLocationProvider.future);
  return QiblaCalculator.bearing(position.latitude, position.longitude);
});

final compassHeadingProvider = StreamProvider<double?>((ref) {
  return FlutterCompass.events!.map((event) => event.heading);
});

final qiblaStateProvider = Provider<AsyncValue<QiblaState>>((ref) {
  final bearingAsync = ref.watch(qiblaBearingProvider);
  final headingAsync = ref.watch(compassHeadingProvider);

  return bearingAsync.when(
    loading: () => const AsyncLoading(),
    error: (e, s) => AsyncError(e, s),
    data: (bearing) {
      final heading = headingAsync.valueOrNull;
      return AsyncData(QiblaState(
        qiblaBearing: bearing,
        compassHeading: heading,
      ));
    },
  );
});
