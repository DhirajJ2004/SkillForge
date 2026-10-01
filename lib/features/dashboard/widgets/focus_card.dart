import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../data/models/roadmap_models.dart';
import '../../common/widgets/custom_button.dart';

class FocusCard extends StatelessWidget {
  final Lesson? focusLesson;

  const FocusCard({
    super.key,
    required this.focusLesson,
  });

  @override
  Widget build(BuildContext context) {
    if (focusLesson == null) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.space20),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: AppDimensions.radiusLg,
          border: Border.all(color: AppColors.primary),
        ),
        child: const Row(
          children: [
            Icon(Icons.emoji_events_rounded,
                color: AppColors.primary, size: 28),
            SizedBox(width: AppDimensions.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Roadmap Completed!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  Text(
                    'Congratulations! You have completed all 6 months of the curriculum.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final lesson = focusLesson!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppDimensions.radiusLg,
        border: Border.all(color: AppColors.primary.withAlpha(120), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(20),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
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
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space6),
                  const Text(
                    'CURRENT FOCUS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: AppDimensions.radiusSm,
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 12, color: AppColors.textSecondaryDark),
                    const SizedBox(width: 4),
                    Text(
                      '${lesson.estimatedMinutes} min',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Text(
            lesson.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryDark,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppDimensions.space6),
          Text(
            lesson.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryDark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppDimensions.space20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Continue Learning',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    context.push('/lesson/${lesson.id}');
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.space10),
              IconButton.filledTonal(
                onPressed: () {
                  context.push(
                    '/study-session?lessonId=${lesson.id}&title=${Uri.encodeComponent(lesson.title)}&duration=${lesson.estimatedMinutes}',
                  );
                },
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryGlow,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDimensions.radiusMd,
                  ),
                ),
                icon: const Icon(Icons.timer_rounded, size: 20),
                tooltip: 'Start Focus Timer',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
