import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CompassPainter extends CustomPainter {
  final double heading; // device heading in degrees
  final double qiblaBearing; // qibla bearing from true north

  CompassPainter({required this.heading, required this.qiblaBearing});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw compass circle
    final circlePaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    final borderPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw tick marks
    final tickPaint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 1.5;

    for (int i = 0; i < 360; i += 15) {
      final angle = (i - heading) * pi / 180;
      final isCardinal = i % 90 == 0;
      final tickLength = isCardinal ? 20.0 : 10.0;
      final outerPoint = Offset(
        center.dx + radius * cos(angle - pi / 2),
        center.dy + radius * sin(angle - pi / 2),
      );
      final innerPoint = Offset(
        center.dx + (radius - tickLength) * cos(angle - pi / 2),
        center.dy + (radius - tickLength) * sin(angle - pi / 2),
      );
      canvas.drawLine(outerPoint, innerPoint, tickPaint);
    }

    // Draw cardinal labels
    final cardinals = {'N': 0, 'E': 90, 'S': 180, 'W': 270};
    for (final entry in cardinals.entries) {
      final angle = (entry.value - heading) * pi / 180 - pi / 2;
      final labelRadius = radius - 35;
      final offset = Offset(
        center.dx + labelRadius * cos(angle),
        center.dy + labelRadius * sin(angle),
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: entry.key,
          style: TextStyle(
            color: entry.key == 'N' ? AppColors.error : AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        offset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Draw Qibla indicator (green triangle)
    final qiblaAngle = (qiblaBearing - heading) * pi / 180 - pi / 2;
    final qiblaPoint = Offset(
      center.dx + (radius - 5) * cos(qiblaAngle),
      center.dy + (radius - 5) * sin(qiblaAngle),
    );
    final qiblaPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    final arrowSize = 14.0;
    path.moveTo(qiblaPoint.dx, qiblaPoint.dy);
    path.lineTo(
      qiblaPoint.dx - arrowSize * cos(qiblaAngle + 0.3),
      qiblaPoint.dy - arrowSize * sin(qiblaAngle + 0.3),
    );
    path.lineTo(
      qiblaPoint.dx - arrowSize * cos(qiblaAngle - 0.3),
      qiblaPoint.dy - arrowSize * sin(qiblaAngle - 0.3),
    );
    path.close();
    canvas.drawPath(path, qiblaPaint);

    // Draw Kaaba icon in center
    final kaabaPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 20, height: 20),
      kaabaPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) {
    return oldDelegate.heading != heading ||
        oldDelegate.qiblaBearing != qiblaBearing;
  }
}
