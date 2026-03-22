import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/prayer_times_provider.dart';
import '../providers/next_prayer_provider.dart';
import 'widgets/prayer_card.dart';

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final nextPrayerAsync = ref.watch(nextPrayerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        centerTitle: true,
      ),
      body: prayerTimesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Failed to load prayer times',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(prayerTimesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (times) {
          final nextName = nextPrayerAsync.valueOrNull?.name;

          return Column(
            children: [
              // Countdown header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: AppColors.primary,
                child: nextPrayerAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (next) {
                    if (next == null) {
                      return const Text(
                        'All prayers completed for today',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      );
                    }
                    final hours = next.remaining.inHours;
                    final minutes = next.remaining.inMinutes % 60;
                    final seconds = next.remaining.inSeconds % 60;
                    return Column(
                      children: [
                        Text(
                          'Next: ${next.name}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.jm().format(next.time),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Date
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  DateFormat.yMMMMd().format(DateTime.now()),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              // Prayer cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: times.asList
                      .map((entry) => PrayerCard(
                            name: entry.key,
                            time: entry.value,
                            isNext: entry.key == nextName,
                          ))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
