import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class CareerPathItem {
  final String title;
  final String description;
  final String roadmapSequence;
  final String duration;
  final int skillCount;
  final String difficulty;
  final double progress;
  final Color accentColor;
  final IconData icon;
  final String targetMonthId;

  const CareerPathItem({
    required this.title,
    required this.description,
    required this.roadmapSequence,
    required this.duration,
    required this.skillCount,
    required this.difficulty,
    required this.progress,
    required this.accentColor,
    required this.icon,
    required this.targetMonthId,
  });
}

class LearningPathCard extends StatelessWidget {
  final CareerPathItem path;
  final VoidCallback onSelect;

  const LearningPathCard({
    super.key,
    required this.path,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: AppDimensions.space16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppDimensions.radiusLg,
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(40)
                : Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppDimensions.radiusLg,
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with Icon and Difficulty Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: path.accentColor.withAlpha(25),
                        borderRadius: AppDimensions.radiusMd,
                      ),
                      child: Icon(
                        path.icon,
                        color: path.accentColor,
                        size: 22,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space10,
                        vertical: AppDimensions.space4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBorderSubtle
                            : AppColors.lightBorder,
                        borderRadius: AppDimensions.radiusPill,
                      ),
                      child: Text(
                        path.difficulty,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space12),

                // Career Title
                Text(
                  path.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  path.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppDimensions.space10),

                // Skill Sequence Road
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space10,
                    vertical: AppDimensions.space6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : const Color(0xFFF1F5F9),
                    borderRadius: AppDimensions.radiusSm,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.alt_route_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          path.roadmapSequence,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Metadata: Duration & Skills
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 13, color: subtitleColor),
                    const SizedBox(width: 4),
                    Text(
                      path.duration,
                      style: TextStyle(fontSize: 11, color: subtitleColor),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.bolt_rounded, size: 14, color: path.accentColor),
                    const SizedBox(width: 4),
                    Text(
                      '${path.skillCount} Skills',
                      style: TextStyle(fontSize: 11, color: subtitleColor),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space10),

                // Progress Bar
                ClipRRect(
                  borderRadius: AppDimensions.radiusPill,
                  child: LinearProgressIndicator(
                    value: (path.progress / 100.0).clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(path.accentColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
