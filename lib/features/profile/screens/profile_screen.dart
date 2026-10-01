import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/app_providers.dart';
import '../../common/widgets/section_header.dart';

class AchievementBadge {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;

  const AchievementBadge({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlocked,
  });
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  List<AchievementBadge> _getAchievements(
      int completedLessons, int streak, int completedProjects) {
    return [
      AchievementBadge(
        title: 'First Lesson',
        description: 'Completed your first study topic',
        icon: Icons.emoji_events_rounded,
        color: AppColors.primary,
        unlocked: completedLessons >= 1,
      ),
      AchievementBadge(
        title: '7-Day Streak',
        description: 'Studied consistently for 7 days',
        icon: Icons.local_fire_department_rounded,
        color: AppColors.accentOrange,
        unlocked: streak >= 7,
      ),
      AchievementBadge(
        title: 'First Project',
        description: 'Shipped a real portfolio application',
        icon: Icons.rocket_launch_rounded,
        color: AppColors.accentCyan,
        unlocked: completedProjects >= 1,
      ),
      AchievementBadge(
        title: 'Python Completed',
        description: 'Finished all Month 1 fundamentals',
        icon: Icons.code_rounded,
        color: AppColors.secondary,
        unlocked: completedLessons >= 25,
      ),
      AchievementBadge(
        title: 'First Portfolio',
        description: 'Built personal developer website',
        icon: Icons.laptop_chromebook_rounded,
        color: AppColors.accentEmerald,
        unlocked: completedProjects >= 2,
      ),
      AchievementBadge(
        title: '100 Lessons',
        description: 'Century milestone of knowledge',
        icon: Icons.military_tech_rounded,
        color: AppColors.accentAmber,
        unlocked: completedLessons >= 100,
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final stats = ref.watch(appStatsProvider);
    final streak = stats.currentStreak;
    final projects = ref.watch(projectsProvider);
    final completedProjects = projects.where((p) => p.isCompleted).length;

    final achievements = _getAchievements(
      stats.completedLessons,
      streak,
      completedProjects,
    );

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space20,
            vertical: AppDimensions.space16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/settings'),
                    icon: Icon(
                      Icons.settings_outlined,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),

              // Learner Header Card
              Container(
                padding: const EdgeInsets.all(AppDimensions.space20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppDimensions.radiusLg,
                  border: Border.all(color: borderColor),
                  gradient: isDark ? AppColors.cardGradient : null,
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'D',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space16),

                    // Name and Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name.isNotEmpty ? user.name : 'Learner',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Full Stack Software Aspirant',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: AppDimensions.radiusPill,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  size: 14,
                                  color: AppColors.accentOrange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$streak Day Streak',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Learning Statistics Row
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.space16,
                  horizontal: AppDimensions.space8,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppDimensions.radiusMd,
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol(
                      '${stats.totalStudyMinutes ~/ 60}h',
                      'Study Time',
                      AppColors.primary,
                      textPrimary,
                      textSecondary,
                    ),
                    Container(width: 1, height: 32, color: borderColor),
                    _buildStatCol(
                      '${stats.completedLessons}',
                      'Lessons Done',
                      AppColors.accentCyan,
                      textPrimary,
                      textSecondary,
                    ),
                    Container(width: 1, height: 32, color: borderColor),
                    _buildStatCol(
                      '$completedProjects',
                      'Projects Built',
                      AppColors.secondary,
                      textPrimary,
                      textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              // Learning Hub Quick Links
              SectionHeader(
                title: 'Learning Hub',
                subtitle: 'Practice drills, focus timer, and portfolio projects',
              ),
              const SizedBox(height: AppDimensions.space8),
              _buildHubTile(
                context,
                icon: Icons.quiz_outlined,
                title: 'Practice Hub',
                subtitle: 'Daily technical drills & interactive quizzes',
                route: '/practice',
                color: AppColors.primary,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              _buildHubTile(
                context,
                icon: Icons.laptop_chromebook_rounded,
                title: 'Portfolio Projects',
                subtitle: '6 production projects with milestone tracking',
                route: '/projects',
                color: AppColors.accentCyan,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              _buildHubTile(
                context,
                icon: Icons.timer_outlined,
                title: 'Study Focus Timer',
                subtitle: 'Deep work sessions with custom durations',
                route: '/study-session',
                color: AppColors.secondary,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              _buildHubTile(
                context,
                icon: Icons.edit_note_rounded,
                title: 'Study Notes & Code Snippets',
                subtitle: 'Personal notes saved across lessons',
                route: '/notes',
                color: AppColors.accentAmber,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              _buildHubTile(
                context,
                icon: Icons.auto_stories_outlined,
                title: 'Curated Resources',
                subtitle: 'Documentation, cheat sheets & courses',
                route: '/resources',
                color: AppColors.accentEmerald,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: AppDimensions.space24),

              // Professional Achievements
              SectionHeader(
                title: 'Achievements',
                subtitle: 'Milestones earned through consistent study',
              ),
              const SizedBox(height: AppDimensions.space8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                ),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final badge = achievements[index];
                  return Container(
                    padding: const EdgeInsets.all(AppDimensions.space12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: AppDimensions.radiusMd,
                      border: Border.all(
                        color: badge.unlocked
                            ? badge.color.withAlpha(80)
                            : borderColor,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: badge.unlocked
                                    ? badge.color.withAlpha(25)
                                    : Colors.grey.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                badge.icon,
                                color: badge.unlocked
                                    ? badge.color
                                    : Colors.grey,
                                size: 18,
                              ),
                            ),
                            const Spacer(),
                            if (badge.unlocked)
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: AppColors.success,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          badge.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: badge.unlocked ? textPrimary : Colors.grey,
                          ),
                        ),
                        Text(
                          badge.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.space24),

              // Settings Action
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppDimensions.radiusMd,
                  border: Border.all(color: borderColor),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.settings_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    'Settings & Data Management',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Theme mode, study reminders, JSON backup & restore',
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings'),
                ),
              ),
              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(
    String value,
    String label,
    Color color,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHubTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required Color color,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppDimensions.radiusMd,
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space14,
          vertical: 2,
        ),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: AppDimensions.radiusSm,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: () => context.push(route),
      ),
    );
  }
}
