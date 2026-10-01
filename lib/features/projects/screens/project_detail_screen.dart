import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/app_providers.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/progress_bar.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  late TextEditingController _githubController;
  late TextEditingController _liveController;
  late TextEditingController _notesController;
  bool _isEditingLinks = false;

  @override
  void initState() {
    super.initState();
    _githubController = TextEditingController();
    _liveController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _githubController.dispose();
    _liveController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initFields(Project project) {
    if (!_isEditingLinks) {
      _githubController.text = project.githubUrl;
      _liveController.text = project.liveUrl;
      _notesController.text = project.notes;
    }
  }

  Future<void> _launchUrl(String url) async {
    if (url.trim().isEmpty) return;
    final uri = Uri.parse(url.trim());
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $url')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    Project? foundProject;
    try {
      foundProject = projects.firstWhere((p) => p.id == widget.projectId);
    } catch (_) {
      foundProject = null;
    }

    if (foundProject == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project Not Found')),
        body: const Center(
          child: Text(
            'The requested project could not be found.',
            style: TextStyle(color: AppColors.textSecondaryDark),
          ),
        ),
      );
    }

    final Project project = foundProject;
    _initFields(project);
    final progress = project.progressPercentage;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(project.title),
        actions: [
          IconButton(
            icon: Icon(
              _isEditingLinks ? Icons.check_rounded : Icons.edit_note_rounded,
              color: _isEditingLinks ? AppColors.primary : null,
            ),
            tooltip: _isEditingLinks ? 'Save URLs & Notes' : 'Edit details',
            onPressed: () async {
              if (_isEditingLinks) {
                await ref
                    .read(projectsProvider.notifier)
                    .updateProjectDetails(
                      projectId: project.id,
                      githubUrl: _githubController.text.trim(),
                      liveUrl: _liveController.text.trim(),
                      notes: _notesController.text.trim(),
                    );
                setState(() => _isEditingLinks = false);
              } else {
                setState(() => _isEditingLinks = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space20,
          vertical: AppDimensions.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Card
            Container(
              padding: const EdgeInsets.all(AppDimensions.space18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: AppDimensions.radiusLg,
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PROJECT • MONTH ${project.monthNumber}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${progress.toStringAsFixed(0)}% Complete',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: progress >= 100
                              ? AppColors.primary
                              : AppColors.accentCyan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryDark,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space6),
                  Text(
                    project.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space12),
                  CustomProgressBar(
                    percentage: progress,
                    height: 8,
                    color:
                        progress >= 100 ? AppColors.primary : AppColors.accentCyan,
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Technology Badges
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: project.technologies.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: AppDimensions.radiusSm,
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: Text(
                          t,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space20),

            // Links Card
            if (!_isEditingLinks) ...[
              Row(
                children: [
                  if (project.githubUrl.isNotEmpty) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.code_rounded, size: 18),
                        label: const Text('GitHub'),
                        onPressed: () => _launchUrl(project.githubUrl),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space10),
                  ],
                  if (project.liveUrl.isNotEmpty) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.launch_rounded, size: 18),
                        label: const Text('Live Demo'),
                        onPressed: () => _launchUrl(project.liveUrl),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppDimensions.space20),
            ] else ...[
              // Edit URLs Form
              Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: AppDimensions.radiusMd,
                  border: Border.all(color: AppColors.primaryLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GitHub Repository URL',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _githubController,
                      style: const TextStyle(
                          color: AppColors.textPrimaryDark, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'https://github.com/username/project',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Live Demo URL',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _liveController,
                      style: const TextStyle(
                          color: AppColors.textPrimaryDark, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'https://project-demo.web.app',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Project Architecture Notes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      style: const TextStyle(
                          color: AppColors.textPrimaryDark, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Technical decisions, architecture, gotchas...',
                      ),
                    ),
                    const SizedBox(height: 14),
                    CustomButton(
                      text: 'Save Details',
                      onPressed: () async {
                        await ref
                            .read(projectsProvider.notifier)
                            .updateProjectDetails(
                              projectId: project.id,
                              githubUrl: _githubController.text.trim(),
                              liveUrl: _liveController.text.trim(),
                              notes: _notesController.text.trim(),
                            );
                        setState(() => _isEditingLinks = false);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space20),
            ],

            // Step-by-Step Task Checklist
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Implementation Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryDark,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '${project.completedTasksCount}/${project.tasks.length} Done',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space12),

            ...project.tasks.map((task) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.space8),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space14,
                  vertical: AppDimensions.space10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: AppDimensions.radiusMd,
                  border: Border.all(
                    color: task.completed
                        ? AppColors.primary.withAlpha(60)
                        : AppColors.darkBorder,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        task.completed
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: task.completed
                            ? AppColors.primary
                            : AppColors.textTertiaryDark,
                        size: 22,
                      ),
                      onPressed: () {
                        ref.read(projectsProvider.notifier).toggleTask(
                              project.id,
                              task.id,
                              !task.completed,
                            );
                      },
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: task.completed
                              ? AppColors.textTertiaryDark
                              : AppColors.textPrimaryDark,
                          decoration:
                              task.completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: AppDimensions.space32),
          ],
        ),
      ),
    );
  }
}
