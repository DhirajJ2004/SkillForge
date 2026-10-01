import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('More Hub'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space20,
            vertical: AppDimensions.space16,
          ),
          children: [
            _buildMenuItem(
              context: context,
              icon: Icons.auto_stories_rounded,
              title: 'Learning Resources',
              subtitle: 'Documentation, YouTube courses, and practice platforms',
              route: '/resources',
              color: AppColors.primary,
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.laptop_chromebook_rounded,
              title: 'Portfolio Projects',
              subtitle: '6 production projects with automated task tracking',
              route: '/projects',
              color: AppColors.accentCyan,
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.edit_note_rounded,
              title: 'Study Notes',
              subtitle: 'Personal code snippets, architecture rules, and notes',
              route: '/notes',
              color: AppColors.accentAmber,
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.tune_rounded,
              title: 'Settings & Data Backup',
              subtitle: 'Study alarms, JSON export/import, and profile',
              route: '/settings',
              color: AppColors.accentPurple,
            ),
            const SizedBox(height: AppDimensions.space24),

            // Quick App Info
            Container(
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: AppDimensions.radiusLg,
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.terminal_rounded,
                          color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'SkillForge • Tech Skills Platform',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Built for offline focus and practical skill mastery.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppDimensions.radiusMd,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space6,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: AppDimensions.radiusSm,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryDark,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textTertiaryDark,
        ),
        onTap: () => context.push(route),
      ),
    );
  }
}
