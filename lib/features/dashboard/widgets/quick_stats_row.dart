import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../data/models/app_stats.dart';

class QuickStatsRow extends StatelessWidget {
  final AppStats stats;

  const QuickStatsRow({
    super.key,
    required this.stats,
  });

  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes m';
    }
    final hours = (minutes / 60).toStringAsFixed(1);
    return '${hours}h';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            label: 'Day Streak',
            value: '${stats.currentStreak}d',
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.accentOrange,
            bgGlow: AppColors.accentOrange.withAlpha(25),
            cardBg: cardBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        Expanded(
          child: _buildStatItem(
            label: 'Study Time',
            value: _formatMinutes(stats.totalStudyMinutes),
            icon: Icons.hourglass_bottom_rounded,
            iconColor: AppColors.accentCyan,
            bgGlow: AppColors.accentCyan.withAlpha(25),
            cardBg: cardBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        Expanded(
          child: _buildStatItem(
            label: 'Completed',
            value: '${stats.completedLessons}',
            icon: Icons.task_alt_rounded,
            iconColor: AppColors.primary,
            bgGlow: AppColors.primary.withAlpha(25),
            cardBg: cardBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgGlow,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space14,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppDimensions.radiusMd,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bgGlow,
                  borderRadius: AppDimensions.radiusSm,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
