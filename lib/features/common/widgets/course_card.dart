import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/roadmap_models.dart';

class CourseCard extends StatelessWidget {
  final Month month;
  final bool isFeatured;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.month,
    this.isFeatured = false,
    this.onTap,
  });

  IconData _getMonthIcon(int monthNum) {
    switch (monthNum) {
      case 1:
        return Icons.code_rounded;
      case 2:
        return Icons.web_rounded;
      case 3:
        return Icons.dns_rounded;
      case 4:
        return Icons.psychology_rounded;
      case 5:
        return Icons.cloud_done_rounded;
      case 6:
        return Icons.terminal_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  LinearGradient _getMonthGradient(int monthNum) {
    switch (monthNum) {
      case 1:
        return const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 2:
        return const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 3:
        return const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 4:
        return const LinearGradient(
          colors: [Color(0xFF9333EA), Color(0xFFC026D3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 5:
        return const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 6:
        return const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppColors.primaryGradient;
    }
  }

  String _getDifficulty(int monthNum) {
    if (monthNum <= 2) return 'Beginner';
    if (monthNum <= 4) return 'Intermediate';
    return 'Advanced';
  }

  int _getEstimatedHours(int monthNum) {
    switch (monthNum) {
      case 1:
        return 18;
      case 2:
        return 24;
      case 3:
        return 30;
      case 4:
        return 28;
      case 5:
        return 22;
      case 6:
        return 32;
      default:
        return 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final descColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final metaColor =
        isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    final progress = month.progressPercentage;
    final isStarted = progress > 0;
    final isCompleted = progress >= 100.0;
    final totalLessons = month.totalLessonsCount;
    final completedLessons = month.completedLessonsCount;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppDimensions.radiusLg,
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(50)
                : Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppDimensions.radiusLg,
          onTap: onTap ?? () => context.push('/course/${month.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Thumbnail Banner
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: _getMonthGradient(month.monthNumber),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusLarge),
                    topRight: Radius.circular(AppDimensions.radiusLarge),
                  ),
                ),
                padding: const EdgeInsets.all(AppDimensions.space16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space10,
                        vertical: AppDimensions.space4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(70),
                        borderRadius: AppDimensions.radiusPill,
                      ),
                      child: Text(
                        'Month ${month.monthNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getMonthIcon(month.monthNumber),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Course Content Details
              Padding(
                padding: const EdgeInsets.all(AppDimensions.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      month.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle / Description
                    Text(
                      month.subtitle.isNotEmpty
                          ? month.subtitle
                          : month.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: descColor,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // Metadata Row
                    Row(
                      children: [
                        Icon(Icons.video_library_outlined,
                            size: 14, color: metaColor),
                        const SizedBox(width: 4),
                        Text(
                          '$totalLessons Lessons',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: metaColor,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Icon(Icons.schedule_rounded,
                            size: 14, color: metaColor),
                        const SizedBox(width: 4),
                        Text(
                          '${_getEstimatedHours(month.monthNumber)}h Total',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: metaColor,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: AppDimensions.radiusPill,
                          ),
                          child: Text(
                            _getDifficulty(month.monthNumber),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // Progress or CTA
                    if (isStarted) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isCompleted
                                ? 'Completed'
                                : '$completedLessons of $totalLessons completed',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                          Text(
                            '${progress.toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isCompleted
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: AppDimensions.radiusPill,
                        child: LinearProgressIndicator(
                          value: (progress / 100.0).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton(
                          onPressed: onTap ??
                              () => context.push('/course/${month.id}'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimensions.radiusSm,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'View Curriculum',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
