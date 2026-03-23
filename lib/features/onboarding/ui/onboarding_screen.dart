import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _loading = false;

  Future<void> _requestLocation() async {
    setState(() => _loading = true);
    final granted = await _permissionService.requestLocation();
    setState(() {
      _locationGranted = granted;
      _loading = false;
      if (granted) _step = 1;
    });

    if (granted) {
      try {
        final position = await ref.read(currentLocationProvider.future);
        await ref.read(settingsProvider.notifier).updateLocation(
              position.latitude,
              position.longitude,
            );
      } catch (_) {}
    }
  }

  Future<void> _requestNotification() async {
    setState(() => _loading = true);
    final granted = await _permissionService.requestNotification();
    setState(() {
      _notificationGranted = granted;
      _loading = false;
      _step = 2;
    });
  }

  void _finish() => context.go('/prayer');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final activeColor =
        isDark ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Brand name
              Text(
                'The Sacred\nInterval',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Prayer times, Qibla compass &\nreflection for Muslims.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 56),

              // Step indicator
              _StepIndicator(step: _step, activeColor: activeColor),

              const SizedBox(height: 40),

              // Step content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 0
                      ? _PermissionStep(
                          key: const ValueKey(0),
                          icon: Icons.location_on_outlined,
                          title: 'Allow Location',
                          description:
                              'We need your location to calculate accurate prayer times and Qibla direction.\n\nYour data stays on-device.',
                          buttonLabel: 'ALLOW LOCATION',
                          skipLabel: 'Skip for now',
                          loading: _loading,
                          isDark: isDark,
                          activeColor: activeColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: _requestLocation,
                          onSkip: () => setState(() => _step = 1),
                        )
                      : _step == 1
                          ? _PermissionStep(
                              key: const ValueKey(1),
                              icon: Icons.notifications_outlined,
                              title: 'Prayer Reminders',
                              description:
                                  'Receive Adhan notifications at prayer times to keep you connected throughout the day.',
                              buttonLabel: 'ALLOW NOTIFICATIONS',
                              skipLabel: 'Skip for now',
                              loading: _loading,
                              isDark: isDark,
                              activeColor: activeColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              onTap: _requestNotification,
                              onSkip: () => setState(() => _step = 2),
                            )
                          : _ReadyStep(
                              key: const ValueKey(2),
                              locationGranted: _locationGranted,
                              notifGranted: _notificationGranted,
                              isDark: isDark,
                              activeColor: activeColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              onFinish: _finish,
                            ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step, required this.activeColor});
  final int step;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i <= step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == step ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? activeColor
                : activeColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _PermissionStep extends StatelessWidget {
  const _PermissionStep({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    this.skipLabel,
    required this.loading,
    required this.isDark,
    required this.activeColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
    this.onSkip,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final String? skipLabel;
  final bool loading;
  final bool isDark;
  final Color activeColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: activeColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 36, color: activeColor),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: textSecondary,
            height: 1.6,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: loading ? null : onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      buttonLabel,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
        if (skipLabel != null) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onSkip,
            child: Text(
              skipLabel!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReadyStep extends StatelessWidget {
  const _ReadyStep({
    super.key,
    required this.locationGranted,
    required this.notifGranted,
    required this.isDark,
    required this.activeColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onFinish,
  });

  final bool locationGranted;
  final bool notifGranted;
  final bool isDark;
  final Color activeColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: activeColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 40, color: activeColor),
        ),
        const SizedBox(height: 24),
        Text(
          "You're all set",
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          locationGranted
              ? 'Prayer times and Qibla\ndirection are ready.'
              : 'You can enable permissions later\nin Settings.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: textSecondary,
            height: 1.6,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onFinish,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                'BEGIN YOUR JOURNEY',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
