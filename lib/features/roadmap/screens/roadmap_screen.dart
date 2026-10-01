import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/app_providers.dart';
import '../widgets/month_accordion.dart';

class RoadmapScreen extends ConsumerWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curriculum = ref.watch(curriculumProvider);
    final stats = ref.watch(appStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Developer Roadmap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
            tooltip: 'Search Curriculum',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space20,
            vertical: AppDimensions.space12,
          ),
          children: [
            // Top Summary Card
            Container(
              padding: const EdgeInsets.all(AppDimensions.space16),
              margin: const EdgeInsets.only(bottom: AppDimensions.space20),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: AppDimensions.radiusMd,
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '6-Month IT Career Curriculum',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${stats.completedLessons} of ${stats.totalLessons} lessons marked complete',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGlow,
                      borderRadius: AppDimensions.radiusSm,
                    ),
                    child: Text(
                      '${stats.overallProgress.toStringAsFixed(0)}% Done',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 6 Months Accordions
            ...curriculum.map((month) {
              return MonthAccordion(
                month: month,
                initialExpanded: month.monthNumber == 1,
              );
            }),

            const SizedBox(height: AppDimensions.space32),
          ],
        ),
      ),
    );
  }
}
