import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/app_providers.dart';
import '../../common/widgets/custom_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final themeMode = ref.watch(themeModeProvider);
    final storage = ref.watch(storageServiceProvider);
    final notifications = ref.watch(notificationServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space20,
            vertical: AppDimensions.space12,
          ),
          children: [
            // Profile & Target Section
            _buildSectionHeader('Profile & Study Target'),
            _buildCard(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryGlow,
                    child: Icon(Icons.person_rounded, color: AppColors.primary),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  subtitle: Text(
                    'Daily Goal: ${user.dailyGoalMinutes} min/day',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () => _editProfileDialog(context, ref, user),
                    child: const Text('Edit'),
                  ),
                ),
                const Divider(color: AppColors.darkBorderSubtle),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.alarm_rounded,
                      color: AppColors.accentAmber),
                  title: const Text(
                    'Study Reminder Time',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  subtitle: Text(
                    '${user.preferredStudyTimeHour.toString().padLeft(2, '0')}:${user.preferredStudyTimeMinute.toString().padLeft(2, '0')} • ${user.studyDays.length} days/week',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: user.preferredStudyTimeHour,
                          minute: user.preferredStudyTimeMinute,
                        ),
                      );
                      if (picked != null) {
                        final updated = user.copyWith(
                          preferredStudyTimeHour: picked.hour,
                          preferredStudyTimeMinute: picked.minute,
                        );
                        await ref
                            .read(userProfileProvider.notifier)
                            .updateProfile(updated);
                        await notifications.scheduleDailyReminder(
                          hour: picked.hour,
                          minute: picked.minute,
                          studyDays: user.studyDays,
                        );
                      }
                    },
                    child: const Text('Change'),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_active_rounded,
                      color: AppColors.primaryLight),
                  title: const Text(
                    'Test Reminder Alarm',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  subtitle: const Text(
                    'Send a test notification immediately',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      await notifications.requestPermissions();
                      await notifications.showStudyReminderNow(
                        currentFocusTitle: 'Python Functions',
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Test study reminder sent!')),
                        );
                      }
                    },
                    child: const Text('Test'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space20),

            // Theme Appearance
            _buildSectionHeader('Appearance'),
            _buildCard(
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      size: 20,
                      color: AppColors.accentCyan,
                    ),
                    SizedBox(width: AppDimensions.space8),
                    Text(
                      'Theme Mode',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded, size: 16),
                        label: Text('Dark'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded, size: 16),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_rounded, size: 16),
                        label: Text('Auto'),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (set) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(set.first);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space20),

            // Data Backup & Restore
            _buildSectionHeader('Data Management'),
            _buildCard(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.upload_file_rounded,
                      color: AppColors.accentCyan),
                  title: const Text(
                    'Export My Data',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  subtitle: const Text(
                    'Backup curriculum progress, sessions & notes to JSON',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textTertiaryDark),
                  onTap: () => _exportDataDialog(context, storage),
                ),
                const Divider(color: AppColors.darkBorderSubtle),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.download_rounded,
                      color: AppColors.accentPurple),
                  title: const Text(
                    'Import My Data',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  subtitle: const Text(
                    'Restore progress from a saved JSON string',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textTertiaryDark),
                  onTap: () => _importDataDialog(context, ref, storage),
                ),
                const Divider(color: AppColors.darkBorderSubtle),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.refresh_rounded,
                      color: AppColors.error),
                  title: const Text(
                    'Reset All Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  subtitle: const Text(
                    'Clear completed lessons, streaks, and reset curriculum',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textTertiaryDark),
                  onTap: () => _confirmResetDialog(context, ref, storage),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space20),

            // About DevPath
            _buildSectionHeader('About'),
            _buildCard(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SkillForge',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        Text(
                          'Learn. Build. Become Job Ready.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space12),
                const Text(
                  'SkillForge is an offline-first productivity roadmap guiding aspiring software engineers from zero to job readiness across 6 comprehensive months: Python, Web, Full Stack APIs, AI/RAG/Agents, DevOps/AWS, and DSA/Interview Prep.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryDark,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
                const Text(
                  'Version 1.0.0 (Production Release)',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiaryDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppDimensions.radiusLg,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  void _editProfileDialog(BuildContext context, WidgetRef ref, user) {
    final nameCtrl = TextEditingController(text: user.name);
    int goalMinutes = user.dailyGoalMinutes;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: AppColors.darkCard,
            shape: const RoundedRectangleBorder(
              borderRadius: AppDimensions.radiusLg,
              side: BorderSide(color: AppColors.darkBorder),
            ),
            title: const Text('Edit Profile & Goal',
                style: TextStyle(color: AppColors.textPrimaryDark)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Name',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondaryDark)),
                const SizedBox(height: 4),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppColors.textPrimaryDark),
                ),
                const SizedBox(height: 16),
                Text('Daily Target: $goalMinutes minutes',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondaryDark)),
                Slider(
                  value: goalMinutes.toDouble(),
                  min: 30,
                  max: 240,
                  divisions: 7,
                  label: '$goalMinutes min',
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => goalMinutes = val.round());
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              CustomButton(
                text: 'Save',
                onPressed: () async {
                  final updated = user.copyWith(
                    name: nameCtrl.text.trim().isEmpty
                        ? 'Developer'
                        : nameCtrl.text.trim(),
                    dailyGoalMinutes: goalMinutes,
                  );
                  await ref
                      .read(userProfileProvider.notifier)
                      .updateProfile(updated);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _exportDataDialog(BuildContext context, storage) {
    final jsonStr = storage.exportAllDataJson();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimensions.radiusLg,
          side: BorderSide(color: AppColors.darkBorder),
        ),
        title: const Text('Exported Data Backup (JSON)',
            style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          height: 250,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonStr,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy JSON'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Backup JSON copied to clipboard!')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _importDataDialog(BuildContext context, WidgetRef ref, storage) {
    final textCtrl = TextEditingController();
    bool isImporting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.darkCard,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusLg,
            side: BorderSide(color: AppColors.darkBorder),
          ),
          title: const Text('Import Backup JSON',
              style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste your exported DevPath JSON data below. This will replace current local progress.',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondaryDark),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textCtrl,
                enabled: !isImporting,
                maxLines: 6,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: AppColors.textPrimaryDark),
                decoration: const InputDecoration(
                  hintText: 'Paste JSON here...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isImporting ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isImporting
                  ? null
                  : () async {
                      final text = textCtrl.text.trim();
                      if (text.isEmpty) return;
                      setModalState(() => isImporting = true);
                      final success = await storage.importDataJson(text);
                      if (success) {
                        ref.read(curriculumProvider.notifier).refresh();
                        ref.read(projectsProvider.notifier).refresh();
                        ref.read(notesProvider.notifier).refresh();
                        ref.read(studySessionsProvider.notifier).refresh();
                        ref.read(userProfileProvider.notifier).refresh();
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Data restored successfully!')),
                          );
                        }
                      } else {
                        setModalState(() => isImporting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Invalid backup JSON format.')),
                          );
                        }
                      }
                    },
              child: isImporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Restore Data'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResetDialog(BuildContext context, WidgetRef ref, storage) {
    bool isResetting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.darkCard,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusLg,
            side: BorderSide(color: AppColors.error, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 8),
              Text('Reset All Progress?',
                  style: TextStyle(color: AppColors.textPrimaryDark)),
            ],
          ),
          content: const Text(
            'This will permanently reset all completed lessons, portfolio tasks, study sessions, and streaks. This action cannot be undone.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondaryDark),
          ),
          actions: [
            TextButton(
              onPressed: isResetting ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            CustomButton(
              text: isResetting ? 'Resetting...' : 'Yes, Reset Everything',
              variant: ButtonVariant.danger,
              isLoading: isResetting,
              onPressed: isResetting
                  ? null
                  : () async {
                      setModalState(() => isResetting = true);
                      await storage.resetAllProgress();
                      ref.read(curriculumProvider.notifier).refresh();
                      ref.read(projectsProvider.notifier).refresh();
                      ref.read(notesProvider.notifier).refresh();
                      ref.read(studySessionsProvider.notifier).refresh();
                      ref.read(userProfileProvider.notifier).refresh();
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('All progress has been reset.')),
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
