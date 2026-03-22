import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/qibla_provider.dart';
import 'widgets/compass_painter.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaAsync = ref.watch(qiblaStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Compass'),
        centerTitle: true,
      ),
      body: qiblaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.explore_off, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Unable to determine Qibla direction',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        data: (state) {
          final heading = state.compassHeading ?? 0;

          return Column(
            children: [
              const SizedBox(height: 32),
              Text(
                'Qibla: ${state.qiblaBearing.toStringAsFixed(1)}°',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                state.compassHeading != null
                    ? 'Heading: ${heading.toStringAsFixed(1)}°'
                    : 'Compass unavailable — calibrate your device',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Spacer(),
              SizedBox(
                width: 300,
                height: 300,
                child: CustomPaint(
                  painter: CompassPainter(
                    heading: heading,
                    qiblaBearing: state.qiblaBearing,
                  ),
                ),
              ),
              const Spacer(),
              if (state.compassHeading == null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    color: Colors.amber.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Move your phone in a figure-8 pattern to calibrate the compass.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
