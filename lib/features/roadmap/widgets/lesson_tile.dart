import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../data/models/roadmap_models.dart';
import '../../../../providers/app_providers.dart';

class LessonTile extends ConsumerWidget {
  final Lesson lesson;

  const LessonTile({
    super.key,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        context.push('/lesson/${lesson.id}');
      },
      borderRadius: AppDimensions.radiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space12,
          vertical: AppDimensions.space10,
        ),
        margin: const EdgeInsets.only(bottom: AppDimensions.space6),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: AppDimensions.radiusMd,
          border: Border.all(
            color: lesson.completed
                ? AppColors.primary.withAlpha(60)
                : AppColors.darkBorderSubtle,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                lesson.completed
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: lesson.completed
                    ? AppColors.primary
                    : AppColors.textTertiaryDark,
                size: 22,
              ),
              onPressed: () {
                ref
                    .read(curriculumProvider.notifier)
                    .toggleLesson(lesson.id, !lesson.completed);
              },
            ),
            const SizedBox(width: AppDimensions.space12),

            // Lesson Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: lesson.completed
                          ? AppColors.textTertiaryDark
                          : AppColors.textPrimaryDark,
                      decoration:
                          lesson.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${lesson.estimatedMinutes} min',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiaryDark,
                        ),
                      ),
                      if (lesson.resources.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${lesson.resources.length} resources',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiaryDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Study Timer trigger or forward arrow
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiaryDark, size: 20),
              onPressed: () => context.push('/lesson/${lesson.id}'),
            ),
          ],
        ),
      ),
    );
  }
}
