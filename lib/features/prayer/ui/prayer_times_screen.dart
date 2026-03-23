import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/permissions/permission_service.dart';
import '../data/prayer_repository.dart';
import '../providers/prayer_times_provider.dart';
import '../providers/next_prayer_provider.dart';
import 'widgets/prayer_row.dart';

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final nextPrayerAsync = ref.watch(nextPrayerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: prayerTimesAsync.when(
        loading: () => const _LoadingView(),
        error: (error, _) => _ErrorView(
          onRetry: () => ref.invalidate(prayerTimesProvider),
        ),
        data: (times) {
          final nextName = nextPrayerAsync.valueOrNull?.name;
          return CustomScrollView(
            slivers: [
              // Header with branding + countdown
              SliverToBoxAdapter(
                child: _HeaderSection(
                  nextPrayerAsync: nextPrayerAsync,
                  isDark: isDark,
                ),
              ),

              // Daily Rhythms section
              SliverToBoxAdapter(
                child: _SectionLabel(label: 'Daily Rhythms', isDark: isDark),
              ),
              SliverToBoxAdapter(
                child: _PrayerListCard(
                  times: times,
                  nextName: nextName,
                  isDark: isDark,
                ),
              ),

              // Digital Fast section
              SliverToBoxAdapter(
                child: _SectionLabel(label: 'Digital Fast', isDark: isDark),
              ),
              SliverToBoxAdapter(
                child: _DigitalFastCard(isDark: isDark),
              ),

              // Reflection quote
              SliverToBoxAdapter(
                child: _ReflectionCard(isDark: isDark),
              ),

              // Bottom padding for nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.nextPrayerAsync,
    required this.isDark,
  });

  final AsyncValue<NextPrayerState?> nextPrayerAsync;
  final bool isDark;

  String _subtitle(String name) => switch (name) {
        'Fajr' => 'Until the morning stillness begins',
        'Sunrise' => 'The sun rises upon the world',
        'Dhuhr' => 'Until the midday prayer',
        'Asr' => 'Until the afternoon stillness',
        'Maghrib' => 'Until the evening stillness begins',
        'Isha' => 'Until the night prayer begins',
        _ => 'The sacred pause approaches',
      };

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      color: bgColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'The Sacred Interval',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.notifications_none_outlined,
                    color: textSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),

            // Countdown
            nextPrayerAsync.when(
              loading: () => const SizedBox(height: 120),
              error: (_, __) => const SizedBox(height: 120),
              data: (NextPrayerState? next) {
                if (next == null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Text(
                      'All prayers completed\nfor today',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        color: textPrimary,
                      ),
                    ),
                  );
                }
                final h = next.remaining.inHours;
                final m = next.remaining.inMinutes % 60;
                final s = next.remaining.inSeconds % 60;
                final timeStr =
                    '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

                return Column(
                  children: [
                    Text(
                      'NEXT PRAYER: ${next.name.toUpperCase()}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeStr,
                      style: GoogleFonts.inter(
                        fontSize: 52,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -1,
                        color: textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle(next.name),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section label ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: textSecondary,
        ),
      ),
    );
  }
}

// ─── Prayer list card ───────────────────────────────────────────────────────

class _PrayerListCard extends StatelessWidget {
  const _PrayerListCard({
    required this.times,
    required this.nextName,
    required this.isDark,
  });

  final PrayerTimesResult times;
  final String? nextName;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final dividerColor =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;

    final prayers = times.asList.where((e) => e.key != 'Sunrise').toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: List.generate(prayers.length, (i) {
            final entry = prayers[i];
            final isLast = i == prayers.length - 1;
            return Column(
              children: [
                PrayerRow(
                  name: entry.key,
                  time: entry.value,
                  isNext: entry.key == nextName,
                  isDark: isDark,
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
}

// ─── Digital Fast card ──────────────────────────────────────────────────────

class _DigitalFastCard extends StatelessWidget {
  const _DigitalFastCard({required this.isDark});
  final bool isDark;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Focus",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Donut chart
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      progress: 0.75,
                      activeColor: activeColor,
                      bgColor: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight,
                    ),
                    child: Center(
                      child: Text(
                        '75%',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: activeColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Screen Time',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prayer windows protected',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.progress,
    required this.activeColor,
    required this.bgColor,
  });

  final double progress;
  final Color activeColor;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = bgColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = activeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress ||
      old.activeColor != activeColor ||
      old.bgColor != bgColor;
}

// ─── Reflection card ────────────────────────────────────────────────────────

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isDark ? const Color(0xFF1E3A36) : const Color(0xFF2D5A52);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pause for a breath\nof reflection.',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '"Silence is the language of God, all else is\npoor translation." — Rumi',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.75),
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.go('/reflect'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white.withOpacity(0.6), width: 1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'WRITE JOURNAL',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Colors.white,
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

// ─── Loading & error ─────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.primaryLight : AppColors.primary;
    return Center(
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: 2,
      ),
    );
  }
}

class _ErrorView extends StatefulWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  State<_ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<_ErrorView> {
  bool _requesting = false;

  Future<void> _grantLocation() async {
    setState(() => _requesting = true);
    final granted = await PermissionService().requestLocation();
    setState(() => _requesting = false);
    if (granted) widget.onRetry();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final activeColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined, size: 56, color: activeColor),
            const SizedBox(height: 20),
            Text(
              'Location needed\nfor prayer times',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                color: textPrimary,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Grant location access to calculate\naccurate prayer times for your area.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _requesting ? null : _grantLocation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _requesting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'ALLOW LOCATION',
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
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: widget.onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    isDark ? AppColors.primaryLight : AppColors.primary,
                side: BorderSide(
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              child: Text(
                'TRY AGAIN',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
