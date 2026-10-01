import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/roadmap_models.dart';
import '../../../providers/app_providers.dart';
import '../../common/widgets/custom_button.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonDetailScreen({
    super.key,
    required this.lessonId,
  });

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _noteContentController = TextEditingController();
  bool _isCreatingNote = false;
  bool _isSavingNote = false;

  @override
  void dispose() {
    _noteTitleController.dispose();
    _noteContentController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(Resource resource) async {
    final uri = Uri.parse(resource.url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        await ref
            .read(curriculumProvider.notifier)
            .markResourceOpened(widget.lessonId, resource.id);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open ${resource.url}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching link: $e')),
        );
      }
    }
  }

  // Find lesson and parent context
  _LessonContext? _findLessonContext(List<Month> curriculum) {
    for (final month in curriculum) {
      for (final topic in month.topics) {
        for (int i = 0; i < topic.lessons.length; i++) {
          final lesson = topic.lessons[i];
          if (lesson.id == widget.lessonId) {
            // Find overall lesson index in month
            final allMonthLessons = month.allLessons;
            final monthIndex = allMonthLessons.indexWhere((l) => l.id == lesson.id);

            Lesson? prev;
            Lesson? next;
            if (monthIndex > 0) {
              prev = allMonthLessons[monthIndex - 1];
            }
            if (monthIndex < allMonthLessons.length - 1) {
              next = allMonthLessons[monthIndex + 1];
            }

            return _LessonContext(
              month: month,
              topic: topic,
              lesson: lesson,
              lessonIndexInMonth: monthIndex + 1,
              totalLessonsInMonth: allMonthLessons.length,
              prevLesson: prev,
              nextLesson: next,
            );
          }
        }
      }
    }
    return null;
  }

  void _showCourseOutline(BuildContext context, Month month, Lesson currentLesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CourseOutlineSheet(
        month: month,
        currentLessonId: currentLesson.id,
        onSelectLesson: (id) {
          Navigator.pop(context);
          context.pushReplacement('/lesson/$id');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final curriculum = ref.watch(curriculumProvider);
    final lContext = _findLessonContext(curriculum);
    final allNotes = ref.watch(notesProvider);
    final lessonNotes =
        allNotes.where((n) => n.lessonId == widget.lessonId).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    if (lContext == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(title: const Text('Lesson Not Found')),
        body: const Center(child: Text('Lesson could not be found.')),
      );
    }

    final lesson = lContext.lesson;
    final month = lContext.month;
    final topic = lContext.topic;
    final prev = lContext.prevLesson;
    final next = lContext.nextLesson;

    final progressRatio = (lContext.lessonIndexInMonth / lContext.totalLessonsInMonth);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${month.title} • ${topic.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            Text(
              'Lesson ${lContext.lessonIndexInMonth} of ${lContext.totalLessonsInMonth}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: progressRatio,
            minHeight: 3,
            backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              lesson.isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: lesson.isBookmarked ? AppColors.accentAmber : null,
            ),
            tooltip: lesson.isBookmarked ? 'Remove bookmark' : 'Bookmark lesson',
            onPressed: () {
              ref
                  .read(curriculumProvider.notifier)
                  .toggleBookmark(lesson.id, !lesson.isBookmarked);
            },
          ),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted_rounded),
            tooltip: 'Course Outline',
            onPressed: () => _showCourseOutline(context, month, lesson),
          ),
          IconButton(
            icon: Icon(
              lesson.completed
                  ? Icons.check_circle_rounded
                  : Icons.check_circle_outline_rounded,
              color: lesson.completed ? AppColors.success : null,
            ),
            tooltip: lesson.completed ? 'Mark incomplete' : 'Mark as completed',
            onPressed: () {
              ref
                  .read(curriculumProvider.notifier)
                  .toggleLesson(lesson.id, !lesson.completed);
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
            // Hero Lesson Header Card
            Container(
              padding: const EdgeInsets.all(AppDimensions.space20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: AppDimensions.radiusLg,
                border: Border.all(
                  color: lesson.completed
                      ? AppColors.success.withAlpha(80)
                      : borderColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: lesson.completed
                              ? AppColors.success.withAlpha(20)
                              : AppColors.primary.withAlpha(20),
                          borderRadius: AppDimensions.radiusSm,
                        ),
                        child: Text(
                          lesson.completed ? 'COMPLETED ✓' : 'IN PROGRESS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: lesson.completed
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 14, color: textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${lesson.estimatedMinutes} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space12),
                  Text(
                    lesson.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  Text(
                    lesson.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Study Focus Timer CTA
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.timer_outlined, size: 18),
                      label: const Text('Start Focus Timer For This Lesson'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimensions.radiusSm,
                        ),
                      ),
                      onPressed: () {
                        context.push(
                          '/study-session?lessonId=${lesson.id}&title=${Uri.encodeComponent(lesson.title)}&duration=${lesson.estimatedMinutes}',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // Video / Material Resources Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lesson Resources & Media',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  '${lesson.resources.length} available',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space12),

            if (lesson.resources.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppDimensions.radiusMd,
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  'No external resources linked for this lesson yet.',
                  style: TextStyle(color: textSecondary),
                ),
              )
            else
              ...lesson.resources.map((resource) {
                final isVideo = resource.type == ResourceType.youtube;
                return Container(
                  margin: const EdgeInsets.only(bottom: AppDimensions.space10),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: AppDimensions.radiusMd,
                    border: Border.all(color: borderColor),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space16,
                      vertical: AppDimensions.space6,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getResourceColor(resource.type).withAlpha(25),
                        borderRadius: AppDimensions.radiusSm,
                      ),
                      child: Icon(
                        _getResourceIcon(resource.type),
                        color: _getResourceColor(resource.type),
                        size: 22,
                      ),
                    ),
                    title: Text(
                      resource.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          resource.type.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getResourceColor(resource.type),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${resource.duration}',
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                        if (resource.opened) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle_rounded,
                              size: 12, color: AppColors.success),
                        ],
                      ],
                    ),
                    trailing: Icon(
                      isVideo
                          ? Icons.play_arrow_rounded
                          : Icons.open_in_new_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    onTap: () => _launchUrl(resource),
                  ),
                );
              }),
            const SizedBox(height: AppDimensions.space24),

            // Study Notes Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Lesson Notes (${lessonNotes.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                TextButton.icon(
                  icon: Icon(
                    _isCreatingNote
                        ? Icons.close_rounded
                        : Icons.add_rounded,
                    size: 18,
                  ),
                  label: Text(_isCreatingNote ? 'Cancel' : 'Add Note'),
                  onPressed: () {
                    setState(() {
                      _isCreatingNote = !_isCreatingNote;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space8),

            // Note Creation Box
            if (_isCreatingNote) ...[
              Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppDimensions.radiusMd,
                  border: Border.all(color: AppColors.primary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _noteTitleController,
                      style: TextStyle(color: textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Note Title / Concept',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const Divider(height: 16),
                    TextField(
                      controller: _noteContentController,
                      maxLines: 4,
                      style: TextStyle(color: textPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Save key insights, syntax examples or rules...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          text: 'Save Note',
                          icon: Icons.save_rounded,
                          isLoading: _isSavingNote,
                          onPressed: _isSavingNote
                              ? null
                              : () async {
                                  final title = _noteTitleController.text.trim();
                                  final content = _noteContentController.text.trim();
                                  if (title.isEmpty) return;

                                  setState(() => _isSavingNote = true);
                                  await ref.read(notesProvider.notifier).saveNote(
                                        lessonId: lesson.id,
                                        lessonTitle: lesson.title,
                                        title: title,
                                        content: content,
                                      );

                                  _noteTitleController.clear();
                                  _noteContentController.clear();
                                  if (mounted) {
                                    setState(() {
                                      _isSavingNote = false;
                                      _isCreatingNote = false;
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
            ],

            if (lessonNotes.isEmpty && !_isCreatingNote)
              Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppDimensions.radiusMd,
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  'No notes recorded for this lesson yet. Tap "Add Note" to write personal takeaways.',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
              )
            else
              ...lessonNotes.map((note) {
                return Container(
                  margin: const EdgeInsets.only(bottom: AppDimensions.space10),
                  padding: const EdgeInsets.all(AppDimensions.space14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: AppDimensions.radiusMd,
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              note.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 18, color: AppColors.error),
                            onPressed: () {
                              ref
                                  .read(notesProvider.notifier)
                                  .deleteNote(note.id);
                            },
                            tooltip: 'Delete note',
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        note.content,
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 80), // Space for fixed bottom bar
          ],
        ),
      ),

      // Fixed Bottom Navigation Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(top: BorderSide(color: borderColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 40 : 10),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Prev Button
              IconButton(
                onPressed: prev != null
                    ? () => context.pushReplacement('/lesson/${prev.id}')
                    : null,
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                tooltip: prev?.title ?? 'No previous lesson',
              ),
              const SizedBox(width: 8),

              // Mark Complete / Toggle Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(curriculumProvider.notifier)
                        .toggleLesson(lesson.id, !lesson.completed);

                    // If completed, offer jumping to next lesson
                    if (!lesson.completed && next != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Completed! Next: ${next.title}'),
                          action: SnackBarAction(
                            label: 'Next Lesson',
                            onPressed: () {
                              if (context.mounted) {
                                context.pushReplacement('/lesson/${next.id}');
                              }
                            },
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    lesson.completed
                        ? Icons.check_circle_rounded
                        : Icons.check_rounded,
                    size: 18,
                  ),
                  label: Text(
                    lesson.completed ? 'Completed' : 'Mark Complete',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lesson.completed
                        ? AppColors.success
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.radiusSm,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Next Button
              IconButton(
                onPressed: next != null
                    ? () => context.pushReplacement('/lesson/${next.id}')
                    : null,
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                tooltip: next?.title ?? 'End of course',
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getResourceIcon(ResourceType type) {
    switch (type) {
      case ResourceType.youtube:
        return Icons.play_circle_fill_rounded;
      case ResourceType.documentation:
        return Icons.menu_book_rounded;
      case ResourceType.article:
        return Icons.article_rounded;
      case ResourceType.practice:
        return Icons.terminal_rounded;
      case ResourceType.project:
        return Icons.code_rounded;
    }
  }

  Color _getResourceColor(ResourceType type) {
    switch (type) {
      case ResourceType.youtube:
        return const Color(0xFFFF0000);
      case ResourceType.documentation:
        return AppColors.accentCyan;
      case ResourceType.article:
        return AppColors.accentAmber;
      case ResourceType.practice:
        return AppColors.primary;
      case ResourceType.project:
        return AppColors.secondary;
    }
  }
}

class _LessonContext {
  final Month month;
  final Topic topic;
  final Lesson lesson;
  final int lessonIndexInMonth;
  final int totalLessonsInMonth;
  final Lesson? prevLesson;
  final Lesson? nextLesson;

  _LessonContext({
    required this.month,
    required this.topic,
    required this.lesson,
    required this.lessonIndexInMonth,
    required this.totalLessonsInMonth,
    this.prevLesson,
    this.nextLesson,
  });
}

class _CourseOutlineSheet extends StatelessWidget {
  final Month month;
  final String currentLessonId;
  final Function(String) onSelectLesson;

  const _CourseOutlineSheet({
    required this.month,
    required this.currentLessonId,
    required this.onSelectLesson,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCard : Colors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            month.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          Text(
            'Course Outline (${month.totalLessonsCount} lessons)',
            style: TextStyle(fontSize: 12, color: textSecondary),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: month.topics.length,
              itemBuilder: (context, tIndex) {
                final topic = month.topics[tIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Section ${tIndex + 1}: ${topic.title}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    ...topic.lessons.map((lesson) {
                      final isCurrent = lesson.id == currentLessonId;
                      return ListTile(
                        dense: true,
                        selected: isCurrent,
                        selectedTileColor: AppColors.primary.withAlpha(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        leading: Icon(
                          lesson.completed
                              ? Icons.check_circle_rounded
                              : isCurrent
                                  ? Icons.play_circle_fill_rounded
                                  : Icons.circle_outlined,
                          size: 18,
                          color: lesson.completed
                              ? AppColors.success
                              : isCurrent
                                  ? AppColors.primary
                                  : textSecondary,
                        ),
                        title: Text(
                          lesson.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrent
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: textPrimary,
                          ),
                        ),
                        trailing: Text(
                          '${lesson.estimatedMinutes}m',
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                        onTap: () => onSelectLesson(lesson.id),
                      );
                    }),
                    const Divider(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
