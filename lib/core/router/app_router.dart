import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/prayer/ui/prayer_times_screen.dart';
import '../../features/qibla/ui/qibla_screen.dart';
import '../../features/settings/ui/settings_screen.dart';
import '../../features/reflect/ui/reflect_screen.dart';
import '../../features/onboarding/ui/onboarding_screen.dart';
import '../../shared/widgets/app_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/prayer',
            builder: (context, state) => const PrayerTimesScreen(),
          ),
          GoRoute(
            path: '/focus',
            builder: (context, state) => const QiblaScreen(),
          ),
          GoRoute(
            path: '/reflect',
            builder: (context, state) => const ReflectScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
