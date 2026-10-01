import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../data/models/app_stats.dart';

class PaceIndicator extends StatelessWidget {
  final AppStats stats;

  const PaceIndicator({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final isAhead = stats.isAheadOfPace;
    final paceColor = isAhead ? AppColors.primary : AppColors.accentCyan;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: AppDimensions.radiusMd,
        border: Border.all(color: paceColor.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(
            isAhead ? Icons.trending_up_rounded : Icons.track_changes_rounded,
            color: paceColor,
            size: 20,
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pace • ${stats.overallProgress.toStringAsFixed(0)}% Actual vs ${stats.expectedProgress.toStringAsFixed(0)}% Target',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: paceColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  stats.paceMessage,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
