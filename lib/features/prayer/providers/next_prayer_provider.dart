import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'prayer_times_provider.dart';

class NextPrayerState {
  final String name;
  final DateTime time;
  final Duration remaining;

  NextPrayerState({
    required this.name,
    required this.time,
    required this.remaining,
  });
}

final nextPrayerProvider = StreamProvider<NextPrayerState?>((ref) async* {
  final timesAsync = await ref.watch(prayerTimesProvider.future);
  final repo = ref.watch(prayerRepositoryProvider);

  while (true) {
    final next = repo.nextPrayer(times: timesAsync);
    if (next == null) {
      yield null;
    } else {
      yield NextPrayerState(
        name: next.key,
        time: next.value,
        remaining: next.value.difference(DateTime.now()),
      );
    }
    await Future.delayed(const Duration(seconds: 1));
  }
});
