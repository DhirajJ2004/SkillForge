import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/roadmap_models.dart';
import '../../../providers/app_providers.dart';
import '../../common/widgets/course_card.dart';
import '../../common/widgets/learning_path_card.dart';
import '../../common/widgets/section_header.dart';

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Programming',
    'Web Development',
    'Backend',
    'AI & ML',
    'Cloud',
    'DevOps',
    'Interview',
  ];

  List<CareerPathItem> _getCareerPaths(List<Month> curriculum) {
    double m1Progress = curriculum.isNotEmpty ? curriculum[0].progressPercentage : 0.0;
    double m2Progress = curriculum.length > 1 ? curriculum[1].progressPercentage : 0.0;
    double m3Progress = curriculum.length > 2 ? curriculum[2].progressPercentage : 0.0;
    double m4Progress = curriculum.length > 3 ? curriculum[3].progressPercentage : 0.0;
    double m5Progress = curriculum.length > 4 ? curriculum[4].progressPercentage : 0.0;
    double m6Progress = curriculum.length > 5 ? curriculum[5].progressPercentage : 0.0;

    return [
      CareerPathItem(
        title: 'Python Developer',
        description: 'Master Python fundamentals, OOP, SQL databases & production scripts.',
        roadmapSequence: 'Python → SQL → APIs → Projects',
        duration: '4-6 Weeks',
        skillCount: 8,
        difficulty: 'Beginner',
        progress: m1Progress,
        accentColor: AppColors.primary,
        icon: Icons.code_rounded,
        targetMonthId: curriculum.isNotEmpty ? curriculum[0].id : '',
      ),
      CareerPathItem(
        title: 'Full Stack Developer',
        description: 'Build responsive web apps and modern APIs with React and FastAPI.',
        roadmapSequence: 'HTML → CSS → JS → React → FastAPI',
        duration: '8-10 Weeks',
        skillCount: 14,
        difficulty: 'Intermediate',
        progress: (m2Progress + m3Progress) / 2,
        accentColor: AppColors.accentCyan,
        icon: Icons.layers_rounded,
        targetMonthId: curriculum.length > 1 ? curriculum[1].id : '',
      ),
      CareerPathItem(
        title: 'AI Engineer',
        description: 'Create production RAG pipelines, LLM agent workflows & vector search.',
        roadmapSequence: 'Python → LLMs → RAG → Agents',
        duration: '6-8 Weeks',
        skillCount: 10,
        difficulty: 'Advanced',
        progress: m4Progress,
        accentColor: AppColors.secondary,
        icon: Icons.psychology_rounded,
        targetMonthId: curriculum.length > 3 ? curriculum[3].id : '',
      ),
      CareerPathItem(
        title: 'Cloud & DevOps Engineer',
        description: 'Automate deployments with Linux, Docker, CI/CD and AWS Cloud.',
        roadmapSequence: 'Linux → Docker → AWS → Deployment',
        duration: '6 Weeks',
        skillCount: 9,
        difficulty: 'Intermediate',
        progress: m5Progress,
        accentColor: AppColors.accentEmerald,
        icon: Icons.cloud_done_rounded,
        targetMonthId: curriculum.length > 4 ? curriculum[4].id : '',
      ),
      CareerPathItem(
        title: 'Job-Ready Software Engineer',
        description: 'Ace technical interviews with DSA patterns and system design fundamentals.',
        roadmapSequence: 'DSA → Projects → Resume → Interviews',
        duration: '8 Weeks',
        skillCount: 12,
        difficulty: 'Advanced',
        progress: m6Progress,
        accentColor: AppColors.accentOrange,
        icon: Icons.work_outline_rounded,
        targetMonthId: curriculum.length > 5 ? curriculum[5].id : '',
      ),
    ];
  }

  List<Month> _filterCurriculum(List<Month> curriculum) {
    if (_selectedCategory == 'All') return curriculum;
    if (_selectedCategory == 'Programming') {
      return curriculum.where((m) => m.monthNumber == 1).toList();
    }
    if (_selectedCategory == 'Web Development') {
      return curriculum.where((m) => m.monthNumber == 2).toList();
    }
    if (_selectedCategory == 'Backend') {
      return curriculum.where((m) => m.monthNumber == 3).toList();
    }
    if (_selectedCategory == 'AI & ML') {
      return curriculum.where((m) => m.monthNumber == 4).toList();
    }
    if (_selectedCategory == 'Cloud' || _selectedCategory == 'DevOps') {
      return curriculum.where((m) => m.monthNumber == 5).toList();
    }
    if (_selectedCategory == 'Interview') {
      return curriculum.where((m) => m.monthNumber == 6).toList();
    }
    return curriculum;
  }

  @override
  Widget build(BuildContext context) {
    final curriculum = ref.watch(curriculumProvider);
    final careerPaths = _getCareerPaths(curriculum);
    final filteredCourses = _filterCurriculum(curriculum);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final searchBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final searchBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
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
              // Screen Header
              Text(
                'Learn',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Build the skills you need to become job-ready.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Search Bar
              InkWell(
                onTap: () => context.push('/search'),
                borderRadius: AppDimensions.radiusMd,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: searchBg,
                    borderRadius: AppDimensions.radiusMd,
                    border: Border.all(color: searchBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Search courses, skills, technologies...',
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        backgroundColor: searchBg,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : textPrimary,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : searchBorder,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimensions.radiusPill,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              // Career Learning Paths
              SectionHeader(
                title: 'Career Learning Paths',
                subtitle: 'Structured career tracks to guide your study',
              ),
              const SizedBox(height: AppDimensions.space8),
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: careerPaths.length,
                  itemBuilder: (context, index) {
                    final path = careerPaths[index];
                    return LearningPathCard(
                      path: path,
                      onSelect: () {
                        if (path.targetMonthId.isNotEmpty) {
                          context.push('/course/${path.targetMonthId}');
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              // 6-Month Complete Curriculum
              SectionHeader(
                title: 'Core Curriculum',
                subtitle: _selectedCategory == 'All'
                    ? '6 comprehensive months from zero to job readiness'
                    : 'Courses matching "$_selectedCategory"',
              ),
              const SizedBox(height: AppDimensions.space8),

              if (filteredCourses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space32),
                  alignment: Alignment.center,
                  child: Text(
                    'No courses found for $_selectedCategory',
                    style: TextStyle(color: textSecondary),
                  ),
                )
              else
                ...filteredCourses.map((month) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppDimensions.space16),
                    child: CourseCard(month: month),
                  );
                }),

              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ),
    );
  }
}
