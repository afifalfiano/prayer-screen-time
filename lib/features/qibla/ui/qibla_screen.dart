import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/qibla_provider.dart';
import 'widgets/compass_painter.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaAsync = ref.watch(qiblaStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final activeColor =
        isDark ? AppColors.primaryLight : AppColors.primary;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
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

            // Page title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Qibla Direction',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      'Face toward the Kaaba in Makkah',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Compass
            SliverToBoxAdapter(
              child: qiblaAsync.when(
                loading: () => SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: activeColor,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.explore_off_outlined,
                            size: 48, color: textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          'Unable to determine direction',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                data: (state) {
                  final heading = state.compassHeading ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Bearing info
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              _InfoChip(
                                label: 'QIBLA',
                                value:
                                    '${state.qiblaBearing.toStringAsFixed(1)}°',
                                activeColor: activeColor,
                                textSecondary: textSecondary,
                              ),
                              Container(
                                width: 1,
                                height: 36,
                                color: isDark
                                    ? AppColors.dividerDark
                                    : AppColors.dividerLight,
                              ),
                              _InfoChip(
                                label: 'HEADING',
                                value: state.compassHeading != null
                                    ? '${heading.toStringAsFixed(1)}°'
                                    : 'N/A',
                                activeColor: activeColor,
                                textSecondary: textSecondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Compass
                          SizedBox(
                            width: 260,
                            height: 260,
                            child: CustomPaint(
                              painter: CompassPainter(
                                heading: heading,
                                qiblaBearing: state.qiblaBearing,
                              ),
                            ),
                          ),
                          if (state.compassHeading == null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.warmGold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: AppColors.warmGold,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Move your device in a figure-8 to calibrate.',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.warmGold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Spiritual tools section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text(
                  'SPIRITUAL TOOLS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: textSecondary,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _ToolCard(
                        icon: Icons.explore_outlined,
                        title: 'Qibla Direction',
                        subtitle: 'Active now',
                        isDark: isDark,
                        activeColor: activeColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        cardColor: cardColor,
                        isActive: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ToolCard(
                        icon: Icons.grain_outlined,
                        title: 'Tasbeeh',
                        subtitle: 'Coming soon',
                        isDark: isDark,
                        activeColor: activeColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        cardColor: cardColor,
                        isActive: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    required this.activeColor,
    required this.textSecondary,
  });

  final String label;
  final String value;
  final Color activeColor;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: activeColor,
          ),
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.activeColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardColor,
    required this.isActive,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final Color activeColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color cardColor;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withOpacity(0.1) : cardColor,
        borderRadius: BorderRadius.circular(18),
        border: isActive
            ? Border.all(color: activeColor.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 28,
            color: isActive ? activeColor : textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? activeColor : textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
