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
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            label: 'Day Streak',
            value: '${stats.currentStreak}d',
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.accentOrange,
            bgGlow: AppColors.accentOrange.withAlpha(20),
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        Expanded(
          child: _buildStatItem(
            label: 'Study Time',
            value: _formatMinutes(stats.totalStudyMinutes),
            icon: Icons.hourglass_bottom_rounded,
            iconColor: AppColors.accentCyan,
            bgGlow: AppColors.accentCyan.withAlpha(20),
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        Expanded(
          child: _buildStatItem(
            label: 'Completed',
            value: '${stats.completedLessons}',
            icon: Icons.task_alt_rounded,
            iconColor: AppColors.primary,
            bgGlow: AppColors.primary.withAlpha(20),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space14,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppDimensions.radiusMd,
        border: Border.all(color: AppColors.darkBorder),
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
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryDark,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
