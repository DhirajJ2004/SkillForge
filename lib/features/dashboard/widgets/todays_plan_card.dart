import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../data/models/roadmap_models.dart';
import '../../../../providers/app_providers.dart';

class TodaysPlanCard extends ConsumerWidget {
  final List<Lesson> plan;

  const TodaysPlanCard({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCompleted = plan.isEmpty || plan.every((l) => l.completed);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final surfaceBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textTertiary =
        isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppDimensions.radiusLg,
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(AppDimensions.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.today_rounded,
                      color: AppColors.primaryLight, size: 20),
                  const SizedBox(width: AppDimensions.space8),
                  Text(
                    'TODAY\'S PLAN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              if (allCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGlow,
                    borderRadius: AppDimensions.radiusSm,
                  ),
                  child: const Text(
                    'Goal Met 🎉',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          if (allCompleted) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: BoxDecoration(
                color: surfaceBg,
                borderRadius: AppDimensions.radiusMd,
                border: Border.all(color: AppColors.primaryLight.withAlpha(60)),
              ),
              child: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s goal completed!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Great consistency! Keep up the momentum or explore additional topics.',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: plan.length,
              separatorBuilder: (context, index) =>
                  Divider(color: borderColor, height: 16),
              itemBuilder: (context, index) {
                final lesson = plan[index];
                return Row(
                  children: [
                    // Checkbox
                    IconButton(
                      icon: Icon(
                        lesson.completed
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: lesson.completed
                            ? AppColors.primary
                            : textTertiary,
                        size: 22,
                      ),
                      onPressed: () {
                        ref
                            .read(curriculumProvider.notifier)
                            .toggleLesson(lesson.id, !lesson.completed);
                      },
                      tooltip: lesson.completed
                          ? 'Mark incomplete'
                          : 'Mark complete',
                    ),
                    const SizedBox(width: AppDimensions.space8),

                    // Lesson Info
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/lesson/${lesson.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: lesson.completed
                                    ? textTertiary
                                    : textPrimary,
                                decoration: lesson.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${lesson.estimatedMinutes} min',
                              style: TextStyle(
                                fontSize: 12,
                                color: textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Start study session button
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.darkSurface,
                        foregroundColor: AppColors.primaryLight,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppDimensions.radiusSm,
                          side: BorderSide(color: AppColors.darkBorder),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 16),
                      label: const Text(
                        'Start',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        context.push(
                          '/study-session?lessonId=${lesson.id}&title=${Uri.encodeComponent(lesson.title)}&duration=${lesson.estimatedMinutes}',
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
