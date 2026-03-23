import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class PrayerRow extends StatelessWidget {
  const PrayerRow({
    super.key,
    required this.name,
    required this.time,
    required this.isDark,
    this.isNext = false,
  });

  final String name;
  final DateTime time;
  final bool isDark;
  final bool isNext;

  String get _arabicName => switch (name) {
        'Fajr' => 'الفجر',
        'Dhuhr' => 'الظهر',
        'Asr' => 'العصر',
        'Maghrib' => 'المغرب',
        'Isha' => 'العشاء',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final activeColor =
        isDark ? AppColors.primaryLight : AppColors.primary;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final activeBg = isDark
        ? AppColors.primaryDark.withOpacity(0.3)
        : AppColors.primary.withOpacity(0.08);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: isNext ? activeBg : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Prayer name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight:
                        isNext ? FontWeight.w600 : FontWeight.w400,
                    color: isNext ? activeColor : textPrimary,
                  ),
                ),
                if (_arabicName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Text(
                      _arabicName,
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Next badge
          if (isNext) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: activeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'NEXT',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: activeColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Time
          Text(
            DateFormat.jm().format(time),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: isNext ? FontWeight.w600 : FontWeight.w400,
              color: isNext ? activeColor : textSecondary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
