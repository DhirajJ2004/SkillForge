import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../data/models/roadmap_models.dart';

class InteractiveRoadmapTree extends StatelessWidget {
  final List<Month> curriculum;

  const InteractiveRoadmapTree({
    super.key,
    required this.curriculum,
  });

  RoadmapNodeStatus _getNodeStatus(Month month, int index, List<Month> list) {
    if (month.isCompleted) return RoadmapNodeStatus.completed;
    if (month.completedLessonsCount > 0) return RoadmapNodeStatus.inProgress;
    if (index == 0) return RoadmapNodeStatus.available;
    // If the immediately prior month is completed, this month is available
    final prevMonth = list[index - 1];
    if (prevMonth.isCompleted) return RoadmapNodeStatus.available;
    return RoadmapNodeStatus.locked;
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: curriculum.length,
      itemBuilder: (context, index) {
        final month = curriculum[index];
        final status = _getNodeStatus(month, index, curriculum);
        final isLast = index == curriculum.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Node & Timeline Column
            Column(
              children: [
                _buildNodeIcon(status),
                if (!isLast)
                  Container(
                    width: 3,
                    height: 160,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTimelineColor(status),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppDimensions.space16),

            // Right Milestone Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.space20),
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppDimensions.radiusLg,
                  border: Border.all(
                    color: _getBorderColor(status, borderColor),
                    width: status == RoadmapNodeStatus.inProgress ? 1.5 : 1.0,
                  ),
                  boxShadow: status == RoadmapNodeStatus.inProgress
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(25),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge and Month Label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'STAGE ${month.monthNumber}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: textSecondary,
                          ),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Month Title
                    Text(
                      month.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      month.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Progress indicator
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: AppDimensions.radiusPill,
                            child: LinearProgressIndicator(
                              value: (month.progressPercentage / 100.0).clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgressColor(status),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${month.completedLessonsCount}/${month.totalLessonsCount}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Topic pills
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: month.topics.take(3).map((topic) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface,
                            borderRadius: AppDimensions.radiusSm,
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            topic.title,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/course/${month.id}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: status == RoadmapNodeStatus.completed
                              ? AppColors.success
                              : (status == RoadmapNodeStatus.inProgress
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkSurface : AppColors.lightSurface)),
                          foregroundColor: (status == RoadmapNodeStatus.completed ||
                                  status == RoadmapNodeStatus.inProgress)
                              ? Colors.white
                              : textPrimary,
                          elevation: 0,
                          side: BorderSide(
                            color: status == RoadmapNodeStatus.locked
                                ? borderColor
                                : (status == RoadmapNodeStatus.completed
                                    ? AppColors.success
                                    : AppColors.primary),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDimensions.radiusSm,
                          ),
                        ),
                        child: Text(
                          status == RoadmapNodeStatus.completed
                              ? 'Review Stage ✓'
                              : (status == RoadmapNodeStatus.inProgress
                                  ? 'Continue Stage →'
                                  : (status == RoadmapNodeStatus.available
                                      ? 'Start Stage'
                                      : 'Explore Modules')),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNodeIcon(RoadmapNodeStatus status) {
    switch (status) {
      case RoadmapNodeStatus.completed:
        return Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
        );
      case RoadmapNodeStatus.inProgress:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(80),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
        );
      case RoadmapNodeStatus.available:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.accentCyan.withAlpha(30),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accentCyan, width: 2),
          ),
          child: const Icon(Icons.radio_button_checked_rounded,
              color: AppColors.accentCyan, size: 20),
        );
      case RoadmapNodeStatus.locked:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.darkBorder, width: 2),
          ),
          child: const Icon(Icons.lock_outline_rounded,
              color: AppColors.textTertiaryDark, size: 18),
        );
    }
  }

  Widget _buildStatusBadge(RoadmapNodeStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case RoadmapNodeStatus.completed:
        bg = AppColors.success.withAlpha(25);
        fg = AppColors.success;
        label = 'COMPLETED';
        break;
      case RoadmapNodeStatus.inProgress:
        bg = AppColors.primary.withAlpha(25);
        fg = AppColors.primary;
        label = 'IN PROGRESS';
        break;
      case RoadmapNodeStatus.available:
        bg = AppColors.accentCyan.withAlpha(25);
        fg = AppColors.accentCyan;
        label = 'AVAILABLE';
        break;
      case RoadmapNodeStatus.locked:
        bg = AppColors.darkBorder.withAlpha(40);
        fg = AppColors.textTertiaryDark;
        label = 'LOCKED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppDimensions.radiusPill,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: fg,
        ),
      ),
    );
  }

  Color _getTimelineColor(RoadmapNodeStatus status) {
    if (status == RoadmapNodeStatus.completed) return AppColors.success;
    if (status == RoadmapNodeStatus.inProgress) return AppColors.primary;
    return AppColors.darkBorder;
  }

  Color _getBorderColor(RoadmapNodeStatus status, Color defaultBorder) {
    if (status == RoadmapNodeStatus.completed) return AppColors.success.withAlpha(90);
    if (status == RoadmapNodeStatus.inProgress) return AppColors.primary;
    return defaultBorder;
  }

  Color _getProgressColor(RoadmapNodeStatus status) {
    if (status == RoadmapNodeStatus.completed) return AppColors.success;
    if (status == RoadmapNodeStatus.inProgress) return AppColors.primary;
    return AppColors.accentCyan;
  }
}
