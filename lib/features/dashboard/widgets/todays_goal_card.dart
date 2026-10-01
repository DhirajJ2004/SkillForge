import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class TodaysGoalCard extends StatelessWidget {
  final int todayMinutes;
  final int goalMinutes;

  const TodaysGoalCard({
    super.key,
    required this.todayMinutes,
    required this.goalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGoal = goalMinutes > 0 ? goalMinutes : 60;
    final progress = (todayMinutes / effectiveGoal).clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();
    final remainingMinutes = (effectiveGoal - todayMinutes).clamp(0, effectiveGoal);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final isGoalMet = todayMinutes >= effectiveGoal;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppDimensions.radiusLg,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan.withAlpha(25),
                      borderRadius: AppDimensions.radiusSm,
                    ),
                    child: const Icon(
                      Icons.track_changes_rounded,
                      size: 16,
                      color: AppColors.accentCyan,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Text(
                    'TODAY\'S GOAL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Text(
                '$todayMinutes / $effectiveGoal min ($percent%)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          ClipRRect(
            borderRadius: AppDimensions.radiusPill,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  isDark ? AppColors.darkBorder : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                isGoalMet ? AppColors.success : AppColors.accentCyan,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isGoalMet
                    ? 'Daily target reached! Awesome focus 🎉'
                    : '$remainingMinutes min remaining to complete today\'s goal',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              InkWell(
                onTap: () => context.push('/study-session'),
                borderRadius: AppDimensions.radiusSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'Focus Timer',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.chevron_right_rounded,
                          size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
