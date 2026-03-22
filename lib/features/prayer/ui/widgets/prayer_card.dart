import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class PrayerCard extends StatelessWidget {
  const PrayerCard({
    super.key,
    required this.name,
    required this.time,
    this.isNext = false,
  });

  final String name;
  final DateTime time;
  final bool isNext;

  IconData get _icon => switch (name) {
        'Fajr' => Icons.wb_twilight,
        'Sunrise' => Icons.wb_sunny_outlined,
        'Dhuhr' => Icons.wb_sunny,
        'Asr' => Icons.wb_cloudy,
        'Maghrib' => Icons.nights_stay_outlined,
        'Isha' => Icons.nights_stay,
        _ => Icons.access_time,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isNext ? AppColors.nextPrayer : null,
      child: ListTile(
        leading: Icon(
          _icon,
          color: isNext ? AppColors.primary : AppColors.textSecondary,
          size: 28,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            color: isNext ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        trailing: Text(
          DateFormat.jm().format(time),
          style: TextStyle(
            fontSize: 16,
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            color: isNext ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
