import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/prayer_method.dart';
import '../../../core/location/location_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'The Sacred Interval',
              style: GoogleFonts.playfairDisplay(
                fontSize: 17,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            centerTitle: true,
          ),

          // Header image with title
          SliverToBoxAdapter(
            child: _SettingsHeader(isDark: isDark),
          ),

          // Prayer Notifications section
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Daily Solace',
              subtitle: 'Choose your moment to remember',
              isDark: isDark,
            ),
          ),
          SliverToBoxAdapter(
            child: _PrayerNotificationCard(
              prayers: prayers,
              prayerNotifications: settings.prayerNotifications,
              onToggle: (prayer, enabled) =>
                  notifier.setPrayerNotification(prayer, enabled),
              isDark: isDark,
            ),
          ),

          // Notification style section
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'The Melody of Call',
              isDark: isDark,
            ),
          ),
          SliverToBoxAdapter(
            child: _NotificationStyleCard(isDark: isDark),
          ),

          // Calculation method
          SliverToBoxAdapter(
            child: _SectionHeader(title: 'Prayer Calculation', isDark: isDark),
          ),
          SliverToBoxAdapter(
            child: _CalculationCard(
              currentIndex: settings.calculationMethodIndex,
              isDark: isDark,
              onTap: () => _showMethodPicker(context, ref),
            ),
          ),

          // Location
          SliverToBoxAdapter(
            child: _SectionHeader(title: 'Location', isDark: isDark),
          ),
          SliverToBoxAdapter(
            child: _LocationCard(
              latitude: settings.latitude,
              longitude: settings.longitude,
              isDark: isDark,
              onRefresh: () async {
                try {
                  final pos =
                      await ref.read(currentLocationProvider.future);
                  await notifier.updateLocation(
                      pos.latitude, pos.longitude);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Location updated',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
            ),
          ),

          // App Blocking
          SliverToBoxAdapter(
            child: _SectionHeader(title: 'App Blocking', isDark: isDark),
          ),
          SliverToBoxAdapter(
            child: _BlockingCard(
              blockBefore: settings.blockDurationBefore,
              blockAfter: settings.blockDurationAfter,
              isDark: isDark,
              onBeforeChanged: (v) =>
                  notifier.setBlockDurations(before: v.toInt()),
              onAfterChanged: (v) =>
                  notifier.setBlockDurations(after: v.toInt()),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showMethodPicker(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);
    final current = ref.read(settingsProvider).calculationMethodIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.dividerDark
                  : AppColors.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Calculation Method',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: PrayerMethod.values.length,
              itemBuilder: (context, index) {
                final method = PrayerMethod.values[index];
                final isSelected = index == current;
                return ListTile(
                  title: Text(
                    method.label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? (isDark
                              ? AppColors.primaryLight
                              : AppColors.primary)
                          : textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                        )
                      : null,
                  onTap: () {
                    notifier.setCalculationMethod(index);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings header ─────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A2F28), const Color(0xFF0D1F1A)]
              : [const Color(0xFF3D7A6F), const Color(0xFF2A5A52)],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Prayer\nNotifications',
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    required this.isDark,
  });

  final String title;
  final String? subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Prayer notification toggles ─────────────────────────────────────────────

class _PrayerNotificationCard extends StatelessWidget {
  const _PrayerNotificationCard({
    required this.prayers,
    required this.prayerNotifications,
    required this.onToggle,
    required this.isDark,
  });

  final List<String> prayers;
  final Map<String, bool> prayerNotifications;
  final void Function(String prayer, bool enabled) onToggle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final dividerColor =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final activeColor =
        isDark ? AppColors.primaryLight : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: List.generate(prayers.length, (i) {
            final prayer = prayers[i];
            final isLast = i == prayers.length - 1;
            final isEnabled = prayerNotifications[prayer] ?? true;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isEnabled
                              ? activeColor.withOpacity(0.12)
                              : textSecondary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _prayerIcon(prayer),
                          size: 18,
                          color: isEnabled
                              ? activeColor
                              : textSecondary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prayer,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              '+ 5 minutes',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isEnabled,
                        onChanged: (v) => onToggle(prayer, v),
                        activeColor:
                            isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                        height: 1, thickness: 0.5, color: dividerColor),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  IconData _prayerIcon(String name) => switch (name) {
        'Fajr' => Icons.wb_twilight_outlined,
        'Dhuhr' => Icons.wb_sunny_outlined,
        'Asr' => Icons.wb_cloudy_outlined,
        'Maghrib' => Icons.nights_stay_outlined,
        'Isha' => Icons.dark_mode_outlined,
        _ => Icons.access_time_outlined,
      };
}

// ─── Notification style card ─────────────────────────────────────────────────

class _NotificationStyleCard extends StatefulWidget {
  const _NotificationStyleCard({required this.isDark});
  final bool isDark;

  @override
  State<_NotificationStyleCard> createState() =>
      _NotificationStyleCardState();
}

class _NotificationStyleCardState extends State<_NotificationStyleCard> {
  int _selected = 0;
  final _styles = ['Adhan', 'Vibrate', 'Silent'];
  final _icons = [
    Icons.volume_up_outlined,
    Icons.vibration_outlined,
    Icons.volume_off_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final cardColor =
        widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final activeColor =
        widget.isDark ? AppColors.primaryLight : AppColors.primary;
    final inactiveColor = widget.isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: List.generate(_styles.length, (i) {
            final isActive = _selected == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isActive
                        ? activeColor
                        : activeColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _icons[i],
                        size: 22,
                        color: isActive ? Colors.white : inactiveColor,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _styles[i],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : inactiveColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Calculation card ─────────────────────────────────────────────────────────

class _CalculationCard extends StatelessWidget {
  const _CalculationCard({
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
  });

  final int currentIndex;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.calculate_outlined,
                  size: 20, color: textSecondary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Method',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      PrayerMethod.values[currentIndex].label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Location card ─────────────────────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.latitude,
    required this.longitude,
    required this.isDark,
    required this.onRefresh,
  });

  final double latitude;
  final double longitude;
  final bool isDark;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final activeColor =
        isDark ? AppColors.primaryLight : AppColors.primary;
    final locationText = latitude == 0
        ? 'Tap to set location'
        : '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined,
                size: 20, color: textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Location',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                  Text(
                    locationText,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onRefresh,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Refresh',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: activeColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Blocking card ───────────────────────────────────────────────────────────

class _BlockingCard extends StatelessWidget {
  const _BlockingCard({
    required this.blockBefore,
    required this.blockAfter,
    required this.isDark,
    required this.onBeforeChanged,
    required this.onAfterChanged,
  });

  final int blockBefore;
  final int blockAfter;
  final bool isDark;
  final ValueChanged<double> onBeforeChanged;
  final ValueChanged<double> onAfterChanged;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final activeColor =
        isDark ? AppColors.primaryLight : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _SliderRow(
              label: 'Before prayer',
              value: blockBefore.toDouble(),
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              activeColor: activeColor,
              onChanged: onBeforeChanged,
            ),
            const SizedBox(height: 16),
            _SliderRow(
              label: 'After prayer',
              value: blockAfter.toDouble(),
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              activeColor: activeColor,
              onChanged: onAfterChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.activeColor,
    required this.onChanged,
  });

  final String label;
  final double value;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
            ),
            Text(
              '${value.toInt()} min',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: activeColor,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: activeColor,
            inactiveTrackColor: activeColor.withOpacity(0.15),
            thumbColor: activeColor,
            overlayColor: activeColor.withOpacity(0.15),
            trackHeight: 3,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 30,
            divisions: 6,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
