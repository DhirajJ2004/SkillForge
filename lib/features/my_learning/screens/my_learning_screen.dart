import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/roadmap_models.dart';
import '../../../providers/app_providers.dart';
import '../../common/widgets/course_card.dart';

class MyLearningScreen extends ConsumerStatefulWidget {
  const MyLearningScreen({super.key});

  @override
  ConsumerState<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends ConsumerState<MyLearningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curriculum = ref.watch(curriculumProvider);
    final notes = ref.watch(notesProvider);

    final inProgressCourses = curriculum
        .where((m) =>
            m.progressPercentage > 0 && m.progressPercentage < 100.0)
        .toList();
    final completedCourses =
        curriculum.where((m) => m.progressPercentage >= 100.0).toList();

    // Recently opened resources or lessons
    final allLessons = curriculum.expand((m) => m.allLessons).toList();
    final completedLessons = allLessons.where((l) => l.completed).toList();

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
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Learning',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your courses, active study tracks & saved material.',
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space16),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: textSecondary,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'In Progress'),
                      Tab(text: 'Completed'),
                      Tab(text: 'Saved'),
                    ],
                  ),
                  bg,
                  borderColor,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // 1. All Courses Tab
              _buildCourseList(
                curriculum,
                emptyMessage: 'No courses registered yet.',
                emptyAction: () => context.go('/learn'),
                actionText: 'Browse Courses',
                isDark: isDark,
              ),

              // 2. In Progress Tab
              _buildCourseList(
                inProgressCourses.isNotEmpty
                    ? inProgressCourses
                    : (curriculum.isNotEmpty ? [curriculum.first] : []),
                emptyMessage: 'No courses currently in progress.',
                emptyAction: () => context.go('/learn'),
                actionText: 'Start a Course',
                isDark: isDark,
              ),

              // 3. Completed Tab
              _buildCompletedList(
                completedCourses,
                completedLessons,
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),

              // 4. Saved Tab (Notes & Bookmarks)
              _buildSavedList(
                notes,
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseList(
    List<Month> courses, {
    required String emptyMessage,
    required VoidCallback emptyAction,
    required String actionText,
    required bool isDark,
  }) {
    if (courses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined,
                  size: 56, color: AppColors.primary.withAlpha(120)),
              const SizedBox(height: AppDimensions.space16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              ElevatedButton(
                onPressed: emptyAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(actionText),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.space20),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.space16),
          child: CourseCard(month: courses[index]),
        );
      },
    );
  }

  Widget _buildCompletedList(
    List<Month> completedCourses,
    List<Lesson> completedLessons, {
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    if (completedCourses.isEmpty && completedLessons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_outlined,
                  size: 56, color: AppColors.primary.withAlpha(120)),
              const SizedBox(height: AppDimensions.space16),
              Text(
                'Complete your first course to earn your SkillForge certificate!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              ElevatedButton(
                onPressed: () => context.go('/learn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue Learning'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.space20),
      children: [
        if (completedCourses.isNotEmpty) ...[
          Text(
            'Completed Courses & Certificates',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.space12),
          ...completedCourses.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CourseCard(month: m),
              )),
          const SizedBox(height: AppDimensions.space20),
        ],
        Text(
          'Completed Lessons (${completedLessons.length})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.space12),
        ...completedLessons.take(15).map((lesson) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: AppDimensions.radiusSm,
                border: Border.all(color: borderColor),
              ),
              child: ListTile(
                dense: true,
                leading: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                title: Text(
                  lesson.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                subtitle: Text(
                  '~45 min • Completed',
                  style: TextStyle(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                onTap: () => context.push('/lesson/${lesson.id}'),
              ),
            )),
      ],
    );
  }

  Widget _buildSavedList(
    dynamic notes, {
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final noteList = notes as List;
    if (noteList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_border_rounded,
                  size: 56, color: AppColors.primary.withAlpha(120)),
              const SizedBox(height: AppDimensions.space16),
              Text(
                'No saved notes or bookmarks yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add study notes and code snippets while reviewing lessons to access them here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              ElevatedButton(
                onPressed: () => context.push('/note-editor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create a Note'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.space20),
      itemCount: noteList.length,
      itemBuilder: (context, index) {
        final note = noteList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.space12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppDimensions.radiusMd,
            border: Border.all(color: borderColor),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space8,
            ),
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.accentAmber.withAlpha(25),
                borderRadius: AppDimensions.radiusSm,
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                color: AppColors.accentAmber,
                size: 20,
              ),
            ),
            title: Text(
              note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  note.lessonTitle.isNotEmpty
                      ? note.lessonTitle
                      : 'General Study Note',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded, size: 20),
            onTap: () => context.push('/note-editor?id=${note.id}'),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _bgColor;
  final Color _borderColor;

  _SliverAppBarDelegate(this._tabBar, this._bgColor, this._borderColor);

  @override
  double get minExtent => _tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 1;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border(
          bottom: BorderSide(color: _borderColor, width: 1),
        ),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
