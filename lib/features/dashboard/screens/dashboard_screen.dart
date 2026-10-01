import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/roadmap_models.dart';
import '../../../providers/app_providers.dart';
import '../../common/widgets/course_card.dart';
import '../../common/widgets/hero_continue_card.dart';
import '../../common/widgets/section_header.dart';
import '../widgets/greeting_header.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final focusLesson = ref.watch(currentFocusLessonProvider);
    final curriculum = ref.watch(curriculumProvider);
    final stats = ref.watch(appStatsProvider);

    // Find current active month
    Month? currentMonth;
    if (focusLesson != null) {
      for (final m in curriculum) {
        if (m.topics.any((t) => t.lessons.any((l) => l.id == focusLesson.id))) {
          currentMonth = m;
          break;
        }
      }
    }
    currentMonth ??= curriculum.isNotEmpty ? curriculum.first : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.read(curriculumProvider.notifier).refresh();
            ref.read(projectsProvider.notifier).refresh();
            ref.read(studySessionsProvider.notifier).refresh();
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space20,
              vertical: AppDimensions.space16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header
                GreetingHeader(user: user),
                const SizedBox(height: AppDimensions.space18),

                // 2. Hero "Continue Learning" Card
                HeroContinueCard(
                  focusLesson: focusLesson,
                  currentMonth: currentMonth,
                  progress: currentMonth?.progressPercentage ?? stats.overallProgress,
                ),
                const SizedBox(height: AppDimensions.space20),

                // 3. Quick Action Hub Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickPill(
                        context,
                        icon: Icons.quiz_outlined,
                        label: 'Practice Hub',
                        color: AppColors.primary,
                        route: '/practice',
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                      ),
                      const SizedBox(width: 10),
                      _buildQuickPill(
                        context,
                        icon: Icons.laptop_chromebook_rounded,
                        label: 'Real Projects',
                        color: AppColors.accentCyan,
                        route: '/projects',
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                      ),
                      const SizedBox(width: 10),
                      _buildQuickPill(
                        context,
                        icon: Icons.timer_outlined,
                        label: 'Focus Timer',
                        color: AppColors.secondary,
                        route: '/study-session',
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                      ),
                      const SizedBox(width: 10),
                      _buildQuickPill(
                        context,
                        icon: Icons.edit_note_rounded,
                        label: 'Study Notes',
                        color: AppColors.accentAmber,
                        route: '/notes',
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),

                // 4. "Your Learning Path" (6-Month Curriculum)
                SectionHeader(
                  title: 'Your Learning Path',
                  subtitle: '6-Month professional journey from fundamentals to job readiness',
                  actionText: 'View All',
                  onAction: () => context.go('/learn'),
                ),
                const SizedBox(height: AppDimensions.space8),

                ...curriculum.map((month) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.space16),
                    child: CourseCard(month: month),
                  );
                }),

                const SizedBox(height: AppDimensions.space16),

                // 5. Career Track Banner
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppDimensions.radiusLg,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(50),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CAREER MILESTONE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Job Ready Software Engineer',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Complete lessons, solve practice drills, and ship your 6 portfolio projects.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => context.go('/progress'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppDimensions.radiusSm,
                                ),
                              ),
                              child: const Text(
                                'Track Career Readiness →',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required String route,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: AppDimensions.radiusPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppDimensions.radiusPill,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
