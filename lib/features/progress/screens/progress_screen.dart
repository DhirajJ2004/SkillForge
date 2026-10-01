import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/app_providers.dart';
import '../../common/widgets/section_header.dart';
import '../widgets/activity_calendar.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  String _formatHours(int totalMinutes) {
    if (totalMinutes < 60) return '$totalMinutes min';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(appStatsProvider);
    final streak = stats.currentStreak;
    final curriculum = ref.watch(curriculumProvider);
    final projects = ref.watch(projectsProvider);
    final sessionRepo = ref.watch(studySessionRepositoryProvider);
    final activityMap = sessionRepo.getActivityMap();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    // Derived skill percentages from curriculum
    double getMonthProgress(int monthNum) {
      if (curriculum.length >= monthNum) {
        return curriculum[monthNum - 1].progressPercentage;
      }
      return 0.0;
    }

    final pythonProgress = getMonthProgress(1);
    final webProgress = getMonthProgress(2);
    final backendProgress = getMonthProgress(3);
    final aiProgress = getMonthProgress(4);
    final cloudProgress = getMonthProgress(5);
    final dsaProgress = getMonthProgress(6);

    final completedProjects = projects.where((p) => p.isCompleted).length;
    final projectProgress = projects.isNotEmpty
        ? (completedProjects / projects.length * 100).clamp(0.0, 100.0)
        : 0.0;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space20,
            vertical: AppDimensions.space16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Measure your growth, study activity, and job readiness.',
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Hero Overall Progress Card
              Container(
                padding: const EdgeInsets.all(AppDimensions.space20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppDimensions.radiusLg,
                  border: Border.all(color: borderColor),
                  gradient: isDark ? AppColors.cardGradient : null,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withAlpha(50)
                          : Colors.black.withAlpha(10),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Large Circular Progress Ring
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: (stats.overallProgress / 100.0).clamp(0.0, 1.0),
                            strokeWidth: 9,
                            backgroundColor: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                          Text(
                            '${stats.overallProgress.toInt()}%',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space20),

                    // Progress Status Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: AppDimensions.radiusPill,
                            ),
                            child: const Text(
                              'OVERALL COMPLETION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            stats.overallProgress > 0
                                ? "You're building momentum."
                                : "Begin your learning path.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${stats.completedLessons} of ${stats.totalLessons} lessons finished across all 6 curriculum modules.',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Study Time & Current Streak Cards Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: AppDimensions.radiusMd,
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded,
                                  size: 16, color: textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                'This Week',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatHours(stats.weeklyStudyMinutes),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatHours(stats.totalStudyMinutes)} total',
                            style: TextStyle(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: AppDimensions.radiusMd,
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department_rounded,
                                size: 16,
                                color: AppColors.accentOrange,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Current Streak',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$streak ${streak == 1 ? 'Day' : 'Days'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentOrange,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Keep daily momentum',
                            style: TextStyle(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space20),

              // GitHub-Style Learning Activity Calendar
              ActivityCalendar(activityMap: activityMap),
              const SizedBox(height: AppDimensions.space24),

              // Career Readiness Section
              SectionHeader(
                title: 'Career Readiness',
                subtitle: 'Your evaluation toward job readiness across core software domains',
              ),
              const SizedBox(height: AppDimensions.space8),
              Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppDimensions.radiusLg,
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildReadinessRow(
                      'Core Programming (Python)',
                      pythonProgress,
                      textPrimary,
                      textSecondary,
                    ),
                    const Divider(height: 16),
                    _buildReadinessRow(
                      'Web Development & Frontend',
                      webProgress,
                      textPrimary,
                      textSecondary,
                    ),
                    const Divider(height: 16),
                    _buildReadinessRow(
                      'Backend & APIs (FastAPI, SQL)',
                      backendProgress,
                      textPrimary,
                      textSecondary,
                    ),
                    const Divider(height: 16),
                    _buildReadinessRow(
                      'AI Engineering & RAG',
                      aiProgress,
                      textPrimary,
                      textSecondary,
                    ),
                    const Divider(height: 16),
                    _buildReadinessRow(
                      'Cloud & DevOps (Docker, AWS)',
                      cloudProgress,
                      textPrimary,
                      textSecondary,
                    ),
                    const Divider(height: 16),
                    _buildReadinessRow(
                      'Real Portfolio Projects',
                      projectProgress,
                      textPrimary,
                      textSecondary,
                    ),
                    const Divider(height: 16),
                    _buildReadinessRow(
                      'Data Structures & Algorithms',
                      dsaProgress,
                      textPrimary,
                      textSecondary,
                    ),
                    const Divider(height: 16),
                    _buildReadinessRow(
                      'Technical Interview Prep',
                      dsaProgress > 50 ? (dsaProgress - 20) : 0.0,
                      textPrimary,
                      textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              // Skills Developed Progress Bars
              SectionHeader(
                title: 'Skills Developed',
                subtitle: 'Practical mastery by engineering discipline',
              ),
              const SizedBox(height: AppDimensions.space8),
              Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppDimensions.radiusLg,
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildSkillBar(
                      'Python & OOP',
                      pythonProgress,
                      AppColors.primary,
                      textPrimary,
                      textSecondary,
                      isDark,
                    ),
                    const SizedBox(height: 14),
                    _buildSkillBar(
                      'SQL & Databases',
                      (pythonProgress * 0.4 + backendProgress * 0.6),
                      AppColors.accentCyan,
                      textPrimary,
                      textSecondary,
                      isDark,
                    ),
                    const SizedBox(height: 14),
                    _buildSkillBar(
                      'JavaScript & React',
                      webProgress,
                      AppColors.secondary,
                      textPrimary,
                      textSecondary,
                      isDark,
                    ),
                    const SizedBox(height: 14),
                    _buildSkillBar(
                      'FastAPI & Backend',
                      backendProgress,
                      AppColors.accentEmerald,
                      textPrimary,
                      textSecondary,
                      isDark,
                    ),
                    const SizedBox(height: 14),
                    _buildSkillBar(
                      'Docker & AWS Cloud',
                      cloudProgress,
                      AppColors.accentOrange,
                      textPrimary,
                      textSecondary,
                      isDark,
                    ),
                    const SizedBox(height: 14),
                    _buildSkillBar(
                      'DSA & Algorithms',
                      dsaProgress,
                      AppColors.accentPurple,
                      textPrimary,
                      textSecondary,
                      isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadinessRow(
    String domain,
    double progress,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isDone = progress >= 100.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            domain,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
        if (isDone)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(20),
              borderRadius: AppDimensions.radiusPill,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded, color: AppColors.success, size: 14),
                SizedBox(width: 4),
                Text(
                  'Job Ready',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            '${progress.toInt()}%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: progress > 0 ? AppColors.primary : textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildSkillBar(
    String skill,
    double percentage,
    Color color,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final clamped = percentage.clamp(0.0, 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              skill,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            Text(
              '${clamped.toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: AppDimensions.radiusPill,
          child: LinearProgressIndicator(
            value: (clamped / 100.0),
            minHeight: 6,
            backgroundColor:
                isDark ? AppColors.darkBorder : AppColors.lightBorder,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
