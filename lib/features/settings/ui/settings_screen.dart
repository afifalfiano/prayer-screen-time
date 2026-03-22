import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/prayer_method.dart';
import '../../../core/location/location_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Calculation Method
          const _SectionHeader(title: 'Prayer Calculation'),
          ListTile(
            title: const Text('Calculation Method'),
            subtitle: Text(
              PrayerMethod.values[settings.calculationMethodIndex].label,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showMethodPicker(context, ref),
          ),

          const Divider(),

          // Block Durations
          const _SectionHeader(title: 'App Blocking'),
          ListTile(
            title: const Text('Block before prayer'),
            subtitle: Text('${settings.blockDurationBefore} minutes'),
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: settings.blockDurationBefore.toDouble(),
                min: 0,
                max: 30,
                divisions: 6,
                label: '${settings.blockDurationBefore} min',
                onChanged: (value) {
                  notifier.setBlockDurations(before: value.toInt());
                },
              ),
            ),
          ),
          ListTile(
            title: const Text('Block after prayer'),
            subtitle: Text('${settings.blockDurationAfter} minutes'),
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: settings.blockDurationAfter.toDouble(),
                min: 0,
                max: 30,
                divisions: 6,
                label: '${settings.blockDurationAfter} min',
                onChanged: (value) {
                  notifier.setBlockDurations(after: value.toInt());
                },
              ),
            ),
          ),

          const Divider(),

          // Notifications
          const _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            title: const Text('Adhan Notifications'),
            subtitle: const Text('Receive alerts at prayer times'),
            value: settings.notificationsEnabled,
            onChanged: (value) {
              notifier.setNotificationsEnabled(value);
            },
          ),

          const Divider(),

          // Location
          const _SectionHeader(title: 'Location'),
          ListTile(
            title: const Text('Refresh Location'),
            subtitle: Text(
              settings.latitude == 0
                  ? 'Not set'
                  : '${settings.latitude.toStringAsFixed(4)}, ${settings.longitude.toStringAsFixed(4)}',
            ),
            trailing: const Icon(Icons.my_location),
            onTap: () async {
              try {
                final position =
                    await ref.read(currentLocationProvider.future);
                await notifier.updateLocation(
                  position.latitude,
                  position.longitude,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Location updated')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showMethodPicker(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);
    final current = ref.read(settingsProvider).calculationMethodIndex;

    showModalBottomSheet(
      context: context,
      builder: (context) => RadioGroup<int>(
        groupValue: current,
        onChanged: (value) {
          if (value != null) {
            notifier.setCalculationMethod(value);
            Navigator.pop(context);
          }
        },
        child: ListView.builder(
          itemCount: PrayerMethod.values.length,
          itemBuilder: (context, index) {
            final method = PrayerMethod.values[index];
            return RadioListTile<int>(
              title: Text(method.label),
              value: index,
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
