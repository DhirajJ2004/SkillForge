import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/app_providers.dart';
import '../widgets/interactive_roadmap_tree.dart';
import '../widgets/month_accordion.dart';

class RoadmapScreen extends ConsumerStatefulWidget {
  const RoadmapScreen({super.key});

  @override
  ConsumerState<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends ConsumerState<RoadmapScreen> {
  int _selectedView = 0; // 0: Interactive Path, 1: Modules Accordion

  @override
  Widget build(BuildContext context) {
    final curriculum = ref.watch(curriculumProvider);
    final stats = ref.watch(appStatsProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('SkillForge Career Roadmap'),
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
              margin: const EdgeInsets.only(bottom: AppDimensions.space16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: AppDimensions.radiusLg,
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Full Stack & AI Engineer Roadmap',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${stats.completedLessons} of ${stats.totalLessons} lessons mastered (${stats.overallProgress.toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
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

            // View Selector Tabs (Interactive Path vs Detailed Modules)
            Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.space20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: AppDimensions.radiusPill,
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedView = 0),
                      borderRadius: AppDimensions.radiusPill,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedView == 0
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: AppDimensions.radiusPill,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.alt_route_rounded,
                              size: 16,
                              color: _selectedView == 0
                                  ? Colors.white
                                  : textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Visual Path',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _selectedView == 0
                                    ? Colors.white
                                    : textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedView = 1),
                      borderRadius: AppDimensions.radiusPill,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedView == 1
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: AppDimensions.radiusPill,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.view_agenda_outlined,
                              size: 16,
                              color: _selectedView == 1
                                  ? Colors.white
                                  : textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Detailed Modules',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _selectedView == 1
                                    ? Colors.white
                                    : textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content based on view
            if (_selectedView == 0)
              InteractiveRoadmapTree(curriculum: curriculum)
            else
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
