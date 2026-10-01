import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../data/models/app_stats.dart';

class OverallProgressRing extends StatelessWidget {
  final AppStats stats;

  const OverallProgressRing({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = stats.overallProgress;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space20,
        vertical: AppDimensions.space24,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppDimensions.radiusLg,
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Widget
          SizedBox(
            width: 110,
            height: 110,
            child: CustomPaint(
              painter: _RingProgressPainter(
                progress: (percentage / 100.0).clamp(0.0, 1.0),
                strokeWidth: 10.0,
                trackColor: AppColors.darkBorder,
                progressGradient: AppColors.primaryGradient,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimaryDark,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const Text(
                      'DONE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.space20),

          // Progress details & description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryDark,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  '${stats.completedLessons} of ${stats.totalLessons} total lessons completed',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryDark,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppDimensions.space12),
                Row(
                  children: [
                    _buildMiniBadge(
                      icon: Icons.checklist_rounded,
                      label: '${stats.remainingLessons} left',
                      color: AppColors.accentCyan,
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    _buildMiniBadge(
                      icon: Icons.assignment_turned_in_rounded,
                      label: '${stats.completedProjects}/${stats.totalProjects} Projs',
                      color: AppColors.accentPurple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: AppDimensions.radiusSm,
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Gradient progressGradient;

  _RingProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final progressPaint = Paint()
        ..shader = progressGradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
