import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../data/models/roadmap_models.dart';
import '../../common/widgets/progress_bar.dart';
import 'lesson_tile.dart';

class MonthAccordion extends StatefulWidget {
  final Month month;
  final bool initialExpanded;

  const MonthAccordion({
    super.key,
    required this.month,
    this.initialExpanded = false,
  });

  @override
  State<MonthAccordion> createState() => _MonthAccordionState();
}

class _MonthAccordionState extends State<MonthAccordion> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final month = widget.month;
    final progress = month.progressPercentage;
    final isDone = progress >= 100.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppDimensions.radiusLg,
        border: Border.all(
          color: isDone
              ? AppColors.primary.withAlpha(80)
              : AppColors.darkBorder,
        ),
      ),
      child: Column(
        children: [
          // Month Header Card
          InkWell(
            onTap: () {
              setState(() => _expanded = !_expanded);
            },
            borderRadius: AppDimensions.radiusLg,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Month Number Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDone
                              ? AppColors.primary
                              : AppColors.darkSurface,
                          borderRadius: AppDimensions.radiusSm,
                          border: Border.all(
                            color: isDone
                                ? AppColors.primary
                                : AppColors.darkBorder,
                          ),
                        ),
                        child: Text(
                          'MONTH ${month.monthNumber}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isDone
                                ? Colors.black
                                : AppColors.primaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space10),
                      Expanded(
                        child: Text(
                          month.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondaryDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space6),
                  Text(
                    month.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomProgressBar(
                          percentage: progress,
                          height: 6,
                          color: isDone
                              ? AppColors.primary
                              : AppColors.accentCyan,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Text(
                        '${month.completedLessonsCount}/${month.totalLessonsCount} (${progress.toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDone
                              ? AppColors.primary
                              : AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Topics & Lessons List
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(
                left: AppDimensions.space16,
                right: AppDimensions.space16,
                bottom: AppDimensions.space16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.darkBorderSubtle),
                  const SizedBox(height: AppDimensions.space8),
                  ...month.topics.map((topic) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.space12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Topic Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppDimensions.space6,
                              horizontal: AppDimensions.space4,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    topic.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryLight,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${topic.completedLessonsCount}/${topic.lessons.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...topic.lessons.map((lesson) {
                            return LessonTile(lesson: lesson);
                          }),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
