import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/permissions/permission_service.dart';
import '../../../core/location/location_provider.dart';
import '../../settings/providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _permissionService = PermissionService();
  int _step = 0;
  bool _locationGranted = false;
  bool _notificationGranted = false;

  Future<void> _requestLocation() async {
    final granted = await _permissionService.requestLocation();
    setState(() {
      _locationGranted = granted;
      if (granted) _step = 1;
    });

    if (granted) {
      // Fetch location and save to settings
      try {
        final position = await ref.read(currentLocationProvider.future);
        await ref.read(settingsProvider.notifier).updateLocation(
              position.latitude,
              position.longitude,
            );
      } catch (_) {
        // Will retry later
      }
    }
  }

  Future<void> _requestNotification() async {
    final granted = await _permissionService.requestNotification();
    setState(() {
      _notificationGranted = granted;
      _step = 2;
    });
  }

  void _finish() {
    context.go('/prayer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mosque,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Prayer Screen Time',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Focus on what matters most',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 48),
              if (_step == 0) ...[
                const _PermissionCard(
                  icon: Icons.location_on,
                  title: 'Location Permission',
                  description:
                      'We need your location to calculate accurate prayer times and Qibla direction. Your data stays on-device.',
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _requestLocation,
                  icon: const Icon(Icons.location_on),
                  label: const Text('Allow Location'),
                ),
              ] else if (_step == 1) ...[
                const _PermissionCard(
                  icon: Icons.notifications_active,
                  title: 'Notification Permission',
                  description:
                      'Allow notifications to receive Adhan alerts when it\'s time to pray.',
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _requestNotification,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Allow Notifications'),
                ),
                TextButton(
                  onPressed: () => setState(() => _step = 2),
                  child: const Text('Skip'),
                ),
              ] else ...[
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 16),
                Text(
                  'You\'re all set!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _locationGranted
                      ? 'Location: Granted${_notificationGranted ? ' | Notifications: Granted' : ''}'
                      : 'You can enable permissions later in Settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _finish,
                  child: const Text('Get Started'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
